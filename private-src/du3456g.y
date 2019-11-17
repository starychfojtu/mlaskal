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
			  | IDENTIFIER /* variable */
			  | IDENTIFIER /* variable */ COMMA realparameters
			  ;

functioninvocation: %empty
				  | LPAR realparameters RPAR
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

statementlabel: UINT COLON
			  | %empty
			  ;

statementcycle: statement SEMICOLON statementcycle
			  | %empty
			  ;

statementbody: IDENTIFIER DOT IDENTIFIER /* record.property (record access) */ ASSIGN expression
			 | IDENTIFIER /* function OR variable */ ASSIGN expression
			 | IDENTIFIER /* procedure */ functioninvocation
			 | GOTO UINT
			 | BEGIN statementcycle END
			 | IF expression /* boolean */ THEN statement 
			 | IF expression /* boolean */ THEN statement ELSE statement
			 | WHILE expression /* boolean */ DO statement
			 | REPEAT statementcycle UNTIL expression /* boolean */
			 | FOR IDENTIFIER /* ordinal type */ ASSIGN expression /* ordinal */ FOR_DIRECTION expression /* ordinal */ DO statement
			 | %empty
			 ;

statement: statementlabel statementbody
		 ;

/* TYPE */

identifiercycle: IDENTIFIER 
			   | identifiercycle COMMA IDENTIFIER
		       ;

fieldlist: identifiercycle COLON type SEMICOLON fieldlist
		 | identifiercycle COLON type
		 | %empty
	     ;

type: IDENTIFIER /* ordinal type OR type OR structured type */
    | RECORD fieldlist END
	;

/* BLOCK */

blocklabelcycle: COLON UINT blocklabelcycle
				| %empty
				;

blocklabel: LABEL UINT blocklabelcycle SEMICOLON
	  | %empty
	  ;

blockconstcycle: IDENTIFIER EQ constant SEMICOLON blockconstcycle
			   | %empty
			   ;

blockconst: CONST IDENTIFIER EQ constant SEMICOLON blockconstcycle
		  | %empty
		  ;

blocktypecycle: TYPE IDENTIFIER EQ type SEMICOLON blocktypecycle
			   | %empty
			   ;

blocktype: TYPE IDENTIFIER EQ type SEMICOLON blocktypecycle
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

