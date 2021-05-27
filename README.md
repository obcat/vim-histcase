# vim-histcase

[![CI](https://github.com/obcat/vim-histcase/workflows/CI/badge.svg)](https://github.com/obcat/vim-histcase/actions?query=workflow%3Aci)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A missing case option for cmdline history search.

![histcase](https://user-images.githubusercontent.com/64692680/119843190-46b5d300-bf42-11eb-8b35-49be7c0cf66a.gif)

## Usage

```vim
cmap <Up>     <Plug>(histcase-Up)
cmap <Down>   <Plug>(histcase-Down)
cmap <S-Up>   <Plug>(histcase-S-Up)
cmap <S-Down> <Plug>(histcase-S-Down)
cmap <C-p>    <Plug>(histcase-C-p)
cmap <C-n>    <Plug>(histcase-C-n)

let g:histcase = {
      \   ':': 'followscs',
      \   '>': 'followscs',
      \   '/': 'match',
      \   '?': 'match',
      \   '=': 'followscs',
      \   '@': 'followscs',
      \   '-': 'match',
      \ }
```

Please see the [help file](doc/histcase.jax) for more information.
