" vim:sw=2:
" ============================================================================
" FileName: terminal.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:timer_map = {}
let s:channel_map = {}

function! s:on_floaterm_create(bufnr) abort
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  augroup floaterm_enter_insertmode
    autocmd! * <buffer>
    autocmd! User FloatermOpen
    autocmd User FloatermOpen call floaterm#util#startinsert()
    autocmd BufEnter <buffer> call floaterm#util#startinsert()
    execute printf(
          \ 'autocmd BufHidden,BufWipeout <buffer=%s> call floaterm#window#hide(%s)',
          \ a:bufnr,
          \ a:bufnr
          \ )
    if floaterm#config#get(a:bufnr, 'disposable')
      execute printf(
            \ 'autocmd BufHidden <buffer=%s> call floaterm#terminal#kill(%s)',
            \ a:bufnr,
            \ a:bufnr
            \ )
    endif
  augroup END
endfunction

" for vim8: a:000 is empty
" for nvim: a:000 is ['exit'](event)
function! s:on_floaterm_close(bufnr, callback, job, data, ...) abort
  if a:bufnr == -1
    " In vim, buffnr is not known before starting a job, therefore, it's
    " impossible to pass the bufnr to a job's callback function. Also change
    " callback after a job was spawned seem not feasible. Therefore, iterate s:
    " channel_map and get the bufnr whose channel matches the channel of a:job
    for [buf, chan] in items(s:channel_map)
      if chan == job_getchannel(a:job)
        let bufnr = str2nr(buf)
        break
      endif
    endfor
  else
    let bufnr = a:bufnr
  endif
  let opener = floaterm#config#get(bufnr, 'opener')
  call setbufvar(bufnr, '&bufhidden', 'wipe')
  call floaterm#config#set(bufnr, 'jobexists', v:false)
  let autoclose = floaterm#config#get(bufnr, 'autoclose')
  if (autoclose == 1 && a:data == 0) || (autoclose == 2) || (a:callback isnot v:null)
    call floaterm#window#hide(bufnr)
    " if the floaterm is created with --silent, delete the buffer explicitly
    silent! execute bufnr . 'bdelete!'
    " update lightline
    doautocmd BufDelete
  endif
  if a:callback isnot v:null
    call a:callback(a:job, a:data, 'exit', opener)
  endif
endfunction

" config: local configuration of a specific floaterm, including:
" cwd, name, width, height, title, silent, wintype, position, autoclose, etc.
function! floaterm#terminal#open(bufnr, cmd, jobopts, config) abort
  " vim8: must close popup can we open and jump to a new window
  if !has('nvim') && &filetype == 'floaterm'
    call floaterm#window#hide(bufnr('%'))
  endif

  if !bufexists(a:bufnr)
    " change cwd
    let savedcwd = getcwd()
    if has_key(a:config, 'cwd')
      call floaterm#path#chdir(a:config.cwd)
    endif

    " spawn terminal
    let bufnr = s:spawn_terminal(a:cmd, a:jobopts, a:config)

    " hide floaterm immediately if silent
    if floaterm#config#get(bufnr, 'silent', 0)
      call floaterm#window#hide(bufnr)
    endif

    " restore cwd
    call floaterm#path#chdir(savedcwd)
  else
    let config = floaterm#config#parse(a:bufnr, a:config)
    call floaterm#window#open(a:bufnr, config)
    let bufnr = a:bufnr
  endif
  doautocmd User FloatermOpen

  return bufnr
endfunction

function! floaterm#terminal#open_existing(bufnr) abort
  if !bufexists(a:bufnr)
    call floaterm#util#show_msg(printf("Buffer %s doesn't exists", a:bufnr), 'error')
    return
  endif
  let config = floaterm#config#get_all(a:bufnr)
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
    let config = floaterm#config#parse(bufnr, a:config)
    call floaterm#window#open(bufnr, config)
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
    let a:jobopts.hidden = 1
    try
      " TODO: need refactor
      let config = floaterm#config#parse(-1, a:config)
      let a:jobopts['term_cols'] = config.width - 2
      let a:jobopts['term_rows'] = config.height - 2
      let bufnr = term_start(a:cmd, a:jobopts)
    catch
      call floaterm#util#show_msg('Failed to execute: ' . a:cmd, 'error')
      return
    endtry
    call floaterm#buflist#add(bufnr)
    let job = term_getjob(bufnr)
    let s:channel_map[bufnr] = job_getchannel(job)
    let config = floaterm#config#parse(bufnr, a:config)
    call floaterm#window#open(bufnr, config)
  endif
  call floaterm#config#set(bufnr, 'jobexists', v:true)
  call floaterm#config#set(bufnr, 'cmd', a:cmd)
  call s:on_floaterm_create(bufnr)
  return bufnr
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
    let newline = "\n"
    if has('win32') && bufname(a:bufnr) !~ 'ipython'
      let newline = "\r\n"
    endif
    call ch_sendraw(ch, join(a:cmds, newline) . newline)
  endif
endfunction

function! floaterm#terminal#get_bufnr(termname) abort
  let buflist = floaterm#buflist#gather()
  for bufnr in buflist
    let name = floaterm#config#get(bufnr, 'name')
    if name ==# a:termname
      return bufnr
    endif
  endfor
  return -1
endfunction

function! floaterm#terminal#kill(bufnr) abort
  call floaterm#window#hide(a:bufnr)
  if has('nvim')
    let job = getbufvar(a:bufnr, '&channel')
    if jobwait([job], 0)[0] == -1
      call jobstop(job)
    endif
  else
    let job = term_getjob(a:bufnr)
    if job != v:null && job_status(job) !=# 'dead'
      call job_stop(job, 'kill')
    endif
  endif
  call s:ensure_terminal_kill(a:bufnr)
  let s:timer_map[a:bufnr] = timer_start(
        \ 5,
        \ { -> s:ensure_terminal_kill(a:bufnr) },
        \ {'repeat': 3}
        \ )
endfunction

function! s:ensure_terminal_kill(bufnr) abort
  try
    if bufexists(a:bufnr)
      execute a:bufnr . 'bwipeout!'
    else
      call timer_stop(s:timer_map[a:bufnr])
      call remove(s:timer_map, a:bufnr)
    endif
  catch
    silent! call popup_close(win_getid())
  endtry
endfunction

function! floaterm#terminal#jobexists(bufnr) abort
  if has('nvim')
    let job = getbufvar(a:bufnr, '&channel')
    return jobwait([job], 0)[0] == -1
  else
    let job = term_getjob(a:bufnr)
    return job != v:null && job_status(job) != 'dead'
  endif
endfunction
