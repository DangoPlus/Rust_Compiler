%{  #include  "com.h"
int calltype=0;//函数调用方式__stdcall&__cdecl
int msgIndex = 0;//字符串索引
int label=0;//自动生成标号
%} 
%token IF ELSE WHILE RETURN __CDECL __STDCALL LE LT GT GE EQ NE OR AND INT VOID CHAR FUNCTION ARRAY POINTER NEG

%start program

%union{ 
	int * value;
	struct symbol * symType;
	struct expression * exprType;
	char * op;
 };

%token <symType> ID
%token <symType> NUM
%token <symType> STRING
%token <symType> CHARACTER

%type <exprType> param
%type <exprType> program
//%type <exprType> startstmt
%type <exprType> declaration_list
%type <exprType> declaration
%type <value> type_specifer
%type <exprType> params
%type <exprType> compound_stmt
%type <exprType> param_list
%type <exprType> local_declarations
%type <exprType> var_declaration
%type <exprType> fun_declaration
%type <exprType> statement_list
%type <exprType> statement
%type <exprType> expression_stmt
%type <exprType> if_stmt
%type <exprType> while_stmt
%type <exprType> return_stmt
%type <exprType> expression
%type <exprType> simple_expression
%type <exprType> additive_expression
%type <exprType> var
%type <exprType> relop
%type <exprType> term
%type <op> mulop
%type <exprType> unary_expression
%type <op> unaryop
%type <exprType> factor
%type <exprType> call
%type <exprType> args
%type <exprType> arg_list
%type <value> calling_convention
%type <exprType> loc_declaration
%type <op> addop

%right  '='
%left   '+' '-'
%left   '*' '/' '%' 

%%
program    : declaration_list
     {
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $1->code ) + 100 );
      sprintf( $$->code, "%sEND main\n", $1->code );
      fprintf( yyout, ".386\n.MODEL flat, stdcall\n.Stack 4096\n" );
      fprintf( yyout, "\n%s", funBuffer );
      fprintf( yyout, "\n.data\n%s", varBuffer );
      fprintf( yyout, "\n.code\n%s", $$->code );
     }
     ;
declaration_list : declaration_list declaration
     {
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $1->code ) + strlen( $2->code ) + 1 );
      sprintf( $$->code, "%s%s", $1->code, $2->code );
     }
     | declaration
     {
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $1->code ) + 1 );
      sprintf( $$->code, "%s", $1->code );
     }
     ;
declaration   : var_declaration
     {
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $1->code ) + 1 );
      sprintf( $$->code, "");
      sprintf( varBuffer, "%s%s", varBuffer, $1->code ); 
     }
     | fun_declaration
     {
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $1->code ) + 10 );
      sprintf( $$->code, "%s", $1->code );
     }
     ;
var_declaration  : type_specifer ID ';'
     {
      if( lookup( $2->name, currentTable ) == NULL )
      {
       $2 = install($2->name, &currentTable, currentLevel, ID);
       $2->isLocal = 0;
      }
      else
      {
       char msg[100];
       sprintf( msg, "Variable %s redefinition: ", $2->name );
       yyerror( msg );
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $2->ty = 1;
        yyerror( "Type Error: " );
        break;
       case 2:
        $2->ty = 2;
        sprintf( $$->code, " %s DWORD 0\n", $2->name );
        break;
       case 3:
        $2->ty = 3;
        sprintf( $$->code, " %s BYTE 0\n", $2->name );
        break;
      }
     }
     | type_specifer ID '[' NUM ']' ';'
     {
      if( lookup( $2->name, currentTable ) == NULL )
      {
       $2 = install($2->name, &currentTable, currentLevel, ID);
       $2->isLocal = 0;
      }
      else
      {
       char msg[100];
       sprintf( msg, "Variable %s redefinition: ", $2->name );
       yyerror( msg );
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + strlen( $4->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $2->ty = 21;
        yyerror( "Type Error: " );
        break;
       case 2:
        $2->ty = 22;
        sprintf( $$->code, " %s DWORD %s DUP(0)\n", $2->name, $4->name );
        break;
       case 3:
        $2->ty = 23;
        sprintf( $$->code, " %s BYTE %s DUP(0)\n", $2->name, $4->name );
        break;
      }
     }
     | type_specifer '*' ID ';'
     {
      if( lookup( $3->name, currentTable ) == NULL )
      {
       $3 = install($3->name, &currentTable, currentLevel, ID);
       $3->isLocal = 0;
      }
      else
      {
       char msg[100];
       sprintf( msg, "Variable %s redefinition: ", $3->name );
       yyerror( msg );
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $3->ty = 11;
        yyerror( "Type Error: " );
        break;
       case 2:
        $3->ty = 12;
        sprintf( $$->code, " %s PTR DWORD 0\n", $3->name );
        break;
       case 3:
        $3->ty = 13;
        sprintf( $$->code, " %s PTR BYTE 0\n", $3->name );
        break;
      }
     }
     | type_specifer '*' ID '[' NUM ']' ';'
     {
      if( lookup( $3->name, currentTable ) == NULL )
      {
       $3 = install($3->name, &currentTable, currentLevel, ID);
       $3->isLocal = 0;
      }
      else
      {
       char msg[100];
       sprintf( msg, "Variable %s redefinition: ", $3->name );
       yyerror( msg );
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->name ) + strlen( $5->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $3->ty = 31;
        yyerror( "Type Error: " );
        break;
       case 2:
        $3->ty = 32;
        sprintf( $$->code, " %s PTR DWORD %s DUP(0)\n", $3->name, $5->name );
        break;
       case 3:
        $3->ty = 33;
        sprintf( $$->code, " %s PTR BYTE %s DUP(0)\n", $3->name, $5->name );
        break;
      }
     }
     ;
loc_declaration  : type_specifer ID ';'
     {
      Symbol temp;
      if( (temp = lookup( $2->name, currentTable )) == NULL )
      {
       $2 = install($2->name, &currentTable, currentLevel, ID);
       $2->isLocal = 1;
      }
      else
      {
       if( temp->scope == currentLevel )
       {
        char msg[100];
        sprintf( msg, "Variable %s redefinition: ", $2->name );
        yyerror( msg );
       }
       else
       {
        $2 = install($2->name, &currentTable, currentLevel, ID);
        $2->isLocal = 1; 
       }
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $2->ty = 1;
        yyerror( "Type Error: " );
        break;
       case 2:
        $2->ty = 2;
        sprintf( localValBuffer, "%s\tlocal %s:DWORD\n", localValBuffer, $2->name );
        break;
       case 3:
        $2->ty = 3;
        sprintf( localValBuffer, "%s\tlocal %s:BYTE\n", localValBuffer, $2->name );
        break;
      }
      sprintf( $$->code, "" );
      paramcount++;
      realParam++;
     }
     | type_specifer ID '[' NUM ']' ';'
     {
      Symbol temp;
      if( (temp = lookup( $2->name, currentTable )) == NULL )
      {
       $2 = install($2->name, &currentTable, currentLevel, ID);
       $2->isLocal = 1;
      }
      else
      {
       if( temp->scope == currentLevel )
       {
        char msg[100];
        sprintf( msg, "Variable %s redefinition: ", $2->name );
        yyerror( msg );
       }
       else
       {
        $2 = install($2->name, &currentTable, currentLevel, ID);
        $2->isLocal = 1; 
       }
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + strlen( $4->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $2->ty = 21;
        yyerror( "Type Error: " );
        break;
       case 2:
        $2->ty = 22;
        sprintf( localValBuffer, "%s\tlocal %s[%s]:DWORD\n", localValBuffer, $2->name, $4->name );
        break;
       case 3:
        $2->ty = 23;
        sprintf( localValBuffer, "%s\tlocal %s[%s]:BYTE\n", localValBuffer, $2->name, $4->name );
        break;
      }
      sprintf( $$->code, "" );
      paramcount++;
      realParam++;
     }
     | type_specifer '*' ID ';'
     {
      Symbol temp;
      if( (temp = lookup( $3->name, currentTable )) == NULL )
      {
       $3 = install($3->name, &currentTable, currentLevel, ID);
       $3->isLocal = 1;
      }
      else
      {
       if( temp->scope == currentLevel )
       {
        char msg[100];
        sprintf( msg, "Variable %s redefinition: ", $3->name );
        yyerror( msg );
       }
       else
       {
        $3 = install($3->name, &currentTable, currentLevel, ID);
        $3->isLocal = 1; 
       }
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $3->ty = 11;
        yyerror( "Type Error: " );
        break;
       case 2:
        $3->ty = 12;
        sprintf( localValBuffer, "\tlocal %s:PTR WORD\n", $3->name );
        break;
       case 3:
        $3->ty = 13;
        sprintf( localValBuffer, "\tlocal %s:PTR BYTE\n", $3->name );
        break;
      }
      sprintf( $$->code, "" );
      paramcount++;
      realParam++;
     }
     | type_specifer '*' ID '[' NUM ']' ';'
     {
      Symbol temp;
      if( (temp = lookup( $3->name, currentTable )) == NULL )
      {
       $3 = install($3->name, &currentTable, currentLevel, ID);
       $3->isLocal = 1;
      }
      else
      {
       if( temp->scope == currentLevel )
       {
        char msg[100];
        sprintf( msg, "Variable %s redefinition: ", $3->name );
        yyerror( msg );
       }
       else
       {
        $3 = install($3->name, &currentTable, currentLevel, ID);
        $3->isLocal = 1; 
       }
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->name ) + strlen( $5->name ) + 13 );
      switch( *$1 )
      {
       case 1:
        $3->ty = 31;
        yyerror( "Type Error: " );
        break;
       case 2:
        $3->ty = 32;
        sprintf( localValBuffer, "\tlocal %s[%s]:DWORD\n", $3->name, $5->name );
        break;
       case 3:
        $3->ty = 33;
        sprintf( localValBuffer, "\tlocal %s[%s]:BYTE\n", $3->name, $5->name );
        break;
      }
      sprintf( $$->code, "" );
      paramcount++;
      realParam++;
     }
     ;
type_specifer  : INT
     {
      $$ = (int*)malloc( sizeof( int ) );
      *$$ = 2;
     }
     | VOID
     {
      $$ = (int*)malloc( sizeof( int ) );
      *$$ = 1;
     }
     | CHAR
     {
      $$ = (int*)malloc( sizeof( int ) );
      *$$ = 3;
     }
     ;
fun_declaration  : type_specifer calling_convention ID '(' params ')' compound_stmt
     {
      
//      if( lookup( $3->name, currentTable ) == NULL )
//      {
//       $3 = install($3->name, &currentTable, currentLevel, ID);
//      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $3->name )*2 + strlen( $5->code ) + strlen( $7->code ) + strlen( localValBuffer ) + 12 );
      if( *$2== 0 && params > 0 )
      {
//       $3->calltype = 0;
       sprintf( $$->code, "%s PROC%s\n%s\tsub esp, %d\n%s\tret %d\n%s ENDP\n", $3->name, $5->code,localValBuffer, (paramcount-realParam)*4, $7->code,  4*params, $3->name );
      }
      else
      {
//       $3->calltype = 1;
       sprintf( $$->code, "%s PROC%s\n%s\tsub esp, %d\n%s\tret\n%s ENDP\n", $3->name, $5->code, localValBuffer, (paramcount-realParam)*4,$7->code, $3->name ); 
      }
      params = 0;
      paramcount = 0;
      realParam = 0;
      sprintf( localValBuffer, "" );
     }
     | type_specifer calling_convention ID '(' params ')' ';'
     {
      if( lookup( $3->name, currentTable ) == NULL )
      {
       $3 = install($3->name, &currentTable, currentLevel, ID);
      }
      else
      {
        char msg[100];
        sprintf( msg, "The Function %s redefinition: ", $3->name );
        yyerror( msg );       
      }
      if( *$2== 0 && params > 0 )
      {
       $3->calltype = 0;
      }
      else
      {
       $3->calltype = 1; 
      }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = "";
      sprintf( funBuffer, "%s PROTO%s\n", $3->name, $5->code );
     }
     | type_specifer ID '(' params ')' compound_stmt
     {
 //     if( lookup( $2->name, currentTable ) == NULL )
 //     {
 //      $2 = install($2->name, &currentTable, currentLevel, ID);
 //     }
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = ( char * ) malloc( strlen( $2->name ) * 2 + strlen( $4->code ) + strlen( $6->code ) + strlen( localValBuffer ) + 20 );
 //     $2->calltype = 0;
      if( params > 0 )
      {
       sprintf( $$->code, "%s PROC%s\n%s\tsub esp, %d\n%s\tret %d\n%s ENDP\n", $2->name, $4->code, localValBuffer, (paramcount-realParam)*4, $6->code, 4*params, $2->name );
      }
      else
      {
       sprintf( $$->code, "%s PROC%s\n%s\tsub esp, %d\n%s\tret\n%s ENDP\n", $2->name, $4->code, localValBuffer, (paramcount-realParam)*4, $6->code, $2->name );
      }
      params = 0;
      paramcount = 0;
      realParam = 0;
      sprintf( localValBuffer, "" );
     }
     | type_specifer ID '(' params ')' ';'
     {
      if( lookup( $2->name, currentTable ) == NULL )
      {
       $2 = install($2->name, &currentTable, currentLevel, ID);
      }
      else
      {
       char msg[100];
       sprintf( msg, "The Function %s redefinition: ", $2->name );
       yyerror( msg );
      }
      $2->calltype = 0;
      $$ = ( expr * ) malloc( sizeof( expr ) );
      $$->code = "";
      sprintf( funBuffer, "%s%s PROTO%s\n", funBuffer, $2->name, $4->code );
     }
     ;
params    : param_list
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = $1->code;
     }
     | VOID
     {
      params = 0;
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = "";
     }
     ;
param_list   : param_list ',' param
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + strlen( $3->code ) + 1 );
      sprintf( $$->code, "%s%s", $1->code, $3->code );
      params++;
     }
     | param
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = $1->code;
      params = 1;
     }
     ;
param    : type_specifer ID
     {
      Symbol temp = install($2->name, &currentTable, currentLevel+1, ID);
      $$->code = (char *) malloc( 100 );
      switch( *$1 )
      {
       case 1:
        temp->ty = 1;
        yyerror( "Parameters Type Error: " );
        break;
       case 2:
        temp->ty = 2;
        sprintf( $$->code, ", %s:DWORD", $2->name );
        break;
       case 3:
        temp->ty = 3;
        sprintf( $$->code, ", %s:BYTE", $2->name );
        break;
       default:
        break;
      }
     }
     | type_specifer '*' ID
     {
      Symbol temp = install($3->name, &currentTable, currentLevel+1, ID);
      $$->code = (char *) malloc( 100 );
      switch( *$1 )
      {
       case 1:
        temp->ty=11;
        sprintf( $$->code, ", %s:PTR DWORD", $3->name );
        break;
       case 2:
        temp->ty=12;
        sprintf( $$->code, ", %s:PTR WORD", $3->name );
        break;
       case 3:
        temp->ty=13;
        sprintf( $$->code, ", %s:PTR BYTE", $3->name );
        break;
      }
     }
     | type_specifer ID '[' ']'
     {
      Symbol temp = install($2->name, &currentTable, currentLevel+1, ID);
      $$->code = (char *) malloc( 100 );
      switch( *$1 )
      {
       case 1:
        temp->ty = 21;
        yyerror( "Parameters Type Error: " );
        break;
       case 2:
        temp->ty = 22;
        sprintf( $$->code, ", %s:PTR WORD", $2->name );
        break;
       case 3:
        temp->ty = 23;
        sprintf( $$->code, ", %s:PTR BYTE", $2->name );
        break;
      }
     }
     | type_specifer '*' ID '[' ']'
     {
      Symbol temp = install($3->name, &currentTable, currentLevel+1, ID);
      $$->code = (char *) malloc( 100 );
      switch( *$1 )
      {
       case 1:
        temp->ty = 31;
        sprintf( $$->code, ", %s:DWORD", $3->name );
        break;
       case 2:
        temp->ty = 32;
        sprintf( $$->code, ", %s:DWORD", $3->name );
        break;
       case 3:
        temp->ty = 33;
        sprintf( $$->code, ", %s:DWORD", $3->name );
        break;
      }
      
     }
     ;
compound_stmt  : '{' local_declarations statement_list '}'
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->code ) + strlen( $3->code ) + 12 );
      sprintf( $$->code, "%s%s", $2->code, $3->code );
     }
     ;
local_declarations : /*空值*/
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = "";
     }
     | local_declarations loc_declaration
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + strlen( $2->code ) + 1 );
      sprintf( $$->code, "%s%s", $1->code, $2->code );
     }
     ;
statement_list  : /*空值*/
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 2 );
      $$->code = "";
     }
     | statement_list statement
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + strlen( $2->code ) + 1 );
      sprintf( $$->code, "%s%s", $1->code, $2->code );
     }
     ;
statement   : expression_stmt
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code )+20 );
      sprintf( $$->code, "%s\n", $1->code );
     }
     | compound_stmt
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = $1->code;
     }
     | if_stmt
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = $1->code;
     }
     | while_stmt
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = $1->code;
     }
     | return_stmt
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = $1->code;
     }
     ;
expression_stmt  : expression ';'
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      //$$->code = (char *) malloc( strlen( $1->code )+20 );
      $$->code= $1->code;
     }
     | ';'
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 2 );
      sprintf( $$->code, "" );
     }
     ;
if_stmt    : IF '(' expression ')' statement
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->code ) + strlen( $5->code ) + strlen( $3->temp ) + 30 );
      sprintf( $$->code, "%s\t.IF %s\n%s\t.ENDIF\n", $3->temp, $3->code, $5->code );
     }
     | IF '(' expression ')' statement ELSE statement
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->code ) + strlen( $5->code ) + strlen( $3->temp ) + strlen( $7->code ) + 10 );
      sprintf( $$->code, "%s\t.IF %s\n%s\t.ELSE\n%s\t.ENDIF\n", $3->temp, $3->code, $5->code, $7->code );
     }
     ;
while_stmt   : WHILE '(' expression ')' statement
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->temp ) + strlen( $3->code ) + strlen( $5->code ) + strlen($3->temp)  + 10 );
      sprintf( $$->code, "_label%d:\n%s\t.IF !( %s ) \n\tjmp _label%d\n\t.ENDIF\n%s\tjmp _label%d\n_label%d:\n", label, $3->temp, $3->code,label+1, $5->code, label, label + 1 );
      label += 2;
     }
     ;
return_stmt   : RETURN ';'
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 15 );
      sprintf( $$->code, "\tmov eax, 0\n\tret\n" );
     }
     | RETURN expression ';'
     {
      $$ = (expr*) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + strlen( $2->code ) + 15 );
      sprintf( $$->code, "%s\tmov eax, %s\n\tret\n", $2->code, $2->name );
     }
     ;
expression   : var '=' expression
     {
      
      if( $1->value == 0 )
      {
       $$ = (expr *) malloc( sizeof( expr ) );
       $$->code = (char *) malloc( strlen( $1->code ) + strlen( $3->code )+ strlen( $3->name ) + 100 );
       sprintf( $$->code, "%s\tmov eax, %s\n\tmov %s, eax\n", $3->code, $3->name, $1->code );
       $$->name = (char *)malloc( sizeof( $1->name ) );
       sprintf( $$->name, "%s", $1->name );
       $$->temp = $$->code;
      }
      else
      {
       
       
       $$ = (expr *) malloc( sizeof( expr ) );
	 $$->code = (char *) malloc( strlen( $1->name ) + strlen( $1->code ) + strlen( $3->code )+ strlen( $3->name ) + 100 );
	sprintf( $$->code, "%s\tmov eax, %s\n%s\tmov %s, eax\n", $3->code, $3->name, $1->code, $1->name );
  //   sprintf( s, "%s\tmov eax, ", $3->code );
  // 	 sprintf( s, "%s%s\n", s, $3->name );
  //   sprintf( s, "%s%s\tmov ", s, $1->code );
  //   sprintf( s, "%s%s, eax\n", s, $1->name );
       //$$->code = (char *) malloc( strlen( $1->name ) + strlen( $1->code ) + strlen( $3->code )+ strlen( $3->name ) + 100 );
      // $$->code = s;
       $$->name = (char *)malloc( sizeof( $1->code ) );
       sprintf( $$->name, "%s", $1->code );
       $$->temp = $$->code; 
       
      }
     }
     | simple_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + 1 );
      $$->name = $1->name;
      sprintf( $$->code, "%s", $1->code );
      $$->temp = $1->temp;
     }
     ;
var     : ID
     {
      if( lookup( $1->name, currentTable ) == NULL )
      {
       char msg[100];
       sprintf( msg, "Variable %s haven't been defined: ", $1->name );
       yyerror( msg );       
      }
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->name ) + 1 );
      sprintf( $$->code, "%s", $1->name );
      $$->is_const = 1;
      $$->name = $1->name;
      $$->value = 0;
     }
     | ID '[' expression ']'
     {
      Symbol temp;
      if( (temp = lookup( $1->name, currentTable )) == NULL )
      {
       char msg[100];
       sprintf( msg, "Variable %s haven't been defined: ", $1->name );
       yyerror( msg );       
      }
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $3->code ) + strlen( $3->name ) + 10 );
      sprintf( $$->code, "%s\tmov edi, %s\n", $3->code, $3->name );
      $$->name = (char *)malloc( sizeof( $1->name ) );
      sprintf( $$->name, "DWORD ptr %s[edi]", $1->name );
      $$->temp = $$->code;
      $$->value = 1;
     }
     | '*' ID
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->name ) + 10 );
      sprintf( $$->code, "\tmov esi, %s\n", $2->name ); 
      $$->name = (char *)malloc( sizeof( 6 ) );
      sprintf( $$->name, "DWORD PTR [esi]" );
      $$->value = 1;
     }
     ;
simple_expression : additive_expression relop additive_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc(  strlen( $3->name ) + strlen( $2->code ) + 5 );
      sprintf( $$->code, "edx %s %s", $2->code, $3->name );
      $$->temp = (char *) malloc( strlen( $1->code ) +strlen( $1->code ) + strlen( $3->code ) + 20 );
      sprintf( $$->temp, "%s%s\tmov edx, %s\n", $3->code, $1->code, $1->name );
     }
     | additive_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->value = $1->value;
      $$->code = $1->code;
      $$->name = $1->name;
     }
     ;
relop    : LE
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 3 );
      sprintf( $$->code, "<=" );
     }
     | LT
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 2 );
      sprintf( $$->code, "<" );
     }
     | GT
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 2 );
      sprintf( $$->code, ">" );
     }
     | GE
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 3 );
      sprintf( $$->code, ">=" );
     }
     | EQ
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 3 );
      sprintf( $$->code, "==" );
     }
     | NE
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 3 );
      sprintf( $$->code, "!=" );
     }
     ;
additive_expression : additive_expression addop term
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      switch( *$2 )
      {
       case '+':
        $$->code = (char *) malloc( strlen($1->code) + strlen($1->name) + strlen($3->name) + strlen($3->code) + 1024 );
        sprintf( $$->code, "%s%s\tmov eax, %s\n\tadd eax, %s\n", $1->code, $3->code, $1->name, $3->name );
        $$->name = (char *) malloc( 20 );
        sprintf( $$->name, "[ebp-%d]", 4*(paramcount+1) );
        paramcount++;
        sprintf( $$->code, "%s\tmov %s, eax\n", $$->code, $$->name );
        break;
       case '-':
        $$->code = (char *) malloc( strlen($1->code) + strlen($1->name) + strlen($3->name) + 1024 );
        sprintf( $$->code, "%s%s\tmov eax, %s\n\tsub eax, %s\n", $3->code, $1->code, $1->name, $3->name );
        $$->name = (char *) malloc( 20 );
        sprintf( $$->name, "[ebp-%d]", 4*(paramcount+1) );
        paramcount++;
        sprintf( $$->code, "%s\tmov %s, eax\n", $$->code, $$->name );
        break;
      }
      $$->value = 0;
     }
     | term
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + 1 );
      if( $1->is_const == 1 )
      {
       strcpy( $$->code, "" );
      }
      else
      {
       strcpy( $$->code, $1->code );
      }
      $$->name = $1->name;
      $$->value = 1;
     }
     ;
addop    : '+'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = '+';
     }
     | '-'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = '-';
     }
     ;
term    : term mulop unary_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      switch( *$2 )
      {
       case '*':
        $$->code = (char *) malloc( strlen($1->code) + strlen($1->name) + strlen($3->name) + 1024 );
        sprintf( $$->code, "%s\tmov eax, %s\n\tmov ebx, %s\n\timul ebx\n", $1->code, $1->name, $3->name );
        $$->name = (char *) malloc( 20 );
        sprintf( $$->name, "[ebp-%d]", 4*(paramcount+1) );
        paramcount++;
        sprintf( $$->code, "%s\tmov %s, eax\n", $$->code, $$->name );
        break;
       case '/':
        $$->code = (char *) malloc( strlen($1->code) + strlen($1->name) + strlen($3->name) + 1024 );
        sprintf( $$->code, "%s\tmov eax, %s\n\tcdq\n\tmov ebx, %s\n\tidiv ebx\n", $1->code, $1->name, $3->name );
        $$->name = (char *) malloc( 20 );
        sprintf( $$->name, "[ebp-%d]", 4*(paramcount+1) );
        paramcount++;
        sprintf( $$->code, "%s\tmov %s, eax\n", $$->code, $$->name );
        break;
       case '%':
        $$->code = (char *) malloc( strlen($1->code) + strlen($1->name) + strlen($3->name) + 1024 );
        sprintf( $$->code, "%s\tmov eax, %s\n\tcdq\n\tmov ebx, %s\n\tidiv ebx\n", $1->code, $1->name, $3->name );
        $$->name = (char *) malloc( 20 );
        sprintf( $$->name, "[ebp-%d]", 4*(paramcount+1) );
        paramcount++;
        sprintf( $$->code, "%s\tmov %s, edx\n", $$->code, $$->name );
        break;
      } 
      $$->is_const = 0;
     }
     | unary_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + 1 );
      if( $1->is_const == 1 )
      {
       strcpy( $$->code, "" );
      }
      else
      {
       strcpy( $$->code, $1->code );
      }
      $$->name = $1->name;
      $$->is_const = $1->is_const;
     }
     ;
mulop    : '*'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = '*';
     }
     | '/'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = '/';
     }
     | '%'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = '%';
     }
     ;
unary_expression : unaryop unary_expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->code ) + 10 );
      sprintf( $$->code, "%s\tmov ebx, %s\n\tneg ebx\n", $2->code, $2->name );
      $$->name = (char *) malloc( 6 );
      sprintf( $$->name, "ebx" );
      $$->is_const = 0;
     }
     | factor
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = $1->code;
      $$->name = $1->name;
      $$->is_const = $1->is_const;
     }
     ;
unaryop    : '-'
     {
      $$ = (char *) malloc( sizeof( char ) );
      *$$ = NEG;//用数NEG表示负号;
     }
     ;
factor    : '(' expression ')'
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $2->code ) + 1 );
      sprintf( $$->code, "%s", $2->code );
      $$->name = $2->name;
      $$->is_const = 0;
     }
     | var
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      if( $1->value == 0 )
      {
       $$->code = (char *) malloc( strlen( $1->code ) + 1 );
       sprintf( $$->code, "%s", $1->code );
       $$->name = $1->name;
       $$->is_const = 1;
      }
      else if( $1->value == 1 )
      {
       $$->code = (char *) malloc( strlen( $1->name ) + 1 );
       sprintf( $$->code, "%s", $1->name );
       $$->name = $1->code;
       $$->is_const = 1;
      }
     }
     | call
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->code ) + 1 );
      sprintf( $$->code,"%s", $1->code );
      $$->name = ( char * )malloc(4);
      sprintf( $$->name, "eax" );
      $$->code = $1->code;
      $$->is_const = 0;
     }
     | NUM
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->name ) + 1 );
      sprintf( $$->code, "" );
      $$->is_const = 1;
      $$->value = atoi( $1->name );
      $$->name = $1->name;
     }
     | STRING
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->name ) + 1 );
      sprintf( $$->code, "" );
      $$->is_const = 1;
      $$->name = (char *) malloc( 20 );
      sprintf( $$->name, "_msg%d", msgIndex );
      sprintf( varBuffer, "%s\t%s BYTE %s, 0\n", varBuffer, $$->name, $1->name );
      sprintf( $$->name, "offset _msg%d", msgIndex );
      msgIndex++;
     }
     ;
call    : ID '(' args ')'
     {
      if( lookup( $1->name, currentTable ) == NULL )
      {
        char msg[100];
        sprintf( msg, "The Function %s must be declared: ", $1->name );
        yyerror( msg );
      }
      
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->name ) + strlen( $3->code) + 50 );
      sprintf( $$->code, "%s\tcall %s\n", $3->code, $1->name );
     }
     ;
args    : /*空值*/
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( 1 );
      sprintf( $$->code, "" );
     }
     | arg_list
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen($1->code) + strlen( $1->temp ) + 1 );
      sprintf( $$->code, "%s%s", $1->temp, $1->code );
     }
     ;
arg_list   : arg_list ',' expression
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen($1->code) + strlen($3->code) + 10 );
      sprintf( $$->code, "\tpush %s\n%s", $3->name, $1->code );
      $$->temp = (char *) malloc(  strlen( $1->temp ) + strlen( $3->code ) + 1 );
      sprintf( $$->temp, "%s%s", $1->temp, $3->code );
      callparam++;
     }
     | expression
     {
      callparam = 1;
      $$ = (expr *) malloc( sizeof( expr ) );
      $$->code = (char *) malloc( strlen( $1->name ) + 10 );
      sprintf( $$->code, "\tpush %s\n", $1->name );
      $$->temp = (char *) malloc( strlen( $1->code ) + 10 );
      sprintf( $$->temp, "%s", $1->code );
     }
     ;
calling_convention : __CDECL
     {
      $$ = (expr *)malloc(sizeof(expr));
      *$$ = 1;
     }
     | __STDCALL
     {
      $$ = (expr *) malloc( sizeof( expr ) );
      *$$ = 0;
     }
     ;

%%
/*#include "Lex.yy.c"*/
int yyparse();
void yyerror();

extern FILE *yyin,*yyout;
extern int lineno;
extern char *yytext;

int main( int argc, char **argv )
{
 FILE *fp ;

 currentTable = table( NULL, 0 );
 currentLevel = 0;
 ++argv;
 --argc;
 if(argc > 0)
  yyin = fopen(argv[0],"r");
 else
  yyin = stdin;
 ++argv;
 --argc;
 if(argc > 0)
  yyout  = fopen(argv[0],"w");
 else
  yyout  = stdout;
// fp = fopen( "a.txt", "r" );
// yyin = fp;
// fp  = fopen( "c.asm", "w" );
// yyout = fp;
 return(yyparse());
}

void yyerror( char *temp )
{
 printf( "\nline %d: %s %s %d\n", lineno, temp, yytext,  currentLevel );
 exit(1);
}
