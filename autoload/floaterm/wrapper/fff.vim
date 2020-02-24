" ============================================================================
" FileName: fff.vim
" Author: benwoodward <ben@terminalcoder.dev>
" GitHub: https://github.com/benwoodward
" ============================================================================

function! floaterm#wrapper#fff#() abort
  let cmd = 'fff -p ' . $PWD
  return [cmd, {'on_exit': funcref('s:fff_callback')}, v:false]
endfunction

function! s:fff_callback(...) abort
    let tmp_file = $XDG_CACHE_HOME

    if !isdirectory(tmp_file)
        let tmp_file = $HOME . "/.cache"
    endif

    let tmp_file .= "/fff/opened_file"
    let tmp_file = fnameescape(tmp_file)

    if filereadable(tmp_file)
        bd!
        let file_data = readfile(tmp_file)
        execute delete(tmp_file)
    else
        return
    endif

    if filereadable(file_data[0])
        execute "e " . file_data[0]
    endif
endfunction
