from denite.base.source import Base
from denite.util import Nvim, UserContext, Candidate, Candidates

DELIMITER = "\u00a0:\u00a0"
FLOATERM_HIGHLIGHT_SYNTAX = [
    {"name": "Bufnr", "link": "Constant", "re": r"\d\+ ", "next": "Name"},
    {"name": "Name", "link": "Function", "delimiter": DELIMITER, "next": "Title"},
    {"name": "Title", "link": "Title", "re": r".*"},
]


class Source(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = "floaterm"
        self.kind = "floaterm"
        self._is_nvim = bool(vim.funcs.has("nvim"))

    def on_init(self, context: UserContext) -> None:
        self.vim.call("floaterm#hide", 1, "")

    def gather_candidates(self, context: UserContext) -> Candidates:
        return (
            [{"word": "[open new floaterm]", "action__is_new": True}]
            if "new" in context["args"]
            else [
                self._make_candidate(x)
                for x in self.vim.call("floaterm#buflist#gather")
            ]
        )

    def highlight(self) -> None:
        for i, syn in enumerate(FLOATERM_HIGHLIGHT_SYNTAX):

            def syn_name(key: str) -> str:
                return "_".join([self.syntax_name, syn[key]])

            self.vim.command(
                f"highlight default link {syn_name('name')} {syn['link']}")
            containedin = f" containedin={self.syntax_name}" if i == 0 else ""
            nextgroup = f" nextgroup={syn_name('next')}" if "next" in syn else ""
            if "delimiter" in syn:
                self.vim.command(
                    "syntax region {0} matchgroup=Delimiter start=/{1}/ end=/{1}/ concealends contained{2}{3}".format(
                        syn_name(
                            "name"), syn["delimiter"], containedin, nextgroup
                    )
                )
            else:
                self.vim.command(
                    "syntax match {0} /{1}/ contained{2}{3}".format(
                        syn_name("name"), syn["re"], containedin, nextgroup
                    )
                )

    def _make_candidate(self, bufnr: int) -> Candidate:
        name = self.vim.buffers[bufnr].name
        title = self._term_title(bufnr)
        return {
            "word": name,
            "abbr": f"{bufnr: >2} {DELIMITER}{name}{DELIMITER} {title}",
            "action__bufnr": bufnr,
        }

    def _term_title(self, bufnr: int) -> str:
        return str(
            self.vim.api.buf_get_var(bufnr, "term_title")
            if self._is_nvim
            else self.vim.funcs.term_gettitle(bufnr)
        )
