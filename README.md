# vim-floaterm

![CI](https://github.com/voldikss/vim-floaterm/workflows/CI/badge.svg)

Use neovim terminal in the floating window.

![](https://user-images.githubusercontent.com/20282795/74757458-fe285800-52b0-11ea-9ff1-e34ab8ea490a.png)

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
  - [Integrate with denite](#integrate-with-vim-denite)
- [How to define more wrappers](#how-to-define-more-wrappers)
- [F.A.Q](#f.a.q)
- [Credits](#credits)
- [License](#license)

## Features

- Floating window support, but not necessary
- Open and toggle terminal window quickly
- Multiple terminal instances
- Customizable floating terminal style
- Switch/Preview floating terminal buffers using [vim-clap](https://github.com/liuchengxu/vim-clap)(try `:Clap floaterm`)
- Switch/Preview/Open floating terminal buffers using [denite.nvim](https://github.com/Shougo/denite.nvim)(try `:Denite floaterm`)

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

Generally just one floaterm instance using `FloatermNew` command is enough to use. The filetype of the terminal buffer is set to `floaterm`.

If you've opened more than one floaterm instances, they are attached to a double-circular-linkedlist. Then you can use `FloatermNext` or `FloatermPrev` to switch between every floaterm instance.

### Commands

- `:FloatermNew [cmd]` Open a floating terminal window and execute the command after the shell startup

- `:FloatermToggle` Open or hide the terminal window

- `:FloatermPrev` Switch to the previous terminal window

- `:FloatermNext` Switch to the next floaterm window

- `:FloatermSend` Send selected lines to floaterm job. Typically this command is executed with a range, i.e., `:'<,'>FloatermSend`, if without a range, send the current line.

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

### Keymaps

This plugin doesn't supply any default mappings. To use a recommended mappings, put the following code in your `vimrc`.

```vim
""" Configuration example
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
```

You can also define other mappings as shown below:

```vim
let g:floaterm_keymap_new = '<Leader>fn'
```

### Change highlight

This plugin supplies two `highlight-groups` to specify the background/foreground color of floaterm (and the border color if `g:floaterm_type` is `'floating'`) window.

By default, they are both linked to `NormalFloat`. To customize, use `hi` command together with the color you prefer.

```vim
" Configuration example
" Set floaterm window's background to black
hi FloatermNF guibg=black
" Set floating window border line color to blue, and background to gray
hi FloatermBorderNF guibg=gray guifg=blue
```

## More use cases and demos

vim-floaterm is a nvim/vim terminal plugin, so it can run all the command line tools even nvim/vim itself.

**❗️Note**: The following should work both in NeoVim and Vim, if some of them doesn't work on Vim, try to startup Vim with `--servername` argument. i.e., `vim --servername /tmp/vimtmpfile`

![](https://user-images.githubusercontent.com/20282795/74755351-06cb5f00-52ae-11ea-84ba-d0b3e88e9377.gif)

### Basic

Requirements: `pip3 install neovim-remote`

Normally if you run `vim/nvim somefile.txt` within builtin terminal, you will get another nvim/vim instance running in the subprocess. This plugin allows you to open files from within `:terminal` without starting a nested nvim process. To archive that, just replace `vim/nvim` with `floaterm`, i.e., `floaterm somefile.txt`

### Use as a fzf plugin

This plugin has implemented a [wrapper](https://github.com/voldikss/vim-floaterm/blob/master/autoload/floaterm/wrapper/fzf.vim) for fzf command. So it can be a tiny fzf plugin.

Type `:FloatermNew fzf` to have a try.

![](https://user-images.githubusercontent.com/20282795/74755357-09c64f80-52ae-11ea-90a0-a6b6bbe8940c.gif)

### Use as a ranger plugin

This plugin can also be a handy ranger plugin since it also has a ranger [wrapper](https://github.com/voldikss/vim-floaterm/blob/master/autoload/floaterm/wrapper/ranger.vim)

Type `:FloatermNew ranger` to have a try.

![](https://user-images.githubusercontent.com/20282795/74755394-15197b00-52ae-11ea-8915-73401ad30228.gif)

### Use as a Python REPL plugin

Use `:FloatermNew python` to open a python REPL, and then you can use `:FloatermSend` to send lines to python interactive shell.

You can use this in other languages such as lua, node, etc.

![](https://user-images.githubusercontent.com/20282795/74755385-12b72100-52ae-11ea-8464-e99df4bfddc9.gif)

### Use with other command line tools

Furthermore, you can also use other command-line tools, such as lazygit, htop, ncdu, etc.

![](https://user-images.githubusercontent.com/20282795/74755376-0f239a00-52ae-11ea-9261-44d94abe5924.png)

### Integrate with vim-clap

Use vim-clap to switch/preview floating terminal buffers. `:Clap floaterm`

![](https://user-images.githubusercontent.com/20282795/74755336-00d57e00-52ae-11ea-8afc-030ff55c2145.gif)

### Integrate with denite

Use denite to switch/preview/open floating terminal buffers. `:Denite floaterm`

![](https://user-images.githubusercontent.com/1239245/73604753-17ef4d00-45d9-11ea-967f-ef75927e2beb.gif)

## How to define more wrappers

There are two ways for a command to be spawned:

- To be executed after `&shell` was startup. see [fzf wrapper](https://github.com/voldikss/vim-floaterm/blob/master/autoload/floaterm/wrapper/fzf.vim)

- To be executed through `termopen()`/`term_start()` function, in this case, a callback function is allowed. See [ranger wrapper](https://github.com/voldikss/vim-floaterm/blob/master/autoload/floaterm/wrapper/fzf.vim)

## F.A.Q

- #### This plugin leaves an empty buffer on startify window

  Put this code in `vimrc`

  ```vim
  autocmd User Startified setlocal buflisted
  ```

- #### I want to use another shell in the terminal. (e.g. Use fish instead of bash)

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

  Use `:wincmd H` or `:wincmd L`. You can also register an `autocmd`:

  ```vim
  autocmd FileType floaterm wincmd H
  ```

## Credits

- [floaterm executable](https://github.com/voldikss/vim-floaterm/blob/master/bin/floaterm) is modified from [vim-terminal-help](https://github.com/skywind3000/vim-terminal-help/blob/master/tools/utils/drop)

- Some features is based on [neovim-remote](https://github.com/mhinz/neovim-remote)

## License

MIT
