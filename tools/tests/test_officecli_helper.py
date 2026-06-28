"""Tests for tools/officecli_helper.py — subprocess.run boundary mocked."""

from __future__ import annotations

import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest


# ── Fixtures ──────────────────────────────────────────────────────


@pytest.fixture
def fake_docx(tmp_path: Path) -> Path:
    p = tmp_path / "test.docx"
    p.write_text("fake docx content")
    return p


@pytest.fixture
def fake_output(tmp_path: Path) -> Path:
    return tmp_path / "screenshot.png"


@pytest.fixture
def mock_run():
    """Patch subprocess.run in officecli_helper module."""
    with patch("tools.officecli_helper.subprocess.run") as mock:
        yield mock


# ── validate_docx ─────────────────────────────────────────────────


class TestValidateDocx:
    def test_success_returns_true(self, mock_run, fake_docx):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import validate_docx

        assert validate_docx(fake_docx) is True
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        assert "officecli" in args[0]
        assert "validate" in args

    def test_invalid_returns_false(self, mock_run, fake_docx):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=1, stdout="", stderr="issues found"
        )

        from tools.officecli_helper import validate_docx

        assert validate_docx(fake_docx) is False

    def test_missing_input_raises_file_not_found(self, mock_run):
        missing = Path("/nonexistent/doc.docx")

        from tools.officecli_helper import validate_docx

        with pytest.raises(FileNotFoundError, match="doc.docx"):
            validate_docx(missing)

    def test_officecli_not_in_path_raises_file_not_found(self, fake_docx):
        from tools.officecli_helper import validate_docx

        with patch(
            "tools.officecli_helper.subprocess.run",
            side_effect=FileNotFoundError("officecli not found"),
        ):
            with pytest.raises(FileNotFoundError, match="officecli not found"):
                validate_docx(fake_docx)


# ── screenshot_docx ───────────────────────────────────────────────


class TestScreenshotDocx:
    def test_success(self, mock_run, fake_docx, fake_output):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import screenshot_docx

        screenshot_docx(fake_docx, fake_output)
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        assert "screenshot" in args
        assert "-o" in args

    def test_failure_raises_runtime_error(self, mock_run, fake_docx, fake_output):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=1, stdout="", stderr="error rendering"
        )

        from tools.officecli_helper import screenshot_docx

        with pytest.raises(RuntimeError, match="exit code 1.*error rendering"):
            screenshot_docx(fake_docx, fake_output)

    def test_missing_input_raises_file_not_found(self, mock_run, fake_output):
        missing = Path("/nonexistent/doc.docx")

        from tools.officecli_helper import screenshot_docx

        with pytest.raises(FileNotFoundError, match="doc.docx"):
            screenshot_docx(missing, fake_output)


# ── apply_pandoc_fixes ────────────────────────────────────────────


class TestApplyPandocFixes:
    def test_default_runs_script(self, mock_run, fake_docx):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import apply_pandoc_fixes

        apply_pandoc_fixes(fake_docx)
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        assert "fix-pandoc-leaks.sh" in str(args[0])
        assert "--curly-quotes" in args
        assert "--code-spacing" in args
        assert "--first-line-indent" in args

    def test_with_specific_fixes(self, mock_run, fake_docx):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import apply_pandoc_fixes

        apply_pandoc_fixes(fake_docx, fixes=["curly-quotes"])
        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        assert "--curly-quotes" in args
        assert "--code-spacing" not in args

    def test_missing_input_raises_file_not_found(self, mock_run):
        missing = Path("/nonexistent/doc.docx")

        from tools.officecli_helper import apply_pandoc_fixes

        with pytest.raises(FileNotFoundError, match="doc.docx"):
            apply_pandoc_fixes(missing)

    def test_script_failure_raises_runtime_error(self, mock_run, fake_docx):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=2, stdout="", stderr="file not found"
        )

        from tools.officecli_helper import apply_pandoc_fixes

        with pytest.raises(RuntimeError, match="exit code 2.*file not found"):
            apply_pandoc_fixes(fake_docx)

    def test_officecli_timeout_raises_runtime_error(self, fake_docx):
        from tools.officecli_helper import validate_docx

        with patch(
            "tools.officecli_helper.subprocess.run",
            side_effect=subprocess.TimeoutExpired(cmd="officecli", timeout=30),
        ):
            with pytest.raises(RuntimeError, match="timeout"):
                validate_docx(fake_docx)

    def test_fix_timeout_raises_runtime_error(self, fake_docx):
        from tools.officecli_helper import apply_pandoc_fixes

        with patch(
            "tools.officecli_helper.subprocess.run",
            side_effect=subprocess.TimeoutExpired(cmd="fix-pandoc-leaks.sh", timeout=30),
        ):
            with pytest.raises(RuntimeError, match="timeout"):
                apply_pandoc_fixes(fake_docx)


# ── CLI tests ─────────────────────────────────────────────────────


class TestCli:
    def test_no_args_exits_nonzero(self):
        from tools.officecli_helper import _build_parser

        with pytest.raises(SystemExit):
            _build_parser().parse_args([])

    def test_unknown_subcommand_exits_nonzero(self):
        from tools.officecli_helper import _build_parser

        with pytest.raises(SystemExit):
            _build_parser().parse_args(["bogus"])

    def test_validate_command_works(self, mock_run, fake_docx, capsys):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import main

        with pytest.raises(SystemExit) as exc:
            main(["validate", str(fake_docx)])
        assert exc.value.code == 0
        captured = capsys.readouterr()
        assert "valid" in captured.out.lower()

    def test_screenshot_command_works(self, mock_run, fake_docx, fake_output, capsys):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import main

        main(["screenshot", str(fake_docx), str(fake_output)])
        captured = capsys.readouterr()
        assert "screenshot" in captured.out.lower()

    def test_fix_command_works(self, mock_run, fake_docx, capsys):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import main

        main(["fix", str(fake_docx)])
        captured = capsys.readouterr()
        assert "fix" in captured.out.lower()

    def test_fix_command_with_custom_fixes(self, mock_run, fake_docx, capsys):
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.officecli_helper import main

        main(["fix", str(fake_docx), "--fix", "curly-quotes"])
        captured = capsys.readouterr()
        assert "fix" in captured.out.lower()
