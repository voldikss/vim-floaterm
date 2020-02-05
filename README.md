# vim-floaterm

[![Build Status](https://travis-ci.org/voldikss/vim-floaterm.svg?branch=master)](https://travis-ci.org/voldikss/vim-floaterm)

Use neovim terminal in the floating window.

![](https://user-images.githubusercontent.com/20282795/71553203-f59c6980-2a45-11ea-88f2-747e938f7f49.gif)

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm')
```

## Keymaps

This plugin doesn't supply any default mappings.

```vim
""" Example configuration
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
```

## Features

- Toggle terminal window quickly
- Multiple terminal instances
- Customizable floating terminal style
- Switch/Preview floating terminal buffer using [vim-clap](https://github.com/liuchengxu/vim-clap)(try `:Clap floaterm`)
- Switch/Preview/Open floating terminal buffers using [denite.nvim](https://github.com/Shougo/denite.nvim)(try `:Denite floaterm`)
  - See the animation GIF in [PR #30](https://github.com/voldikss/vim-floaterm/pull/30).

## Configurations

#### **`g:floaterm_type`**

- Available: `'floating'`(neovim only), `'normal'`(vim8 and neovim)

- Default: `'floating'`

#### **`g:floaterm_width`**

- Type: `int` (number of columns) or `float` (between 0 and 1). If `float`, the width is relative to `&columns`.
- Default: `0.6`

#### **`g:floaterm_height`**

- Type: `int` (number of lines) or `float` (between 0 and 1). If `float`, the height is relative to `&lines`.
- Default: `0.6`

#### `g:floaterm_winblend`

- Description: The transparency of the floating terminal

- Default: `0`

#### **`g:floaterm_position`**

- Available: `'center'`, `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'auto'(at the cursor place)`

- Default: `'center'`

#### **`g:floaterm_background`**

- Type: string(e.g. `'#000000'`, `'black'`)

- Default: background color of normal floating window

#### **`g:floaterm_borderchars`**

- Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:floaterm_border_color`**

- Type: string(e.g. `'#FFFFFF'`, `'blue'`)

- Default: foreground color of normal floating window

#### **`g:floaterm_border_bgcolor`**

- Type: string(e.g. `'#FFFFFF'`, `'blue'`)

- Default: Same as `g:floaterm_background`

## Commands

- `:FloatermNew`

- `:FloatermToggle`

- `:FloatermPrev`

- `:FloatermNext`

## Q & A

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
