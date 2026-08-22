" tests for g:floaterm_autohide
" NOTE: Vim does not support multiple popup terminals

function! Test_01_autohide_never() abort
  if !has('nvim') | return | endif
  let g:floaterm_autohide = 'never'
  Log '# FloatermNew'
    FloatermNew
    let buffer1 = bufnr('%')
    FloatermNew
    let buffer2 = bufnr('%')
    Assert BufWinExists(buffer1)
    Assert BufWinExists(buffer2)

  Log '# FloatermPrev'
    FloatermPrev
    Assert BufWinExists(buffer1)
    Assert BufWinExists(buffer2)

  Log '# FloatermNext'
    FloatermNext
    Assert BufWinExists(buffer1)
    Assert BufWinExists(buffer2)

  FloatermKill!
endfunction

function! Test_02_autohide_smart() abort
  if !has('nvim') | return | endif
  let g:floaterm_autohide = 'smart'
  Log '# Overlaied: true'
    Log '  * FloatermNew'
      FloatermNew
      let buffer1 = bufnr('%')
      FloatermNew
      let buffer2 = bufnr('%')
      Assert !BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

    Log '  * FloatermPrev'
      FloatermPrev
      Assert BufWinExists(buffer1)
      Assert !BufWinExists(buffer2)

    Log '  * FloatermNext'
      FloatermNext
      Assert !BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

  Log '# Overlaied: false'
    Log '  * FloatermNew'
      FloatermNew --position=left
      let buffer1 = bufnr('%')
      FloatermNew --position=right
      let buffer2 = bufnr('%')
      Assert BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

    Log '  * FloatermPrev'
      FloatermPrev
      Assert BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

    Log '  * FloatermNext'
      FloatermNext
      Assert BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

  FloatermKill!
endfunction

function! Test_03_autohide_always() abort
  if !has('nvim') | return | endif
  let g:floaterm_autohide = 'always'
  Log '# FloatermNew'
    FloatermNew --position=left
    let buffer1 = bufnr('%')
    FloatermNew --position=right
    let buffer2 = bufnr('%')
      Assert !BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

  Log '# FloatermPrev'
    FloatermPrev
      Assert BufWinExists(buffer1)
      Assert !BufWinExists(buffer2)

  Log '# FloatermNext'
    FloatermNext
      Assert !BufWinExists(buffer1)
      Assert BufWinExists(buffer2)

  FloatermKill!
  stopinsert
endfunction

function! Test_04_autohide_backward_compatibility_with_numbers() abort
  let g:floaterm_autohide = 0
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'never', g:floaterm_autohide

  let g:floaterm_autohide = 1
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'smart', g:floaterm_autohide

  let g:floaterm_autohide = 2
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'always', g:floaterm_autohide

  let g:floaterm_autohide = 'always'
  unlet! g:loaded_floaterm
  source plugin/floaterm.vim
  AssertEqual 'always', g:floaterm_autohide
endfunction

call RunTests()
