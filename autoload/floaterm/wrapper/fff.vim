" vim:sw=2:
" ============================================================================
" FileName: fff.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#fff#(cmd) abort
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'fff -p'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:fff_callback')}, v:false]
endfunction

function! s:fff_callback(...) abort
  let s:fff_tmpfile = $XDG_CACHE_HOME

  if !isdirectory(s:fff_tmpfile)
    let s:fff_tmpfile = $HOME . "/.cache"
  endif

  let s:fff_tmpfile .= "/fff/opened_file"
  let s:fff_tmpfile = fnameescape(s:fff_tmpfile)

  if filereadable(s:fff_tmpfile)
    let file_data = readfile(s:fff_tmpfile)
    execute delete(s:fff_tmpfile)
  else
    return
  endif

  if filereadable(file_data[0])
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
    execute g:floaterm_open_command . ' ' . file_data[0]
  endif
endfunction
