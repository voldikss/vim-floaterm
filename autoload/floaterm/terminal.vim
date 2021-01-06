" vim:sw=2:
" ============================================================================
" FileName: terminal.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:channel_map = {}
let s:is_win = has('win32') || has('win64')

function! s:on_floaterm_open(bufnr, winid, config) abort
  call setbufvar(a:bufnr, 'floaterm_winid', a:winid)
  call setbufvar(a:bufnr, 'floaterm_config', a:config)
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  if has('nvim')
    " TODO: need to be reworked
    execute printf(
          \ 'autocmd BufHidden <buffer=%s> ++once call floaterm#window#hide(%s)',
          \ a:bufnr,
          \ a:bufnr
          \ )
  endif
endfunction

function! s:on_floaterm_close(bufnr, callback, job, data, ...) abort
  if a:bufnr == -1
    let bufnr = bufnr('%')
  else
    let bufnr = a:bufnr
  endif
  let config = getbufvar(bufnr, 'floaterm_config', {})
  let autoclose = get(config, 'autoclose', 0)
  if (autoclose == 1 && a:data == 0) || (autoclose == 2) || (a:callback isnot v:null)
    call floaterm#window#hide(bufnr)
    try
      execute bufnr . 'bdelete!'
    catch
    endtry
    " update lightline
    doautocmd BufDelete
  endif
  if a:callback isnot v:null
    call a:callback(a:job, a:data, 'exit')
  endif
endfunction

" config: local configuration of a specific floaterm, including:
" cwd, name, width, height, title, silent, wintype, position, autoclose, etc.
function! floaterm#terminal#open(bufnr, cmd, jobopts, config) abort
  " vim8: must close popup can we open and jump to a new window
  if !has('nvim') && &filetype == 'floaterm'
    call floaterm#window#hide(bufnr('%'))
  endif

  " just open if floaterm exists
  if a:bufnr > 0
    let [winid, config] = floaterm#window#open(a:bufnr, a:config)
    call s:on_floaterm_open(a:bufnr, winid, config)
    return a:bufnr
  endif

  " change cwd
  let savedcwd = getcwd()
  let dest = ''
  if has_key(a:config, 'cwd')
    let dest = a:config.cwd
  elseif !empty(g:floaterm_rootmarkers)
    let dest = floaterm#path#get_root()
  endif
  if !empty(dest)
    call floaterm#path#chdir(dest)
  endif

  " spawn terminal
  let [bufnr, config] = s:spawn_terminal(a:cmd, a:jobopts, a:config)

  " hide floaterm immediately if silent
  if has_key(config, 'silent') && config.silent == 1
    call floaterm#window#hide(bufnr)
    stopinsert
  endif

  " restore cwd
  call floaterm#path#chdir(savedcwd)

  return bufnr
endfunction

function! floaterm#terminal#open_existing(bufnr) abort
  let winnr = bufwinnr(a:bufnr)
  if winnr > -1
    execute winnr . 'hide'
  endif
  let config = getbufvar(a:bufnr, 'floaterm_config', {})
  call floaterm#terminal#open(a:bufnr, '', {}, config)
endfunction

function! s:spawn_terminal(cmd, jobopts, config) abort
  if has('nvim')
    let bufnr = nvim_create_buf(v:false, v:true)
    call floaterm#buflist#add(bufnr)
    let a:jobopts.on_exit = function(
          \ 's:on_floaterm_close',
          \ [bufnr, get(a:jobopts, 'on_exit', v:null)]
          \ )
    let [winid, config] = floaterm#window#open(bufnr, a:config)
    let ch = termopen(a:cmd, a:jobopts)
    let s:channel_map[bufnr] = ch
  else
    let a:jobopts.exit_cb = function(
          \ 's:on_floaterm_close',
          \ [-1, get(a:jobopts, 'on_exit', v:null)]
          \ )
    if has_key(a:jobopts, 'on_exit')
      unlet a:jobopts.on_exit
    endif
    if has('patch-8.1.2080')
      let a:jobopts.term_api = 'floaterm#util#edit'
    endif
    let a:jobopts.hidden = 1
    let bufnr = term_start(a:cmd, a:jobopts)
    call floaterm#buflist#add(bufnr)
    let job = term_getjob(bufnr)
    let s:channel_map[bufnr] = job_getchannel(job)
    let [winid, config] = floaterm#window#open(bufnr, a:config)
  endif
  call s:on_floaterm_open(bufnr, winid, config)
  return [bufnr, config]
endfunction

function! floaterm#terminal#send(bufnr, cmds) abort
  let ch = get(s:channel_map, a:bufnr, v:null)
  if empty(ch) || empty(a:cmds)
    return
  endif
  if has('nvim')
    call add(a:cmds, '')
    call chansend(ch, a:cmds)
    let curr_winnr = winnr()
    let ch_winnr = bufwinnr(a:bufnr)
    if ch_winnr > 0
      noautocmd execute ch_winnr . 'wincmd w'
      noautocmd execute 'normal! G'
    endif
    noautocmd execute curr_winnr . 'wincmd w'
  else
    let newline = s:is_win ? "\r\n" : "\n"
    call ch_sendraw(ch, join(a:cmds, newline) . newline)
  endif
endfunction

function! floaterm#terminal#get_bufnr(termname) abort
  let buflist = floaterm#buflist#gather()
  for bufnr in buflist
    let config = getbufvar(bufnr, 'floaterm_config', {})
    let name = get(config, 'name', '')
    if name ==# a:termname
      return bufnr
    endif
  endfor
  return -1
endfunction

function! floaterm#terminal#kill(bufnr) abort
  call floaterm#window#hide(a:bufnr)
  if has('nvim')
    let jobid = getbufvar(a:bufnr, '&channel')
    if jobwait([jobid], 0)[0] == -1
      call jobstop(jobid)
    endif
  else
    let job = term_getjob(a:bufnr)
    if job != v:null && job_status(job) !=# 'dead'
      call job_stop(job)
    endif
  endif
  if bufexists(a:bufnr)
    execute a:bufnr . 'bwipeout!'
  endif
endfunction
