" vim:sw=2:
" ============================================================================
" FileName: floaterm.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h')

function! s:check_common() abort
  call health#start('common')
  call health#info('Platform: ' . s:get_platform_info())
  call health#info('Nvim: ' . s:get_nvim_info())
  call health#info('Plugin: ' . s:get_plugin_info())
endfunction

function! s:check_terminal() abort
  call health#start('terminal')
  if exists(':terminal') > 0
    call health#ok('Terminal emulator is available')
  else
    call health#error(
          \ 'Terminal emulator is missing',
          \ ['Install the latest version neovim']
          \ )
  endif
endfunction

function! s:check_floating() abort
  call health#start('floating')
  if exists('*nvim_win_set_config')
    call health#ok('Floating window is available')
  else
    call health#warn(
          \ 'Floating window is missing, will fallback to use normal window',
          \ ['Install the latest version neovim']
          \ )
  endif
endfunction

function! health#floaterm#check() abort
  call s:check_common()
  call s:check_terminal()
  call s:check_floating()
endfunction


function! s:get_nvim_info() abort
  return split(execute('version'), "\n")[0]
endfunction

function! s:get_platform_info() abort
  if has('win32') || has('win64')
    return 'win'
  elseif has('mac') || has('macvim')
    return 'macos'
  endif
  return 'linux'
endfunction

function! s:get_plugin_info() abort
  let save_cwd = getcwd()
  silent! execute 'cd ' . s:home
  let result = system('git rev-parse --short HEAD')
  silent! execute 'cd ' . save_cwd
  return result
endfunction
