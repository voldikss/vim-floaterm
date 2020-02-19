from denite.util import Nvim, UserContext, debug
from typing import Any, Callable, Dict, List, TypeVar, cast

PREVIEW_FILENAME = "[denite-floaterm-preview]"
T = TypeVar("T", bound=Callable[..., Any])


class Floaterm:
    def __init__(self, vim: Nvim) -> None:
        self.vim = vim
        self.is_nvim = bool(vim.funcs.has("nvim"))

    def term_title(self, bufnr: int) -> str:
        return str(
            self.vim.api.buf_get_var(bufnr, "term_title")
            if self.is_nvim
            else self.vim.funcs.term_gettitle(bufnr)
        )

    def restore_window_wrapper(self, f: T) -> T:
        def wrapper(*args: List[Any], **kwargs: Dict[str, Any]) -> Any:
            self._save_win()
            result = f()
            self._restore_win()
            return result

        return cast(T, wrapper)

    def _save_win(self) -> None:
        if self.is_nvim:
            self._current_window = self.vim.current.window
        else:
            self._current_window = self.vim.funcs.win_getid()

    def _restore_win(self) -> None:
        if self.is_nvim:
            self.vim.current.window = self._current_window
        else:
            self.vim.funcs.win_gotoid(self._current_window)
