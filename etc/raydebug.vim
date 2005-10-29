" vim syntax file
" Language:	BBCode
" Maintainer:	Korenlius Kalnbach <korny@cYcnus.de>
" Last Change:	2004 Dec 12

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

syn case ignore


syn match rayKind /\w\+(\@=/
syn match rayRegion /\w\+<\@=/

syn match rayRegionParen /[<>]/

syn region rayText matchgroup=rayParen start='(' end=')' skip=/\\./

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_raydebug_syn_inits")
	if version < 508
		let did_raydebug_syn_inits = 1
		command -nargs=+ HiLink hi link <args>
	else
		command -nargs=+ HiLink hi def link <args>
	endif

	hi link	rayKind Type
	hi link	rayRegion Statement
	hi link	rayRegionParen Statement

	hi link	rayText Constant
	hi link	rayTextParen Operator

	delcommand HiLink
endif
