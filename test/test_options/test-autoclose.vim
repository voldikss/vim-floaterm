" tests for g:floaterm_autoclose

function! Test_01_autoclose_never_with_normal_exit() abort
  FloatermNew --autoclose=never ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertEqual bufnr, bufnr('%')

  let g:floaterm_autoclose = 'never'
  FloatermNew ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertEqual bufnr, bufnr('%')
endfunction

function! Test_02_autoclose_smart_with_normal_exit() abort
  FloatermNew --autoclose=smart ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertNotEqual bufnr, bufnr('%')

  let g:floaterm_autoclose = 'smart'
  FloatermNew ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertNotEqual bufnr, bufnr('%')
endfunction

function! Test_03_autoclose_smart_with_abnormal_exit() abort
  FloatermNew --autoclose=smart xxx
  let bufnr = bufnr('%')
  sleep 100m
  AssertEqual bufnr, bufnr('%')

  let g:floaterm_autoclose = 'smart'
  FloatermNew xxx
  let bufnr = bufnr('%')
  sleep 100m
  AssertEqual bufnr, bufnr('%')
endfunction

function! Test_04_autoclose_always_with_abnormal_exit() abort
  FloatermNew --autoclose=always xxx
  let bufnr = bufnr('%')
  sleep 100m
  AssertNotEqual bufnr, bufnr('%')

  let g:floaterm_autoclose = 'always'
  FloatermNew xxx
  let bufnr = bufnr('%')
  sleep 100m
  AssertNotEqual bufnr, bufnr('%')
endfunction

function! Test_05_autoclose_cmdline_overrides_global() abort
  let g:floaterm_autoclose = 'never'
  FloatermNew --autoclose=smart ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertNotEqual bufnr, bufnr('%')

  let g:floaterm_autoclose = 'always'
  FloatermNew --autoclose=never ls
  let bufnr = bufnr('%')
  sleep 100m
  AssertEqual bufnr, bufnr('%')
endfunction

function! Test_06_autoclose_backward_compatibility_with_numbers() abort
  let g:floaterm_autoclose = 0
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'never', g:floaterm_autoclose

  let g:floaterm_autoclose = 1
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'smart', g:floaterm_autoclose

  let g:floaterm_autoclose = 2
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'always', g:floaterm_autoclose

  let g:floaterm_autoclose = 'always'
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'always', g:floaterm_autoclose
endfunction

call RunTests()
