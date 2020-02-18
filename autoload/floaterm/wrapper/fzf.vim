" ============================================================================
" FileName: fzf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#fzf#() abort
  return ['floaterm $(fzf)', {}, v:true]
endfunction
