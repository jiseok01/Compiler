PARSER  
flex lexer.l      -> lex.yy.c 생성  
bison -d parser.y  -> toypl.tab.c 생성  
gcc -o parser lex.yy.c parser.tab.c  
./parser < sample.txt  

PARSER TREE 
flex lexer.l  
bison -d parser.y 
gcc -o ParserTree lex.yy.c paser.tab.c node.c paser.tab.h -lfl 
