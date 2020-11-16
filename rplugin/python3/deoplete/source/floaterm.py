# ========================================================================
# FileName: floaterm.py
# Description:
# Author: voldikss
# GitHub: https://github.com/voldikss
# ========================================================================

import re
from typing import List

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)

        complete_options = self.vim.eval("g:floaterm_complete_options")
        if "filetypes" in complete_options:
            self.filetypes = complete_options["filetypes"]
        self.mark = complete_options["shortcut"]
        self.rank = complete_options["priority"]
        [self.minlength, self.maxlength] = complete_options["filter_length"]
        self.matchers = ["matcher_length", "matcher_full_fuzzy"]
        self.name = "floaterm"
        self.max_candidates = 0

    def gather_candidates(self, context):
        lines: List[str] = self.vim.call("floaterm#util#getbufline", -1, 100)
        candidates = []
        for line in lines:
            for word in line.split(" "):
                if self.minlength <= len(word) <= self.maxlength:
                    candidates.append({"word": word, "dup": 0})
        return candidates
