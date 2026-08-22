" ============================================================================
" FileName: test/run.vim
" Entry point of the headless test runner.
"
" The test file is passed via the environment variable FLOATERM_TEST_FILE:
"
"   FLOATERM_TEST_FILE=test/test_options/test-autoclose.vim \
"     nvim --headless -u test/vimrc -c 'source test/run.vim' -c 'qa!'
"
" The working directory must be the repository root.
" ============================================================================

execute 'source' fnamemodify(expand('<sfile>'), ':h') . '/harness.vim'
let g:floaterm_test_file = fnamemodify($FLOATERM_TEST_FILE, ':t')

if empty($FLOATERM_TEST_FILE)
  echo 'FLOATERM_TEST_FILE is not set'
  cquit
endif

try
  execute 'source' $FLOATERM_TEST_FILE
catch
  echo 'FAIL error while loading ' . $FLOATERM_TEST_FILE
  echo '     ' . v:exception
  echo '     at ' . v:throwpoint
  cquit
endtry
