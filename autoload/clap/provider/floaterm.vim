" vim:sw=2:
" ============================================================================
" FileName: floaterm.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:floaterm = {}
let s:preview_height = 10
let s:bar = '[bufnr]    [name]'

function! s:floaterm.source() abort
  let candidates = [s:bar]
  let bufs = floaterm#buflist#gather()
  for bufnr in bufs
    let bufinfo = getbufinfo(bufnr)[0]
    let name = bufinfo['name']
    let title = getbufvar(bufnr, 'term_title')
    let line = printf('    %s    %s    %s', bufnr, name, title)
    call add(candidates, line)
  endfor
  return candidates
endfunction

function! s:floaterm.on_move() abort
  let curline = g:clap.display.getcurline()
  if curline == s:bar
    return
  endif
  let bufnr = str2nr(matchstr(curline, '\S'))
  let lines = floaterm#util#getbufline(bufnr, s:preview_height)
  call g:clap.preview.show(lines)
endfunction

function! s:floaterm.sink(curline) abort
  if a:curline == s:bar | return | endif
  let bufnr = str2nr(matchstr(a:curline, '\S'))
  call floaterm#terminal#open_existing(bufnr)
endfunction

let g:clap#provider#floaterm# = s:floaterm
