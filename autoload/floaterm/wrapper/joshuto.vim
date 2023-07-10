" vim:sw=2:
" ============================================================================
" FileName: joshuto.vim
" Author: JohanChane <johanchanex@gmail.com>
" GitHub: https://github.com/JohanChane
" ============================================================================

function! floaterm#wrapper#joshuto#(cmd, jobopts, config) abort
  let s:joshuto_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'joshuto --file-chooser --output-file="' . s:joshuto_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    if !has_key(a:config, 'cwd')
      let cmd .= ' "' . getcwd() . '"'
    endif
  endif

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:joshuto_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:joshuto_callback(job, data, event, opener) abort
  if filereadable(s:joshuto_tmpfile)
    let filenames = readfile(s:joshuto_tmpfile)
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
