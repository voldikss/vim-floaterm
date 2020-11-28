" vim:sw=2:
" ============================================================================
" FileName: nnn.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#nnn#(cmd) abort
  let s:nnn_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'nnn -p "' . s:nnn_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:nnn_callback')}, v:false]
endfunction

function! s:nnn_callback(...) abort
  if filereadable(s:nnn_tmpfile)
    let filenames = readfile(s:nnn_tmpfile)
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
