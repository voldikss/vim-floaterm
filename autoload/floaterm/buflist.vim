" vim:sw=2:
" ============================================================================
" FileName: buflist.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" ----------------------------------------------------------------------------
" Node type
" ----------------------------------------------------------------------------

" @type
"   {
"     \'next': s:node,
"     \'prev': s:node,
"     \'bufnr': int
"   \}
let s:node = {}

function! s:node.new(bufnr) dict abort
  let node = deepcopy(self)
  let node.bufnr = a:bufnr
  return node
endfunction

function! s:node.to_string() dict abort
  return string(self.bufnr)
endfunction

function! s:node.is_valid() dict abort
  return bufexists(self.bufnr)
endfunction


" ----------------------------------------------------------------------------
" Linkedlist type and functions
" ----------------------------------------------------------------------------

" @type
"   {
"     \'head': s:none,
"     \'index': s:node,
"     \'size': int
"   \}
let s:buflist = {}
let s:buflist.head = s:node.new(-1)
let s:buflist.head.next = s:buflist.head
let s:buflist.head.prev = s:buflist.head
let s:buflist.index = s:buflist.head
let s:buflist.size = 0

function! s:buflist.insert(node) dict abort
  let a:node.prev = self.index
  let a:node.next = self.index.next
  let self.index.next.prev = a:node
  let self.index.next = a:node
  let self.index = a:node
  let self.size += 1
endfunction

function! s:buflist.remove(node) dict abort
  if self.empty() || a:node == self.head
    return v:false
  endif
  if bufexists(a:node.bufnr)
    execute a:node.bufnr . 'bdelete!'
  endif
  let a:node.prev.next = a:node.next
  let a:node.next.prev = a:node.prev
  let self.index = a:node.next
  let self.size -= 1
  return v:true
endfunction

function! s:buflist.empty() dict abort
  " Method 1: use self.size
  " return self.size == 0
  " Method 2: only head node
  return self.head.next == self.head
endfunction

" Find next bufnr with bufexists(bufnr) == v:true
" If not found, return -1
" If bufexists(bufnr) != v:true, remove that node
function! s:buflist.next() dict abort
  let node = self.index.next
  while !node.is_valid()
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.next
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" Find prev bufnr with bufexists(bufnr) == v:true
" If not found, return -1
" If bufexists(bufnr) != v:true, remove that node
function! s:buflist.prev() dict abort
  let node = self.index.prev
  while !node.is_valid()
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.prev
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" Find current bufnr with bufexists(bufnr) == v:true
" If not found, find next and next
" If bufexists(bufnr) != v:true, remove that node
function! s:buflist.curr() dict abort
  let node = self.index
  while !node.is_valid()
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.next
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" Find the first bufnr with bufexists(bufnr) == v:true
" If bufexists(bufnr) != v:true, remove that node
function! s:buflist.first() dict abort
  let node = self.head.next
  while !node.is_valid()
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.next
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" Find the last bufnr with bufexists(bufnr) == v:true
" If bufexists(bufnr) != v:true, remove that node
function! s:buflist.last() dict abort
  let node = self.head.prev
  while !node.is_valid()
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.prev
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" Return buflist str, note that node.bufnr may not exist
function! s:buflist.to_string() dict abort
  let str = '[-'
  let curr = self.head
  let str .= printf('(%s)', curr.to_string())
  let curr = curr.next
  while curr != self.head
    let str .= printf('--(%s)', curr.to_string())
    let curr = curr.next
  endwhile
  let str .= '-]'
  let str .= ' current floaterm buffer number: ' . self.index.bufnr
  return str
endfunction

" For source extensions(vim-clap, denite)
" Return a list containing floaterm bufnr
" Every bufnr should exist
function! s:buflist.gather() dict abort
  let candidates = []
  let curr = self.head.next
  while curr != self.head
    if curr.is_valid()
      call add(candidates, curr.bufnr)
    endif
    let curr = curr.next
  endwhile
  return candidates
endfunction


" ----------------------------------------------------------------------------
" Wrap functions to allow to be involved
" ----------------------------------------------------------------------------
function! floaterm#buflist#add(bufnr) abort
  let node = s:node.new(a:bufnr)
  call s:buflist.insert(node)
endfunction
function! floaterm#buflist#next() abort
  return s:buflist.next()
endfunction
function! floaterm#buflist#prev() abort
  return s:buflist.prev()
endfunction
function! floaterm#buflist#curr() abort
  return s:buflist.curr()
endfunction
function! floaterm#buflist#first() abort
  return s:buflist.first()
endfunction
function! floaterm#buflist#last() abort
  return s:buflist.last()
endfunction
function! floaterm#buflist#info() abort
  echom s:buflist.to_string()
endfunction
function! floaterm#buflist#gather() abort
  return s:buflist.gather()
endfunction


" ----------------------------------------------------------------------------
" UNIT TEST
" ----------------------------------------------------------------------------
function! floaterm#buflist#test() abort
  let list = deepcopy(s:buflist)
  echo list.index.bufnr
  call list.insert(s:node.new(1))
  echo list.index.bufnr
  call list.insert(s:node.new(2))
  echo list.index.bufnr
  call list.insert(s:node.new(3))
  echo list.index.bufnr
  echo list.to_string()
endfunction
" call floaterm#buflist#test()
" ----------------------------------------------------------------------------
