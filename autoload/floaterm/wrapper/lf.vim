" ============================================================================
" FileName: lf.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#lf#() abort
  let tmp_file = s:lf_tmp_file()
  let original_dir = getcwd()
  lcd %:p:h
  let cmd = 'lf -selection-path=' . tmp_file
  exe "lcd " . original_dir
  return [cmd, {'on_exit': funcref('s:lf_callback')}, v:false]
endfunction

function! s:lf_tmp_file()
  let tmp_file = $XDG_CACHE_HOME

  if !isdirectory(tmp_file)
    let tmp_file = $HOME . "/.cache"
  endif

  let tmp_file .= "/lf-opened_file"
  let tmp_file = fnameescape(tmp_file)
  return tmp_file
endfunction

function! s:lf_callback(...) abort
  let tmp_file = s:lf_tmp_file()

  if filereadable(tmp_file)
    bd!
    let file_data = readfile(tmp_file)
    execute delete(tmp_file)
  else
    return
  endif

  if filereadable(file_data[0])
    execute g:floaterm_open_command . ' ' . file_data[0]
  endif
endfunction

