" Idris autoindent

fun! s:lmatch(pat)
  let line = getline(search(a:pat, 'bn'))
  return match(line, a:pat)
endf

" returns the indent of the enclosing scope if we're in a
" data decl, otherwise -1
fun! s:dataIndent()
  let line = line('.')
  let ind = indent(line)
  while line > 0
    let line -= 1
    if getline(line) =~ '^\s*data\>'
      return indent(line)
    elseif getline(line) == '' || indent(line) > ind
      return -1
    endif
  endw
endf

" after a definition
fun! s:defnIndent()
  return indent(
        \ search("^\s*\(\k\+\|(.\+)\|{.\+}\)\(\s\+\(\k\+\|(.\+)\|{.\+}\)\)\+",
        \        'bn'))
endf

fun! IdrisIndent()
  let curno  = line('.')
  let prevno = curno - 1
  let cur    = getline(curno)
  let prev   = getline(prevno)

  let assignRegexp = g:idrisOpChars.'\@<!?\?='.g:idrisOpChars.'\@![^;]\+$'

  if curno == 1
    return 0
  elseif prev =~ '^--'
    " comment
    return indent(prevno)
  elseif prev =~ '^[^{]*{$'
    " ends with {
    return indent(prevno) + &sw
  elseif prev =~ '{[^{}]\+$'
    " contains unclosed {
    return match(prev, '{\s*\zs[^{}]\+$')
  elseif cur =~ '^\s*}'
    return cindent(curno)
  elseif cur =~ '^\s*|' && prev !~ '\<with\>'
    " typed a | for a datatype alternative
    if prev =~ '^\s*|'
      return indent(prevno)
    else
      return indent(prevno) - 2
    endif
  elseif prev =~ '^\s*data\>.*:.*=[^;]\+$'
    " data _ = _    -- expecting '|' on next line
    return match(prev, '=[^;]\+$') + 2
  elseif prev =~ '\<where\>\s*$'
    " data _ where
    return indent(prevno) + &sw + 2
  elseif prev =~ '^\s*data\>[^;]' && prev !~ '\<where$\|=$'
        \ || prev =~ ':.*->$'
    " data X: F -> G -> ...     -- continued on next line
    return match(prev, ':\s*\zs.')
  elseif prev =~ '\<let\>.\+\<in$' || cur =~ '^\s*in\>'
    " in
    return s:lmatch('\<let\>')
  elseif prev =~ '\<let\>.\+,$'
    " let x = y,
    return match(prev, '\<let\>') + 4
  elseif prev =~ ',$'
    return indent(prevno)
  elseif prev =~ '?\?=$'
    " x =
    return indent(prevno) + &sw
  elseif prev =~ assignRegexp
    " x = ...     -- no semicolon
    return match(prev, assignRegexp)
  elseif cur =~ '^\s*then\>'
    " then after if
    return match(prev, '\<if\>') + 3
  elseif cur =~ '^\s*else\s\+if'
    return match(prev, '\<\(else\s\+\)\?if\>')
  elseif cur =~ '^\s*else\>'
    " else after then or else-if
    if prev =~ '^\s*else\>'
      return match(prev, '\<else\>')
    else
      return match(prev, '\<then\>')
    endif
  else
    if prev =~ ';$'
      let i = s:dataIndent()
      if i >= 0 | return i | endif
      let i = s:defnIndent()
      if i >= 0 | return i | endif
    endif
    return indent(search('.', 'bn'))
  endif
endf

set indentexpr=IdrisIndent()
set indentkeys=0{,0},0),!,o,O,0\|,0=then,e,0=in,=else\ if
set comments=ns:{-,nex:-},b:--
