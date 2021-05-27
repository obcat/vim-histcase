let s:suite = themis#suite('histcase')


function s:suite.before()
  cmap <Up>     <Plug>(histcase-Up)
  cmap <Down>   <Plug>(histcase-Down)
  cmap <S-Up>   <Plug>(histcase-S-Up)
  cmap <S-Down> <Plug>(histcase-S-Down)
endfunction

function s:suite.before_each()
endfunction

function s:suite.after()
  silent! cunmap <Up>
  silent! cunmap <Down>
  silent! cunmap <S-Up>
  silent! cunmap <S-Down>
  let g:histcase = {
        \   ':': 'followscs',
        \   '>': 'followscs',
        \   '/': 'match',
        \   '?': 'match',
        \   '=': 'followscs',
        \   '@': 'followscs',
        \   '-': 'match',
        \ }
  set ignorecase& smartcase&
endfunction


function s:suite.followic()
  let g:histcase[':'] = 'followic'

  set ignorecase
  call HistTest(':', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#1-2'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#1-3'],
        \ ])

  set noignorecase
  call HistTest(':', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#2-1'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#2-2'],
        \ ])
endfunction


function s:suite.followscs()
  let g:histcase['/'] = 'followscs'

  set ignorecase smartcase
  call HistTest('/', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#1-2'],
        \ ])

  set ignorecase nosmartcase
  call HistTest('/', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#2-1'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#2-2'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#2-3'],
        \ ])

  set noignorecase smartcase
  call HistTest('/', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#3-1'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#3-2'],
        \ ])

  set noignorecase nosmartcase
  call HistTest('/', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#4-1'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#4-2'],
        \ ])
endfunction


function s:suite.ignore()
  let g:histcase['?'] = 'ignore'

  call HistTest('?', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#1-2'],
        \ ])

  call HistTest('?', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["ba",    {'cmdline': 'ba',  'cmdpos': 3}, '#2-1'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#2-2'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#2-3'],
        \ ])
endfunction


function s:suite.smart()
  let g:histcase['='] = 'smart'

  call HistTest('=', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["Ba",    {'cmdline': 'Ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#1-2'],
        \ ])

  call HistTest('=', ['Foo', 'Bar', 'Qux', 'foo', 'bar', 'qux'], [
        \ ["ba",    {'cmdline': 'ba',  'cmdpos': 3}, '#2-1'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#2-2'],
        \ ["\<Up>", {'cmdline': 'Bar', 'cmdpos': 4}, '#2-3'],
        \ ])
endfunction
