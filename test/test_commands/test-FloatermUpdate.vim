" tests for :FloatermUpdate

function! Test_01_update() abort
  Log '# Basic'
    FloatermNew
    FloatermUpdate --name=ft
    AssertEqual 'ft', b:floaterm_name

  FloatermKill!
  stopinsert
endfunction

function! Test_02_update_all() abort
  Log '# FloatermUpdate! applies to every floaterm (#428)'
    FloatermNew --name=ft1
    FloatermNew --name=ft2
    " hide both so the bang path manages reopening on its own
    FloatermHide!
    FloatermUpdate! --width=0.8 --height=0.8

    let buffers = floaterm#buflist#gather()
    AssertEqual 2, len(buffers)
    for bufnr in buffers
      AssertEqual 0.8, floaterm#config#get(bufnr, 'width', 0)
      AssertEqual 0.8, floaterm#config#get(bufnr, 'height', 0)
    endfor

  FloatermKill!
  stopinsert
endfunction

call RunTests()
