" vim:sw=2:
" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:check_terminal() abort
  if exists(':terminal') > 0
    call health#report_ok('Terminal feature is OK')
  else
    call health#report_error('Terminal feature is required but not found')
  endif
endfunction

function! s:check_floating() abort
  if has('nvim') && exists('*nvim_win_set_config')
    call health#report_ok('Floating window feature is OK')
  else
    call health#report_error('Floating window feature is required but not found, will use normal window')
  endif
endfunction

function! s:check_nvr() abort
  if executable('nvr')
    call health#report_ok('nvr is OK')
  else
    call health#report_error('nvr executable is not found, run `pip3 install neovim-remote` to install')
  endif
endfunction

function! health#floaterm#check() abort
  call s:check_terminal()
  call s:check_floating()
  call s:check_nvr()
endfunction
