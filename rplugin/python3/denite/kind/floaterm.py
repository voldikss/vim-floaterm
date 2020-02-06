import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent.parent.resolve()))

from denite.kind.base import Base
from denite.util import Nvim, Candidates, UserContext
from denite_floaterm import Floaterm

PREVIEW_FILENAME = "[denite-floaterm-preview]"


class Kind(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = "floaterm"
        self.default_action = "open"
        self._previewed_bufnr = -1
        self._floaterm = Floaterm(vim)

    def action_new(self, context: UserContext) -> None:
        self.vim.call("floaterm#start", "new")

    def action_open(self, context: UserContext) -> None:
        target = context["targets"][0]
        if target.get("action__is_new", False):
            self.action_new(context)
            return

        bufnr = target["action__bufnr"]
        self._floaterm.call("jump", bufnr)

    def action_preview(self, context: UserContext) -> None:
        target = context["targets"][0]

        if "action__bufnr" not in target:
            self.vim.command("pclose!")
            return

        bufnr = target["action__bufnr"]

        if context["auto_action"] != "preview" and self._previewed_bufnr == bufnr:
            self.vim.command("pclose!")
            return

        @self._floaterm.restore_window_wrapper
        def preview() -> None:
            self.vim.call("denite#helper#preview_file", context, PREVIEW_FILENAME)
            self.vim.command("wincmd P")
            self.vim.current.buffer.options["swapfile"] = False
            self.vim.current.buffer.options["bufhidden"] = "wipe"
            self.vim.current.buffer.options["buftype"] = "nofile"

            buf = self.vim.buffers[bufnr]
            last_line = len(buf) - 1
            last_non_empty_line = next(
                filter(lambda x: buf[x] != "", range(last_line, 0, -1)), last_line
            )
            start = max(0, last_non_empty_line - self.vim.options["previewheight"] + 1)
            end = last_non_empty_line + 1
            self.vim.current.buffer[:] = buf[start:end]

        preview()
        self._previewed_bufnr = bufnr
