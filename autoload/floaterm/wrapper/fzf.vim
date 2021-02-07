" vim:sw=2:
" ============================================================================
" FileName: fzf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#fzf#(cmd) abort
  let s:fzf_tmpfile = tempname()
  let cmd = a:cmd
  if cmd !~ '--preview'
    if executable('bat')
      let cmd .= " --preview 'bat --style=numbers --color=always {} | head -500'"
    else
      let cmd .= " --preview 'cat -n {} | head -500'"
    endif
  endif
  let cmd .= ' > ' . s:fzf_tmpfile
  let cmd = [&shell, &shellcmdflag, cmd]
  return [cmd, {'on_exit': funcref('s:fzf_callback')}, v:false]
endfunction

function! s:fzf_callback(...) abort
  if filereadable(s:fzf_tmpfile)
    let filenames = readfile(s:fzf_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      let locations = []
      for filename in filenames
        let dict = {'filename': fnamemodify(filename, ':p')}
        call add(locations, dict)
      endfor
      call floaterm#util#open(g:floaterm_open_command, locations)
    endif
  endif
endfunction
