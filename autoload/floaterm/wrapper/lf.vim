" vim:sw=2:
" ============================================================================
" FileName: lf.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#lf#(cmd) abort
  let s:lf_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'lf -selection-path="' . s:lf_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:lf_callback')}, v:false]
endfunction

function! s:lf_callback(...) abort
  if filereadable(s:lf_tmpfile)
    let filenames = readfile(s:lf_tmpfile)
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
