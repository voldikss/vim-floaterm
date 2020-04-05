from denite.kind.base import Base
from denite.util import Nvim, UserContext

PREVIEW_FILENAME = "[denite-floaterm-preview]"


class Kind(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = "floaterm"
        self.default_action = "open"
        self._previewed_bufnr = -1
        self._is_nvim = bool(vim.funcs.has("nvim"))

    def action_new(self, context: UserContext) -> None:
        self.vim.command("FloatermNew")

    def action_open(self, context: UserContext) -> None:
        target = context["targets"][0]
        if target.get("action__is_new", False):
            self.action_new(context)
            return

        bufnr = target["action__bufnr"]
        self.vim.call("floaterm#terminal#open_existing", bufnr)

    def action_preview(self, context: UserContext) -> None:
        target = context["targets"][0]

        if "action__bufnr" not in target:
            self.vim.command("pclose!")
            return

        bufnr = target["action__bufnr"]

        if (
            context["auto_action"] != "preview"
            and self._is_preview_window_opened()
            and self._previewed_bufnr == bufnr
        ):
            self.vim.command("pclose!")
            self._previewed_bufnr = -1
            return

        self._save_win()

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

        self._restore_win()
        self._previewed_bufnr = bufnr

    def _is_preview_window_opened(self) -> bool:
        # NOTE: Using `vim.windows` is better, but vim does not recognize it.
        # So here uses an odd way to list windows.
        return next(
            filter(
                lambda x: bool(self.vim.call("getwinvar", x, "&previewwindow")),
                range(1, self.vim.call("winnr", "$") + 1),
            ),
            False,
        )

    def _save_win(self) -> None:
        if self._is_nvim:
            self._current_window = self.vim.current.window
        else:
            self._current_window = self.vim.funcs.win_getid()

    def _restore_win(self) -> None:
        if self._is_nvim:
            self.vim.current.window = self._current_window
        else:
            self.vim.funcs.win_gotoid(self._current_window)
