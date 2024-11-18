%{
#include <stdio.h>
#include <string.h>
#include "node.h"
extern int yylex(void);
Node * rootNode;
%}
%union {
	double dval;
	char * sval;
	struct _node * nodeP;
}
%token <dval> TNUMBER 
%token <sval> TNAME
%token TPROGRAM TMAIN TPROC TFUNC TRETURNS TVAR TINT TLONG
%token TIF TTHEN TELSE TWHILE TFOR TTO TCALL TRETURN TBEGIN TEND
%token TASS TAND TOR TNOT TEQ TLT TLE TGT TGE TNE TPLUS TMINUS TMUL TDIV;
%type <nodeP> Fact Program VarDecl Stmt AsgnStmt IfStmt WhileStmt
%type <nodeP> Term ForStmt CallStmt RtrnStmt CompStmt StmtList
%type <nodeP> Cond Rel Expr FuncCall DclList Decl VarList Type Var 
%type <nodeP> SubPgmList SubPgm ProcDecl FuncDecl FormParam
%type <nodeP> ParamList ExprList Name 
%left '+' '-' '*' '/' '(' ')'
%start Program
%%
Stmt: 
    AsgnStmt {$$ = $1;}
    | IfStmt {$$ = $1;}
    | WhileStmt {$$ = $1;}
    | ForStmt {$$ = $1;}
    | CallStmt {$$ = $1;}
    | RtrnStmt {$$ = $1;}
    | CompStmt {$$ = $1;}
    ;

AsgnStmt:
    Var TASS Expr 
    {$$ = makeNode("ASGN", NULL, $1);
     $1->bro = $3;}
    ;

IfStmt:
    TIF '(' Cond ')' TTHEN Stmt
    { $$ = makeNode("IF", NULL, $3);
      $3->bro = $6; }
    | TIF '(' Cond ')' TTHEN Stmt TELSE Stmt
    { $$ = makeNode("IF", NULL, $3);
      $3->bro = $6;
      $3->bro->bro = $8; }
    ;

WhileStmt: 
    TWHILE '(' Cond ')' Stmt
    { $$ = makeNode("WHILE", NULL, $3);
      $3->bro = $5; }
    ;

ForStmt:
    TFOR '(' Var TASS Expr TTO Expr ')' Stmt
    { 
      $$ = makeNode("FOR", NULL, $3);
      $3->bro = $5; 
      $3->bro->bro = $7;
      $3->bro->bro->bro = $9;}
    ;
   
CallStmt:
    TCALL Name '(' ParamList ')'
    { $$ = makeNode("PCALL", NULL, $2);
      $2->bro = $4; }
    ;
    
RtrnStmt:
    TRETURN '(' Expr ')'
    {$$ = makeNode("RTRN", NULL, $3);}
    ;

CompStmt:
    TBEGIN StmtList TEND
    {$$ = makeNode("COMP", NULL, $2);}
    ;


StmtList:
    Stmt
    { $$ = $1; }
    | StmtList ';' Stmt
    { $$ = $3;
      $3->bro = $1;}
    ;

Cond:
    Cond TAND Rel
    { $$ = makeNode("AND", NULL, $1);
      $1->bro = $3; }
    | Cond TOR Rel
    { $$ = makeNode("OR", NULL, $1);
      $1->bro = $3; }
    | TNOT Rel
    { $$ = makeNode("NOT", NULL, $2);}
    | Rel
    { $$ = $1; }
    ;

Rel:
    Expr TLT Expr
    { $$ = makeNode("LT", NULL, $1);
      $1->bro = $3; }
    | Expr TLE Expr
    { $$ = makeNode("LE", NULL, $1); 
      $1->bro = $3;}
    | Expr TGT Expr
    { $$ = makeNode("GT", NULL, $1); 
      $1->bro = $3;}
    | Expr TGE Expr
    { $$ = makeNode("GE", NULL, $1); 
      $1->bro = $3;}
    | Expr TEQ Expr
    { $$ = makeNode("EQ", NULL, $1); 
      $1->bro = $3;}
    | Expr TNE Expr
    { $$ = makeNode("NE", NULL, $1); 
      $1->bro = $3;}
    ;
    
Expr:
    Expr TPLUS Term
    { $$=makeNode("PLUS", NULL, $1);
  	$1->bro = $3; }
    | Expr TMINUS Term
    { $$=makeNode("MINUS", NULL, $1);
  	$1->bro = $3; }
    | Term
    { $$ = $1; }
    ;

Term:
    Term TMUL Fact
    { $$=makeNode("TIMES", NULL, $1);
      $1->bro = $3; }
    | Term TDIV Fact
    { $$=makeNode("DIVIDE", NULL, $1);
      $1->bro = $3; }
    | Fact
    { $$ = $1; }
    ;
Fact:
    Var
    { $$ = $1; }
    | TNUMBER
    { 
      $$ = makeNode("NUMBER", NULL, NULL);
      $$->value.dv = $1; }
    | FuncCall
    { $$ = $1; }
    | TMINUS Fact
    { $$ = makeNode("NEG", NULL, $2); }
    | '(' Expr ')'
    { $$ = $2; }
    ;
    
FuncCall:
    Name '(' ParamList ')'
    {$$=makeNode("FCALL", NULL, $1);
     $1->bro = $3;}
    ;
    
ParamList:
    ExprList
    { $$=$1; }
    |
    {$$=NULL;}
    ;
    
ExprList: 
    ExprList ',' Expr
    {$$ = $3; 
     $3->bro = $1;}
    | Expr
    { $$=$1; }
    ;
    
Program:
    TPROGRAM Name ';' SubPgmList TMAIN VarDecl CompStmt '.' 
    {rootNode = makeNode("MAIN",$4, $6);
     $6->bro = $7;
     }
    ;

VarDecl:
    TVAR DclList ';'
    {$$ = makeNode("VARDECL",NULL, $2);}
    |
    { $$= makeNode("VARDECL",NULL, NULL); }
    ;

DclList:
    DclList ';' Decl 
    {$$ = $3;
     $3->bro = $1;}
    | Decl
    { $$=$1; }
    ;

Decl:
    VarList ':' Type
    {$$ = makeNode("DECL",NULL, $1);
     $1->bro = $3;}
    ;

VarList:
    VarList ',' Var 
    {$$ = $1;
     $1->bro = $3;}
    | Var
    { $$=$1; }
    ;
    
Type:
    TINT
    {$$ = makeNode("INT",NULL, NULL);}
    | TLONG 
    {$$ = makeNode("LONG",NULL, NULL);}
    ;

Var:
    Name
    { $$=$1; }
    ;

Name : 
    TNAME 
    { $$ = makeNode("NAME", NULL, NULL);
      $$->value.sv = $1; }
    ;
    
SubPgmList:
    SubPgmList SubPgm 
    {
     if($1 == NULL){
        $$ = $2;}
     else{
     	$$ = $1;
     	$1->bro = $2;}
    }
    | 
    {$$ = NULL;}
    ;

SubPgm:
    ProcDecl 
    {$$ = $1;}
    | FuncDecl 
    {$$ = $1;}
    ;

ProcDecl:
    TPROC Name '(' FormParam ')' VarDecl CompStmt
    {$$ = makeNode("PROC", NULL, $2);
     $2->bro = $4;
     $2->bro->bro = $6;
     $2->bro->bro->bro = $7;}
    ;

FuncDecl:
    TFUNC Name '(' FormParam ')' TRETURNS '(' Type ')' VarDecl CompStmt 
    {$$ = makeNode("FUNC", NULL, $2);
     $2->bro = $8;
     $2->bro->bro = $4;
     $2->bro->bro->bro = $10;
     $2->bro->bro->bro->bro=$11;}
    ;
    
FormParam:
    DclList
    {$$ = $1;}
    |
    {$$ = NULL;}
    ;

%%

void yyerror() {
   printf("Syntax error\n");
}

void traverse(Node * nodeP) {
	while (nodeP!=NULL) {
		printf("%s\n", nodeP->kind);
		traverse(nodeP->son);
		nodeP=nodeP->bro;
	}
}

int main(void) {
    yyparse();
    traverse(rootNode);
    return 0;
}
