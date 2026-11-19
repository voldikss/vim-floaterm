" tests for the automatic resizing of visible floaterms on |VimResized| (#296)

function! Test_00_resize_handler_lifecycle() abort
  Assert !exists('#floaterm_vimresized#VimResized')
  Assert !exists('*floaterm#window#on_vimresized')
  let autohide_saved = g:floaterm_autohide
  try
    let g:floaterm_autohide = 'never'
    FloatermNew --position=topleft
    let first = bufnr('%')
    Assert exists('#floaterm_vimresized#VimResized')
    FloatermNew --position=bottomright
    let second = bufnr('%')
    call floaterm#window#schedule_resize()
    call floaterm#window#hide(first)
    Assert exists('#floaterm_vimresized#VimResized')
    call floaterm#window#hide(second)
    Assert !exists('#floaterm_vimresized#VimResized')
    Assert empty(filter(timer_info(), "string(v:val.callback) =~# 'resize_after_event'"))
    FloatermShow
    Assert exists('#floaterm_vimresized#VimResized')
  finally
    FloatermKill!
    let g:floaterm_autohide = autohide_saved
    stopinsert
  endtry
  Assert !exists('#floaterm_vimresized#VimResized')
endfunction

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
    let original_width = nvim_win_get_width(winid)

    let &columns = &columns / 2
    let &lines = &lines / 2
    " the editor fires VimResized itself when it has a UI
    doautocmd VimResized
    doautocmd VimResized
    AssertEqual original_width, nvim_win_get_width(winid)
    sleep 20m

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
    sleep 20m

    let height = float2nr(0.5 * (&lines - &cmdheight - 1))
    AssertEqual height, winheight(0)
  finally
    FloatermKill!
    let &lines = lines_saved
    stopinsert
  endtry
endfunction

function! Test_03_resize_popup() abort
  if has('nvim') | return | endif
  let g:floaterm_width = 0.5
  let g:floaterm_height = 0.5
  let columns_saved = &columns
  let lines_saved = &lines
  try
    FloatermNew
    let winid = getbufvar(bufnr('%'), 'floaterm_winid')
    let &columns = &columns / 2
    let &lines = &lines / 2
    doautocmd VimResized
    sleep 20m

    let options = popup_getoptions(winid)
    AssertEqual float2nr(0.5 * &columns) - 2, options.minwidth
    AssertEqual float2nr(0.5 * (&lines - &cmdheight - 1)) - 2, options.minheight
  finally
    FloatermKill!
    let &columns = columns_saved
    let &lines = lines_saved
    stopinsert
  endtry
endfunction

call RunTests()
