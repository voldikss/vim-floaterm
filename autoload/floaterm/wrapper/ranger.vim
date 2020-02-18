" ============================================================================
" FileName: ranger.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#ranger#() abort
  let s:ranger_tmpfile = tempname()
  let cmd = 'ranger --choosefiles=' . s:ranger_tmpfile
  return [cmd, {'on_exit': funcref('s:ranger_callback')}, v:false]
endfunction

function! s:ranger_callback(...)
  if filereadable(s:ranger_tmpfile)
    let filenames = readfile(s:ranger_tmpfile)
    if !empty(filenames)
      call floaterm#hide()
      for filename in filenames
        execute 'edit ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
