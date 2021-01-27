let s:EDITOR_SAVED = exists('$EDITOR') ? $EDITOR : v:null
let s:GIT_EDITOR_SAVED = exists('$GIT_EDITOR') ? $GIT_EDITOR : v:null


function! floaterm#edita#setup#EDITOR() abort
  return has('nvim')
        \ ? floaterm#edita#neovim#client#EDITOR()
        \ : floaterm#edita#vim#client#EDITOR()
endfunction

function! floaterm#edita#setup#enable() abort
  let editor = floaterm#edita#setup#EDITOR()
  let $EDITOR = editor
  let $GIT_EDITOR = editor
endfunction

" not used 
function! floaterm#edita#setup#disable() abort
  if s:EDITOR_SAVED is# v:null
    unlet $EDITOR
  else
    let $EDITOR = s:EDITOR_SAVED
  endif
  if s:GIT_EDITOR_SAVED is# v:null
    unlet $GIT_EDITOR
  else
    let $GIT_EDITOR = s:GIT_EDITOR_SAVED
  endif
endfunction

