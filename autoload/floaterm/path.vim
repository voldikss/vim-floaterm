" vim:sw=2:
" ============================================================================
" FileName: path.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" Description: This is modified from part of skywind3000/asyncrun
" ============================================================================

if has('win32') || has('win64')
  let s:is_windows = 1
else
  let s:is_windows = 0
endif

" find project root
function! s:find_root(path, markers, strict) abort
  function! s:guess_root(filename, markers) abort
    let fullname = s:fullname(a:filename)
    if fullname =~ '^fugitive:/'
      if exists('b:git_dir')
        return fnamemodify(b:git_dir, ':h')
      endif
      return '' " skip any fugitive buffers early
    endif
    let pivot = fullname
    if !isdirectory(pivot)
      let pivot = fnamemodify(pivot, ':h')
    endif
    while 1
      let prev = pivot
      for marker in a:markers
        let newname = s:path_join(pivot, marker)
        if newname =~ '[\*\?\[\]]'
          if glob(newname) != ''
            return pivot
          endif
        elseif filereadable(newname)
          return pivot
        elseif isdirectory(newname)
          return pivot
        endif
      endfor
      let pivot = fnamemodify(pivot, ':h')
      if pivot == prev
        break
      endif
    endwhile
    return ''
  endfunction
  let root = s:guess_root(a:path, a:markers)
  if root != ''
    return s:fullname(root)
  elseif a:strict != 0
    return ''
  endif
  " Not found: return parent directory of current file / file itself.
  let fullname = s:fullname(a:path)
  if isdirectory(fullname)
    return fullname
  endif
  return s:fullname(fnamemodify(fullname, ':h'))
endfunction

" Replace string
function! s:string_replace(text, old, new) abort
  let l:data = split(a:text, a:old, 1)
  return join(l:data, a:new)
endfunction

function! s:fullname(f) abort
  let f = a:f
  if f =~ "'."
    try
      redir => m
      silent exe ':marks' f[1]
      redir END
      let f = split(split(m, '\n')[-1])[-1]
      let f = filereadable(f)? f : ''
    catch
      let f = '%'
    endtry
  endif
  let f = (f != '%')? f : expand('%')
  let f = fnamemodify(f, ':p')
  if s:is_windows
    let f = substitute(f, "\\", '/', 'g')
  endif
  if len(f) > 1
    let size = len(f)
    if f[size - 1] == '/'
      let f = strpart(f, 0, size - 1)
    endif
  endif
  return f
endfunction

function! s:path_join(home, name) abort
  let l:size = strlen(a:home)
  if l:size == 0 | return a:name | endif
  let l:last = strpart(a:home, l:size - 1, 1)
  if has("win32") || has("win64") || has("win16") || has('win95')
    let l:first = strpart(a:name, 0, 1)
    if l:first == "/" || l:first == "\\"
      let head = strpart(a:home, 1, 2)
      if index([":\\", ":/"], head) >= 0
        return strpart(a:home, 0, 2) . a:name
      endif
      return a:name
    elseif index([":\\", ":/"], strpart(a:name, 1, 2)) >= 0
      return a:name
    endif
    if l:last == "/" || l:last == "\\"
      return a:home . a:name
    else
      return a:home . '/' . a:name
    endif
  else
    if strpart(a:name, 0, 1) == '/'
      return a:name
    endif
    if l:last == "/"
      return a:home . a:name
    else
      return a:home . '/' . a:name
    endif
  endif
endfunction

function! floaterm#path#get_root(path=getcwd()) abort
  let strict = 0
  let l:hr = s:find_root(a:path, g:floaterm_rootmarkers, strict)
  if s:is_windows
    let l:hr = s:string_replace(l:hr, '/', "\\")
  endif
  return l:hr
endfunction

function! floaterm#path#chdir(path) abort
  let l:cd = { 0: 'cd', 1: 'lcd', 2: 'tcd' }[haslocaldir()]
  silent execute l:cd . ' ' . fnameescape(a:path)
endfunction
