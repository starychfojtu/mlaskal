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
%type<mlc::parameter_list_ptr> formalparametercycle formalparameter formalparametersheader
%type<mlc::ls_id_index> blockpfunctionheader procedureheader functionheader

%%

/* CONSTANT */

constant: IDENTIFIER EQ IDENTIFIER	{
										auto symbol = ctx->tab->find_symbol($3);
										if (symbol->kind() != SKIND_CONST) {
											message(DUERR_NOTCONST, @3, *$3);
										}

										auto const_symbol = symbol->access_const();
										auto type_cat = const_symbol->type()->cat();\
										switch (type_cat) {
											case TCAT_STR: {
													auto str_value = const_symbol->access_str_const()->str_value();
													auto fin_str_value = ctx->tab->ls_str().add(*str_value);
													ctx->tab->add_const_str(@1, $1, fin_str_value);
												}
												break;
											case TCAT_INT: {
													auto int_value = const_symbol->access_int_const()->int_value();
													auto fin_int_value = ctx->tab->ls_int().add(*int_value);
													ctx->tab->add_const_int(@1, $1, fin_int_value);
												}
												break;
											case TCAT_REAL: {
													auto real_value = const_symbol->access_real_const()->real_value();
													auto fin_real_value = ctx->tab->ls_real().add(*real_value);
													ctx->tab->add_const_real(@1, $1, fin_real_value);
												}
												break;
											default: {
													auto bool_value = const_symbol->access_bool_const()->bool_value();
													ctx->tab->add_const_bool(@1, $1, bool_value);
												}
												break;
										}
									}
	    | IDENTIFIER EQ UINT	{
									ctx->tab->add_const_int(@1, $1, $3);
								}
	    | IDENTIFIER EQ REAL	{
									ctx->tab->add_const_real(@1, $1, $3);
								}
	    | IDENTIFIER EQ STRING	{
									ctx->tab->add_const_str(@1, $1, $3);
								}
	    | IDENTIFIER EQ OPER_SIGNADD UINT	{
												if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
												{
													auto value = ctx->tab->ls_int().add(-(*$4));
													ctx->tab->add_const_int(@1, $1, value);
												}
												else
												{
													ctx->tab->add_const_int(@1, $1, $4);
												}
											}
		| IDENTIFIER EQ OPER_SIGNADD REAL	{
												if($3 == mlc::DUTOKGE_OPER_SIGNADD::DUTOKGE_MINUS)
												{
													auto value = ctx->tab->ls_real().add(-(*$4));
													ctx->tab->add_const_real(@1, $1, value);
												}
												else
												{				
													ctx->tab->add_const_real(@1, $1, $4);
												}
											}
		;

/* EXPRESSION */

realparameters: expression
			  | expression COMMA realparameters
			  ;

factor: UINT 
	  | REAL
	  | STRING
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
																			for (auto id: $1) {
																				list->append_field(id, $3);
																			}
																			list->append_and_kill($5);
																			$$ = list;
																		}
				| %empty	{
								$$ = mlc::create_field_list();
							}
				;

type: IDENTIFIER /* ordinal type OR type OR structured type */ {
																	$$ = mlc::get_type(ctx->tab, $1, @1);
															   }
    | RECORD recordfieldlist END	{
										$$ = ctx->tab->create_record_type($2, @1);
									}
	;

/* BLOCK */

blocklabeldeclaration: UINT {
								ctx->tab->add_label_entry(@1, $1, ctx->tab->new_label());
							}

blocklabelcycle: blocklabeldeclaration COMMA blocklabelcycle	
			   | blocklabeldeclaration
			   ;

blocklabel: LABEL blocklabelcycle SEMICOLON
	  | %empty
	  ;

blockconstcycle: constant SEMICOLON
			   | constant SEMICOLON blockconstcycle
			   ;

blockconst: CONST blockconstcycle
		  | %empty
		  ;

blocktypedeclaration: IDENTIFIER EQ type SEMICOLON	{
														ctx->tab->add_type(@1, $1, $3);	
													}

blocktypecycle: blocktypedeclaration 
			   | blocktypedeclaration blocktypecycle
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

formalparameter: VAR identifiercycle COLON IDENTIFIER /* type */	{
																		auto list = mlc::create_parameter_list();
																		auto type = mlc::get_type(ctx->tab, $4, @4);
																		for(auto index : $2) {
																			list->append_parameter_by_reference(index, type);
																		}
																		$$ = list;			
																	}
			   | identifiercycle COLON IDENTIFIER /* type */	{
																	auto list = mlc::create_parameter_list();
																	auto type = mlc::get_type(ctx->tab, $3, @3);
																	for(auto index : $1) {
																		list->append_parameter_by_value(index, type);
																	}
																	$$ = list;					
																}
			   ;

formalparametercycle: formalparameter SEMICOLON formalparametercycle	{
																			auto list = mlc::create_parameter_list();
																			list->append_and_kill($1);
																			list->append_and_kill($3);
																			$$ = list;
																		}
					| formalparameter	{
											$$ = $1;
										}
					;

formalparametersheader: %empty	{
									$$ = mlc::create_parameter_list();
								}
					  | LPAR formalparametercycle RPAR	{
															$$ = $2;
														}
					  ;

procedureheader: PROCEDURE IDENTIFIER formalparametersheader	{
																	ctx->tab->add_proc(@1, $2, $3);
																	$$ = $2;
																}
			   ;

functionheader: FUNCTION IDENTIFIER formalparametersheader COLON IDENTIFIER /* scalar type */	{
																									ctx->tab->add_fnc(@1, $2, mlc::get_type(ctx->tab, $5, @5), $3);
																									$$ = $2;
																								}

/* BLOCK P */

blockpfunctionheader: functionheader	{
											$$ = $1;
										}
					| procedureheader	{
											$$ = $1;
										}
					;

blockpfunction: blockpfunctionheader SEMICOLON { ctx->tab->enter(@2, $1); } block { ctx->tab->leave(@4); } SEMICOLON
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

