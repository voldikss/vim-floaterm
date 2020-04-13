" vim:sw=2:
" ============================================================================
" FileName: fzf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#fzf#(...) abort
  if stridx(&shell, 'fish') >= 0
    let cmd = 'floaterm (fzf)'
  elseif stridx(&shell, 'csh')
    let cmd = 'floaterm `fzf`'
  else
    " sh/bash/zsh
    let cmd = 'floaterm $(fzf)'
  endif
  return [cmd, {}, v:true]
endfunction
