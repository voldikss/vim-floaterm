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

function! s:create_floating_terminal(bufnr, width, height) abort
  if a:bufnr > 0
    call floaterm#floatwin#nvim_open_win(a:bufnr, a:width, a:height)
    return 0
  else
    let bufnr = nvim_create_buf(v:false, v:true)
    call floaterm#floatwin#nvim_open_win(bufnr, a:width, a:height)
    let opts = {'on_exit': funcref('floaterm#floatwin#hide_border')}
    let chan_id = termopen(&shell, opts)
    let s:channel_map[bufnr] = chan_id
    return bufnr
  endif
endfunction

function! s:create_normal_terminal(found_bufnr, width, height) abort
  if a:found_bufnr > 0
    execute 'botright ' . a:height . 'split'
    execute 'buffer ' . a:found_bufnr
    return 0
  else
    if has('nvim')
      execute 'botright ' . a:height . 'split term://' . &shell
      let bufnr = bufnr('%')
      let s:channel_map[bufnr] = &channel
    else
      execute 'botright terminal ++rows=' . a:height
      let bufnr = bufnr('%')
      let job = term_getjob(bufnr)
      let s:channel_map[bufnr] = job_getchannel(job)
    endif
    return bufnr('%')
  endif
endfunction

function! s:on_open() abort
  setlocal nobuflisted
  setlocal filetype=floaterm
  if has('nvim')
    execute 'setlocal winblend=' . g:floaterm_winblend
    setlocal winhighlight=NormalFloat:FloatermNF,Normal:FloatermNF
    augroup close_floaterm_window
      autocmd!
      autocmd TermClose <buffer> bdelete!
      autocmd BufHidden <buffer> call floaterm#floatwin#hide_border()
    augroup END
  endif
  startinsert
endfunction

function! floaterm#terminal#open(bufnr) abort
  let width = g:floaterm_width == v:null ? 0.6 : g:floaterm_width
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = g:floaterm_height == v:null ? 0.6 : g:floaterm_height
  if type(height) == v:t_float | let height = height * &lines | endif
  let height = float2nr(height)

  if s:wintype ==# 'floating'
    let bufnr = s:create_floating_terminal(a:bufnr, width, height)
  else
    let bufnr = s:create_normal_terminal(a:bufnr, width, height)
  endif
  call s:on_open()
  return bufnr
endfunction

function! floaterm#terminal#send(bufnr, cmd) abort
  let chan_id = get(s:channel_map, a:bufnr, v:null)
  if empty(chan_id) | return | endif
  sleep 300m
  if has('nvim')
    call chansend(chan_id, [a:cmd, ''])
  else
    call ch_sendraw(chan_id, a:cmd.(s:is_win ? "\r\n" : "\n"))
  endif
endfunction
