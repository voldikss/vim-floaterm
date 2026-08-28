" tests for the automatic resizing of visible floaterms on |VimResized| (#296)

function! Test_01_resize_float() abort
  if !has('nvim') | return | endif
  let g:floaterm_width = 0.5
  let g:floaterm_height = 0.5
  let columns_saved = &columns
  let lines_saved = &lines
  try
    FloatermNew
    let bufnr = bufnr('%')
    let winid = getbufvar(bufnr, 'floaterm_winid')

    let &columns = &columns / 2
    let &lines = &lines / 2
    " the editor fires VimResized itself when it has a UI
    doautocmd VimResized

    " 'center' position: the window keeps its relative size and position
    let width = float2nr(0.5 * &columns)
    let height = float2nr(0.5 * (&lines - &cmdheight - 1))
    AssertEqual width - 2, nvim_win_get_width(winid)
    AssertEqual height - 2, nvim_win_get_height(winid)
    let config = nvim_win_get_config(winid)
    AssertEqual (&columns - width) / 2 + 1, float2nr(config.col)
    AssertEqual (&lines - height) / 2 + 1, float2nr(config.row)

    " the hand-drawn border frame is rebuilt at the new size
    let bd_winid = getbufvar(bufnr, 'floaterm_borderwinid', -1)
    if !empty(getwininfo(bd_winid))
      AssertEqual width, nvim_win_get_width(bd_winid)
      AssertEqual height, nvim_win_get_height(bd_winid)
    endif
  finally
    FloatermKill!
    let &columns = columns_saved
    let &lines = lines_saved
    stopinsert
  endtry
endfunction

function! Test_02_resize_split() abort
  let g:floaterm_height = 0.5
  let lines_saved = &lines
  try
    FloatermNew --wintype=split
    let &lines = &lines / 2
    doautocmd VimResized

    let height = float2nr(0.5 * (&lines - &cmdheight - 1))
    AssertEqual height, winheight(0)
  finally
    FloatermKill!
    let &lines = lines_saved
    stopinsert
  endtry
endfunction

call RunTests()
