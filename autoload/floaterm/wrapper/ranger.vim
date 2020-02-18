" ============================================================================
" FileName: ranger.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! floaterm#wrapper#ranger#parse() abort
  return ['floaterm $(fzf)', {}]
endfunction

let s:ranger_tempfile = tempname()
let opts = ' --cmd="set viewmode '. g:neoranger_viewmode .'"'
let opts .= ' --choosefiles=' . shellescape(s:ranger_tempfile)
if a:0 > 1
  let opts .= ' --selectfile='. shellescape(a:2)
else
  let opts .= ' ' . shellescape(path)
endif

if exists('g:neoranger_opts')
  let opts .= ' ' . g:neoranger_opts
endif

