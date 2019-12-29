" ============================================================================
" FileName: floaterm.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:floaterm = {}

let s:preview_height = 10

let s:bar = '[bufnr]    [name]'


function! s:floaterm.source() abort
  if !exists('g:floaterm')
    return []
  endif

  let lst = [s:bar]
  let bufs = g:floaterm.gather()
  for bufnr in bufs
    let bufinfo = getbufinfo(bufnr)[0]
    let name = bufinfo['name']
    let title = getbufvar(bufnr, 'term_title')
    let line = '   ' . string(bufnr) . '    ' . name . '    ' . title
    call add(lst, line)
  endfor
  return lst
endfunction

function! s:floaterm.on_move() abort
  let curline = g:clap.display.getcurline()
  if curline == s:bar
    return
  endif

  let bufnr = str2nr(matchstr(curline, '\S'))
  let lnum = getbufinfo(bufnr)[0]['lnum']
  let lines = getbufline(bufnr, max([lnum-s:preview_height, 0]), '$')
  let lines = lines[max([len(lines)-s:preview_height, 0]):]
  call g:clap.preview.show(lines)
endfunction

function! s:floaterm.sink(curline) abort
  if a:curline == s:bar | return | endif
  call g:floaterm.jump(str2nr(matchstr(a:curline, '\S')))
endfunction

let s:floaterm.on_enter = { -> g:clap.display.setbufvar('&syntax', 'clap_floaterm') }

let g:clap#provider#floaterm# = s:floaterm

let &cpoptions = s:save_cpo
unlet s:save_cpo
