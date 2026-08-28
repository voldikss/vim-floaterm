" tests for the border and title drawn natively via the 'winborder' option

function! Test_01_winborder_title() abort
  if !has('nvim') || !exists('&winborder') | return | endif
  let winborder_saved = &winborder
  set winborder=single
  try
    FloatermNew
    let bufnr = bufnr('%')
    let winid = getbufvar(bufnr, 'floaterm_winid')

    " the border is drawn by neovim, no border window is created
    Assert empty(getbufvar(bufnr, 'floaterm_borderwinid'))
    let config = nvim_win_get_config(winid)
    AssertEqual 'floaterm(1/1)', config.title[0][0]
    AssertEqual 'left', config.title_pos

    " FloatermBorder highlights the native border and its title
    let winhl = getwinvar(winid, '&winhl')
    Assert winhl =~# 'FloatBorder:FloatermBorder'
    Assert winhl =~# 'FloatTitle:FloatermBorder'

    Log '# custom title and title position'
    FloatermNew --title=thistitle --titleposition=center
    let config = nvim_win_get_config(win_getid())
    AssertEqual 'thistitle', config.title[0][0]
    AssertEqual 'center', config.title_pos
  finally
    FloatermKill!
    let &winborder = winborder_saved
    stopinsert
  endtry
endfunction

call RunTests()
