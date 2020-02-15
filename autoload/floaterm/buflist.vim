" ============================================================================
" FileName: buflist.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

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

" @param
"   node: type s:node
function! s:buflist.insert(node) dict abort
  let a:node.prev = self.index
  let a:node.next = self.index.next
  let self.index.next.prev = a:node
  let self.index.next = a:node
  let self.index = a:node
  let self.size += 1
endfunction

" @param
"   node: type s:node
" @todo:
"   How to delete those removed nodes?
function! s:buflist.remove(node) dict abort
  if self.empty() || a:node == self.head
    return v:false
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

" @usage:
"   Find next bufnr with bufexists(bufnr) == v:true
"   If not found, return -1
"   If bufexists(bufnr) != v:true, remove that node
function! s:buflist.find_next() dict abort
  let node = self.index.next
  while !bufexists(node.bufnr)
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.next
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" @usage:
"   Find prev bufnr with bufexists(bufnr) == v:true
"   If not found, return -1
"   If bufexists(bufnr) != v:true, remove that node
function! s:buflist.find_prev() dict abort
  let node = self.index.prev
  while !bufexists(node.bufnr)
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.prev
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" @usage:
"   Find current bufnr with bufexists(bufnr) == v:true
"   If not found, find next and next
"   If bufexists(bufnr) != v:true, remove that node
function! s:buflist.find_curr() dict abort
  let node = self.index
  while !bufexists(node.bufnr)
    call self.remove(node)
    if self.empty()
      return -1
    endif
    let node = node.next
  endwhile
  let self.index = node
  return node.bufnr
endfunction

" @usage:
"   Return buflist str, node.bufnr may not exist
function! s:buflist.to_string() dict abort
  let str = '[-'
  let curr = self.head
  let str .= curr.to_string()
  let curr = curr.next
  while curr != self.head
    let str .= '--' . curr.to_string()
    let curr = curr.next
  endwhile
  let str .= '-]'
  let str .= ' current index: ' . self.index.bufnr
  return str
endfunction

" @usage:
"   For source extensions(vim-clap, denite)
"   Return a list containing floaterm bufnr
"   Every bufnr should exist
function! s:buflist.gather() dict abort
  let candidates = []
  let curr = self.head.next
  while curr != self.head
    if bufexists(curr.bufnr)
      call add(candidates, curr.bufnr)
    endif
    let curr = curr.next
  endwhile
  return candidates
endfunction

function! floaterm#buflist#add(bufnr) abort
  let node = s:node.new(a:bufnr)
  call s:buflist.insert(node)
endfunction
function! floaterm#buflist#find_next() abort
  return s:buflist.find_next()
endfunction
function! floaterm#buflist#find_prev() abort
  return s:buflist.find_prev()
endfunction
function! floaterm#buflist#find_curr() abort
  return s:buflist.find_curr()
endfunction
function! floaterm#buflist#info() abort
  echom s:buflist.to_string()
endfunction
function! floaterm#buflist#gather() abort
  return s:buflist.gather()
endfunction


" ----------------------------------------------------------------------------
" UNIT TEST
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
