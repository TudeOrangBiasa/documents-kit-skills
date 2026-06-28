"""Tests for tools/scholar_bibtex.py — MCP SDK boundary mocked."""

from __future__ import annotations

import json
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from mcp.types import TextContent


# ── fixtures ──────────────────────────────────────────────────────

@pytest.fixture
def mock_stdio():
    """Patch stdio_client and return mocked (read, write, session)."""
    read = MagicMock()
    write = MagicMock()
    session = AsyncMock()

    # client_session is already patched in each test via return_value
    # stdio_client returns (read, write) via async context manager
    stdio_cm = AsyncMock()
    stdio_cm.__aenter__.return_value = (read, write)

    with (
        patch("tools.scholar_bibtex.stdio_client", return_value=stdio_cm),
        patch("tools.scholar_bibtex.ClientSession") as mock_cls,
        patch("tools.scholar_bibtex.PEER_DIR") as mock_peer_dir,
    ):
        mock_peer_dir.exists.return_value = True
        mock_cls.return_value.__aenter__.return_value = session
        yield read, write, session


@pytest.fixture
def temp_bib(tmp_path: Path) -> Path:
    return tmp_path / "out.bib"


# ── helpers ────────────────────────────────────────────────────────

def _make_text_content(data: dict) -> TextContent:
    return TextContent(type="text", text=json.dumps({"data": data, "meta": {}}))


def _make_result(content: list[TextContent], is_error: bool = False) -> MagicMock:
    result = MagicMock()
    result.content = content
    result.isError = is_error
    return result


# ── CLI tests ──────────────────────────────────────────────────────

class TestCli:
    def test_no_args_exits_nonzero(self):
        from tools.scholar_bibtex import _build_parser

        with pytest.raises(SystemExit):
            _build_parser().parse_args([])

    def test_unknown_subcommand_exits_nonzero(self):
        from tools.scholar_bibtex import _build_parser

        with pytest.raises(SystemExit):
            _build_parser().parse_args(["bogus"])


# ── export_bibtex tests ────────────────────────────────────────────
class TestExportBibtex:

    @pytest.mark.asyncio
    async def test_empty_session(self, mock_stdio, temp_bib):
        _, _, session = mock_stdio
        session.call_tool.return_value = _make_result([_make_text_content([])])

        from tools.scholar_bibtex import export_bibtex

        count = await export_bibtex("test-session", temp_bib)
        assert count == 0
        assert temp_bib.read_text() == ""

    @pytest.mark.asyncio
    async def test_single_paper(self, mock_stdio, temp_bib):
        _, _, session = mock_stdio
        papers = [
            {
                "paperId": "abc123",
                "title": "Test Paper",
                "year": 2024,
                "bibtex": "@article{test2024,\n  title={Test Paper},\n  year={2024}\n}",
            }
        ]
        session.call_tool.return_value = _make_result([_make_text_content(papers)])

        from tools.scholar_bibtex import export_bibtex

        count = await export_bibtex("test-session", temp_bib)
        assert count == 1
        content = temp_bib.read_text()
        assert "@article{test2024" in content
        assert "Test Paper" in content

    @pytest.mark.asyncio
    async def test_multiple_papers(self, mock_stdio, temp_bib):
        _, _, session = mock_stdio
        papers = [
            {
                "paperId": "p1",
                "title": "Paper One",
                "year": 2023,
                "bibtex": "@article{p1,\n  title={Paper One}\n}",
            },
            {
                "paperId": "p2",
                "title": "Paper Two",
                "year": 2024,
                "bibtex": "@inproceedings{p2,\n  title={Paper Two}\n}",
            },
            {
                "paperId": "p3",
                "title": "Paper Three",
                "year": 2025,
                "bibtex": "@article{p3,\n  title={Paper Three}\n}",
            },
        ]
        session.call_tool.return_value = _make_result([_make_text_content(papers)])

        from tools.scholar_bibtex import export_bibtex

        count = await export_bibtex("multi-session", temp_bib)
        assert count == 3
        content = temp_bib.read_text()
        assert "@article{p1" in content
        assert "@inproceedings{p2" in content
        assert "@article{p3" in content

    @pytest.mark.asyncio
    async def test_malformed_response(self, mock_stdio, temp_bib):
        _, _, session = mock_stdio
        result = MagicMock()
        result.content = [TextContent(type="text", text="not valid json")]
        result.isError = False
        session.call_tool.return_value = result

        from tools.scholar_bibtex import export_bibtex

        with pytest.raises(RuntimeError, match="malformed"):
            await export_bibtex("bad-session", temp_bib)

    @pytest.mark.asyncio
    async def test_timeout_raises_connection_error(self, mock_stdio, temp_bib):
        _, _, session = mock_stdio
        import asyncio
        session.call_tool.side_effect = asyncio.TimeoutError()

        from tools.scholar_bibtex import export_bibtex

        with pytest.raises(ConnectionError, match="timeout"):
            await export_bibtex("slow-session", temp_bib)

    @pytest.mark.asyncio
    async def test_server_down(self, temp_bib):
        """stdio_client raises — simulate connection failure."""
        from tools.scholar_bibtex import export_bibtex

        with patch("tools.scholar_bibtex.stdio_client") as mock_sc:
            cm = AsyncMock()
            cm.__aenter__.side_effect = ConnectionError("uv not found")
            mock_sc.return_value = cm

            with pytest.raises(ConnectionError):
                await export_bibtex("fail-session", temp_bib)


# ── add_paper tests ────────────────────────────────────────────────

class TestAddPaper:

    @pytest.mark.asyncio
    async def test_success(self, mock_stdio):
        _, _, session = mock_stdio
        session.call_tool.return_value = _make_result([_make_text_content({"success": True})])

        from tools.scholar_bibtex import add_paper

        await add_paper("s1", "10.1145/123456")
        session.call_tool.assert_called_once_with(
            "add_paper_to_session",
            arguments={"session_id": "s1", "paper_id": "10.1145/123456"},
        )

    @pytest.mark.asyncio
    async def test_paper_not_found(self, mock_stdio):
        _, _, session = mock_stdio
        session.call_tool.side_effect = RuntimeError("Paper not found")

        from tools.scholar_bibtex import add_paper

        with pytest.raises(ConnectionError, match="Paper not found"):
            await add_paper("s1", "invalid-id")

    @pytest.mark.asyncio
    async def test_is_error_raises_runtime_error(self, mock_stdio):
        """add_paper should raise RuntimeError when tool returns isError=True."""
        _, _, session = mock_stdio
        session.call_tool.return_value = _make_result(
            [TextContent(type="text", text="paper not found: invalid_id")],
            is_error=True,
        )

        from tools.scholar_bibtex import add_paper

        with pytest.raises(RuntimeError, match="paper not found"):
            await add_paper("test-session", "invalid_id")


# ── list_papers tests ──────────────────────────────────────────────

class TestListPapers:

    @pytest.mark.asyncio
    async def test_connection_error_when_peer_missing(self):
        """PEER_DIR missing raises ConnectionError."""
        with patch("tools.scholar_bibtex.PEER_DIR") as mock_peer:
            mock_peer.exists.return_value = False
            from tools.scholar_bibtex import list_papers

            with pytest.raises(ConnectionError, match="not installed"):
                await list_papers("s1")

    @pytest.mark.asyncio
    async def test_returns_dicts(self, mock_stdio):
        _, _, session = mock_stdio
        papers = [
            {"paperId": "abc", "title": "Paper A"},
            {"paperId": "def", "title": "Paper B"},
        ]
        session.call_tool.return_value = _make_result([_make_text_content(papers)])

        from tools.scholar_bibtex import list_papers

        result = await list_papers("s1")
        assert isinstance(result, list)
        assert len(result) == 2
        assert result[0]["paperId"] == "abc"
        assert result[1]["title"] == "Paper B"


# ── parse_response tests ───────────────────────────────────────────

class TestParseResponse:
    def test_strips_envelope(self):
        from tools.scholar_bibtex import _parse_response

        result = _make_result([_make_text_content(["a", "b"])])
        assert _parse_response(result) == ["a", "b"]

    def test_empty_content_list(self):
        from tools.scholar_bibtex import _parse_response

        result = MagicMock()
        result.content = []
        result.isError = False
        with pytest.raises(RuntimeError, match="empty"):
            _parse_response(result)

    def test_parse_response_is_error(self):
        from tools.scholar_bibtex import _parse_response

        result = MagicMock()
        result.isError = True
        result.content = [TextContent(type="text", text="Paper not found in session")]
        with pytest.raises(RuntimeError, match="Paper not found"):
            _parse_response(result)

    def test_missing_data_key(self):
        from tools.scholar_bibtex import _parse_response

        tc = TextContent(type="text", text=json.dumps({"meta": {}}))
        result = _make_result([tc])
        with pytest.raises(RuntimeError, match="missing.*data"):
            _parse_response(result)
