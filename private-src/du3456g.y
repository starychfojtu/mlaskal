%language "c++"
%require "3.0.4"
%defines
%define parser_class_name{ mlaskal_parser }
%define api.token.constructor
%define api.token.prefix{DUTOK_}
%define api.value.type variant
%define parse.assert
%define parse.error verbose

%locations
%define api.location.type{ unsigned }

%code requires
{
	// this code is emitted to du3456g.hpp

	// allow references to semantic types in %type
#include "dutables.hpp"
#include "du3456sem.hpp"

	// avoid no-case warnings when compiling du3g.hpp
#pragma warning (disable:4065)

// adjust YYLLOC_DEFAULT macro for our api.location.type
#define YYLLOC_DEFAULT(res,rhs,N)	(res = (N)?YYRHSLOC(rhs, 1):YYRHSLOC(rhs, 0))
// supply missing YY_NULL in bfexpg.hpp
#define YY_NULL	0
#define YY_NULLPTR	0
}

%param{ mlc::yyscan_t2 yyscanner }	// formal name "yyscanner" is enforced by flex
%param{ mlc::MlaskalCtx* ctx }

%start mlaskal

%code
{
	// this code is emitted to du3456g.cpp

	// declare yylex here 
	#include "bisonflex.hpp"
	YY_DECL;

	// allow access to context 
	#include "dutables.hpp"

	// other user-required contents
	#include <assert.h>
	#include <stdlib.h>

    /* local stuff */
    using namespace mlc;

}

%token EOF	0	"end of file"

%token PROGRAM			/* program */
%token LABEL			    /* label */
%token CONST			    /* const */
%token TYPE			    /* type */
%token VAR			    /* var */
%token BEGIN			    /* begin */
%token END			    /* end */
%token PROCEDURE			/* procedure */
%token FUNCTION			/* function */
%token ARRAY			    /* array */
%token OF				    /* of */
%token GOTO			    /* goto */
%token IF				    /* if */
%token THEN			    /* then */
%token ELSE			    /* else */
%token WHILE			    /* while */
%token DO				    /* do */
%token REPEAT			    /* repeat */
%token UNTIL			    /* until */
%token FOR			    /* for */
%token OR				    /* or */
%token NOT			    /* not */
%token RECORD			    /* record */

/* literals */
%token<mlc::ls_id_index> IDENTIFIER			/* identifier */
%token<mlc::ls_int_index> UINT			    /* unsigned integer */
%token<mlc::ls_real_index> REAL			    /* real number */
%token<mlc::ls_str_index> STRING			    /* string */

/* delimiters */
%token SEMICOLON			/* ; */
%token DOT			    /* . */
%token COMMA			    /* , */
%token EQ				    /* = */
%token COLON			    /* : */
%token LPAR			    /* ( */
%token RPAR			    /* ) */
%token DOTDOT			    /* .. */
%token LSBRA			    /* [ */
%token RSBRA			    /* ] */
%token ASSIGN			    /* := */

/* grouped operators and keywords */
%token<mlc::DUTOKGE_OPER_REL> OPER_REL			    /* <, <=, <>, >=, > */
%token<mlc::DUTOKGE_OPER_SIGNADD> OPER_SIGNADD		    /* +, - */
%token<mlc::DUTOKGE_OPER_MUL> OPER_MUL			    /* *, /, div, mod, and */
%token<mlc::DUTOKGE_FOR_DIRECTION> FOR_DIRECTION		    /* to, downto */

%type<mlc::type_pointer> type
%type<std::vector<mlc::ls_id_index>> identifiercycle
%type<mlc::field_list_ptr> recordfieldlist

%%

/* CONSTANT */

uconstant: IDENTIFIER /* constant identifier */
         | UINT
		 | REAL
		 | STRING
		 ;

constant: uconstant
	    | OPER_SIGNADD UINT
		| OPER_SIGNADD REAL
		;

/* EXPRESSION */

realparameters: expression
			  | expression COMMA realparameters
			  ;

factor: UINT /* uconstant inlining */
	  | REAL /* uconstant inlining */
	  | STRING /* uconstant inlining */
      | IDENTIFIER /* variable OR function OR uconstant inlining */
	  | IDENTIFIER /* function */ LPAR realparameters RPAR
	  | LPAR expression RPAR
	  | NOT factor
	  ;

term: factor
	| factor OPER_MUL term

simpleexpression: term 
				| term OPER_SIGNADD simpleexpression
				| term OR simpleexpression
				;

expression: simpleexpression
		  | OPER_SIGNADD simpleexpression
		  | simpleexpression OPER_REL simpleexpression
		  ;

/* STATEMENT */

functioninvocation: %empty
				  | LPAR realparameters RPAR
				  ;

statementlabel: UINT COLON
			  | %empty
			  ;

statementacycle: statementa SEMICOLON statementacycle
			  | %empty
			  ;

statementbodya: IDENTIFIER DOT IDENTIFIER /* record.property (record access) */ ASSIGN expression
			  | IDENTIFIER /* function OR variable */ ASSIGN expression
			  | IDENTIFIER /* procedure */ functioninvocation
			  | GOTO UINT
			  | BEGIN statementacycle END
			  | IF expression /* boolean */ THEN statementa ELSE statementa
			  | WHILE expression /* boolean */ DO statementa
			  | REPEAT statementacycle UNTIL expression /* boolean */
			  | FOR IDENTIFIER /* ordinal type */ ASSIGN expression /* ordinal */ FOR_DIRECTION expression /* ordinal */ DO statementa
			  | %empty
			  ;

statementbcycle: statementb SEMICOLON statementbcycle
			   | statementb
			   ;

statementbodyb: BEGIN statementbcycle END
			  | IF expression /* boolean */ THEN statement
			  | IF expression /* boolean */ THEN statementa ELSE statementb
			  | WHILE expression /* boolean */ DO statementb
			  | REPEAT statementbcycle UNTIL expression /* boolean */
			  | FOR IDENTIFIER /* ordinal type */ ASSIGN expression /* ordinal */ FOR_DIRECTION expression /* ordinal */ DO statementb
			  ;

statementa: statementlabel statementbodya
		  ;

statementb: statementlabel statementbodyb
		  ;

statement: statementa
		 | statementb
		 ;

/* TYPE */

identifiercycle:	IDENTIFIER	{
									$$.push_back($1);
								}
				|	identifiercycle COMMA IDENTIFIER	{
															auto ids = $1;
															ids.push_back($3);
															$$ = ids;
														}
		       ;

/* TODO: Move and rename */
fieldlistvariabledeclaration:	identifiercycle COLON type	{
																for(auto identifier: $1) {
																	ctx->tab->add_var(@1, identifier, $3);
																}
															}

fieldlist: fieldlistvariabledeclaration SEMICOLON fieldlist
		 | fieldlistvariabledeclaration
		 | %empty
	     ;

recordfieldlist:  identifiercycle COLON type SEMICOLON recordfieldlist	{
																			auto list = mlc::create_field_list();
																			for(auto id: $1) {
																				list->append_field(id, $3);
																			}
																			list->append_and_kill($5);
																			$$ = list;
																		}
				| identifiercycle COLON type	{
													auto list = mlc::create_field_list();
													for(auto id: $1) {
														list->append_field(id, $3);
													}
													$$ = list;
												}
				| %empty
				;

type: IDENTIFIER /* ordinal type OR type OR structured type */ {
																	$$ = mlc::get_type(ctx->tab, $1, @1);
															   }
    | RECORD recordfieldlist END	{
										$$ = ctx->tab->create_record_type($2, @1);
									}
	;

/* BLOCK */

blocklabelcycle: UINT COMMA blocklabelcycle
			   | UINT
			   ;

blocklabel: LABEL blocklabelcycle SEMICOLON
	  | %empty
	  ;

blockconstcycle: IDENTIFIER EQ constant SEMICOLON
			   | IDENTIFIER EQ constant SEMICOLON blockconstcycle
			   ;

blockconst: CONST blockconstcycle
		  | %empty
		  ;

blocktypecycle: IDENTIFIER EQ type SEMICOLON
			   | IDENTIFIER EQ type SEMICOLON blocktypecycle
			   ;

blocktype: TYPE blocktypecycle
		 | %empty
		 ;

blockvar: VAR fieldlist
		| %empty
		;

blockstatementcycle: SEMICOLON statement blockstatementcycle
				   | %empty
				   ;

block: blocklabel blockconst blocktype blockvar BEGIN statement blockstatementcycle END
     ;

/* FUNCTION HEADERS */

formalparametersidentifiercycle: COMMA IDENTIFIER
							   | %empty
							   ;

formalparametersvar: VAR
				   | %empty
				   ;

formalparameter: formalparametersvar IDENTIFIER formalparametersidentifiercycle COLON IDENTIFIER /* type */
			   ;

formalparametercycle: SEMICOLON formalparameter formalparametercycle
					| %empty
					;

formalparameters: formalparameter formalparametercycle
				;

formalparametersheader: %empty
					  | LPAR formalparameters RPAR
					  ;

procedureheader: PROCEDURE IDENTIFIER formalparametersheader
			   ;

functionheader: FUNCTION IDENTIFIER formalparametersheader COLON IDENTIFIER /* scalar type */

/* BLOCK P */

blockpfunctionheader: functionheader
					| procedureheader
					;

blockpfunction: blockpfunctionheader SEMICOLON block SEMICOLON
			  ;

blockpfunctions: blockpfunction blockpfunctions
			   | %empty
			   ;

blockp: blocklabel blockconst blocktype blockvar blockpfunctions BEGIN statement blockstatementcycle END
     ;

mlaskal: PROGRAM IDENTIFIER SEMICOLON blockp DOT
	   ;


%%


namespace yy {

	void mlaskal_parser::error(const location_type& l, const std::string& m)
	{
		message(DUERR_SYNTAX, l, m);
	}

}

