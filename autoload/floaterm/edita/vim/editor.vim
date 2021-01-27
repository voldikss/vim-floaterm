let s:quit_expr = "\<C-\>\<C-n>iEditaquit"

function! floaterm#edita#vim#editor#open(target, bufnr)
  call floaterm#window#hide(a:bufnr)
  execute printf('%s %s', g:floaterm_gitcommit, fnameescape(a:target))
  setlocal bufhidden=wipe
  augroup edita_buffer
    autocmd! * <buffer>
    autocmd BufDelete <buffer> call s:BufDelete()
  augroup END
  let b:edita = a:bufnr
endfunction

function! s:BufDelete() abort
  let bufnr = getbufvar(expand('<afile>'), 'edita', v:null)
  if bufnr is# v:null
    return
  endif
  silent! call term_sendkeys(bufnr, s:quit_expr)
endfunction

function! s:VimLeave() abort
  let expr = v:dying || v:exiting > 0 ? 'cquit' : 'qall'
  let editas = range(0, bufnr('$'))
  call map(editas, { -> getbufvar(v:val, 'edita', v:null) })
  call filter(editas, { -> !empty(v:val) })
  silent! call map(editas, { -> term_sendkeys(v:val, s:quit_expr) })
endfunction

augroup edita_internal
  autocmd! *
  autocmd VimLeave * call s:VimLeave()
augroup END
