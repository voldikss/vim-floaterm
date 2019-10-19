# vim-floaterm

Open the terminal in the neovim's floating window, detached from my [dotfiles](https://github.com/voldikss/dotfiles)

**Note: Only available in NeoVim.**

![](https://user-images.githubusercontent.com/20282795/62412186-8c006680-b631-11e9-842b-1fffda64d926.gif)

## Installation

- vim-plug

```vim
Plug 'voldikss/vim-floaterm'
```

- dein.nvim

```vim
call dein#add('voldikss/vim-floaterm', {'on_cmd': 'FloatermToggle'})
```

## Configurations

#### **`g:floaterm_type`**

- Available: `'floating'`, `'normal'`

- Default: `'floating'`

#### **`g:floaterm_width`**

- Type: number

- Default: `0.7 * &columns`

#### **`g:floaterm_height`**

- Type: number

- Default: `0.7 * &lines`

#### `g:floaterm_winblend`

- Description: The opacity of the floating terminal

- Type: number(0-100)

- Default: 0

#### **`g:floaterm_position`**

- Available: `'auto'`, `'topleft'`, `'topright'`, `'bottomleft'`, `'bottomright'`, `'center'`

- Default: `'auto'`(at the cursor position)

#### **`g:floaterm_background`**

- Type: string(e.g. `'#000000'`)

- Default: depends on your colorscheme

## Commands

```
:FloatermToggle
```

## Keymaps

Recommended configuration

```vim
noremap  <silent> <F12>           :FloatermToggle<CR>i
noremap! <silent> <F12>           <Esc>:FloatermToggle<CR>i
tnoremap <silent> <F12>           <C-\><C-n>:FloatermToggle<CR>
```

## Q & A

- #### This plguin leaves an empty window on startify window

  Put this code in `vimrc`

  ```vim
  autocmd User Startified setlocal buflisted
  ```

- #### I want to use another shell in the terminal. (e.g. Use fish instead of bash/zsh)

  Set `shell` option in your `vimrc`:

  ```vim
  set shell=/path/to/shell
  ```

- #### I would like to customize the floating window behavior

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
