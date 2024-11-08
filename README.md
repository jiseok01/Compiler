PARSER  
flex lexer.l      -> lex.yy.c 생성  
bison -d parser.y  -> toypl.tab.c 생성  
gcc -o parser lex.yy.c parser.tab.c  
./parser < sample.txt  
