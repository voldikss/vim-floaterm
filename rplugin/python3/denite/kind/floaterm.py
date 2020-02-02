from denite.kind.base import Base
from denite.util import Nvim, Candidates, UserContext

PREVIEW_FILENAME = "[denite-floaterm-preview]"


class Kind(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = "floaterm"
        self.default_action = "open"
        self._previewed_bufnr = -1

    def action_new(self, context: UserContext) -> None:
        self.vim.call("floaterm#start", "new")

    def action_open(self, context: UserContext) -> None:
        target = context["targets"][0]
        if target.get("action__is_new", False):
            self.action_new(context)
            return

        bufnr = target["action__bufnr"]
        self.vim.call("nvim_call_dict_function", "g:floaterm", "jump", [bufnr])

    def action_preview(self, context: UserContext) -> None:
        target = context["targets"][0]

        if "action__bufnr" not in target:
            self.vim.command("pclose!")
            return

        bufnr = target["action__bufnr"]

        if context["auto_action"] != "preview" and self._previewed_bufnr == bufnr:
            self.vim.command("pclose!")
            return

        denite_window = self.vim.current.window
        self.vim.call("denite#helper#preview_file", context, PREVIEW_FILENAME)
        self.vim.command("wincmd P")
        self.vim.current.buffer.options["swapfile"] = False
        self.vim.current.buffer.options["bufhidden"] = "wipe"
        self.vim.current.buffer.options["buftype"] = "nofile"
        self.vim.current.buffer[:] = self.vim.buffers[bufnr][
            0 : self.vim.options["previewheight"]
        ]
        self.vim.current.window = denite_window
        self._previewed_bufnr = bufnr
