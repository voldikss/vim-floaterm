" vim:sw=2:
" ============================================================================
" FileName: autoload/floaterm/edita/util.vim
" Description: Shared helpers for the `floaterm` editor integration.
" ============================================================================

" Filenames for which the terminal should stay open until the edited buffer is
" closed, instead of quitting the editor immediately. Values are |regular
" expressions| matched against the buffer's basename.
let s:wait_filename_patterns = [
      \ '^COMMIT_EDITMSG$',
      \ '^MERGE_MSG$',
      \ '^git-rebase-todo$',
      \ '^git-revise-todo$',
      \ '^addp-hunk-edit\.diff$',
      \ 'commit\.hg\.txt',
      \ '^\.jjdescription$',
      \ ]

" Returns |v:true| when editing `a:filename` (a basename) should keep the
" originating terminal waiting until the buffer is closed.
function! floaterm#edita#util#should_wait(filename) abort
  for pattern in s:wait_filename_patterns
    if a:filename =~# pattern
      return v:true
    endif
  endfor
  return v:false
endfunction
