" ============================================================================
" FileName: autocmd/floaterm.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" `hidden` option must be set, otherwise the floating terminal would be wiped
" out, see #17
set hidden

" Note:
" The data structure of the floaterm chain is a double circular linkedlist
" g:floaterm.count is the count of the terminal node
" g:floaterm.index is the pointer
" g:floaterm.head is the HEAD node which only have 'prev' and 'next'
" g:floaterm_node is the node prototype to create a terminal node
let g:floaterm = {}
let g:floaterm.count = 0
let g:floaterm.head = {}
let g:floaterm.head.next = g:floaterm.head
let g:floaterm.head.prev = g:floaterm.head
let g:floaterm.index = g:floaterm.head

let g:floaterm_node = {
  \ 'bufnr': 0,
  \ 'border_bufnr': 0,
  \ 'next': v:null,
  \ 'prev': v:null
  \ }

if g:floaterm_border_color == v:null
  let g:floaterm_border_color = floaterm#util#get_normalfloat_fg()
endif

if g:floaterm_background == v:null
  let g:floaterm_background = floaterm#util#get_normalfloat_bg()
endif

if g:floaterm_border_bgcolor == v:null
  let g:floaterm_border_bgcolor = g:floaterm_background
endif

" Remove a node if it was closed(the buffer doesn't exist)
function! g:floaterm.kickout() dict abort
  if self.count == 0 | return | endif
  let self.index.prev.next = self.index.next
  let self.index.next.prev = self.index.prev
  let self.count -= 1
endfunction

function! g:floaterm.toggle() dict abort
  let found_winnr = self.find_term_win()
  if found_winnr > 0
    if &buftype ==# 'terminal'
      execute found_winnr . ' wincmd q'
    else
      execute found_winnr . ' wincmd w | startinsert'
    endif
  else
    while v:true
      if self.count == 0
        call self.open(0)
        return
      endif
      " If the current node is HEAD(which doesn't have 'bufnr' key),
      " skip and point to the node after HEAD
      if self.index == self.head
        let self.index = self.head.next
      endif
      let found_bufnr = self.index.bufnr
      if found_bufnr != 0 && bufexists(found_bufnr)
        call self.open(found_bufnr)
        return
      else
        call self.kickout()
        let self.index = self.index.next
      endif
    endwhile
  endif
endfunction

function! g:floaterm.new() dict abort
  call self.hide()
  call self.open(0)
endfunction

function! g:floaterm.next() dict abort
  call self.hide()
  while v:true
    if self.count == 0
      call floaterm#util#show_msg('No more terminal buffers', 'warning')
      return
    endif
    " If the current node is the end node(whose next node is HEAD),
    " skip and point to the HEAD's next node
    if self.index.next == self.head
      let self.index = self.head.next
    else
      let self.index = self.index.next
    endif
    let next_bufnr = self.index.bufnr
    if next_bufnr != 0 && bufexists(next_bufnr)
      call self.open(next_bufnr)
      return
    else
      call self.kickout()
    endif
  endwhile
endfunction

function! g:floaterm.prev() dict abort
  call self.hide()
  while v:true
    if self.count == 0
      call floaterm#util#show_msg('No more terminal buffers', 'warning')
      return
    endif
    " If the current node is the node after HEAD(whose previous node is HEAD),
    " skip and point to the HEAD's prev node(the end node)
    if self.index.prev == self.head
      let self.index = self.head.prev
    else
      let self.index = self.index.prev
    endif
    let prev_bufnr = self.index.bufnr
    if prev_bufnr != 0 && bufexists(prev_bufnr)
      call self.open(prev_bufnr)
      return
    else
      call self.kickout()
    endif
  endwhile
endfunction

" Hide the current terminal before opening another terminal window
" Therefore, you cannot have two terminals displayed at once
function! g:floaterm.hide() dict abort
  while v:true
    let found_winnr = self.find_term_win()
    if found_winnr > 0
      execute found_winnr . ' wincmd q'
    else
      break
    endif
  endwhile
endfunction

" Gather active floaterm for vim-clap
function! g:floaterm.gather() dict abort
  let lst = []
  let self.index = self.head.next
  while self.index != self.head
    let bufnr = self.index.bufnr
    if bufnr != 0 && bufexists(bufnr)
      call add(lst, bufnr)
    else
      call self.kickout()
    endif
    let self.index = self.index.next
  endwhile
  return lst
endfunction

" Jump to terminal buffer bufnr, for vim-clap
function! g:floaterm.jump(bufnr) dict abort
  let self.index = self.head.next
  while self.index != self.head
    if a:bufnr == self.index.bufnr
      call self.open(a:bufnr)
      return
    endif
    let self.index = self.index.next
  endwhile
endfunction

" Find if there is a terminal among all opened windows
" If found, hide it or jump into it
function! g:floaterm.find_term_win() abort
  let found_winnr = 0
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&filetype') ==# 'floaterm'
      let found_winnr = winnr
    endif
  endfor
  return found_winnr
endfunction

function! g:floaterm.open(found_bufnr) dict abort
  let height = g:floaterm_height == v:null ? 0.6 : g:floaterm_height
  if type(height) == v:t_float | let height = height * &lines | endif
  let height = float2nr(height)

  let width = g:floaterm_width == v:null ? 0.6 : g:floaterm_width
  if type(width) == v:t_float | let width = width * &columns | endif
  let width = float2nr(width)

  if g:floaterm_type ==# 'floating'
    let [bufnr, border_bufnr] = s:open_floating_terminal(a:found_bufnr, height, width)
  else
    let bufnr = s:open_normaml_terminal(a:found_bufnr, height, width)
    let border_bufnr = 0
  endif
  if bufnr != 0
    " Build a terminal node
    let node = deepcopy(g:floaterm_node)
    let node.bufnr = bufnr
    let node.prev = self.index
    let node.next = self.index.next
    " If current node is the end node, let HEAD's prev point to the new node
    if self.index.next == self.head
      let self.head.prev = node
    endif
    let self.index.next = node
    let self.index = self.index.next
    let self.count += 1
  endif
  if border_bufnr != 0
    let self.index.border_bufnr = border_bufnr
  endif
  call s:on_open()
endfunction

function! s:on_open() abort
  setlocal cursorline
  setlocal filetype=floaterm

  " Find the true background(not 'hi link') for floating
  if has('nvim')
    execute 'setlocal winblend=' . g:floaterm_winblend
    execute 'hi FloatTermNormal term=NONE guibg='. g:floaterm_background
    setlocal winhighlight=NormalFloat:FloatTermNormal,FoldColumn:FloatTermNormal

    augroup close_floaterm_window
      autocmd!
      autocmd TermClose <buffer> bdelete!
      autocmd BufHidden <buffer> call s:hide_border()
    augroup END
  endif

  startinsert
endfunction

function! s:hide_border(...) abort
  if exists('g:floaterm.index.border_bufnr')
    \ && bufexists(g:floaterm.index.border_bufnr)
    \ && g:floaterm.index.border_bufnr != 0
    execute 'bw ' . g:floaterm.index.border_bufnr
  endif
endfunction

function! s:open_floating_terminal(found_bufnr, height, width) abort
  let [row, col, vert, hor] = floaterm#util#floating_win_pos(a:width, a:height)

  let border_opts = {
    \ 'relative': 'editor',
    \ 'anchor': vert . hor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:width + 2,
    \ 'height': a:height + 2,
    \ 'style':'minimal'
    \ }
  let top = g:floaterm_borderchars[4] .
          \ repeat(g:floaterm_borderchars[0], a:width) .
          \ g:floaterm_borderchars[5]
  let mid = g:floaterm_borderchars[3] .
          \ repeat(' ', a:width) .
          \ g:floaterm_borderchars[1]
  let bot = g:floaterm_borderchars[7] .
          \ repeat(g:floaterm_borderchars[2], a:width) .
          \ g:floaterm_borderchars[6]
  let lines = [top] + repeat([mid], a:height) + [bot]
  let border_bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_option(border_bufnr, 'synmaxcol', 3000) " #27
  call nvim_buf_set_lines(border_bufnr, 0, -1, v:true, lines)
  call nvim_open_win(border_bufnr, v:false, border_opts)
  " Floating window border highlight
  augroup floaterm_border_highlight
    autocmd!
    autocmd FileType floaterm_border ++once execute printf(
      \ 'syn match Border /.*/ | hi Border guibg=%s guifg=%s',
      \ g:floaterm_border_bgcolor,
      \ g:floaterm_border_color
      \ )
  augroup END
  call nvim_buf_set_option(border_bufnr, 'filetype', 'floaterm_border')

  ""
  " TODO:
  " Use 'relative': 'cursor' for the border window
  " Use 'relative':'win'(which behaviors not as expected...) for content window
  let opts = {
    \ 'relative': 'editor',
    \ 'anchor': vert . hor,
    \ 'row': row + (vert ==# 'N' ? 1 : -1),
    \ 'col': col + (hor ==# 'W' ? 1 : -1),
    \ 'width': a:width,
    \ 'height': a:height,
    \ 'style':'minimal'
    \ }

  if a:found_bufnr > 0
    call nvim_open_win(a:found_bufnr, v:true, opts)
    return [0, border_bufnr]
  else
    let bufnr = nvim_create_buf(v:false, v:true)
    call nvim_open_win(bufnr, v:true, opts)
    let opts = {'on_exit': function('s:hide_border')}
    call termopen(&shell, opts)
    return [bufnr, border_bufnr]
  endif
endfunction

function! s:open_normaml_terminal(found_bufnr, height, width) abort
  if a:found_bufnr > 0
    if &lines > 30
      execute 'botright ' . a:height . 'split'
      execute 'buffer ' . a:found_bufnr
    else
      botright split
      execute 'buffer ' . a:found_bufnr
    endif
    return
  else
    if &lines > 30
      if has('nvim')
        execute 'botright ' . a:height . 'split term://' . &shell
      else
        botright terminal
        resize a:height
      endif
    else
      if has('nvim')
        execute 'botright split term://' . &shell
      else
        botright terminal
      endif
    endif
    return bufnr('%')
  endif
endfunction

function! floaterm#start(action) abort
  if !floaterm#util#is_floaterm_available()
    return
  endif

  if a:action ==# 'new'
    call g:floaterm.new()
  elseif a:action ==# 'next'
    call g:floaterm.next()
  elseif a:action ==# 'prev'
    call g:floaterm.prev()
  elseif a:action ==# 'toggle'
    call g:floaterm.toggle()
  endif
endfunction
