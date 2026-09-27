%{
#include<bits/stdc++.h>
#include<fstream>
#include "1905099_classes.h"

#include<sstream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<stdio.h>
#include<string.h>
#include<vector>

#define MAX_SIZE INT_MAX/10

using namespace std;

int yyparse(void);
int yylex(void);

extern FILE *yyin;
// File *inputFile;//may need

FILE *logout;
FILE *tokenout;
FILE *errorout;
FILE *parseout;
//FILE *fout;

SymbolTable symbol_table(11);//may need
//SymbolTable *symbol_table;//check



int line_count=1;
int error_count=0;
// string currType="";

// bool isError=false;
// vector <SymbolInfo*>* tempParamList;
// SymbolInfo* currFunc;

struct variable{
    string v_name;
    int v_size;//if not array -1
}temp_var;

vector<variable> temp_var_list;//declaration list

struct parameter{
    string p_name;
    string p_type;
}temp_par;

vector<parameter> temp_par_list;//parameter list

vector <SymbolInfo*> tempChildList;//for printing parse tree

char* stTOch(string str)
{
    int i;
    int s=str.length()+5;
    char *ch=(char *)malloc(s * sizeof(char));
    for(i=0;str[i]!='\0';i++)
        ch[i]=str[i];
    ch[i]='\0';
    //printf("%s\n",ch);

    return ch;
}

char* myToLower(char* token){
	for (int i = 0 ; token[i] != '\0'; i++) {
		token[i]=tolower(token[i]);
    }

	return token;
}

ofstream asmFile;
int tempCount = 0;
int labelCount = 0;
string currentIfFalseLabel = "";
string currentIfEndLabel = "";
string currentWhileStartLabel = "";
string currentWhileEndLabel = "";

string newTemp()
{
    return "t" + to_string(tempCount++);
}

string newLabel()
{
    return "L" + to_string(labelCount++);
}

string asmRelop(const string &op)
{
    if (op == ">") return "JG";
    if (op == ">=") return "JGE";
    if (op == "<") return "JL";
    if (op == "<=") return "JLE";
    if (op == "==") return "JE";
    if (op == "!=") return "JNE";
    return "CMP";
}

void emitCode(const string &line)
{
    if (asmFile.is_open())
        asmFile << line << endl;
}

string getOperandName(SymbolInfo *sym)
{
    if (sym == NULL)
        return "";
    return sym->getName();
}

void yyerror(char *s)
{
	//write your code
	//cout<<s<<endl;
    //fprintf(errorout,"Line# %d: Redifinition of variable %s\n",line_count,temp_var_list[i].v_name.c_str());
	fprintf(errorout,"%s",s);
}

void PrintParseTree(SymbolInfo* sym,int depth)
{
    int loop =depth;
    while(loop--)
    {
        fprintf(parseout," ");
    }
    if(sym->isLeaf())
    {
        fprintf(parseout,"%s : %s\t",sym->getType().c_str(),myToLower(stTOch(sym->getName())));
        fprintf(parseout,"<Line: %d>\n",sym->getStartLine());
    }
    else
    {        
        fprintf(parseout,"%s : %s \t",sym->getName().c_str(),sym->getType().c_str());
        fprintf(parseout,"<Line: %d-%d>\n",sym->getStartLine(),sym->getEndLine());
    }

    for(int i=0;i<sym->getChildList().size();i++)
    {
        PrintParseTree(sym->getChildList().at(i),depth+1);
        //cout<<depth<<endl;
    }

}

void DeleteParseTree(SymbolInfo* sym)
{
    for(int i=0;i<sym->getChildList().size();i++)
    {
        DeleteParseTree(sym->getChildList().at(i));
    }
    free(sym);
}


%}




%union{
	SymbolInfo* symbol;
}

%token<symbol> IF ELSE FOR WHILE INT FLOAT DOUBLE CHAR RETURN VOID PRINTLN
%token<symbol> INCOP DECOP RELOP ASSIGNOP LOGICOP NOT SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE 
%token<symbol> NEWLINE ADDOP MULOP CONST_INT CONST_FLOAT ID
%type<symbol> start program unit type_specifier compound_statement statements statement variable term factor argument_list arguments
%type<symbol> expression_statement expression  logic_expression rel_expression simple_expression unary_expression
%type<symbol> func_declaration func_definition parameter_list
%type<symbol> var_declaration declaration_list


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program
	{
		//write your code in this block in all the similar blocks below
        $$=new SymbolInfo("start","program");
        // tempChildList= new vector<SymbolInfo*>();
             tempChildList.push_back($1);
             $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

        fprintf(logout,"start : program \n");
        fprintf(logout,"Total Lines: %d\n",line_count);
        fprintf(logout,"Total Errors: %d\n",error_count);
        //symbol_table.PrintAllScopeTable();

        PrintParseTree($$,0);
        DeleteParseTree($$);
    }
	;


program : program unit 
{
    $$=new SymbolInfo("program","program unit");
    // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

    fprintf(logout,"program : program unit\n");
}
	| unit{
        $$=new SymbolInfo("program","unit");
        // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());
        
        fprintf(logout,"program : unit\n");
    }
	;


unit : var_declaration{
    $$=new SymbolInfo("unit","var_declaration");
    // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

    fprintf(logout,"unit : var_declaration\n");
}
     | func_declaration
     {
            $$=new SymbolInfo("unit","func_declaration");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"unit : func_declaration\n");
     }
     | func_definition
     {
            $$=new SymbolInfo("unit","func_definition");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"unit : func_definition\n");
     }
     ;


func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
{
        $$=new SymbolInfo("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
        tempChildList.push_back($1);
        tempChildList.push_back($2);
        tempChildList.push_back($3);
        tempChildList.push_back($4);
        tempChildList.push_back($5);
        tempChildList.push_back($6);
        $$->setChildList(tempChildList);

        tempChildList.clear();

        $$->setStartLine($1->getStartLine());
        $$->setEndLine($6->getEndLine());

        fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");

        SymbolInfo* temp_sym=new SymbolInfo($2->getName(),$1->getType());

        temp_sym->setFunction(true);
        //$2->setType($1->getType());
        for(int i=0;i<temp_par_list.size();i++)
        {
            string name=temp_par_list.at(i).p_name;
            string type=temp_par_list.at(i).p_type;
            temp_sym->addParameter(name,type);
        }

        //checking for redefinition of function parameter
        //cout<<temp_par_list.size()<<endl;
        for(int i=0;i<temp_par_list.size();i++)
        {
            string nam1=temp_par_list.at(i).p_name;
            for(int j=i+1;j<temp_par_list.size();j++)
                {
                    string nam2=temp_par_list.at(j).p_name;
                    if(nam1==nam2)
                    {
                        fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",line_count,nam1.c_str());
                        error_count++;
                        break;
                    }
                }
        }
        
        temp_par_list.clear();

        //symbol_table.Insert(temp_sym);

        if(!symbol_table.Insert(temp_sym))
        {
            fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",line_count,$2->getName().c_str());
            error_count++;
        }

        // SymbolInfo* temp_sym2=symbol_table.LookUp($2->getName());
        // cout<<"function "<<$2->getName()<<" #parameter "<<temp_sym2->getParameterListSize()<<endl;


        // temp_sym=symbol_table.LookUp($2->getName());
        // if(temp_sym!=NULL)
        // {
        //     if(temp_sym->isFunction())
        //     fprintf(errorout,"Line# %d: Redeclaration of function '%s'\n",line_count,$2->getName().c_str());
        //     else
        //     fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",line_count,$2->getName().c_str());
            
        //     error_count++;
        //     //fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",line_count,$2->getName(),c_str());
        // }
        
        

}
		| type_specifier ID LPAREN RPAREN SEMICOLON
        {
            $$=new SymbolInfo("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($5->getEndLine());

            fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");

            SymbolInfo* temp_sym=new SymbolInfo($2->getName(),$1->getType());

            temp_sym->setFunction(true);
            //$2->setType((string)$1->getType());

             if(!symbol_table.Insert(temp_sym))
            {
                fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",line_count,$2->getName().c_str());
                error_count++;
            }
        
        }
		;
		 

func_definition : type_specifier ID LPAREN parameter_list RPAREN{
           
            string func_name=$2->getName();
            string func_type=$1->getType();

            SymbolInfo* temp_sym=symbol_table.LookUp($2->getName());
            if(temp_sym!=NULL)
            {
                if(!temp_sym->isFunction())
                {
                    fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",line_count,$2->getName().c_str());
                    error_count++;
                }
                else
                {
                    if(temp_sym->isDefined())
                    {
                        fprintf(errorout,"Line# %d: '%s' redefined as different kind of symbol\n",line_count,$2->getName().c_str());
                        error_count++;
                    }
                    else//funtion declared not defined
                    {
                        if(temp_sym->getType()!=func_type)
                        {
                            fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",line_count,$2->getName().c_str());
                            error_count++;
                            cout<<"func type error"<<endl;

                        }
                        if(temp_sym->getParameterListSize()!=temp_par_list.size())
                        {
                            fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",line_count,$2->getName().c_str());
                            error_count++;
                            cout<<" parameter size error"<<endl;
                        }
                        else if(temp_par_list.size()!=0)//not necessary to check
                        {
                            for(int i=0;i<temp_par_list.size();i++)
                            {
                                string type1=temp_par_list.at(i).p_type;
                                string type2=temp_sym->getParameterType(i);
                                if(type1!=type2)
                                {
                                    cout<<type1<<"!="<<type2<<endl;
                                    fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",line_count,$2->getName().c_str());
                                    error_count++;
                                }

                            }
                        }

                    symbol_table.Remove(func_name);

                    SymbolInfo* temp_sym2=new SymbolInfo(func_name,func_type);

                    temp_sym2->setFunction(true);
                    temp_sym2->setDefined(true);
                    
                    for(int i=0;i<temp_par_list.size();i++)
                    {
                        string name=temp_par_list.at(i).p_name;
                        string type=temp_par_list.at(i).p_type;
                        temp_sym2->addParameter(name,type);
                    }
                    symbol_table.Insert(temp_sym2);

                    //temp_par_list.clear();

                    }
                }
            }
            else//not declared but here to defined
            {
                for(int i=0;i<temp_par_list.size();i++)
                {
                    string nam1=temp_par_list.at(i).p_name;
                    for(int j=i+1;j<temp_par_list.size();j++)
                        {
                            string nam2=temp_par_list.at(j).p_name;
                            if(nam1==nam2)
                            {
                                fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",line_count,nam1.c_str());
                                error_count++;
                                break;
                            }
                        }
                }

                SymbolInfo* temp_sym2=new SymbolInfo(func_name,func_type);

                temp_sym2->setFunction(true);
                temp_sym2->setDefined(true);
                
                for(int i=0;i<temp_par_list.size();i++)
                {
                    string name=temp_par_list.at(i).p_name;
                    string type=temp_par_list.at(i).p_type;
                    temp_sym2->addParameter(name,type);
                }
                symbol_table.Insert(temp_sym2);

                //temp_par_list.clear();
            }


        
} compound_statement
{
    symbol_table.PrintAllScopeTable();
    symbol_table.ExitScope();
}{
            $$=new SymbolInfo("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            tempChildList.push_back($7);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($7->getEndLine());


    fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");

}

		| type_specifier ID LPAREN RPAREN {

            string func_name=$2->getName();
            string func_type=$1->getType();

            SymbolInfo* temp_sym=symbol_table.LookUp($2->getName());
            if(temp_sym!=NULL)
            {
                if(!temp_sym->isFunction())
                {
                    fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",line_count,$2->getName().c_str());
                    error_count++;
                }
                else
                {
                    if(temp_sym->isDefined())
                    {
                        fprintf(errorout,"Line# %d: '%s' redefined as different kind of symbol\n",line_count,$2->getName().c_str());
                        error_count++;
                    }
                    else//funtion declared not defined
                    {
                        if(temp_sym->getType()!=func_type)
                        {
                            fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",line_count,$2->getName().c_str());
                            error_count++;
                            //cout<<"func type error"<<endl;

                        }
                       
                        temp_sym->setDefined(true);
                    

                        //temp_par_list.clear();//no risk

                    }
                }
            }
            else//not declared but here to defined
            {
               
                SymbolInfo* temp_sym2=new SymbolInfo(func_name,func_type);

                temp_sym2->setFunction(true);
                temp_sym2->setDefined(true);
                
                symbol_table.Insert(temp_sym2);

                //temp_par_list.clear();//no risk
            }

        }
        compound_statement{
            symbol_table.PrintAllScopeTable();
            symbol_table.ExitScope();

        }
        {
            $$=new SymbolInfo("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($6);
            
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($6->getEndLine());


            fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");

        }
 		;				



parameter_list  : parameter_list COMMA type_specifier ID
{
            $$=new SymbolInfo("parameter_list","parameter_list COMMA type_specifier ID");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($4->getEndLine());

            temp_par.p_type=(string)$3->getType();
            temp_par.p_name=(string)$4->getName();

            temp_par_list.push_back(temp_par);

            fprintf(logout,"parameter_list : parameter_list COMMA type_specifier IDt\n");
        
}
		| parameter_list COMMA type_specifier
        {
            $$=new SymbolInfo("parameter_list","parameter_list COMMA type_specifier");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());
            
            temp_par.p_type=(string)$3->getType();//eg INT
            temp_par.p_name="";

            temp_par_list.push_back(temp_par);

            fprintf(logout,"parameter_list : parameter_list COMMA type_specifier\n");
        }
 		| type_specifier ID
        {
            $$=new SymbolInfo("parameter_list","type_specifier ID");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            temp_par.p_type=(string)$1->getType();
            temp_par.p_name=(string)$2->getName();

            temp_par_list.push_back(temp_par);

            fprintf(logout,"parameter_list : type_specifier ID\n");
        }
		| type_specifier
        {
            $$=new SymbolInfo("parameter_list","type_specifier");
            tempChildList.push_back($1);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            temp_par.p_type=(string)$1->getType();//eg INT
            temp_par.p_name="";

            temp_par_list.push_back(temp_par);


            fprintf(logout,"parameter_list : type_specifier\n");
        }
 		;

 		
compound_statement : LCURL {
    symbol_table.EnterScope();
    //inserting parameters in funtion definition
    for(int i=0;i<temp_par_list.size();i++)
    {
        string var_name=temp_par_list.at(i).p_name;
        string var_type=temp_par_list.at(i).p_type;
        SymbolInfo* tem_sym=new SymbolInfo(var_name,var_type);
        if(!symbol_table.Insert(tem_sym))
        {
            // fprintf(errorout,"Line# %d: redefinition of parameter '%s'\n",line_count,var_name.c_str());
            // error_count++;
        }

    }
    temp_par_list.clear();

}statements RCURL
{
            $$=new SymbolInfo("compound_statement","LCURL statements RCURL");
            tempChildList.push_back($1);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($4->getEndLine());


            fprintf(logout,"compound_statement : LCURL statements RCURL\n");
            //symbol_table.PrintAllScopeTable();

}
 		    | LCURL{
                symbol_table.EnterScope();
            } RCURL{
            //this is never going to be a function body(return)
            $$=new SymbolInfo("compound_statement","LCURL RCURL");
            tempChildList.push_back($1);
            tempChildList.push_back($3);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());


            fprintf(logout,"compound_statement : LCURL RCURL\n");

            symbol_table.PrintAllScopeTable();//may need to comment
            //symbol_table.ExitScope();
            }
 		    ;
            
     

var_declaration : type_specifier declaration_list SEMICOLON{
    $$=new SymbolInfo("var_declaration","type_specifier declaration_list SEMICOLON");
    // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());
    
    fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON\n");
    for(int i=0;i<temp_var_list.size();i++)
    {
        SymbolInfo* temp_sym=new SymbolInfo(temp_var_list[i].v_name,$1->getType());

        cout<<"array size "<<temp_var_list[i].v_size<<endl;
        if(temp_var_list[i].v_size>0)
            temp_sym->setArray(true);

        temp_sym->setArrSize(temp_var_list[i].v_size);
        bool flag = symbol_table.Insert(temp_sym);
        
        if(flag)
        {

        }
        else
        {
            SymbolInfo* temp_sym=symbol_table.LookUpCurrentScope(temp_var_list[i].v_name);
            if(temp_sym->getType()!=$1->getType())
            fprintf(errorout,"Line# %d: Conflicting types for'%s'\n",line_count,temp_var_list[i].v_name.c_str());
            else
            fprintf(errorout,"Line# %d: Redefinition of variable %s\n",line_count,temp_var_list[i].v_name.c_str());

        }
    }
    temp_var_list.clear();
}
 		 ;

 		 
type_specifier	: INT{
    $$ =new SymbolInfo("type_specifier","INT");
    // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());
            //$$->setDataType($1->getType());

            fprintf(logout,"type_specifier	: INT\n");
    
}
 		| FLOAT{
            
            $$ =new SymbolInfo("type_specifier","FLOAT");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());
            //$$->setDataType($1->getType());

            fprintf(logout,"type_specifier	: FLOAT\n");
        }
 		| VOID{
            $$ =new SymbolInfo("type_specifier","VOID");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());
            //$$->setDataType($1->getType());

            fprintf(logout,"type_specifier	: VOID\n");
        }
 		;
 		
declaration_list : declaration_list COMMA ID
{
            $$=new SymbolInfo("declaration_list","declaration_list COMMA ID");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
           
            temp_var.v_name=(string)$3->getName();
            temp_var.v_size=-1;
            temp_var_list.push_back(temp_var);
     
}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE{
            $$=new SymbolInfo("declaration_list","declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            tempChildList.push_back($6);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($6->getEndLine());

            fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");
           
            int x=stoi($5->getName());
            temp_var.v_name=(string)$3->getName();
            temp_var.v_size=x;
            temp_var_list.push_back(temp_var);

          }
 		  | ID
          {
            $$=new SymbolInfo("declaration_list","ID");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"declaration_list : ID\n");
            
            temp_var.v_name=(string)$1->getName();
            temp_var.v_size=-1;
            temp_var_list.push_back(temp_var);

          }
 		  | ID LSQUARE CONST_INT RSQUARE
          {
            $$=new SymbolInfo("declaration_list","ID LSQUARE CONST_INT RSQUARE");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($4->getEndLine());

            fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE\n");
           
            int x=stoi($3->getName());
            temp_var.v_name=(string)$1->getName();
            temp_var.v_size=x;
            temp_var_list.push_back(temp_var);            

          }
 		  ;
 		  
		  
statements : statement
{
            $$=new SymbolInfo("statements" ,"statement");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"statements : statement\n");
           
}
	   | statements statement
       {
         $$=new SymbolInfo("statements","statements statement");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"statements : statements statement\n");
           
       }
	   ;
	   
statement : var_declaration
{
            $$=new SymbolInfo("statement","var_declaration");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"statement : var_declaration\n");
     
}
        |func_declaration{
            fprintf(errorout,"Line# %d: Invalid scoping of function\n",line_count);
        }
        |func_definition{
            fprintf(errorout,"Line# %d: Invalid scoping of function\n",line_count);
        }
	  | expression_statement
      {
          $$=new SymbolInfo("statement","expression_statement");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"statement : expression_statement\n");
     
      }
      
	  | {symbol_table.EnterScope();}compound_statement{
        symbol_table.PrintAllScopeTable();
        symbol_table.ExitScope();
      }{
         $$=new SymbolInfo("statement","compound_statement");
           // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($2);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($2->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"statement : compound_statement\n");
     
      }
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement
      {
        $$=new SymbolInfo("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            tempChildList.push_back($6);
            tempChildList.push_back($7);
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($7->getEndLine());

            fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
           
      }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
      {
        string cond = getOperandName($3);
        string falseLabel = newLabel();
        emitCode("CMP " + cond + ", 0");
        emitCode("JE " + falseLabel);
        emitCode(falseLabel + ":");

        $$=new SymbolInfo("statement","IF LPAREN expression RPAREN statement");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
           
            $$->setChildList(tempChildList);

             tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($5->getEndLine());

            fprintf(logout,"statement : IF LPAREN expression RPAREN statement\n");
           
      }
	  | IF LPAREN expression RPAREN statement ELSE statement
      {
        string cond = getOperandName($3);
        string elseLabel = newLabel();
        string endLabel = newLabel();
        emitCode("CMP " + cond + ", 0");
        emitCode("JE " + elseLabel);
        emitCode("JMP " + endLabel);
        emitCode(elseLabel + ":");
        emitCode(endLabel + ":");

        $$=new SymbolInfo("statement","IF LPAREN expression RPAREN statement ELSE statement");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            tempChildList.push_back($6);
            tempChildList.push_back($7);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($7->getEndLine());

            fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
           
      }
	  | WHILE LPAREN expression RPAREN statement
      {
        string cond = getOperandName($3);
        string startLabel = newLabel();
        string endLabel = newLabel();
        emitCode(startLabel + ":");
        emitCode("CMP " + cond + ", 0");
        emitCode("JE " + endLabel);
        emitCode(endLabel + ":");

        $$=new SymbolInfo("statement","WHILE LPAREN expression RPAREN statement");
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($5->getEndLine());

            fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");
           
      }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
      {
        $$=new SymbolInfo("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
            tempChildList.push_back($5);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($5->getEndLine());

            if(!symbol_table.LookUp($3->getName()))
            {
                fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",line_count,$3->getName().c_str());
                error_count++;
            }

            fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");

            emitCode("PRINT " + $3->getName());
           
      }
	  | RETURN expression SEMICOLON
      {
        $$=new SymbolInfo("statement","RETURN expression SEMICOLON");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"statement : RETURN expression SEMICOLON\n");

            emitCode("MOV AX, " + getOperandName($2));
            emitCode("RET");
           
      }
	  ;
	  
expression_statement 	: SEMICOLON		
{
     $$=new SymbolInfo("expression_statement","SEMICOLON");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"expression_statement : SEMICOLON\n");
           
}	
			| expression SEMICOLON 
            {
                 $$=new SymbolInfo("expression_statement","expression SEMICOLON");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"expression_statement : expression SEMICOLON\n");
           
            }
			;
	  
variable : ID 	
{
     $$=new SymbolInfo("variable","ID");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            SymbolInfo* temp_sym=symbol_table.LookUp($1->getName());
            if(temp_sym==NULL)
            {
                fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",line_count,$1->getName().c_str());
                error_count++;
    
            }
            else
            {
                if(temp_sym->isFunction())
                {
                fprintf(errorout,"Line# %d: Type mismatch of funtion'%s'\n",line_count,$1->getName().c_str());
                error_count++;
                }
                else if(temp_sym->isArray())
                {
                //fprintf(errorout,"Line# %d: Type mismatch of array'%s'\n",line_count,$1->getName().c_str());
                error_count++;
                }
            }


            fprintf(logout,"variable : ID\n");
           
}	
	 | ID LSQUARE expression RSQUARE {
         $$=new SymbolInfo("variable","ID LSQUARE expression RSQUARE");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($4->getEndLine());
            
             SymbolInfo* temp_sym=symbol_table.LookUp($1->getName());
            if(temp_sym==NULL)
            {
                fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",line_count,$1->getName().c_str());
                error_count++;
    
            }
            else
            {
                if(temp_sym->isFunction())
                {
                fprintf(errorout,"Line# %d: Type mismatch of funtion'%s'\n",line_count,$1->getName().c_str());
                error_count++;
                }
                else if(!temp_sym->isArray())
                {
                fprintf(errorout,"Line# %d: '%s' is not an array\n",line_count,$1->getName().c_str());
                error_count++;
                }
            }

            //const_int check

            fprintf(logout,"variable : ID LSQUARE expression RSQUARE\n");
           
     }
	 ;
	 
 expression : logic_expression	{
          $$=new SymbolInfo("expression","logic_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"expression : logic_expression\n");
           

 }
	   | variable ASSIGNOP logic_expression
       {
              $$=new SymbolInfo("expression","variable ASSIGNOP logic_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            $$->setName($1->getName());

            fprintf(logout,"expression : variable ASSIGNOP logic_expression\n");

            string destination = getOperandName($1);
            string source = getOperandName($3);
            emitCode("MOV " + destination + ", " + source);
           
       } 	
	   ;
			
logic_expression : rel_expression 
 {
              $$=new SymbolInfo("logic_expression","rel_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"logic_expression : rel_expression\n");
           
       } 	
		 | rel_expression LOGICOP rel_expression 
         {
               $$=new SymbolInfo("logic_expression","rel_expression LOGICOP rel_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            string left = getOperandName($1);
            string right = getOperandName($3);
            string label1 = newLabel();
            string label2 = newLabel();
            string temp = newTemp();
            emitCode("CMP " + left + ", " + right);
            emitCode("JE " + label1);
            emitCode("MOV " + temp + ", 0");
            emitCode("JMP " + label2);
            emitCode(label1 + ":");
            emitCode("MOV " + temp + ", 1");
            emitCode(label2 + ":");
            $$->setName(temp);

            fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression\n");
           
         }	
		 ;
			
rel_expression	: simple_expression 
{
        $$=new SymbolInfo("rel_expression","simple_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"rel_expression	: simple_expression\n");
           
}
		| simple_expression RELOP simple_expression	
        {
             $$=new SymbolInfo("rel_expression","simple_expression RELOP simple_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"rel_expression : simple_expression RELOP simple_expression\n");

            string left = getOperandName($1);
            string rel = asmRelop($2->getName());
            string right = getOperandName($3);
            string label1 = newLabel();
            string label2 = newLabel();
            string temp = newTemp();
            emitCode("CMP " + left + ", " + right);
            emitCode(rel + " " + label1);
            emitCode("MOV " + temp + ", 0");
            emitCode("JMP " + label2);
            emitCode(label1 + ":");
            emitCode("MOV " + temp + ", 1");
            emitCode(label2 + ":");
            $$->setName(temp);
           
        }
		;
				
simple_expression : term 
{
      $$=new SymbolInfo("simple_expression","term");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"simple_expression : term\n");
           
}
		  | simple_expression ADDOP term 
          {
              $$=new SymbolInfo("simple_expression","simple_expression ADDOP term");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"simple_expression : simple_expression ADDOP term\n");

            string left = getOperandName($1);
            string op = $2->getName();
            string right = getOperandName($3);
            string temp = newTemp();
            emitCode("MOV " + temp + ", " + left);
            if (op == "+") emitCode("ADD " + temp + ", " + right);
            else emitCode("SUB " + temp + ", " + right);
            $$->setName(temp);
           
          }
		  ;
					
term :	unary_expression
{
     
              $$=new SymbolInfo("term","unary_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"term :	unary_expression\n");
           
          
}
     |  term MULOP unary_expression
     {
        
              $$=new SymbolInfo("term","term MULOP unary_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           tempChildList.push_back($2);
           tempChildList.push_back($3);
           
            
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"term :	term MULOP unary_expression\n");

            string left = getOperandName($1);
            string op = $2->getName();
            string right = getOperandName($3);
            string temp = newTemp();
            emitCode("MOV " + temp + ", " + left);
            if (op == "*") emitCode("MUL " + temp + ", " + right);
            else if (op == "/") emitCode("DIV " + temp + ", " + right);
            else emitCode("MOD " + temp + ", " + right);
            $$->setName(temp);
           
          
     }
     
     ;

unary_expression : ADDOP unary_expression 
{
      $$=new SymbolInfo("unary_expression","ADDOP unary_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           tempChildList.push_back($2);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"unary_expression : ADDOP unary_expression\n");
          
} 
		 | NOT unary_expression 
         {
      $$=new SymbolInfo("unary_expression","NOT unary_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           tempChildList.push_back($2);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"unary_expression : NOT unary_expression\n");
          
} 
		 | factor
           {
      $$=new SymbolInfo("unary_expression","factor");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
          
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"unary_expression : factor\n");
          
} 
		 ;
	
factor	: variable{
    $$=new SymbolInfo("factor","variable");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
          
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            $$->setName($1->getName());
            fprintf(logout,"factor : variable\n");
}

	| ID LPAREN argument_list RPAREN
    {
     $$=new SymbolInfo("factor","ID LPAREN argument_list RPAREN");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            tempChildList.push_back($4);
          
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($4->getEndLine());

            SymbolInfo* temp_sym=symbol_table.LookUp($1->getName());
            if(temp_sym==NULL)
            {
                fprintf(errorout,"Line# %d: Undeclared function '%s'\n",line_count,$1->getName().c_str());
                error_count++;
            }
            else
            {
                if(!temp_sym->isFunction())
                {
                 fprintf(errorout,"Line# %d: Not a function '%s'\n",line_count,$1->getName().c_str());
                error_count++;                   
                }

            }

            fprintf(logout,"factor : ID LPAREN argument_list RPAREN\n");   
    }
	| LPAREN expression RPAREN
    {
         $$=new SymbolInfo("factor","LPAREN expression RPAREN");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
          
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"factor : LPAREN expression RPAREN\n");
    }
	| CONST_INT 
    {
      $$=new SymbolInfo("factor","CONST_INT");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"factor : CONST_INT\n");
            $$->setName($1->getName());
      
    }
	| CONST_FLOAT
    {
      $$=new SymbolInfo("factor","CONST_FLOAT");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"factor : CONST_FLOAT\n");
            $$->setName($1->getName());
      
    }
	| variable INCOP 
    {
            $$=new SymbolInfo("factor","variable INCOP");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"factor : variable INCOP\n");
      
    }
	| variable DECOP
    {
            $$=new SymbolInfo("factor","variable DECOP");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
           
           
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($2->getEndLine());

            fprintf(logout,"factor : variable DECOP\n");
      
    }
	;
	
argument_list : arguments
{
            $$=new SymbolInfo("argument_list","arguments");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            
        
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"argument_list : arguments\n");
      
    }
			  ;
	
arguments : arguments COMMA logic_expression
{
            $$=new SymbolInfo("arguments","arguments COMMA logic_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            tempChildList.push_back($2);
            tempChildList.push_back($3);
            
        
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($3->getEndLine());

            fprintf(logout,"arguments : arguments COMMA logic_expression\n");
      
    }
	      | logic_expression
          {
              $$=new SymbolInfo("arguments","logic_expression");
            // tempChildList= new vector<SymbolInfo*>();
            tempChildList.push_back($1);
            
        
            $$->setChildList(tempChildList);

            tempChildList.clear();

            $$->setStartLine($1->getStartLine());
            $$->setEndLine($1->getEndLine());

            fprintf(logout,"arguments : logic_expression\n");
      
          }
	      ;
 


%%

int main(int argc,char *argv[])
{
    if(argc < 2 || argc > 3){
		printf("Usage: %s <input_file> [output_file]\n", argv[0]);
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
    string asmOutput = (argc == 3) ? argv[2] : "assembly.asm";
    if (argc == 2)
    {
        string inputPath = argv[1];
        size_t pos = inputPath.find("examples/inputs/");
        if (pos != string::npos)
        {
            string fileName = inputPath.substr(inputPath.find_last_of("/") + 1);
            size_t dot = fileName.find_last_of(".");
            if (dot != string::npos)
                fileName = fileName.substr(0, dot);
            asmOutput = "examples/outputs/" + fileName + ".asm";
            system("mkdir -p examples/outputs");
        }
    }

    //tempChildList= new vector<SymbolInfo*>();

	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");
    errorout= fopen("error.txt","w");
    parseout= fopen("parsetree.txt","w");
    asmFile.open(asmOutput.c_str());
    if (!asmFile.is_open())
    {
        printf("Failed to open assembly output file\n");
        return 0;
    }
	//symbol_table.fileWork(logout);

	yyin= fin;
	yyparse();
	//st.print();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
    fclose(errorout);
    fclose(parseout);
	return 0;

	// if((fp=fopen(argv[1],"r"))==NULL)
	// {
	// 	printf("Cannot Open Input File.\n");
	// 	exit(1);
	// }

	// fp2= fopen(argv[2],"w");
	// fclose(fp2);
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	// yyin=fp;
	// yyparse();
	

	// fclose(fp2);
	// fclose(fp3);
	
	// return 0;
}

