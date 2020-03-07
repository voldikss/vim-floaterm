" ============================================================================
" FileName: lf.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#lf#() abort
  let s:lf_tmpfile = s:lf_tmp_file()
  let original_dir = getcwd()
  lcd %:p:h
  let cmd = 'lf -selection-path=' . s:lf_tmpfile . ' ' . getcwd()
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
  if filereadable(s:lf_tmpfile)
    let filenames = readfile(s:lf_tmpfile)
    if !empty(filenames)
      call floaterm#hide()
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
