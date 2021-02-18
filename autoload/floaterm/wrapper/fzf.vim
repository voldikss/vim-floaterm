" vim:sw=2:
" ============================================================================
" FileName: fzf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#fzf#(cmd, jobopts, config) abort
  let s:fzf_tmpfile = tempname()
  let cmd = a:cmd
  if cmd !~ '--preview'
    if executable('bat')
      let cmd .= ' --preview ' . shellescape('bat --style=numbers --color=always {}')
    else
      let cmd .= ' --preview ' . shellescape('cat -n {}')
    endif
  endif
  let cmd .= ' > ' . s:fzf_tmpfile
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:fzf_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:fzf_callback(job, data, event, opener) abort
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
      call floaterm#util#open(locations, a:opener)
    endif
  endif
endfunction
