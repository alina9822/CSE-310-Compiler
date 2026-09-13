%option noyywrap


%x STRING_START_ST
%x SLASH_COMMENT_ST
%x STAR_COMMENT_ST

%{

#include<bits/stdc++.h>
#include<fstream>
#include "1905099_classes.h"

#include<cstdio>
#include<cstdlib>
#include<string>
#include<stdio.h>
#include<string.h>
#include<vector>

#define MAX_SIZE INT_MAX/10

using namespace std;

#include "y.tab.h"//necessary

extern YYSTYPE yylval;//necessary
extern void yyerror(char*);//necessary

extern FILE *logout;//necessary
extern FILE *tokenout;
extern FILE *errorout;

extern int line_count;
extern int error_count;

int error_line;
bool multi_line=false;
char const_char_lexeme;

char string_log[MAX_SIZE]="";
char string_token[MAX_SIZE]="";

char comment_log[MAX_SIZE]="";
char comment_token[MAX_SIZE]="";



//ScopeTable st;
extern SymbolTable symbol_table;

char* myToUpper(char* token){
	for (int i = 0 ; token[i] != '\0'; i++) {
		token[i]=toupper(token[i]);
    }

	return token;
}

void foundKeyword()
{
	char lexeme[yyleng+5]="";
	strcpy(lexeme,yytext);
	fprintf(tokenout,"<%s, %s>\n",myToUpper(yytext),lexeme);
	fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,yytext,lexeme);
}

void foundOperator(char* token)
{
	fprintf(tokenout,"<%s, %s>\n",token,yytext);
	fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,token,yytext);
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

FLOAT {DIGIT}*(\.)?{DIGIT}+([Ee][+-]?{DIGIT}+)?
CHARACTER_BUT_BACKSLASH ([ -~]{-}['\\])
CHARACTER_BUT_BACKSLASH_SEMICOLON ([ -~]{-}['\\;])
IDENTIFIERS	[A-Za-z_][A-Za-z0-9_]*
ADDOP [+-] 
MULOP [*/%]

%%

{NEWLINE} {line_count++;}

[\n\r]		{
	return NEWLINE;
}

{WHITESPACE} {}

"if" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"IF");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return IF;
    }
"else" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ELSE");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return ELSE;
    }
"for" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FOR");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return FOR;
    }
"while" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"WHILE");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return WHILE;
    }
"int" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INT");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return INT;
    }
"float" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FLOAT");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return FLOAT;
    }
"double" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DOUBLE");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return DOUBLE;
    }
"char" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CHAR");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return CHAR;
    }
"return" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RETURN");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return RETURN;
    }
"void" {
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"VOID");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return VOID;
    }

"println"	{
    foundKeyword();
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"PRINTLN");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return PRINTLN;
    }


{ADDOP} { 
            foundOperator("ADDOP");
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
			s->setStartLine(line_count);
            s->setEndLine(line_count);
            s->setLeaf(true);
            yylval.symbol =s;
			return ADDOP;
		}



{MULOP}	{
            foundOperator("MULOP");
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
			s->setStartLine(line_count);
            s->setEndLine(line_count);
            s->setLeaf(true);
            yylval.symbol =s;
			return MULOP;
		}

"++" 	{
            foundOperator("INCOP");
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INCOP");
			s->setStartLine(line_count);
            s->setEndLine(line_count);
            s->setLeaf(true);
            yylval.symbol =s;
            return INCOP;
    }


"--" 	{
            foundOperator("DECOP");
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DECOP");
			s->setStartLine(line_count);
            s->setEndLine(line_count);
            s->setLeaf(true);
            yylval.symbol =s;
            return DECOP;
            }

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
        foundOperator("RELOP");
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
		s->setStartLine(line_count);
        s->setEndLine(line_count);
        s->setLeaf(true);
        yylval.symbol = s;
		return RELOP;
	}

"=" 	{
        foundOperator("ASSIGNOP");
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ASSIGNOP");
		s->setStartLine(line_count);
        s->setEndLine(line_count);
        s->setLeaf(true);
        yylval.symbol = s;
        return ASSIGNOP;
    }

"&&"	|
"||"	{
		foundOperator("LOGICOP");
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP");
		s->setStartLine(line_count);
        s->setEndLine(line_count);
        s->setLeaf(true);
        yylval.symbol = s;
		return LOGICOP;
		}


"!"		{	
    foundOperator("NOT");
		SymbolInfo *s= new  SymbolInfo(yytext, (char *)"NOT");
		s->setStartLine(line_count);
        s->setEndLine(line_count);
        s->setLeaf(true);
        yylval.symbol = s;
    return NOT; 
    }



";" 	{ 
    foundOperator("SEMICOLON");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"SEMICOLON");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return SEMICOLON;
    }

"," 	{
    foundOperator("COMMA");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"COMMA");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return COMMA;
    }

"(" 	{
    foundOperator("LPAREN");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LPAREN");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
	s->setLeaf(true);
    yylval.symbol = s;
    return LPAREN;
    }

")" 	{
    foundOperator("RPAREN");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RPAREN");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
	s->setLeaf(true);
    yylval.symbol = s;
    return RPAREN;
    }

"{" 	{
    foundOperator("LCURL");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LCURL");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
	s->setLeaf(true);
    yylval.symbol = s;

    //symbol_table.EnterScope();
    return LCURL;
    }

"}" 	{
    foundOperator("RCURL");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RCURL");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
	s->setLeaf(true);
    yylval.symbol = s;

    //symbol_table.ExitScope();
    return RCURL;
    }

"[" 	{
    foundOperator("LSQUARE");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LSQUARE");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return LSQUARE;
    }
"]" 	{
    foundOperator("RSQUARE");
    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RSQUARE");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
    return RSQUARE;
    }



{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
				
				// //insert in symbol table and print symbol table content(only non empty buckets)
				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT");
                s->setStartLine(line_count);
                s->setEndLine(line_count);
				s->setLeaf(true);
                yylval.symbol=s;
				return CONST_INT;
			}

{FLOAT}		{
				fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);

				SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
				s->setStartLine(line_count);
                s->setEndLine(line_count);
				s->setLeaf(true);
                yylval.symbol=s;
				return CONST_FLOAT;
			}

			

{IDENTIFIERS}	{
	fprintf(tokenout,"<ID, %s>\n",yytext);
	fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);

    SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ID");
    s->setStartLine(line_count);
    s->setEndLine(line_count);
    s->setLeaf(true);
    yylval.symbol=s;
//NEED TO CHECK THE LENGTH

	return ID;

	// if(symbol_table.Insert(new SymbolInfo(yytext,"ID")))
	// {
	// 	symbol_table.PrintAllScopeTable();
	// }
}


<INITIAL><<EOF>>	{
	// symbol_table.PrintAllScopeTable();
	// fprintf(logout,"Total lines: %d\nTotal errors: %d\n",line_count,error_count);
	return 0;
}


%%

// int main(int argc, char** argv) {
// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}
	
// 	FILE *fin=fopen(argv[1],"r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}
	
// 	logout= fopen("log.txt","w");
// 	tokenout= fopen("token.txt","w");

// 	symbol_table.fileWork(logout);

// 	yyin= fin;
// 	yylex();
// 	//st.print();
// 	fclose(yyin);
// 	fclose(tokenout);
// 	fclose(logout);
// 	return 0;
// }
