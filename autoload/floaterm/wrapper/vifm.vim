" ============================================================================
" FileName: vifm.vim
" Author: kazhala <kevin7441@gmail.com>
" GitHub: https://github.com/kazhala
" ============================================================================

function! floaterm#wrapper#vifm#() abort
  let s:vifm_tmpfile = tempname()
  let original_dir = expand("%:p:h")
  let cmd = 'vifm ' . original_dir . ' --choose-files ' . s:vifm_tmpfile
  return [cmd, {'on_exit': funcref('s:vifm_callback')}, v:false]
endfunction

function! s:vifm_callback(...) abort
  if filereadable(s:vifm_tmpfile)
    let filenames = readfile(s:vifm_tmpfile)
    if !empty(filenames)
      call floaterm#hide()
      for filename in filenames
        execute g:floaterm_open_command . ' ' . fnameescape(filename)
      endfor
    endif
  endif
endfunction
