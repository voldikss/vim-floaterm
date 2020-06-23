" vim:sw=2:
" ============================================================================
" FileName: terminal.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:channel_map = {}
let s:is_win = has('win32') || has('win64')
let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

if g:floaterm_wintype == v:null
  if s:has_float
    let s:wintype = 'floating'
  elseif s:has_popup
    let s:wintype = 'popup'
  else
    let s:wintype = 'normal'
  endif
elseif g:floaterm_wintype == 'floating' && !s:has_float
  call floaterm#util#show_msg("floating window is not supported in your nvim, fall back to normal window", 'warning')
  let s:wintype = 'normal'
elseif g:floaterm_wintype == 'popup' && !s:has_popup
  call floaterm#util#show_msg("popup window is not supported in your vim, fall back to normal window", 'warning')
  let s:wintype = 'normal'
else
  let s:wintype = g:floaterm_wintype
endif

function! s:on_floaterm_open(bufnr, winid, winopts) abort
  call setbufvar(a:bufnr, 'floaterm_winid', a:winid)
  call setbufvar(a:bufnr, 'floaterm_winopts', a:winopts)
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')

  let termname = get(a:winopts, 'name', '')
  if termname != ''
    let termname = 'floaterm://' . termname
    execute 'file ' . termname
  endif

  if has('nvim')
    execute 'autocmd! BufHidden <buffer=' . a:bufnr . '> ++once call floaterm#window#hide_floaterm_border(' . a:bufnr . ')'
  endif
endfunction

function! s:on_floaterm_close(callback, job, data, ...) abort
  let bufnr = bufnr('%')
  if getbufvar(bufnr, '&filetype') != 'floaterm'
    return
  endif
  let winopts = getbufvar(bufnr, 'floaterm_winopts', {})
  let autoclose = get(winopts, 'autoclose', 0)
  if (autoclose == 1 && a:data == 0) || (autoclose == 2) || (a:callback isnot v:null)
    call floaterm#window#hide_floaterm(bufnr)
    try
      execute bufnr . 'bdelete!'
    catch
    endtry
    doautocmd BufDelete   "call lightline#update()
  endif
  if a:callback isnot v:null
    call a:callback(a:job, a:data, 'exit')
  endif
endfunction

function! s:update_winopts(winopts) abort
  if has_key(a:winopts, 'width')
    let width = a:winopts.width
  else
    let width = type(g:floaterm_width) == 7 ? 0.6 : g:floaterm_width
    let a:winopts.width = width
  endif

  if has_key(a:winopts, 'height')
    let height = a:winopts.height
  else
    let height = type(g:floaterm_height) == 7 ? 0.6 : g:floaterm_height
    let a:winopts.height = height
  endif

  if has_key(a:winopts, 'wintype')
    let wintype = a:winopts.wintype
  else
    let wintype = s:wintype
    let a:winopts.wintype = wintype
  endif

  if has_key(a:winopts, 'position')
    let position = a:winopts.position
  else
    let position = g:floaterm_position
    let a:winopts.position = position
  endif

  if has_key(a:winopts, 'autoclose')
    let autoclose = a:winopts.autoclose
  else
    let autoclose = g:floaterm_autoclose
    let a:winopts.autoclose = autoclose
  endif
  return a:winopts
endfunction

function! floaterm#terminal#open(bufnr, cmd, jobopts, winopts) abort
  " for vim's popup, must close popup can we open and jump to a new window
  if !has('nvim')
    call floaterm#window#hide_floaterm(bufnr('%'))
  endif

  " change to root directory
  if !empty(g:floaterm_rootmarkers)
    let dest = floaterm#path#get_root()
    if dest !=# ''
      call floaterm#path#chdir(dest)
    endif
  endif

  let winopts = s:update_winopts(a:winopts)
  let wintype = a:winopts.wintype
  let position = a:winopts.position

  let width = winopts.width
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = winopts.height
  if type(height) == v:t_float | let height = height * (&lines - &cmdheight - 1) | endif
  let height = float2nr(height)

  if a:bufnr > 0
    if wintype == 'floating'
      let winid = floaterm#window#open_floating(a:bufnr, width, height, position)
    elseif wintype == 'popup'
      let winid = floaterm#window#open_popup(a:bufnr, width, height, position)
    else
      let winid = floaterm#window#open_split(a:bufnr, height, width, position)
    endif
    call s:on_floaterm_open(a:bufnr, winid, a:winopts)
    return 0
  endif

  if has('nvim')
    let bufnr = nvim_create_buf(v:false, v:true)
    call floaterm#buflist#add(bufnr)
    let a:jobopts.on_exit = function('s:on_floaterm_close', [get(a:jobopts, 'on_exit', v:null)])
    if wintype == 'floating'
      let winid = floaterm#window#open_floating(bufnr, width, height, position)
      call nvim_set_current_win(winid)
      let ch = termopen(a:cmd, a:jobopts)
      let s:channel_map[bufnr] = ch
    else
      let winid = floaterm#window#open_split(bufnr, height, width, position)
      let ch = termopen(a:cmd, a:jobopts)
      let s:channel_map[bufnr] = ch
    endif
  else
    let a:jobopts.exit_cb = function('s:on_floaterm_close', [get(a:jobopts, 'on_exit', v:null)])
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
    if wintype == 'popup'
      let winid = floaterm#window#open_popup(bufnr, width, height, position)
    else
      let winid = floaterm#window#open_split(bufnr, height, width, position)
    endif
  endif
  call s:on_floaterm_open(bufnr, winid, a:winopts)
  return bufnr
endfunction

function! floaterm#terminal#open_existing(bufnr) abort
  let winnr = bufwinnr(a:bufnr)
  if winnr > -1
    execute winnr . 'hide'
  endif
  let winopts = getbufvar(a:bufnr, 'floaterm_winopts', {})
  call floaterm#terminal#open(a:bufnr, '', {}, winopts)
endfunction

function! floaterm#terminal#send(bufnr, cmds) abort
  let ch = get(s:channel_map, a:bufnr, v:null)
  if empty(ch) || empty(a:cmds)
    return
  endif
  if has('nvim')
    if !empty(a:cmds[len(a:cmds) - 1])
      call add(a:cmds, '')
    endif
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
  return bufnr('floaterm://' . a:termname)
endfunction


function! floaterm#terminal#kill(bufnr) abort
  call floaterm#window#hide_floaterm(a:bufnr)
  if has('nvim')
    let jobid = getbufvar(a:bufnr, '&channel')
    if jobwait([jobid], 0)[0] == -1
      call jobstop(jobid)
    endif
  else
    let job = term_getjob(a:bufnr)
    if job_status(job) !=# 'dead'
      call job_stop(job)
    endif
  endif
  if bufexists(a:bufnr)
    execute a:bufnr . 'bwipeout!'
  endif
endfunction
