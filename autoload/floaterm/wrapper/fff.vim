" vim:sw=2:
" ============================================================================
" FileName: fff.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#fff#(cmd, jobopts, config) abort
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
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:fff_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:fff_callback(job, data, event, opener) abort
  let s:fff_tmpfile = $XDG_CACHE_HOME

  if !isdirectory(s:fff_tmpfile)
    let s:fff_tmpfile = $HOME . "/.cache"
  endif

  let s:fff_tmpfile .= "/fff/opened_file"
  let s:fff_tmpfile = fnameescape(s:fff_tmpfile)

  if filereadable(s:fff_tmpfile)
    let filenames = readfile(s:fff_tmpfile)
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
