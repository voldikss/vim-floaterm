" tests for g:floaterm_autoinsert
" NOTE: `:startinsert` takes effect only after the current command or script
" finishes, therefore `mode()` can not be asserted right after `FloatermNew!`
" within the same function. The insert-mode assertions are covered by the
" headless timer-driven tests instead. Here we assert the normal-mode cases
" (which are synchronous) and the recorded state.

function! Test_01_autoinsert_never() abort
  if !has('nvim') | return | endif
  let g:floaterm_autoinsert = 'never'
  FloatermNew! --autoclose=never sh -c 'sleep 30'
  Assert IsInFloatermBuffer()
  AssertEqual 'n', mode()

  Log '  * hide and reopen'
    FloatermHide
    Assert !IsInFloatermBuffer()
    FloatermShow
    Assert IsInFloatermBuffer()
    AssertEqual 'n', mode()
  FloatermKill!
endfunction

function! Test_02_autoinsert_smart() abort
  if !has('nvim') | return | endif
  let g:floaterm_autoinsert = 'smart'
  FloatermNew! --autoclose=never sh -c 'sleep 30'
  Assert IsInFloatermBuffer()

  Log '  * reopen with the cursor in the scrollback stays in normal mode'
    stopinsert
    call nvim_win_set_cursor(bufwinid(bufnr('%')), [1, 0])
    FloatermHide
    Assert !IsInFloatermBuffer()
    FloatermShow
    Assert IsInFloatermBuffer()
    AssertEqual 'n', mode()
  FloatermKill!
endfunction

function! Test_03_autoinsert_cmdline_option() abort
  if !has('nvim') | return | endif
  let g:floaterm_autoinsert = 'always'
  FloatermNew! --autoinsert=never --autoclose=never sh -c 'sleep 30'
  Assert IsInFloatermBuffer()
  AssertEqual 'n', mode()

  Log '  * the local config survives hide/reopen'
    FloatermHide
    FloatermShow
    Assert IsInFloatermBuffer()
    AssertEqual 'n', mode()
  FloatermKill!

  let g:floaterm_autoinsert = 'never'
  FloatermNew! --autoinsert=smart --autoclose=never sh -c 'sleep 30'
  Assert IsInFloatermBuffer()
  AssertEqual 'smart', floaterm#config#get(bufnr('%'), 'autoinsert')
  stopinsert
  FloatermKill!

  let g:floaterm_autoinsert = 'always'
  FloatermNew! --autoinsert=never --autoclose=never sh -c 'sleep 30'
  Assert IsInFloatermBuffer()
  AssertEqual 'never', floaterm#config#get(bufnr('%'), 'autoinsert')
  FloatermKill!
endfunction

function! Test_04_autoinsert_backward_compatibility_with_booleans() abort
  let g:floaterm_autoinsert = v:false
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'never', g:floaterm_autoinsert

  let g:floaterm_autoinsert = v:true
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'smart', g:floaterm_autoinsert

  unlet! g:floaterm_autoinsert
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'smart', g:floaterm_autoinsert

  let g:floaterm_autoinsert = 'always'
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'always', g:floaterm_autoinsert

  let g:floaterm_autoinsert = 'smart'
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'smart', g:floaterm_autoinsert
endfunction

function! Test_05_autoinsert_cursor_position_recorded_on_hide() abort
  if !has('nvim') | return | endif
  let g:floaterm_autoinsert = 'smart'
  FloatermNew! --autoclose=never sh -c 'sleep 30'
  let bufnr1 = bufnr('%')
  stopinsert
  call nvim_win_set_cursor(bufwinid(bufnr1), [1, 0])
  FloatermHide
  AssertEqual 1, floaterm#config#get(bufnr1, 'cursorline', -1)
  FloatermShow
  let lastline = line('$')
  call nvim_win_set_cursor(bufwinid(bufnr1), [lastline, 0])
  FloatermHide
  AssertEqual lastline, floaterm#config#get(bufnr1, 'cursorline', -1)
  FloatermShow
  stopinsert
  FloatermKill!
endfunction

call RunTests()
