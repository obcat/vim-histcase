" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

if exists('g:loaded_histcase')
  finish
endif
let g:loaded_histcase = v:true


if !exists('g:histcase')
  let g:histcase = {}
endif
let s:def_config = {
      \   ':': 'followscs',
      \   '>': 'followscs',
      \   '/': 'match',
      \   '?': 'match',
      \   '=': 'followscs',
      \   '@': 'followscs',
      \   '-': 'match',
      \ }
call extend(g:histcase, s:def_config, 'keep')
unlet s:def_config

augroup histcase
  autocmd!
  autocmd CmdlineEnter * call histcase#onCmdlineEnter()
  autocmd CmdlineLeave * call histcase#onCmdlineLeave()
augroup END


cmap <expr> <Plug>(histcase-Up)
      \ wildmenumode() && <SID>getcompltype() =~ '^\%(file\|menu\)$'
      \ ? '<SID>[cnoremap-Up]' : '<SID>[Up]'

cmap <expr> <Plug>(histcase-Down)
      \ wildmenumode() && <SID>getcompltype() =~ '^\%(file\|menu\)$'
      \ ? '<SID>[cnoremap-Down]' : '<SID>[Down]'

cmap <Plug>(histcase-S-Up)   <SID>[S-Up]
cmap <Plug>(histcase-S-Down) <SID>[S-Down]

cmap <expr> <Plug>(histcase-C-p)
      \ <SID>getcompltype() != ''
      \ ? '<SID>[cnoremap-C-p]' : '<SID>[S-Up]'

cmap <expr> <Plug>(histcase-C-n)
      \ <SID>getcompltype() != ''
      \ ? '<SID>[cnoremap-C-n]' : '<SID>[S-Down]'


cnoremap <SID>[cnoremap-Up]   <Up>
cnoremap <SID>[cnoremap-Down] <Down>
cnoremap <SID>[cnoremap-C-p]  <C-p>
cnoremap <SID>[cnoremap-C-n]  <C-n>
cmap <expr> <SID>[Up]     printf('<SID>{%s}', histcase#brain('Up'))
cmap <expr> <SID>[Down]   printf('<SID>{%s}', histcase#brain('Down'))
cmap <expr> <SID>[S-Up]   printf('<SID>{%s}', histcase#brain('S-Up'))
cmap <expr> <SID>[S-Down] printf('<SID>{%s}', histcase#brain('S-Down'))


cnoremap <SID>{beep} <S-Down>
cmap <SID>{next} <SID>((next-pre))<SID>((next))<SID>((next-post))


cnoremap <expr> <SID>((next-pre))  histcase#nextPre()
cnoremap <expr> <SID>((next-post)) histcase#nextPost()
cmap <SID>((next)) <SID>([next])<SID>([redraw])


cnoremap <silent> <SID>([next]) <End><C-\>eg:histcase#next<CR>
" HACK: <Space><BS> can be used to redraw cmdline.  This idea is by @machakann.
" @kuuote, @thinca, and @Milly also helped me.  Thanks all!
cnoremap <SID>([redraw]) <Space><BS>


" TODO: Send a patch that implements this.
function s:getcompltype()
  return ''
endfunction
