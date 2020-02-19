# vim-floaterm

![CI](https://github.com/voldikss/vim-floaterm/workflows/CI/badge.svg)

【[Introduction in Chinese|中文文档](https://zhuanlan.zhihu.com/p/107749687)】

Use neovim terminal in the floating window.

![](https://user-images.githubusercontent.com/20282795/74799912-de268200-530c-11ea-9831-d412a7700505.png)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Global variables](#global-variables)
  - [Commands](#commands)
  - [Keymaps](#keymaps)
  - [Change highlight](#change-highlight)
- [More use cases and demos](#more-use-cases-and-demos)
  - [Use as a Fzf plugin](#use-as-a-fzf-plugin)
  - [Use as a Ranger plugin](#use-as-a-ranger-plugin)
  - [Use as a Python REPL plugin](#use-as-a-python-repl-plugin)
  - [Use with other command line tools](#use-with-other-command-line-tools)
  - [Integrate with vim-clap](#integrate-with-vim-clap)
  - [Integrate with denite](#integrate-with-denite)
- [How to define more wrappers](#how-to-define-more-wrappers)
- [F.A.Q](#f.a.q)
- [Credits](#credits)
- [License](#license)

## Features

- Floating window support
- Open and toggle terminal window quickly
- Multiple terminal instances
- Customizable floating terminal style
- Switch/Preview floating terminal buffers using [vim-clap](https://github.com/liuchengxu/vim-clap)
- Switch/Preview/Open floating terminal buffers using [denite.nvim](https://github.com/Shougo/denite.nvim)
- Integrate with other external command-line tools(ranger, fzf, etc.)

## Requirements

- Vim or NeoVim with `terminal` feature

- NeoVim supporting `floating window` is better, but not necessary

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm')
```

## Usage

Use `:FloatermNew` command to open a terminal window, `:FloatermToggle` to hide/reopen that. The filetype of the terminal buffer is set to `floaterm`.

Generally just one floaterm instance is enough. If you've opened more than one floaterm instances, they are attached to a double-circular-linkedlist. Then you can use `:FloatermNext` or `:FloatermPrev` to switch between them.

### Commands

- `:FloatermNew [cmd]` Open a floating terminal window, if `cmd` exists, it will be executed after the shell startup

- `:FloatermToggle` Open or hide the floaterm window

- `:FloatermPrev` Switch to the previous floaterm window

- `:FloatermNext` Switch to the next floaterm window

- `:FloatermSend` Send selected lines to a job in floaterm. Typically this command is executed with a range, i.e., `:'<,'>FloatermSend`, if no ranges, send the current line.

## Global variables

- **`g:floaterm_type`**

  Type `string`. `'floating'`(neovim only) by default. Set it to `'normal'` if your vim/nvim doesn't support `floatwin` or you don't like floating window.

- **`g:floaterm_width`**

  Type `int` (number of columns) or `float` (between 0 and 1). If `float`, the width is relative to `&columns`. Default: `0.6`

- **`g:floaterm_height`**

  Type `int` (number of lines) or `float` (between 0 and 1). If `float`, the height is relative to `&lines`. Default: `0.6`

- **`g:floaterm_winblend`**

  Type `int`. The transparency of the floating terminal. Default: `0`

- **`g:floaterm_position`**

  Type `string`. The position of the floating window. Available: `'center'`, `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'auto'(at the cursor place)`. Default: `'center'`

- **`g:floaterm_borderchars`**

  Type `array of string`. Characters of the floating window border. Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

- **`g:floaterm_open_in_root`**

  Type `bool`. Open floaterm in project root directory. Default: `v:false`

* **`g:floaterm_rootmarkers`**

  Type `array of string`. Default: `['.project', '.git', '.hg', '.svn', '.root']`

### Keymaps

This plugin doesn't supply any default mappings. To use a recommended mappings, put the following code in your `vimrc`.

```vim
""" Configuration example
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
```

You can also use other keys as shown below:

```vim
let g:floaterm_keymap_new = '<Leader>fn'
```

Note that this key mapping is installed from the [plugin](./plugin) directory, so if you use on-demand loading provided by some plugin manager, the keymap won't take effect. Actually you don't need the on-demand loading for this plugin as it even doesn't slow your startup.

### Change highlight

This plugin supplies two `highlight-groups` to specify the background/foreground color of floaterm (also the border color if `g:floaterm_type` is `'floating'`) window.

By default, they are both linked to `NormalFloat`. To customize, use `hi` command together with the colors you prefer.

```vim
" Configuration example

" Set floaterm window's background to black
hi FloatermNF guibg=black
" Set floating window border line color to cyan, and background to orange
hi FloatermBorderNF guibg=orange guifg=cyan
```

![](https://user-images.githubusercontent.com/20282795/74794098-42d9e080-52fd-11ea-9ccf-661dd748aa03.png)

## More use cases and demos

vim-floaterm is a nvim/vim terminal plugin, it can run all the command-line programs in the terminal even `nvim/vim` itself.

**❗️Note**: The following cases should work both in NeoVim and Vim, if some of them don't work on Vim, try startuping Vim with `--servername` argument, i.e., `vim --servername /tmp/vimtmpfile`

### Basic

Requirements: `pip3 install neovim-remote`

Normally if you run `vim/nvim somefile.txt` within a builtin terminal, you will get another nvim/vim instance running in the subprocess. This plugin allows you to open files from within `:terminal` without starting a nested nvim process. To archive that, just replace `vim/nvim` with `floaterm`, i.e., `floaterm somefile.txt`

![](https://user-images.githubusercontent.com/20282795/74755351-06cb5f00-52ae-11ea-84ba-d0b3e88e9377.gif)

### Use as a fzf plugin

This plugin has implemented a [wrapper](./autoload/floaterm/wrapper/fzf.vim) for fzf command. So it can be used as a tiny fzf plugin.

Try `:FloatermNew fzf` or even wrap this to a new command like this:

```vim
command! FzfTiny FloatermNew fzf
```

![](https://user-images.githubusercontent.com/20282795/74755357-09c64f80-52ae-11ea-90a0-a6b6bbe8940c.gif)

### Use as a ranger plugin

This plugin can also be a handy ranger plugin since it also has a [ranger wrapper](./autoload/floaterm/wrapper/ranger.vim)

Try `:FloatermNew ranger` or define a new command:

```vim
command! Ranger FloatermNew ranger
```

![](https://user-images.githubusercontent.com/20282795/74800026-2e054900-530d-11ea-8e2a-67168a9532a9.gif)

### Use as a Python REPL plugin

Use `:FloatermNew python` to open a python REPL. After that you can use `:FloatermSend` to send lines to the Python interactive shell.

This can also work for other languages which have interactive shell, such as lua, node, etc.

![](https://user-images.githubusercontent.com/20282795/74755385-12b72100-52ae-11ea-8464-e99df4bfddc9.gif)

### Use with other command line tools

Furthermore, you can also use other command-line programs, such as lazygit, htop, ncdu, etc.

Use `lazygit` for instance:

![](https://user-images.githubusercontent.com/20282795/74755376-0f239a00-52ae-11ea-9261-44d94abe5924.png)

### Integrate with vim-clap

Use vim-clap to switch/preview floating terminal buffers.

Try `:Clap floaterm`

![](https://user-images.githubusercontent.com/20282795/74755336-00d57e00-52ae-11ea-8afc-030ff55c2145.gif)

### Integrate with denite

Use denite to switch/preview/open floating terminal buffers.

Try `:Denite floaterm`

![](https://user-images.githubusercontent.com/1239245/73604753-17ef4d00-45d9-11ea-967f-ef75927e2beb.gif)

## How to define more wrappers

There are two ways for a command to be spawned:

- To be executed after `&shell` was startup. see [fzf wrapper](./autoload/floaterm/wrapper/fzf.vim)

  ```vim
  function! floaterm#wrapper#fzf#() abort
    return ['floaterm $(fzf)', {}, v:true]
  endfunction
  ```

  The code above returns an array. `floaterm $(fzf)` is the command to be executed. `v:true` means the command will be executed after the `&shell` startup.

- To be executed through `termopen()`/`term_start()` function, in this case, a callback function is allowed. See [ranger wrapper](./autoload/floaterm/wrapper/ranger.vim)

  ```vim
  function! floaterm#wrapper#ranger#() abort
    let s:ranger_tmpfile = tempname()
    let cmd = 'ranger --choosefiles=' . s:ranger_tmpfile
    return [cmd, {'on_exit': funcref('s:ranger_callback')}, v:false]
  endfunction

  function! s:ranger_callback(...) abort
    if filereadable(s:ranger_tmpfile)
      let filenames = readfile(s:ranger_tmpfile)
      if !empty(filenames)
        call floaterm#hide()
        for filename in filenames
          execute 'edit ' . fnameescape(filename)
        endfor
      endif
    endif
  endfunction
  ```

  Here `v:false` means `cmd` will be passed through `termopen()`(neovim) or `term_start()`(vim). Function `s:ranger_callback()` will be invoked when the `cmd` exits.

## F.A.Q

- #### This plugin leaves an empty buffer on startify window

  Put this code in your `vimrc`

  ```vim
  autocmd User Startified setlocal buflisted
  ```

- #### I want to use another shell in the terminal. (e.g., Use fish instead of bash)

  Set `shell` option in your `vimrc`:

  ```vim
  set shell=/path/to/shell
  ```

- #### I would like to customize the style of the floating terminal window

  Use `autocmd`. For example

  ```vim
  function s:floatermSettings()
      setlocal number
      " more settings
  endfunction

  autocmd FileType floaterm call s:floatermSettings()
  ```

- #### I want to open normal floaterm in the vsplit window.

  Use `:wincmd H` or `:wincmd L`. If you want a persistent layout, register an `autocmd`:

  ```vim
  autocmd FileType floaterm wincmd H
  ```

## Credits

- [floaterm executable](https://github.com/voldikss/vim-floaterm/blob/master/bin/floaterm) is modified from [vim-terminal-help](https://github.com/skywind3000/vim-terminal-help/blob/master/tools/utils/drop)

- Some features require [neovim-remote](https://github.com/mhinz/neovim-remote)

## License

MIT
