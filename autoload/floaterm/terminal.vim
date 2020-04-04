" ============================================================================
" FileName: terminal.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:channel_map = {}
let s:is_win = has('win32') || has('win64')

if g:floaterm_type != v:null
  let s:wintype = g:floaterm_type
elseif has('nvim') && exists('*nvim_win_set_config')
  let s:wintype = 'floating'
else
  let s:wintype = 'normal'
endif

function! s:on_open() abort
  setlocal nobuflisted
  setlocal filetype=floaterm
  if has('nvim')
    execute 'setlocal winblend=' . g:floaterm_winblend
    setlocal winhighlight=NormalFloat:FloatermNF,Normal:FloatermNF
    augroup close_floaterm_window
      autocmd!
      autocmd TermClose <buffer> if &filetype ==# 'floaterm' | bdelete! | endif
      autocmd TermClose <buffer> call floaterm#floatwin#hide_border()
      autocmd TermClose <buffer> doautocmd BufDelete
      autocmd BufHidden <buffer> call floaterm#floatwin#hide_border()
    augroup END
  endif
  if g:floaterm_autoinsert == v:true
    startinsert
  endif
endfunction

function! floaterm#terminal#open(bufnr, ...) abort

  if a:0 == 0
    let cmd = &shell
    let opts = {}
    let window_opts = {}
  elseif a:0 == 1
    let cmd = a:1
    let opts = {}
    let window_opts = {}
  elseif a:0 == 2
    let cmd = a:1
    let opts = a:2
    let window_opts = {}
  elseif a:0 == 3
    let cmd = a:1
    let opts = a:2
    let window_opts = a:3
  endif

  let width = g:floaterm_width == v:null ? 0.6 : g:floaterm_width
  let width = get(window_opts, 'width', width)
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = g:floaterm_height == v:null ? 0.6 : g:floaterm_height
  let height = get(window_opts, 'height', height)
  if type(height) == v:t_float | let height = height * &lines | endif
  let height = float2nr(height)

  if a:bufnr > 0
    if s:wintype ==# 'floating'
      call floaterm#floatwin#nvim_open_win(a:bufnr, width, height)
    else
      execute 'botright ' . height . 'split'
      execute 'buffer ' . a:bufnr
    endif
    call s:on_open()
    return 0
  endif

  if s:wintype ==# 'floating'
    let bufnr = nvim_create_buf(v:false, v:true)
    call floaterm#floatwin#nvim_open_win(bufnr, width, height)
    let ch = termopen(cmd, opts)
    let s:channel_map[bufnr] = ch
  else
    if has('nvim')
      execute 'botright ' . height . 'split'
      wincmd j | enew
      let bufnr = bufnr('%')
      let ch = termopen(cmd, opts)
      let s:channel_map[bufnr] = ch
    else
      if has_key(opts, 'on_exit')
        let opts['exit_cb'] = opts.on_exit
        unlet opts.on_exit
      endif
      let bufnr = term_start(cmd, opts)
      let job = term_getjob(bufnr)
      let s:channel_map[bufnr] = job_getchannel(job)
      wincmd J
    endif
  endif
  call setbufvar(bufnr, 'window_opts', window_opts)
  call s:on_open()
  return bufnr
endfunction

function! floaterm#terminal#open_existing(bufnr) abort
  let window_opts = getbufvar(a:bufnr, 'window_opts', {})
  call floaterm#terminal#open(a:bufnr, '', {}, window_opts)
endfunction

function! floaterm#terminal#send(bufnr, cmds) abort
  let ch = get(s:channel_map, a:bufnr, v:null)
  if empty(ch) | return | endif
  if has('nvim')
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
