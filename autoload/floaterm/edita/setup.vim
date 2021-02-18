function! floaterm#edita#setup#EDITOR() abort
  return has('nvim')
        \ ? floaterm#edita#neovim#client#EDITOR()
        \ : floaterm#edita#vim#client#EDITOR()
endfunction
