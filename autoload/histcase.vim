" Maintainer: obcat <obcat@icloud.com>
" License:    MIT License

let s:cmdlineStack = []
" :foo<C-r>='bar'<CR>baz<Esc>
"  ├─┘      ├───┘    ├─┘
"  │        │        └ [{'cmdtype': ':', ...}]
"  │        └───────── [{'cmdtype': ':', ...}, {'cmdtype': '=', ...}]
"  └────────────────── [{'cmdtype': ':', ...}]

function histcase#onCmdlineEnter() abort
  let cmdline = {}
  let cmdline.cmdtype = expand('<afile>')
  " TODO: postpone loading history until it is actually needed?
  let cmdline.history = s:cmdtype2history(cmdline.cmdtype)
  let cmdline.histidx = len(cmdline.history)
  let cmdline.query = 'shouldRefreshThis!'
  let cmdline.shouldRefreshQuery = v:true
  let cmdline.lastCmdpos = -1
  let cmdline.next = '???' " an entry to be inserted
  let s:cmdlineStack += [cmdline]
endfunction

function histcase#onCmdlineLeave() abort
  unlet s:cmdlineStack[-1]
  autocmd! histcase CmdlineChanged
endfunction


" key: Up, Down, S-Up, or S-Down
" return: beep or next
function histcase#brain(key) abort
  let c = s:cmdlineStack[-1]

  if getcmdpos() != c.lastCmdpos
    let c.shouldRefreshQuery = v:true
  endif
  if c.shouldRefreshQuery
    let c.query = strpart(getcmdline(), 0, getcmdpos() - 1)
  endif

  let candidates = c.history + [c.query]
  let segment = a:key =~ 'Up'
        \      ? candidates[: c.histidx]->reverse()
        \      : candidates[c.histidx :]

  let regexp = '' "{{{
  if a:key =~ 'S-'
    let regexp = '.*'
  else
    let config = g:histcase[c.cmdtype]
    if type(config) != v:t_string
      call s:echoerr(printf(
            \   '[histcase] Invalid argument: g:histcase[%s] = %s',
            \   string(c.cmdtype), strtrans(string(config))
            \ ))
      return 'beep'
    endif
    let ignorecase = v:false
    if config == 'followic'
      let ignorecase = &ignorecase
    elseif config == 'followscs'
      let ignorecase = s:smartcase(&ignorecase, &smartcase, c.query)
    elseif config == 'ignore'
      let ignorecase = v:true
    elseif config == 'match'
      let ignorecase = v:false
    elseif config == 'smart'
      let ignorecase = s:smartcase(v:true, v:true, c.query)
    else
      call s:echoerr(printf(
            \   '[histcase] Invalid argument: g:histcase[%s] = %s',
            \   string(c.cmdtype), strtrans(string(config))
            \ ))
      return 'beep'
    endif
    let regexp = '^\V'
          \   .. (ignorecase ? '\c' : '\C')
          \   .. escape(c.query, '\')
  endif "}}}

  let result = match(segment, regexp, 1)
  let distance = result == -1 ? 0 : result
  if distance == 0
    return 'beep'
  endif

  let sign = a:key =~ 'Up' ? -1 : +1
  let c.histidx += sign * distance
  let c.next = candidates[c.histidx]
  let c.lastCmdpos = len(c.next) + 1
  let c.shouldRefreshQuery = v:false
  return 'next'
endfunction


function histcase#nextPre() abort
  call s:adjustAutocmd('pre')
  return ''
endfunction

function histcase#nextPost() abort
  call s:adjustAutocmd('post')
  return ''
endfunction

function histcase#next() abort
  return s:cmdlineStack[-1]['next']
endfunction

" phase: pre or post
function s:adjustAutocmd(phase) abort
  augroup histcase
    autocmd!
    if a:phase == 'post'
      autocmd CmdlineEnter * call histcase#onCmdlineEnter()
      autocmd CmdlineLeave * call histcase#onCmdlineLeave()
      let cmdtype = escape(s:cmdlineStack[-1]['cmdtype'], '?')
      execute 'autocmd CmdlineChanged' cmdtype '++once let s:cmdlineStack[-1][''shouldRefreshQuery''] = v:true'
    endif
  augroup END
  return ''
endfunction


let s:cmdtype2histname = {
      \   ':': 'cmd',
      \   '/': 'search',
      \   '?': 'search',
      \   '=': 'expr',
      \   '@': 'input',
      \   '>': 'debug',
      \   '-': '',
      \ }

function s:cmdtype2history(cmdtype) abort
  if a:cmdtype == '-'
    return []
  endif
  let histname = s:cmdtype2histname[a:cmdtype]
  let histnr = histnr(histname)
  if histnr == -1
    return []
  endif
  " NOTE: range(1, 0) == []
  let history = map(range(1, histnr), 'histget(histname, v:val)')
  call filter(history, 'v:val != ''''')
  return history
endfunction


function s:smartcase(ignorecase, smartcase, query) abort
  let ignorecase = a:ignorecase
  if ignorecase && a:smartcase && s:hasUpper(a:query)
    let ignorecase = v:false
  endif
  return ignorecase
endfunction

function s:hasUpper(text) abort
  return a:text =~ '\u'
endfunction


function s:echoerr(msg) abort
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction
