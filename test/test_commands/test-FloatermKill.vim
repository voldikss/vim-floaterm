" tests for :FloatermKill

function! Test_01_kill() abort
  Log '# FloatermKill'
    FloatermNew
    Assert IsInFloatermBuffer()
    FloatermKill
    AssertEqual '', &filetype

  Log '# FloatermKill!'
    FloatermNew
    let bufnr1 = bufnr('%')
    FloatermNew
    let bufnr2 = bufnr('%')

    FloatermKill!
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 0, IsBufValid(bufnr2)

  Log '# [N]FloatermKill'
    FloatermNew
    let bufnr1 = bufnr('%')
    FloatermNew
    let bufnr2 = bufnr('%')

    " otherwise vim8 testing fails
    FloatermHide
    execute bufnr1 . 'FloatermKill'
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)
    execute bufnr2 . 'FloatermKill'
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 0, IsBufValid(bufnr2)

  Log '# FloatermKill --name'
    FloatermNew --name=ft1
    let bufnr1 = bufnr('%')
    FloatermNew --name=ft2
    let bufnr2 = bufnr('%')

    FloatermKill ft1
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)
    FloatermKill ft2
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 0, IsBufValid(bufnr2)

  Log '# FloatermKill --name=xxx'
    FloatermNew --name=ft1
    let bufnr1 = bufnr('%')
    FloatermNew --name=ft2
    let bufnr2 = bufnr('%')

    FloatermKill --name=ft1
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)
    FloatermKill --name=ft2
    AssertEqual 0, IsBufValid(bufnr1)
    AssertEqual 0, IsBufValid(bufnr2)

  Log '# FloatermKill nonexistent-name'
    FloatermNew --name=ft1
    let bufnr1 = bufnr('%')
    FloatermNew --name=ft2
    let bufnr2 = bufnr('%')
    " otherwise vim8 testing fails
    FloatermHide

    FloatermKill nonexistent
    AssertEqual 1, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)
    FloatermKill --name=nonexistent
    AssertEqual 1, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)

  Log '# [N]FloatermKill with a non-floaterm buffer'
    new
    let filebufnr = bufnr('%')
    execute filebufnr . 'FloatermKill'
    AssertEqual 1, IsBufValid(bufnr1)
    AssertEqual 1, IsBufValid(bufnr2)
    execute filebufnr . 'bwipeout'

  FloatermKill!
  stopinsert
endfunction

call RunTests()
