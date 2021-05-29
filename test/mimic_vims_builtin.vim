let s:suite = themis#suite('mimic_vims_builtin')


function s:suite.before()
  " By commenting out these mappings, we can check if the expected result of
  " each test is the same as the result when using Vim's builtin <Up>, <Down>,
  " <S-Up>, and <S-Down>.
  cmap <Up>     <Plug>(histcase-Up)
  cmap <Down>   <Plug>(histcase-Down)
  cmap <S-Up>   <Plug>(histcase-S-Up)
  cmap <S-Down> <Plug>(histcase-S-Down)

  " mimic Vim's builtins
  let g:histcase = {
        \   ':': 'match',
        \   '>': 'match',
        \   '/': 'match',
        \   '?': 'match',
        \   '=': 'match',
        \   '@': 'match',
        \   '-': 'match',
        \ }
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
endfunction


function s:suite.basic()
  call HistTest(':', ['foo', 'bar', 'baz', 'qux'], [
        \ ["ba",      {'cmdline': 'ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>",   {'cmdline': 'baz', 'cmdpos': 4}, '#1-2'],
        \ ["\<Up>",   {'cmdline': 'bar', 'cmdpos': 4}, '#1-3'],
        \ ["\<Down>", {'cmdline': 'baz', 'cmdpos': 4}, '#1-4'],
        \ ["\<Down>", {'cmdline': 'ba',  'cmdpos': 3}, '#1-5'],
        \ ])

  call HistTest('/', ['foo', 'bar'], [
        \ ["qu",        {'cmdline': 'qu',  'cmdpos': 3}, '#2-1'],
        \ ["\<S-Up>",   {'cmdline': 'bar', 'cmdpos': 4}, '#2-2'],
        \ ["\<S-Up>",   {'cmdline': 'foo', 'cmdpos': 4}, '#2-3'],
        \ ["\<S-Down>", {'cmdline': 'bar', 'cmdpos': 4}, '#2-4'],
        \ ["\<S-Down>", {'cmdline': 'qu',  'cmdpos': 3}, '#2-5'],
        \ ])
endfunction


function s:suite.stop_at_top()
  call HistTest('?', ['foo', 'bar', 'baz', 'qux'], [
        \ ["ba",    {'cmdline': 'ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>", {'cmdline': 'baz', 'cmdpos': 4}, '#1-2'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#1-3'],
        \ ["\<Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#1-4'],
        \ ])

  call HistTest('=', ['foo', 'bar'], [
        \ ["qu",      {'cmdline': 'qu',  'cmdpos': 3}, '#2-1'],
        \ ["\<S-Up>", {'cmdline': 'bar', 'cmdpos': 4}, '#2-2'],
        \ ["\<S-Up>", {'cmdline': 'foo', 'cmdpos': 4}, '#2-3'],
        \ ["\<S-Up>", {'cmdline': 'foo', 'cmdpos': 4}, '#2-4'],
        \ ])
endfunction


function s:suite.stop_at_bottom()
  call HistTest('=', ['foo', 'bar', 'baz'], [
        \ ["fo",      {'cmdline': 'fo', 'cmdpos': 3}, '#1-1'],
        \ ["\<Down>", {'cmdline': 'fo', 'cmdpos': 3}, '#1-2'],
        \ ])

  call HistTest(':', ['foo', 'bar', 'baz'], [
        \ ["fo",        {'cmdline': 'fo', 'cmdpos': 3}, '#2-1'],
        \ ["\<S-Down>", {'cmdline': 'fo', 'cmdpos': 3}, '#2-2'],
        \ ])
endfunction


function s:suite.cmdline_before_cursor_is_used_as_query()
  call HistTest('?', ['foo', 'bar', 'baz', 'qux'], [
        \ ["bat",     {'cmdline': 'bat', 'cmdpos': 4}, '#1-1'],
        \ ["\<Left>", {'cmdline': 'bat', 'cmdpos': 3}, '#1-2'],
        \ ["\<Up>",   {'cmdline': 'baz', 'cmdpos': 4}, '#1-3'],
        \ ["\<Down>", {'cmdline': 'ba',  'cmdpos': 3}, '#1-4'],
        \ ])

  call HistTest('?', ['foo', 'bar', 'baz', 'qux'], [
        \ ["bat",       {'cmdline': 'bat', 'cmdpos': 4}, '#2-1'],
        \ ["\<Left>",   {'cmdline': 'bat', 'cmdpos': 3}, '#2-2'],
        \ ["\<S-Up>",   {'cmdline': 'qux', 'cmdpos': 4}, '#2-3'],
        \ ["\<S-Down>", {'cmdline': 'ba',  'cmdpos': 3}, '#2-4'],
        \ ])
endfunction


function s:suite.changing_cmdline_refreshes_query()
  call HistTest('/', ['foo', 'bar', 'baz', 'qux'], [
        \ ["fo",       {'cmdline': 'fo',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>",    {'cmdline': 'foo', 'cmdpos': 4}, '#1-2'],
        \ ["\<Down>",  {'cmdline': 'fo',  'cmdpos': 3}, '#1-3'],
        \ ["\<C-u>ba", {'cmdline': 'ba',  'cmdpos': 3}, '#1-4'],
        \ ["\<Up>",    {'cmdline': 'baz', 'cmdpos': 4}, '#1-5'],
        \ ["\<Down>",  {'cmdline': 'ba',  'cmdpos': 3}, '#1-6'],
        \ ])

  call HistTest('/', ['foo', 'bar', 'baz', 'qux'], [
        \ ["fo",        {'cmdline': 'fo',  'cmdpos': 3}, '#2-1'],
        \ ["\<S-Up>",   {'cmdline': 'qux', 'cmdpos': 4}, '#2-2'],
        \ ["\<S-Down>", {'cmdline': 'fo',  'cmdpos': 3}, '#2-3'],
        \ ["\<C-u>ba",  {'cmdline': 'ba',  'cmdpos': 3}, '#2-4'],
        \ ["\<S-Up>",   {'cmdline': 'qux', 'cmdpos': 4}, '#2-5'],
        \ ["\<S-Down>", {'cmdline': 'ba',  'cmdpos': 3}, '#2-6'],
        \ ])
endfunction


function s:suite.changing_cmdpos_should_always_refresh_query()
  " Compatible
  call HistTest('=', ['foo', 'fred', 'bar'], [
        \ ["fr",              {'cmdline': 'fr',   'cmdpos': 3}, '#1-1'],
        \ ["\<Up>",           {'cmdline': 'fred', 'cmdpos': 5}, '#1-2'],
        \ ["\<Down>",         {'cmdline': 'fr',   'cmdpos': 3}, '#1-3'],
        \ ["\<Up>",           {'cmdline': 'fred', 'cmdpos': 5}, '#1-4'],
        \ ["\<Home>\<Right>", {'cmdline': 'fred', 'cmdpos': 2}, '#1-5'],
        \ ["\<Up>",           {'cmdline': 'foo',  'cmdpos': 4}, '#1-6'],
        \ ["\<Down>",         {'cmdline': 'fred', 'cmdpos': 5}, '#1-7'],
        \ ["\<Down>",         {'cmdline': 'f',    'cmdpos': 2}, '#1-8'],
        \ ])

  " Compatible
  call HistTest('=', ['foo', 'fred', 'bar'], [
        \ ["fr",              {'cmdline': 'fr',   'cmdpos': 3}, '#2-1'],
        \ ["\<S-Up>",         {'cmdline': 'bar',  'cmdpos': 4}, '#2-2'],
        \ ["\<S-Down>",       {'cmdline': 'fr',   'cmdpos': 3}, '#2-3'],
        \ ["\<S-Up>",         {'cmdline': 'bar',  'cmdpos': 4}, '#2-4'],
        \ ["\<Home>\<Right>", {'cmdline': 'bar',  'cmdpos': 2}, '#2-5'],
        \ ["\<S-Up>",         {'cmdline': 'fred', 'cmdpos': 5}, '#2-6'],
        \ ["\<S-Down>",       {'cmdline': 'bar',  'cmdpos': 4}, '#2-7'],
        \ ["\<S-Down>",       {'cmdline': 'b',    'cmdpos': 2}, '#2-8'],
        \ ])

  " Incompatible
  call HistTest('=', ['foo', 'fred', 'bar'], [
        \ ["fr",                 {'cmdline': 'fr',   'cmdpos': 3}, '#3-1'],
        \ ["\<Up>",              {'cmdline': 'fred', 'cmdpos': 5}, '#3-2'],
        \ ["\<Down>",            {'cmdline': 'fr',   'cmdpos': 3}, '#3-3'],
        \ ["\<Up>",              {'cmdline': 'fred', 'cmdpos': 5}, '#3-4'],
        \ [repeat("\<Left>", 3), {'cmdline': 'fred', 'cmdpos': 2}, '#3-5'],
        \ ["\<Up>",              {'cmdline': 'foo',  'cmdpos': 4}, '#3-6'],
        \ ["\<Down>",            {'cmdline': 'fred', 'cmdpos': 5}, '#3-7'],
        \ ["\<Down>",            {'cmdline': 'f',    'cmdpos': 2}, '#3-8'],
        \ ])

  " Incompatible
  call HistTest('=', ['foo', 'fred', 'bar'], [
        \ ["fr",                 {'cmdline': 'fr',   'cmdpos': 3}, '#4-1'],
        \ ["\<S-Up>",            {'cmdline': 'bar',  'cmdpos': 4}, '#4-2'],
        \ ["\<S-Down>",          {'cmdline': 'fr',   'cmdpos': 3}, '#4-3'],
        \ ["\<S-Up>",            {'cmdline': 'bar',  'cmdpos': 4}, '#4-4'],
        \ [repeat("\<Left>", 2), {'cmdline': 'bar',  'cmdpos': 2}, '#4-5'],
        \ ["\<S-Up>",            {'cmdline': 'fred', 'cmdpos': 5}, '#4-6'],
        \ ["\<S-Down>",          {'cmdline': 'bar',  'cmdpos': 4}, '#4-7'],
        \ ["\<S-Down>",          {'cmdline': 'b',    'cmdpos': 2}, '#4-8'],
        \ ])
endfunction


function s:suite.go_to_expr_and_come_back()
  call HistTest('/', ['bar', 'foo', 'baz', 'qux'], [
        \ ["ba",               {'cmdline': 'ba',  'cmdpos': 3}, '#1-1'],
        \ ["\<Up>",            {'cmdline': 'baz', 'cmdpos': 4}, '#1-2'],
        \ ["\<Up>",            {'cmdline': 'bar', 'cmdpos': 4}, '#1-3'],
        \ ["\<C-\>e'fo'\<CR>", {'cmdline': 'fo',  'cmdpos': 3}, '#1-4'],
        \ ["\<Down>",          {'cmdline': 'foo', 'cmdpos': 4}, '#1-5'],
        \ ["\<Down>",          {'cmdline': 'fo',  'cmdpos': 3}, '#1-6'],
        \ ])
endfunction


function s:suite.special_charactors_are_inserted_literally()
  call HistTest('?', ["foo\n"], [
        \ ["ba",      {'cmdline': 'ba',    'cmdpos': 3}, '#1-1'],
        \ ["\<S-Up>", {'cmdline': "foo\n", 'cmdpos': 5}, '#1-2'],
        \ ])
endfunction
