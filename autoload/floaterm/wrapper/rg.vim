" vim:sw=2:
" ============================================================================
" FileName: rg.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#rg#(cmd) abort
  let s:rg_tmpfile = tempname()
  let cmd = a:cmd . '| fzf > ' . s:rg_tmpfile
  return [cmd, {'on_exit': funcref('s:rg_callback')}, v:false]
endfunction

function! s:rg_callback(...) abort
  if filereadable(s:rg_tmpfile)
    let filenames = readfile(s:rg_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      for filename in filenames
        let realfilename = matchlist(filename, '\(.\{-}\):.*$')[1]
        execute g:floaterm_open_command . ' ' . fnameescape(realfilename)
      endfor
    endif
  endif
endfunction
