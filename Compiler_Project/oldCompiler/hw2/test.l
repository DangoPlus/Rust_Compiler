%{
#include <stdio.h>
#include <ctype.h>
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n","t");}
#define upper(t) { for(int i = 0; i < strlen(t); i++){t[i] = toupper(t[i]);};printf("<%s>\n", t); }
#define keyword(t) {LIST; upper(t)}
#define tokenInteger {LIST; printf("<%s:%s>\n","integer",yytext);return INTEGER;}
#define tokenReal {LIST;printf("<%s:%s>\n", "real", yytext);return REAL}
#define tokenBoolean {LIST; printf("<%s:%s>\n","boolean",yytext);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n","string",s);}
#define tokenId {insert(yytext);LIST; printf("<%s:%s>\n","id",yytext);}
#define MAX_SIZE 1000
#define MAX_LINE_LENG 256
#define STRLEN 1000
int linenum = 1;
char buf[MAX_LINE_LENG];
char str[STRLEN];


int key_id = 1;
struct symbol_table {
  char sym[256];
  int key;};
struct symbol_table* *hash_table;
int hash(int key){
return key % MAX_SIZE;
}
struct symbol_table* *create(){
static struct symbol_table* newhash_table[MAX_SIZE];
  return newhash_table;
}
int lookup(char *sym){
int hash_index = 1;
int find = 0;
printf("lookup:%s\n",sym);
printf("hash_index:%s",hash_table[1]->sym);
while(hash_table[hash_index] != NULL){
if(strcmp(hash_table[hash_index]->sym, sym) == 0)
{
find = 1;
  break;}
else
{hash_index = hash_index + 1;}
}
if(find == 1){
return hash_index;
}
else{
return -1;
}
}

int insert(char *sym){
  struct symbol_table *a = (struct symbol_table*) malloc(sizeof(struct symbol_table));
  strcpy(a->sym,sym);
  a->key = key_id;
  int hash_index = hash(key_id);
  int k = 1;
  for(int i = 1; i < MAX_SIZE; i++){
  if(hash_table[i]->sym != NULL && (strcmp(sym,hash_table[i]->sym)==0)){
  k = 0;
  }
  }
  if(k){
  hash_table[hash_index] = a;
  key_id = key_id +1;
  }
}

int dump(){
for(int i = 1; i < MAX_SIZE; i++){
if(hash_table[i] != NULL){
printf("%d %s\n",i,hash_table[i]->sym);
}
}
}


%}

%x STATE_string
%x STATE_dcommet
%x STATE_scommet
digs        [0-9]
integer      {digs}+
real         -?(([0-9]+)([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?)
letter       [a-zA-Z]
identifier   {letter}({letter}|{digit})*
newline      \n
whitespace   [ \t]+
boolean      (true|false)
%%
{boolean}     {tokenString("BOOLEAN",yytext);}


"bool"       {keyword(yytext);}
"break"      {keyword(yytext);}
"case"       {keyword(yytext);}
"const"      {keyword(yytext);}
"continue"   {keyword(yytext);}
"default"    {keyword(yytext);}
"else"       {keyword(yytext);}
"for"        {keyword(yytext);}
"func"       {keyword(yytext);}
"go"         {keyword(yytext);}
"if"         {keyword(yytext);}
"import"     {keyword(yytext);}
"int"        {keyword(yytext);}
"nil"        {keyword(yytext);}
"print"      {keyword(yytext);}
"println"    {keyword(yytext);}
"real"       {keyword(yytext);}
"return"     {keyword(yytext);}
"string"     {keyword(yytext);}
"struct"     {keyword(yytext);}
"switch"     {keyword(yytext);}
"type"       {keyword(yytext);}
"var"        {keyword(yytext);}
"void"       {keyword(yytext);}
"while"      {keyword(yytext);}


"+"          {token;}
"-"          {token;}
"*"          {token;}
"/"          {token;}
"<"          {token;}
">"          {token;}
"<="         {token;}
">="         {token;}
"=="         {token;}
"!="         {token;}
"="          {token;}
";"          {token;}
","          {token;}
"("          {token;}
")"          {token;}
"["          {token;}
"]"          {token;}
"{"          {token;}
"}"          {token;}
{identifier}  {tokenId;}
{integer}     {tokenInteger;}
{real}        {tokenReal;}
"//"          {
                LIST;
                BEGIN STATE_dcommet;
            }
<STATE_dcommet>\n {
                      LIST;
                      printf("%d: %s", linenum++, buf);
                      buf[0] = '\0';
                      BEGIN 0;
                    }
<STATE_dcommet>.     {
                      LIST;
                    }

"/*"               {
                      LIST;
                      BEGIN STATE_scommet;
                    }
<STATE_scommet>\n    {
                        LIST;
                        printf("%d: %s", linenum++, buf);
                        buf[0] = '\0';
                      }
<STATE_scommet>"*/"   {
                      LIST;
                      BEGIN 0;
                    }
<STATE_scommet>.     {
                      LIST;
                    }




\"          {
              LIST;
              BEGIN STATE_string;
              }

<STATE_string>\" {
                    char c = input();
                    if(c=='\"')
                    {
                    LIST;
                    strcat(buf,"\"");
                    strcat(str,yytext);
                    }
                    else
                    {
                    tokenString("string",str);
                    unput(c);
                    str[0] = '\0';
                    BEGIN 0;
                    }
                  }
<STATE_string>.     {
                      LIST;
                      strcat(str,yytext);
                    }
\n             {
                  LIST;
                  printf("%d: %s", linenum++, buf);
                  buf[0] = '\0';
                  }

[ \t]*  {LIST;}







%%

int main(){
hash_table = create();
yylex();
printf( "%d of lines\n",linenum );
printf("\n%s\n", "Symbol Table:");
dump();
}
int yywrap()
{
return 1;
}
