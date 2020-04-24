" vim:sw=2:
" ============================================================================
" FileName: vifm.vim
" Author: kazhala <kevin7441@gmail.com>
" GitHub: https://github.com/kazhala
" ============================================================================

function! floaterm#wrapper#vifm#(cmd) abort
  let s:vifm_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'vifm --choose-files "' . s:vifm_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:vifm_callback')}, v:false]
endfunction

function! s:vifm_callback(...) abort
  if filereadable(s:vifm_tmpfile)
    let filenames = readfile(s:vifm_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide_floaterm(bufnr('%'))
      endif
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
