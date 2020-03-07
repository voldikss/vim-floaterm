" ============================================================================
" FileName: ranger.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#ranger#() abort
  let s:ranger_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h
  let cmd = 'ranger ' . shellescape(getcwd()) . ' --choosefiles=' . s:ranger_tmpfile
  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:ranger_callback')}, v:false]
endfunction

function! s:ranger_callback(...) abort
  if filereadable(s:ranger_tmpfile)
    let filenames = readfile(s:ranger_tmpfile)
    if !empty(filenames)
      call floaterm#hide()
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
