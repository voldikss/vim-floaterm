# vim-floaterm

Open the built-in terminal in neovim's floating window.

![](https://user-images.githubusercontent.com/20282795/71539980-39786b80-297f-11ea-9c19-a61f77f853b0.gif)

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm')
```

## Configurations

#### **`g:floaterm_type`**

- Available: `'floating'`(neovim only), `'normal'`(vim8 and neovim)

- Default: `'floating'`

#### **`g:floaterm_width`**

- Default: `0.6 * &columns`

#### **`g:floaterm_height`**

- Default: `0.6 * &lines`

#### `g:floaterm_winblend`

- Description: The opacity of the floating terminal

- Default: `0`

#### **`g:floaterm_position`**

- Available: `'auto'`, `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'center'`

- Default: `'auto'`(at the cursor place)

#### **`g:floaterm_background`**

- Type: string(e.g. `'#000000'`, `'black'`)

- Default: depends on your `colorscheme`

#### **`g:floaterm_borderchars`**

- Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:translator_window_border_highlight`**

- Available: see `:help group-name` and `:help highlight-groups`

- Default: `'NormalFloat'`

## Commands

- `:FloatermNew`

- `:FloatermToggle`

- `:FloatermPrev`

- `:FloatermNext`

## Keymaps

This plugin doesn't supply any default mappings.

```vim
""" Example configuration
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
```

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

  autocmd FileType terminal call s:floatermSettings()
  ```

## Todo

- [ ] add doc
