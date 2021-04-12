" vim:sw=2:
" ============================================================================
" FileName: xplr.vim
" Author: Arijit Basu <sayanarijit@gmail.com>
" GitHub: https://github.com/sayanarijit
" ============================================================================

function! floaterm#wrapper#xplr#(cmd, jobopts, config) abort
  let s:xplr_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'xplr > "' . s:xplr_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:xplr_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:xplr_callback(job, data, event, opener) abort
  if filereadable(s:xplr_tmpfile)
    let filenames = readfile(s:xplr_tmpfile)
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
