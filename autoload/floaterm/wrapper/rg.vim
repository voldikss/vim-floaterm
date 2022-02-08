" vim:sw=2:
" ============================================================================
" FileName: rg.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if executable('bat')
  let s:viewer = 'bat --style=numbers --color=always --highlight-line {2}'
elseif executable('batcat')
  let s:viewer = 'batcat --style=numbers --color=always --highlight-line {2}'
else
  let s:viewer = 'cat -n'
endif

function! floaterm#wrapper#rg#(cmd, jobopts, config) abort
  let FZF_DEFAULT_COMMAND = join([
        \ "rg",
        \ "--column",
        \ "--line-number",
        \ "--no-heading",
        \ "--color=always",
        \ "--smart-case",
        \ join(split(a:cmd)[1:])
        \ ])

  let s:rg_tmpfile = tempname()
  let prog = 'fzf'
  let arglist = [
        \ '--ansi',
        \ '--multi',
        \ '--no-height',
        \ '--delimiter :',
        \ '--bind ctrl-/:toggle-preview' ,
        \ '--bind alt-a:select-all,alt-d:deselect-all',
        \ '--preview-window +{2}-/2 --preview-window right',
        \ printf('--preview "%s {1}"', s:viewer)
        \ ]
  let cmd = printf('%s %s > %s', prog, join(arglist), s:rg_tmpfile)
  let cmd = [&shell, &shellcmdflag, cmd]
  let jobopts = {
        \ 'on_exit': funcref('s:rg_callback'),
        \ 'env': {'FZF_DEFAULT_COMMAND': FZF_DEFAULT_COMMAND}
        \ }
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:rg_callback(job, data, event, opener) abort
  if filereadable(s:rg_tmpfile)
    let filenames = readfile(s:rg_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      let locations = []
      for filename in filenames
        let parts = matchlist(filename, '\(.\{-}\)\s*:\s*\(\d\+\)\%(\s*:\s*\(\d\+\)\)\?\%(\s*:\(.*\)\)\?')
        let dict = {
              \ 'filename': fnamemodify(parts[1], ':p'),
              \ 'lnum': parts[2],
              \ 'text': parts[4]
              \ }
        call add(locations, dict)
      endfor
      call floaterm#util#open(locations, a:opener)
    endif
  endif
endfunction
