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
      autocmd TermClose <buffer> doautocmd BufRead
      autocmd BufHidden <buffer> call floaterm#floatwin#hide_border()
    augroup END
  endif
  startinsert
endfunction

function! floaterm#terminal#open(bufnr, ...) abort
  let width = g:floaterm_width == v:null ? 0.6 : g:floaterm_width
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  let height = g:floaterm_height == v:null ? 0.6 : g:floaterm_height
  if type(height) == v:t_float | let height = height * &lines | endif
  let height = float2nr(height)

  if a:0 == 0
    let cmd = &shell
    let opts = {}
  elseif a:0 == 1
    let cmd = a:1
    let opts = {}
  elseif a:0 == 2
    let cmd = a:1
    let opts = a:2
  endif

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
  call s:on_open()
  return bufnr
endfunction

function! floaterm#terminal#send(bufnr, cmd) abort
  let ch = get(s:channel_map, a:bufnr, v:null)
  if empty(ch) | return | endif
  sleep 300m
  if has('nvim')
    call chansend(ch, [a:cmd, ''])
  else
    call ch_sendraw(ch, a:cmd.(s:is_win ? "\r\n" : "\n"))
  endif
endfunction
