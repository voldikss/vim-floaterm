" vim:sw=2:
" ============================================================================
" FileName: lf.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#lf#(cmd, jobopts, config) abort
  let s:lf_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'lf -selection-path="' . s:lf_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    if !has_key(a:config, 'cwd')
      if glob('%') != ''
        let cmd .= ' "' . expand('%:p') . '"'
      else
        let cmd .= ' "' . getcwd() . '"'
      endif
    endif
  endif

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:lf_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:lf_callback(job, data, event, opener) abort
  if filereadable(s:lf_tmpfile)
    let filenames = readfile(s:lf_tmpfile)
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
