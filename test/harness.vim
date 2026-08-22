" ============================================================================
" FileName: test/harness.vim
" Minimal test harness for vim-floaterm, replacing vader.vim.
"
" A test file:
"   - defines global functions named Test_NN_description() where NN is a
"     numeric prefix defining the execution order (functions are discovered
"     via `:function /^Test_[0-9]` and sorted alphabetically)
"   - ends with `call RunTests()`
"
" Available commands (same semantics as vader):
"   Assert {expr} [, {message}]
"   AssertEqual {expected}, {actual}
"   AssertNotEqual {unexpected}, {actual}
"   Log {expr}
"
" Available helpers (from the old test/base_vader.vim):
"   BufWinExists(), IsFloatOrPopup(), IsBufValid(), IsInFloatermBuffer()
" ============================================================================

if exists('g:loaded_floaterm_test_harness')
  finish
endif
let g:loaded_floaterm_test_harness = 1

let g:floaterm_test_log = []

function! s:assert(cond, ...) abort
  if !a:cond
    throw printf('Assertion failed: %s', a:0 > 0 ? string(a:1) : 'condition is false')
  endif
endfunction

function! s:assert_equal(expected, actual) abort
  if type(a:expected) != type(a:actual) || a:expected !=# a:actual
    throw printf('Assertion failed: expected %s but got %s',
          \ string(a:expected), string(a:actual))
  endif
endfunction

function! s:assert_not_equal(unexpected, actual) abort
  if type(a:unexpected) == type(a:actual) && a:unexpected ==# a:actual
    throw printf('Assertion failed: did not expect %s',
          \ string(a:unexpected))
  endif
endfunction

command! -nargs=+ Assert       call s:assert(<args>)
command! -nargs=+ AssertEqual  call s:assert_equal(<args>)
command! -nargs=+ AssertNotEqual call s:assert_not_equal(<args>)
command! -nargs=+ Log          call add(g:floaterm_test_log, string(<args>))

" ----------------------------------------------------------------------------
" helpers ported from test/base_vader.vim
" ----------------------------------------------------------------------------
function! BufWinExists(bufnr) abort
  return bufwinnr(a:bufnr) != -1
endfunction

function! IsFloatOrPopup(winid) abort
  if has('nvim')
    return has_key(nvim_win_get_config(a:winid), 'anchor')
  else
    return win_gettype(a:winid) == 'popup'
  endif
endfunction

function! IsBufValid(bufnr) abort
  return bufexists(a:bufnr) && floaterm#terminal#jobexists(a:bufnr)
endfunction

function! IsInFloatermBuffer() abort
  return &filetype == 'floaterm'
endfunction

" ----------------------------------------------------------------------------
" runner
" ----------------------------------------------------------------------------
" Extract the position of interest from v:throwpoint: the last frame, unless
" it is an assertion helper inside this harness, in which case the caller
" (i.e. the test function and the line of the failing assertion)
function! s:throwpoint_location() abort
  let frames = split(v:throwpoint, '\.\.')
  if empty(frames)
    return v:throwpoint
  endif
  let last = frames[-1]
  if last =~# '^<SNR>' && len(frames) >= 2
    let last = frames[-2]
  endif
  return last
endfunction

function! RunTests() abort
  let test_file = exists('g:floaterm_test_file') ?
        \ g:floaterm_test_file : fnamemodify(expand('<sfile>'), ':t')
  redir => s:func_output
  silent function /^Test_[0-9]
  redir END
  let tests = []
  for line in split(s:func_output, '\n')
    let name = matchstr(line, '^function \zs\S\+\ze(')
    if !empty(name)
      call add(tests, name)
    endif
  endfor
  " `:function` lists functions in an unspecified order, sort to make the
  " execution deterministic (numeric prefixes in test names keep the intended
  " order)
  call sort(tests)
  if empty(tests)
    echo "SKIP no tests found in '" . test_file . "'"
    return
  endif

  let output = []
  let failed = 0
  for name in tests
    let g:floaterm_test_log = []
    try
      execute 'call ' . name . '()'
      call add(output, 'PASS ' . name)
    catch
      let failed += 1
      call add(output, 'FAIL ' . name)
      call add(output, '     ' . v:exception)
      call add(output, '     at ' . s:throwpoint_location())
      for entry in g:floaterm_test_log
        call add(output, '     log: ' . entry)
      endfor
    endtry
  endfor
  echo join(output, "\n")
  if failed > 0
    echo printf('%d/%d tests failed in %s', failed, len(tests), test_file)
    cquit
  endif
  echo printf('%d tests passed in %s', len(tests), test_file)
endfunction
