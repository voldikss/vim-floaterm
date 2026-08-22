" tests for :FloatermUpdate

function! Test_01_update() abort
  Log '# Basic'
    FloatermNew
    FloatermUpdate --name=ft
    AssertEqual 'ft', b:floaterm_name

  FloatermKill!
  stopinsert
endfunction

function! Test_02_dynamic_title() abort
  function! GetTitleTopline() abort
    if has('nvim')
      let bd_winid = getbufvar(bufnr('%'), 'floaterm_borderwinid')
      return getbufline(winbufnr(bd_winid), 1)[0]
    else
      return popup_getoptions(win_getid()).title
    endif
  endfunction

  let g:floaterm_title = 'floaterm ($1/$2)'

  Log '# update the title of the current (visible) floaterm'
    FloatermNew
    Assert GetTitleTopline() =~ 'floaterm (1/1)'
    FloatermUpdate --title=updated-title
    Assert GetTitleTopline() =~ 'updated-title'

  Log '# updating a hidden floaterm by name does not show it, and the new'
  Log '# title is applied the next time it is shown'
    FloatermNew --name=hidden-term
    FloatermHide
    Assert !floaterm#window#is_open(floaterm#terminal#get_bufnr('hidden-term'))
    FloatermUpdate --title=hidden-title hidden-term
    Assert !floaterm#window#is_open(floaterm#terminal#get_bufnr('hidden-term'))
    FloatermShow hidden-term
    Assert GetTitleTopline() =~ 'hidden-title'

  Log '# updating a floaterm that is already visible refreshes its title'
  Log '# immediately, without needing to hide/show it manually first'
    FloatermShow hidden-term
    Assert floaterm#window#is_open(floaterm#terminal#get_bufnr('hidden-term'))
    FloatermUpdate --title=other-title hidden-term
    Assert GetTitleTopline() =~ 'other-title'

  Log '# unknown floaterm name reports an error instead of throwing'
    let v:errmsg = ''
    redir => messages_before
    silent messages
    redir END
    FloatermUpdate --title=nope no-such-term
    redir => messages_after
    silent messages
    redir END
    Assert messages_after !=# messages_before
    Assert messages_after =~ 'No floaterm found with name: no-such-term'

  FloatermKill!
  stopinsert
endfunction

call RunTests()
