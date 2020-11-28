" vim:sw=2:
" ============================================================================
" FileName: fzf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#fzf#(cmd) abort
  let s:fzf_tmpfile = tempname()
  let cmd = a:cmd . ' > ' . s:fzf_tmpfile
  return [cmd, {'on_exit': funcref('s:fzf_callback')}, v:false]
endfunction

function! s:fzf_callback(...) abort
  if filereadable(s:fzf_tmpfile)
    let filenames = readfile(s:fzf_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
