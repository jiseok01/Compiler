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
void codeL(Node *nodeP){
    if (nodeP == NULL) return;
    printf("ldc ρ(%s); ", nodeP->value.sv); 
}
void codeR(Node *nodeP){
    if (nodeP == NULL) return;
    
    if (strcmp(nodeP->kind, "NAME") == 0) {
    	codeL(nodeP);
        printf("ind; ");
    } else if (strcmp(nodeP->kind, "NUMBER") == 0) {
        printf("ldc %.1lf; ", nodeP->value.dv);  
    } else if (strcmp(nodeP->kind, "PLUS") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("add; ");
    } else if (strcmp(nodeP->kind, "MINUS") == 0) {
      	codeR(nodeP->son);
        codeR(nodeP->son->bro);
      	printf("sub; ");
    } else if (strcmp(nodeP->kind, "TIMES") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("mul; ");
    } else if (strcmp(nodeP->kind, "DIVIDE") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro); 
        printf("div; ");
    } else if (strcmp(nodeP->kind, "NEG") == 0) {
        codeR(nodeP->son);
        printf("neg; ");
    } else if (strcmp(nodeP->kind, "AND") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro); 
        printf("and; ");
    } else if (strcmp(nodeP->kind, "OR") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro); 
        printf("or; ");
    } else if (strcmp(nodeP->kind, "NOT") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro); 
        printf("not; ");
    } else if (strcmp(nodeP->kind, "EQ") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("equ; ");
    } else if (strcmp(nodeP->kind, "LT") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("les; ");
    } else if (strcmp(nodeP->kind, "LE") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("leq; ");
    } else if (strcmp(nodeP->kind, "GT") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("grt; ");
    } else if (strcmp(nodeP->kind, "GE") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("geq; ");
    } else if (strcmp(nodeP->kind, "NE") == 0) {
        codeR(nodeP->son);
        codeR(nodeP->son->bro);
        printf("neq; ");
    }
}

void code(Node *nodeP) {
    if (nodeP == NULL) return;	
    if (strcmp(nodeP->kind, "MAIN") == 0) {  
    	printf("spp v+2; "); 
	code(nodeP->son->bro);
	printf("stp; ");
    } else if (strcmp(nodeP->kind, "COMP") == 0) {
	code(nodeP->son);    
    } else if (strcmp(nodeP->kind, "ASGN") == 0) {
	codeL(nodeP->son);    
	codeR(nodeP->son->bro);
	printf("sto; ");
    } else if (strcmp(nodeP->kind, "IF") == 0) {
	if(nodeP ->son->bro->bro != NULL){
		codeR(nodeP->son);
		printf("fjp l1; ");  
		code(nodeP->son->bro);
		printf("ujp l2; l1: ");
		code(nodeP->son->bro->bro);
		printf("l2: "); 
	}
	else {
		codeR(nodeP->son);
		printf("fjp l; ");  
		code(nodeP->son->bro);
		printf("l: ");
	}
    } else if (strcmp(nodeP->kind, "WHILE") == 0) {
     	printf("l1: "); 
	codeR(nodeP->son);
	printf("fjp l2; ");  
	code(nodeP->son->bro);
	printf("ujp l1; l2: ");
    } else if (strcmp(nodeP->kind, "FOR") == 0) {
	code(nodeP->son);
	printf("l1: ");    
	codeR(nodeP->son->bro->bro);
	printf("fjp l2; "); 
	code(nodeP->son->bro->bro->bro);
	printf("ujp l1; l2: ");
    } else if (strcmp(nodeP->kind, "RTRN") == 0) {
	codeR(nodeP->son);    
	printf("str 0; retf ");
    } else if (strcmp(nodeP->kind, "PCALL") == 0) {
	printf("mst; ");
	codeR(nodeP->son->bro);    
	printf("cup n lname ");
    } else if (strcmp(nodeP->kind, "FCALL") == 0) {
	printf("mst; ");
	codeR(nodeP->son->bro->bro->bro->bro);    
	printf("cup n lname ");
    } else if (strcmp(nodeP->kind, "PROC") == 0) {
	printf("lname: ssp p+v+2; ");
	code(nodeP->son->bro->bro->bro);    
	printf("retp ");
    } else if (strcmp(nodeP->kind, "FUNC") == 0) {
	printf("lname: ssp p+v+2; ");
	code(nodeP->son->bro->bro->bro->bro);    
	printf("retf ");
    } 
}

int main(void) {
    yyparse();
    traverse(rootNode);
    Node* crt = rootNode;
    while (crt!=NULL) {
    	code(crt);
    	crt = crt->bro;
    };
    return 0;
}
