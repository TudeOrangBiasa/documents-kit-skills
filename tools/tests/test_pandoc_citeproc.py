"""Tests for tools/pandoc_citeproc.py — subprocess.run boundary mocked."""

from __future__ import annotations

import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest


# ── Fixtures ──────────────────────────────────────────────────────


@pytest.fixture
def fake_md(tmp_path: Path) -> Path:
    p = tmp_path / "input.md"
    p.write_text("# Test\nHello")
    return p


@pytest.fixture
def fake_bib(tmp_path: Path) -> Path:
    p = tmp_path / "refs.bib"
    p.write_text("@article{test,\n  title={Test}\n}")
    return p


@pytest.fixture
def fake_output(tmp_path: Path) -> Path:
    return tmp_path / "output.docx"


@pytest.fixture
def mock_run():
    """Patch subprocess.run in pandoc_citeproc module."""
    with patch("tools.pandoc_citeproc.subprocess.run") as mock:
        yield mock


@pytest.fixture
def mock_validate_true():
    """Patch officecli_helper.validate_docx to return True."""
    with patch("tools.officecli_helper.validate_docx", return_value=True) as mock:
        yield mock


@pytest.fixture
def mock_validate_false():
    """Patch officecli_helper.validate_docx to return False."""
    with patch("tools.officecli_helper.validate_docx", return_value=False) as mock:
        yield mock


# ── build_docx ────────────────────────────────────────────────────


class TestBuildDocx:
    def test_happy_path(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output
    ):
        """All 3 steps succeed, validate returns True."""
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import build_docx

        build_docx(fake_md, fake_bib, fake_output)
        assert mock_run.call_count == 2  # pandoc + fix-pandoc-leaks

    def test_pandoc_missing_raises(self, fake_md, fake_bib, fake_output):
        """FileNotFoundError when pandoc not in PATH."""
        from tools.pandoc_citeproc import build_docx

        with patch(
            "tools.pandoc_citeproc.subprocess.run",
            side_effect=FileNotFoundError("pandoc: not found"),
        ):
            with pytest.raises(FileNotFoundError, match="pandoc"):
                build_docx(fake_md, fake_bib, fake_output)

    def test_pandoc_failure_raises_runtimeerror(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output
    ):
        """RuntimeError when pandoc exit non-zero."""
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=1, stdout="", stderr="pandoc: error"
        )

        from tools.pandoc_citeproc import build_docx

        with pytest.raises(RuntimeError, match="pandoc.*exit code 1"):
            build_docx(fake_md, fake_bib, fake_output)

    def test_fixes_failure_raises_runtimeerror(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output
    ):
        """RuntimeError when fix-pandoc-leaks exit non-zero."""
        mock_run.side_effect = [
            subprocess.CompletedProcess(
                args=[], returncode=0, stdout="", stderr=""
            ),  # pandoc succeeds
            subprocess.CompletedProcess(
                args=[], returncode=2, stdout="", stderr="fix error"
            ),  # fix fails
        ]

        from tools.pandoc_citeproc import build_docx

        with pytest.raises(RuntimeError, match="fix.*exit code 2"):
            build_docx(fake_md, fake_bib, fake_output)

    def test_validate_warning_does_not_raise(
        self, mock_run, mock_validate_false, fake_md, fake_bib, fake_output
    ):
        """Validate returns False, function completes without raising."""
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import build_docx

        build_docx(fake_md, fake_bib, fake_output)  # no exception

    def test_pandoc_timeout_raises_runtimeerror(
        self, fake_md, fake_bib, fake_output
    ):
        """TimeoutExpired from pandoc step wrapped in RuntimeError."""
        from tools.pandoc_citeproc import build_docx

        with patch(
            "tools.pandoc_citeproc.subprocess.run",
            side_effect=subprocess.TimeoutExpired(cmd="pandoc", timeout=30),
        ):
            with pytest.raises(RuntimeError, match="timeout.*30"):
                build_docx(fake_md, fake_bib, fake_output)

    def test_fixes_timeout_raises_runtimeerror(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output
    ):
        """TimeoutExpired from fix-pandoc-leaks step wrapped in RuntimeError."""
        mock_run.side_effect = [
            subprocess.CompletedProcess(
                args=[], returncode=0, stdout="", stderr=""
            ),  # pandoc succeeds
            subprocess.TimeoutExpired(
                cmd="fix-pandoc-leaks.sh", timeout=30
            ),  # fix times out
        ]

        from tools.pandoc_citeproc import build_docx

        with pytest.raises(RuntimeError, match="timeout.*30"):
            build_docx(fake_md, fake_bib, fake_output)

    def test_md_path_missing_raises(
        self, mock_run, mock_validate_true, fake_bib, fake_output
    ):
        """FileNotFoundError when md_path doesn't exist."""
        from tools.pandoc_citeproc import build_docx

        missing = Path("/nonexistent/input.md")
        with pytest.raises(FileNotFoundError, match="input.md"):
            build_docx(missing, fake_bib, fake_output)

    def test_bib_path_missing_raises(
        self, mock_run, mock_validate_true, fake_md, fake_output
    ):
        """FileNotFoundError when bib_path doesn't exist."""
        from tools.pandoc_citeproc import build_docx

        missing = Path("/nonexistent/refs.bib")
        with pytest.raises(FileNotFoundError, match="refs.bib"):
            build_docx(fake_md, missing, fake_output)

    def test_with_reference_doc(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output, tmp_path
    ):
        """--reference-doc flag passed to pandoc when reference_doc provided."""
        ref = tmp_path / "template.docx"
        ref.write_text("template")

        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import build_docx

        build_docx(fake_md, fake_bib, fake_output, reference_doc=ref)
        pandoc_call = mock_run.call_args_list[0]
        pandoc_args = pandoc_call[0][0]
        assert "--reference-doc" in str(pandoc_args)
        assert str(ref) in str(pandoc_args)

    def test_without_reference_doc(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output
    ):
        """--reference-doc flag omitted when reference_doc not provided."""
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import build_docx

        build_docx(fake_md, fake_bib, fake_output)
        pandoc_call = mock_run.call_args_list[0]
        pandoc_args = pandoc_call[0][0]
        assert "--reference-doc" not in str(pandoc_args)


# ── CLI tests ─────────────────────────────────────────────────────


class TestCli:
    def test_no_args_exits_nonzero(self):
        from tools.pandoc_citeproc import _build_parser

        with pytest.raises(SystemExit):
            _build_parser().parse_args([])

    def test_build_command_works(
        self, mock_run, mock_validate_true, fake_md, fake_bib, fake_output, capsys
    ):
        """CLI build command succeeds."""
        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import main

        main(["build", str(fake_md), str(fake_bib), "-o", str(fake_output)])
        captured = capsys.readouterr()
        assert "docx" in captured.out.lower()

    def test_build_with_reference(
        self,
        mock_run,
        mock_validate_true,
        fake_md,
        fake_bib,
        fake_output,
        tmp_path,
        capsys,
    ):
        """CLI build --reference passes --reference-doc to pandoc."""
        ref = tmp_path / "ref.docx"
        ref.write_text("template")

        mock_run.return_value = subprocess.CompletedProcess(
            args=[], returncode=0, stdout="", stderr=""
        )

        from tools.pandoc_citeproc import main

        main(
            [
                "build",
                str(fake_md),
                str(fake_bib),
                "-o",
                str(fake_output),
                "--reference",
                str(ref),
            ]
        )
        pandoc_call = mock_run.call_args_list[0]
        pandoc_args = pandoc_call[0][0]
        assert "--reference-doc" in str(pandoc_args)
        assert str(ref) in str(pandoc_args)
        captured = capsys.readouterr()
        assert "docx" in captured.out.lower()
