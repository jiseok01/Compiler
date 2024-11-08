Toypl Grammar Checker
flex toypl.l      -> lex.yy.c 생성
bison -d toypl.y  -> toypl.tab.c 생성
gcc -o toypl lex.yy.c toypl.tab.c
./toypl < sample.txt
