function! floaterm#edita#neovim#editor#open(target, client)
  let bufnr = floaterm#buflist#curr()
  call floaterm#window#hide(bufnr)
  let opener = floaterm#config#get(bufnr, 'opener', g:floaterm_opener)
  call floaterm#util#open([{'filename': fnameescape(a:target)}], opener)
  let mode = floaterm#edita#neovim#util#mode(a:client)
  let b:edita = sockconnect(mode, a:client, { 'rpc': 1 })
  if index(['gitcommit', 'gitrebase'], &ft) > -1
    setlocal bufhidden=wipe
    augroup edita_buffer
      autocmd! * <buffer>
      autocmd BufDelete <buffer> call s:BufDelete()
    augroup END
  else
    call timer_start(100, {->s:BufDelete()})
  endif
endfunction

function! s:BufDelete() abort
  let ch = getbufvar(expand('<afile>'), 'edita', v:null)
  if ch is# v:null
    return
  endif
  silent! call rpcrequest(ch, 'nvim_command', 'qall')
  call setbufvar(expand('<afile>'), 'edita', v:null)
endfunction

function! s:VimLeave() abort
  let expr = v:dying || v:exiting > 0 ? 'cquit' : 'qall'
  let editas = range(0, bufnr('$'))
  call map(editas, { -> getbufvar(v:val, 'edita', v:null) })
  call filter(editas, { -> !empty(v:val) })
  silent! call map(editas, { -> rpcrequest(v:val, 'nvim_command', expr) })
  " If COMMIT_EDITMSG buffer exists, suspend for the git commiting
  if len(editas) > 0
    sleep 10m
  endif
endfunction

augroup edita_internal
  autocmd! *
  autocmd VimLeave * call s:VimLeave()
augroup END
