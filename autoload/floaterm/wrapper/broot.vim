" vim:sw=2:
" ============================================================================
" FileName: broot.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:broot_default_confpath = fnamemodify('~/.config/broot/conf.hjson', ':p')
let s:broot_wrapper_confpath = fnamemodify(expand('<sfile>'), ':h') . '/broot.hjson'
let s:broot_confpath = s:broot_wrapper_confpath . ';' . s:broot_default_confpath

let s:broot_wrapper_config = [
      \ '{',
      \ '	verbs: [',
      \ '		{',
      \ '			invocation: terminal',
      \ '			key: enter',
      \ '			execution: "echo {line} {file}"',
      \ '			leave_broot: true',
      \ '			apply_to: file',
      \ '		}',
      \ '	]',
      \ '}',
      \ ]
call writefile(s:broot_wrapper_config, s:broot_wrapper_confpath)

function! floaterm#wrapper#broot#(cmd, jobopts, config) abort
  let s:broot_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = printf(
        \ '%s --conf "%s" > "%s"',
        \ a:cmd,
        \ s:broot_confpath,
        \ s:broot_tmpfile
        \ )

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {'on_exit': funcref('s:broot_callback')}
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:broot_callback(job, data, event, opener) abort
  if filereadable(s:broot_tmpfile)
    let filenames = readfile(s:broot_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      let locations = []
      for filename in filenames
        let lnum_file = split(filename)
        let dict = {
              \ 'filename': fnamemodify(lnum_file[1], ':p'),
              \ 'lnum': lnum_file[0],
              \ }
        call add(locations, dict)
      endfor
      call floaterm#util#open(locations, a:opener)
    endif
  endif
endfunction
