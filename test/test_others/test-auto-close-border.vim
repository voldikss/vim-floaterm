" tests that the border window is closed along with the floaterm window

function! Test_01_auto_close_border() abort
  if !has('nvim') | return | endif
  function! BorderExists(bufnr) abort
    let bd_winid = getbufvar(a:bufnr, 'floaterm_borderwinid', -1)
    return !empty(getwininfo(bd_winid))
  endfunction

  Log '# FloatermToggle and execute `hide` only for floaterm window'
    FloatermToggle
    let bufnr = bufnr('%')
    hide
    AssertEqual 0,BorderExists(bufnr)

    FloatermToggle
    let bufnr = bufnr('%')
    hide
    AssertEqual 0,BorderExists(bufnr)

  FloatermKill!
  stopinsert
endfunction

call RunTests()
