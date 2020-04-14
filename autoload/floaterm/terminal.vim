" vim:sw=2:
" ============================================================================
" FileName: terminal.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:channel_map = {}
let s:is_win = has('win32') || has('win64')
let s:is_nvim = has('nvim')

if g:floaterm_wintype != v:null
  let s:wintype = g:floaterm_wintype
elseif s:is_nvim && exists('*nvim_win_set_config')
  let s:wintype = 'floating'
elseif has('textprop') && has('patch-8.1.1522')
  let s:wintype = 'popup'
else
  let s:wintype = 'normal'
endif

function! s:on_floaterm_open(bufnr) abort
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&filetype', 'floaterm')
  if s:is_nvim
    let winnr = bufwinnr(a:bufnr)
    call setwinvar(winnr, '&winblend', g:floaterm_winblend)
    call setwinvar(winnr, '&winhl', 'NormalFloat:Floaterm,Normal:Floaterm')
    augroup close_floaterm_window
      execute 'autocmd! TermClose <buffer=' . a:bufnr . '> call s:on_floaterm_close(' . a:bufnr .')'
      execute 'autocmd! BufHidden <buffer=' . a:bufnr . '> call floaterm#window#hide_floaterm_border(' . a:bufnr . ')'
    augroup END
  endif
  if g:floaterm_autoinsert == v:true
    call floaterm#util#startinsert()
  endif
endfunction

function! s:on_floaterm_close(bufnr) abort
  if getbufvar(a:bufnr, '&filetype') != 'floaterm'
    return
  endif
  " NOTE: MUST hide border BEFORE deleting floaterm buffer
  call floaterm#window#hide_floaterm_border(a:bufnr)
  bdelete!
  doautocmd BufDelete   " call lightline#update()
endfunction

function! floaterm#terminal#open(bufnr, cmd, job_opts, winopts) abort
  " for vim's popup, must close popup can we open and jump to a new window
  if !has('nvim')
    call floaterm#window#hide_floaterm(bufnr())
  endif

  let width = type(g:floaterm_width) == 7 ? 0.6 : g:floaterm_width
  let width = get(a:winopts, 'width', width)
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = type(g:floaterm_height) == 7 ? 0.6 : g:floaterm_height
  let height = get(a:winopts, 'height', height)
  if type(height) == v:t_float | let height = height * &lines | endif
  let height = float2nr(height)

  let wintype = get(a:winopts, 'wintype', s:wintype)
  let pos = get(a:winopts, 'position', g:floaterm_position)

  if a:bufnr > 0
    if wintype == 'floating'
      let winid = floaterm#window#open_floating(a:bufnr, width, height, pos)
    elseif wintype == 'popup'
      let winid = floaterm#window#open_popup(a:bufnr, width, height, pos)
    else
      let winid = floaterm#window#open_split(a:bufnr, height, width, pos)
    endif
    call setbufvar(a:bufnr, 'floaterm_winid', winid)
    call s:on_floaterm_open(a:bufnr)
    return 0
  endif

  if s:is_nvim
    let bufnr = nvim_create_buf(v:false, v:true)
    call floaterm#buflist#add(bufnr)
    if wintype == 'floating'
      let winid = floaterm#window#open_floating(bufnr, width, height, pos)
      call nvim_set_current_win(winid)
      let ch = termopen(a:cmd, a:job_opts)
      let s:channel_map[bufnr] = ch
    else
      let winid = floaterm#window#open_split(bufnr, height, width, pos)
      let ch = termopen(a:cmd, a:job_opts)
      let s:channel_map[bufnr] = ch
    endif
  else
    if has_key(a:job_opts, 'on_exit')
      let a:job_opts['exit_cb'] = a:job_opts.on_exit
      unlet a:job_opts.on_exit
    endif
    let a:job_opts.hidden = 1
    let a:job_opts.term_finish = 'close'
    let bufnr = term_start(a:cmd, a:job_opts)
    call floaterm#buflist#add(bufnr)
    let job = term_getjob(bufnr)
    let s:channel_map[bufnr] = job_getchannel(job)
    if wintype == 'popup'
      let winid = floaterm#window#open_popup(bufnr, width, height, pos)
    else
      let winid = floaterm#window#open_split(bufnr, height, width, pos)
    endif
  endif
  " save floaterm attributes
  call setbufvar(bufnr, 'floaterm_winid', winid)
  let a:winopts.width = width
  let a:winopts.height = height
  let a:winopts.wintype = wintype
  let a:winopts.pos = pos
  call setbufvar(bufnr, 'floaterm_winopts', a:winopts)
  let term_name = get(a:winopts, 'name', '')
  if term_name != ''
    let term_name = 'floaterm://' . term_name
    execute 'file ' . term_name
    let a:winopts.name = term_name
  endif

  call s:on_floaterm_open(bufnr)
  return bufnr
endfunction

function! floaterm#terminal#open_existing(bufnr) abort
  let winopts = getbufvar(a:bufnr, 'floaterm_winopts', {})
  call floaterm#terminal#open(a:bufnr, '', {}, winopts)
endfunction

function! floaterm#terminal#send(bufnr, cmds) abort
  let ch = get(s:channel_map, a:bufnr, v:null)
  if empty(ch) | return | endif
  if s:is_nvim
    if !empty(a:cmds[len(a:cmds) - 1])
      call add(a:cmds, '')
    endif
    call chansend(ch, a:cmds)
    let curr_winnr = winnr()
    let ch_winnr = bufwinnr(a:bufnr)
    if ch_winnr > 0
      execute ch_winnr . 'wincmd w'
      execute 'normal! G'
    endif
    execute curr_winnr . 'wincmd w'
  else
    let newline = s:is_win ? "\r\n" : "\n"
    call ch_sendraw(ch, join(a:cmds, newline) . newline)
  endif
endfunction

function! floaterm#terminal#get_bufnr(termname) abort
  return bufnr('floaterm://' . a:termname)
endfunction


"-----------------------------------------------------------------------------
" check if a job is running in the buffer(not used)
"-----------------------------------------------------------------------------
function! floaterm#terminal#jobexists(bufnr) abort
  if s:is_nvim
    let jobid = getbufvar(a:bufnr, '&channel')
    return jobwait([jobid], 0)[0] == -1
  else
    let job = term_getjob(a:bufnr)
    return job_status(job) !=# 'dead'
  endif
endfunction
