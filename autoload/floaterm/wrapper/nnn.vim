" ============================================================================
" FileName: nnn.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#nnn#() abort
  let s:nnn_tmpfile = tempname()
  let cmd = 'nnn -p ' . s:nnn_tmpfile
  return [cmd, {'on_exit': funcref('s:nnn_callback')}, v:false]
endfunction

function! s:nnn_callback(...) abort
  if filereadable(s:nnn_tmpfile)
    let filenames = readfile(s:nnn_tmpfile)
    if !empty(filenames)
      call floaterm#hide()
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
