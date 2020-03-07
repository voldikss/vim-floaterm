" ============================================================================
" FileName: fff.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#fff#() abort
  let original_dir = getcwd()
  lcd %:p:h
  let cmd = 'fff -p ' . getcwd()
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
    call floaterm#hide()
    execute g:floaterm_open_command . ' ' . file_data[0]
  endif
endfunction
