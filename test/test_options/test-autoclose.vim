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

" tests for autoclose + user-supplied on_exit callback (issue #445)

function! s:on_exit_recorder(job, data, event, opener) abort
  let g:floaterm_test_on_exit_called += 1
endfunction

function! Test_07_on_exit_respects_autoclose_never() abort
  let g:floaterm_autoclose = 'smart'
  let g:floaterm_test_on_exit_called = 0
  let bufnr = floaterm#new(v:false, 'ls',
        \ {'on_exit': function('s:on_exit_recorder')}, {'autoclose': 'never'})
  sleep 500m
  Assert bufexists(bufnr)
  AssertEqual 1, g:floaterm_test_on_exit_called

  let g:floaterm_test_on_exit_called = 0
  let bufnr = floaterm#new(v:false, 'xxx',
        \ {'on_exit': function('s:on_exit_recorder')}, {'autoclose': 'never'})
  sleep 500m
  Assert bufexists(bufnr)
  AssertEqual 1, g:floaterm_test_on_exit_called
endfunction

function! Test_08_on_exit_respects_autoclose_smart() abort
  " normal exit: close
  let g:floaterm_test_on_exit_called = 0
  let bufnr = floaterm#new(v:false, 'ls',
        \ {'on_exit': function('s:on_exit_recorder')}, {'autoclose': 'smart'})
  sleep 500m
  Assert !bufexists(bufnr)
  AssertEqual 1, g:floaterm_test_on_exit_called

  " abnormal exit: stay
  let g:floaterm_test_on_exit_called = 0
  let bufnr = floaterm#new(v:false, 'xxx',
        \ {'on_exit': function('s:on_exit_recorder')}, {'autoclose': 'smart'})
  sleep 500m
  Assert bufexists(bufnr)
  AssertEqual 1, g:floaterm_test_on_exit_called
endfunction

function! Test_09_on_exit_respects_autoclose_always() abort
  let g:floaterm_test_on_exit_called = 0
  let bufnr = floaterm#new(v:false, 'xxx',
        \ {'on_exit': function('s:on_exit_recorder')}, {'autoclose': 'always'})
  sleep 500m
  Assert !bufexists(bufnr)
  AssertEqual 1, g:floaterm_test_on_exit_called
endfunction

function! Test_10_wrappers_default_autoclose_to_always() abort
  " wrappers rely on autoclose to close the picker window when it exits
  split test/vimrc
  try
    for name in ['broot', 'fff', 'fzf', 'joshuto', 'lf', 'nnn', 'ranger', 'rg', 'vifm', 'xplr', 'yazi']
      let WrapFunc = function(printf('floaterm#wrapper#%s#', name))
      let config = {}
      call WrapFunc(name, {}, config)
      AssertEqual 'always', config.autoclose

      " an explicit autoclose from the user wins over the wrapper default
      let config = {'autoclose': 'never'}
      call WrapFunc(name, {}, config)
      AssertEqual 'never', config.autoclose
    endfor
  finally
    close
  endtry
endfunction

call RunTests()
