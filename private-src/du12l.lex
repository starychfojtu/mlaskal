%{
	// this code is emitted into du12l.cpp 
	// avoid macro redefinition warnings when compiling du1l.cpp
	#pragma warning (disable:4005)
	// avoid unreferenced parameter warnings when compiling du1l.cpp
	#pragma warning (disable:4100)
	// avoid unreferenced function warnings when compiling du1l.cpp
	#pragma warning (disable:4505)

	// allow access to YY_DECL macro
	#include "bisonflex.hpp"

	// allow access to context 
	// CHANGE THIS LINE TO #include "du3456g.hpp" WHEN THIS FILE IS COPIED TO du3456l.lex
	#include "dummyg.hpp"
%}

/* DO NOT TOUCH THIS OPTIONS! */
%option noyywrap nounput batch noinput stack reentrant
%option never-interactive

WHITESPACE[ \r\t\f]
UINT[0-9]+
EREALPART([eE][+-]?[0-9]+)

%%

%{
	typedef yy::mlaskal_parser parser;
%}

[pP][rR][oO][gG][rR][aA][mM]	{
									return parser::make_PROGRAM(ctx->curline);
								}

[lL][aA][bB][eE][lL]	{
							return parser::make_LABEL(ctx->curline);
						}

[cC][oO][nN][sS][tT]	{
							return parser::make_CONST(ctx->curline);
						}

[tT][yY][pP][eE]	{
						return parser::make_TYPE(ctx->curline);
					}

[vV][aA][rR]	{
					return parser::make_VAR(ctx->curline);
				}

[bB][eE][gG][iI][nN]	{
							return parser::make_BEGIN(ctx->curline);
						}

[eE][nN][dD]	{
					return parser::make_END(ctx->curline);
				}

[pP][rR][oO][cC][eE][dD][uU][rR][eE]	{
											return parser::make_PROCEDURE(ctx->curline);
										}

[fF][uU][nN][cC][tT][iI][oO][nN]	{
										return parser::make_FUNCTION(ctx->curline);
									}

[aA][rR][rR][aA][yY]	{
							return parser::make_ARRAY(ctx->curline);
						}

[oO][fF]	{
				return parser::make_OF(ctx->curline);
			}

[gG][oO][tT][oO]	{
						return parser::make_GOTO(ctx->curline);
					}

[iI][fF]	{
				return parser::make_IF(ctx->curline);
			}

[tT][hH][eE][nN]	{
						return parser::make_THEN(ctx->curline);
					}

[eE][lL][sS][eE]	{
						return parser::make_ELSE(ctx->curline);
					}

[wW][hH][iI][lL][eE]	{
							return parser::make_WHILE(ctx->curline);
						}

[dD][oO]	{
				return parser::make_DO(ctx->curline);
			}

[rR][eE][pP][eE][aA][tT]	{
								return parser::make_REPEAT(ctx->curline);
							}

[uU][nN][tT][iI][lL]	{
							return parser::make_UNTIL(ctx->curline);
						}

[fF][oO][rR]	{
					return parser::make_FOR(ctx->curline);
				}

[oO][rR]	{
				return parser::make_OR(ctx->curline);
			}

[nN][oO][tT]	{
					return parser::make_NOT(ctx->curline);
				}

[rR][eE][cC][oO][rR][dD]	{
								return parser::make_RECORD(ctx->curline);
							}

;			{
				return parser::make_SEMICOLON(ctx->curline);
			}

\.			{
				return parser::make_DOT(ctx->curline);
			}

,			{
				return parser::make_COMMA(ctx->curline);
			}

=			{
				return parser::make_EQ(ctx->curline);
			}

:			{
				return parser::make_COLON(ctx->curline);
			}

\(			{
				return parser::make_LPAR(ctx->curline);
			}

\)			{
				return parser::make_RPAR(ctx->curline);
			}

\.\.		{
				return parser::make_DOTDOT(ctx->curline);
			}

\[			{
				return parser::make_LSBRA(ctx->curline);
			}

\]			{
				return parser::make_RSBRA(ctx->curline);
			}

:=			{
				return parser::make_ASSIGN(ctx->curline);
			}

>			{
				return parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_GT, ctx->curline);
			}

\<			{
				return parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_LT, ctx->curline);
			}

\<>			{
				return parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_NE, ctx->curline);
			}

\<=			{
				return parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_LE, ctx->curline);
			}

>=			{
				return parser::make_OPER_REL(mlc::DUTOKGE_OPER_REL::DUTOKGE_GE, ctx->curline);
			}

\+			{
				return parser::make_OPER_SIGNADD(mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_PLUS, ctx->curline);
			}

\-			{
				return parser::make_OPER_SIGNADD(mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS, ctx->curline);
			}

\*			{
				return parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_ASTERISK, ctx->curline);
			}

\/			{
				return parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_SOLIDUS, ctx->curline);
			}

[dD][iI][vV]	{
					return parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_DIV, ctx->curline);
				}

[mM][oO][dD]	{
					return parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_MOD, ctx->curline);
				}

[aA][nN][dD]	{
					return parser::make_OPER_MUL(mlc::DUTOKGE_OPER_MUL::DUTOKGE_AND, ctx->curline);
				}

[tT][oO]	{
				return parser::make_FOR_DIRECTION(mlc::DUTOKGE_FOR_DIRECTION::DUTOKGE_TO, ctx->curline);
			}

[dD][oO][wW][nN][tT][oO]	{
								return parser::make_FOR_DIRECTION(mlc::DUTOKGE_FOR_DIRECTION::DUTOKGE_DOWNTO, ctx->curline);
							}

[A-Za-z][A-Za-z0-9]*	{
							return parser::make_IDENTIFIER(mlc::ls_id_index(), ctx->curline);
						}

{UINT}		{
			    return parser::make_UINT(mlc::ls_int_index(), ctx->curline);
			}

{UINT}((\.{UINT}{EREALPART}?)|{EREALPART})		{
													return parser::make_REAL(mlc::ls_real_index(), ctx->curline);
												}

\n		{
			ctx->curline++;
		}

{WHITESPACE}+		/* go out with whitespaces */

.			message(mlc::DUERR_UNKCHAR, ctx->curline, *yytext, *yytext);

<<EOF>>		return parser::make_EOF(ctx->curline);

%%

namespace mlc {

	yyscan_t2 lexer_init(FILE * iff)
	{
		yyscan_t2 scanner;
		yylex_init(&scanner);
		yyset_in(iff, scanner);
		return scanner;
	}

	void lexer_shutdown(yyscan_t2 scanner)
	{
		yyset_in(nullptr, scanner);
		yylex_destroy(scanner);
	}

}
