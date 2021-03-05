" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

augroup floaterm_enter_insertmode
  autocmd! * <buffer>
  autocmd! User FloatermOpen
  autocmd User FloatermOpen call floaterm#util#startinsert()
  autocmd BufEnter <buffer> call floaterm#util#startinsert()
  autocmd BufHidden,BufWipeout <buffer> call floaterm#window#hide(expand('<abuf>'))
  " autocmd BufHidden,BufWipeout <buffer> echom expand('<abuf>')
  if floaterm#config#get(bufnr('%'), 'disposable')
    autocmd BufHidden <buffer> call floaterm#terminal#kill(expand('<abuf>'))
  endif
augroup END
