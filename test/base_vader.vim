" vim:ft=vim

" Seems vader.vim doesn't support relative path in `Include:`
" So I can not use `Include: ../base.vader`
" The solution is to use vim's `:source` command

function! BufWinExists(bufnr) abort
  return bufwinnr(a:bufnr) != -1
endfunction

function! IsFloatOrPopup(winid) abort
  if has('nvim')
    return has_key(nvim_win_get_config(a:winid), 'anchor')
  else
    return win_gettype(a:winid) == 'popup'
  endif
endfunction

function! IsBufValid(bufnr) abort
  return bufexists(a:bufnr) && floaterm#terminal#jobexists(a:bufnr)
endfunction

function! IsInFloatermBuffer() abort
  return &ft == 'floaterm'
endfunction
