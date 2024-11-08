%{
#include <stdio.h>
extern int yylex(void);
void yyerror(const char *s);
%}

%start Program
%union {
    int num;
    char *str;
}

%token <num> NUMBER
%token <str> NAME
%token TPROGRAM TMAIN TPROC TFUNC TRETURNS TVAR TINT TLONG
%token TIF TTHEN TELSE TWHILE TFOR TTO TCALL TRETURN TBEGIN TEND
%token TASS TAND TOR TNOT TLT TLE TGT TGE TNE TPLUS TMINUS TMUL TDIV;
%token ERROR

%%
Stmt: 
    AsgnStmt | IfStmt
    | WhileStmt | ForStmt
    | CallStmt | RtrnStmt
    | CompStmt
    ;

AsgnStmt:
    Var TASS Expr
    ;

IfStmt:
    TIF '(' Cond ')' TTHEN Stmt
    | TIF '(' Cond ')' TTHEN Stmt TELSE Stmt
    ;

WhileStmt: 
    TWHILE '(' Cond ')' Stmt
    ;

ForStmt:
    TFOR '(' Var TASS Expr TTO Expr ')'
    Stmt
    ;
   
CallStmt:
    TCALL NAME '(' ParamList ')'
    ;
    
RtrnStmt:
    TRETURN '(' Expr ')'
    ;

CompStmt:
    TBEGIN StmtList TEND
    ;


StmtList:
    Stmt
    | StmtList ';' Stmt
    ;

Cond:
    Cond TAND Rel
    | Cond TOR Rel
    | TNOT Rel
    | Rel
    ;

Rel:
    Expr TLT Expr
    | Expr TLE Expr
    | Expr TGT Expr
    | Expr TGE Expr
    | Expr TASS Expr
    | Expr TNE Expr
    ;
    
Expr:
    Expr TPLUS Term
    | Expr TMINUS Term
    | Term
    ;

Term:
    Term TMUL Fact
    | Term TDIV Fact
    | Fact
    ;
    
Fact:
    Var
    | NUMBER
    | FuncCall
    | TMINUS Fact
    | '(' Expr ')'
    ;
    
FuncCall:
    NAME '(' ParamList ')'
    ;
    
ParamList:
    ExprList
    |
    ;
    
ExprList: 
    ExprList ',' Expr
    | Expr
    ;
    
Program:
    TPROGRAM NAME ';' 
    SubPgmList 
    TMAIN VarDecl CompStmt '.'
    ;

VarDecl:
    TVAR DclList ';'
    |
    ;

DclList:
    DclList ';' Decl 
    | Decl
    ;

Decl:
    VarList ':' Type
    ;

VarList:
    VarList ',' Var 
    | Var
    ;
    
Type:
    TINT 
    | TLONG  
    ;

Var:
    NAME
    ;
    
SubPgmList:
    SubPgmList SubPgm
    |
    ;

SubPgm:
    ProcDecl 
    | FuncDecl
    ;

ProcDecl:
    TPROC NAME '(' FormParam ')'
    VarDecl CompStmt
    ;

FuncDecl:
    TFUNC NAME '(' FormParam ')'
    TRETURNS '(' Type ')'
    VarDecl CompStmt
    ;
    
FormParam:
    DclList
    |
    ;

%%

void yyerror(const char *s) {
     fprintf(stderr, "오류: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
