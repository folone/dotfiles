" Idris (http://www.cs.st-and.ac.uk/~eb/Idris) syntax highlighting

if exists("b:current_syntax")
  finish
endif

setlocal iskeyword+=',?,#,_

let g:idrisOpChars = '[:+\-\*/=_.?|&><!@$%\^~]'

fun! s:Builtin(ops, hi)
  let opChars = g:idrisOpChars
  for o in split(a:ops)
    exec "syn match idris".a:hi." '".opChars."\\@<!\\V".o."\\m".opChars."\\@!'"
  endfor
endf

hi def link idrisOperator Operator
syn match   idrisOperator '\V\[:+\-*/=_.?|&><!@$%^~\\]\+'

hi def link idrisIdent Normal
syn match   idrisIdent '\k\+'

hi def link idrisDelimiter Delimiter
syn match   idrisDelimiter '[()[\]{},;]'
call s:Builtin('<< >> : | & ! ~ = -> **', 'Delimiter')

hi def link idrisSyntax Operator
call s:Builtin('<- => ... \\', 'Syntax')

hi def link idrisSpecial Special
syn match   idrisSpecial '%\k\+'
syn match   idrisSpecial '\k\@<!_\k\@!'
call s:Builtin('?= ?', 'Special')

syn region  idrisQDef transparent start="?=" end="\n"
hi def link idrisProofName Special
syn region  idrisProofName start="\[" end="\]"
      \ containedin=idrisQDef contained
syn match   idrisProofName "\<?\k\+\>"

hi def link idrisKeyword Keyword
syn keyword idrisKeyword
      \ using idiom params namespace where with lazy infix
      \ infixl infixr do return if then else let in

hi def link idrisStructure Structure
syn keyword idrisStructure data module

hi def link idrisMeta PreProc
syn keyword idrisMeta
      \ noElim collapsible import export inline partial syntax include

hi def link idrisBuiltinType Identifier
syn match   idrisBuiltinType '()\|#'
call s:Builtin('_|_', 'BuiltinType')
syn keyword idrisBuiltinType
      \ Int Char Float String Lock Handle Ptr Bool Sigma Pair Either List
      \ Maybe Nat Vect Fin IO

hi def link idrisBuiltinValue Constant
syn keyword idrisBuiltinValue
      \ True False II refl Exists mkPair Left Right Nil Cons Just Nothing O S
      \ VNil fO fS

syn region  idrisProof  transparent matchgroup=idrisStructure
      \ start='proof\ze\s*{' end='}\zs' contains=TOP,idrisSpecial
syn region  idrisBraces transparent start='{' end='}'
hi def link idrisTactic PreProc
syn match   idrisTactic contained '%\k\+\>' containedin=idrisProof

hi def link idrisString String
syn region  idrisString start=+"+ end=+"+ skip=+\\"+

hi def link idrisChar Character
syn match   idrisChar "'\\.'\|'.'"

hi def link idrisNumber Number
syn match   idrisNumber '\d\+\(\.\d\+\)\?'

hi def link idrisComment Comment
syn match   idrisComment '--.*$' contains=idrisTodo
hi def link idrisNestComment idrisComment
syn region  idrisNestComment start='{-' end='-}'
      \ contains=idrisNestComment,idrisTodo
hi def link idrisTodo Todo
syn keyword idrisTodo TODO FIXME XXX HACK contained

delfunction s:Builtin
let b:current_syntax = "idris"
