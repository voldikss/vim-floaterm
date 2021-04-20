function! floaterm#edita#neovim#util#mode(address) abort
  return a:address =~# '^\%(\%(\d\{1,3}\.\)\{3}\d\{1,3}\|localhost\)\?:\d\+'
        \ ? 'tcp'
        \ : 'pipe'
endfunction
