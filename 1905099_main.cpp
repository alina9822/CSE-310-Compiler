#include<bits/stdc++.h>
#include<fstream>
#include "1905099_classes.h"

using namespace std;


int main()
{
    freopen("1905099_input.txt","r",stdin);
    freopen("1905099_output.txt","w",stdout);

    int bucket_size;
    int cmd=0;

    cin>>bucket_size;
    //cout<<bucket_size;

    SymbolTable symbol_table(bucket_size);

    string str;
    getline(cin,str);
    while(getline(cin,str))
    {
        cmd++;
        char ch;
        string word;
        int param=0;
        stringstream iss(str);
        iss>>ch;
        cout<<"Cmd "<<cmd<<": "<<ch;
        while(iss>>word)
        {
            param++;
            cout<<" "<<word;
        }
        cout<<endl;

        if(ch=='I')
        {
            if(param!=2)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                string name,type;
                stringstream iss(str);
                iss>>word;
                iss>>name;
                iss>>type;
                symbol_table.Insert(new SymbolInfo(name,type));
            }
        }
        else if(ch=='L')
        {
            if(param!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                string name;
                stringstream iss(str);
                iss>>word;
                iss>>name;
                symbol_table.LookUp(name);
            }
        }
        else if(ch=='D')
        {
            if(param!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                string name;
                stringstream iss(str);
                iss>>word;
                iss>>name;
                symbol_table.Remove(name);
            }
        }
        else if(ch=='P')
        {
            if(param!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                char c;
                stringstream iss(str);
                iss>>word;
                iss>>c;
                if(c=='C')
                    symbol_table.PrintCurrentScopeTable();
                else if(c=='A')
                    symbol_table.PrintAllScopeTable();
                else
                    cout<<"\tType of parameters mismatch for the command "<<ch<<endl;
            }

        }
        else if(ch=='S')
        {
            if(param!=0)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                symbol_table.EnterScope();
            }
        }
        else if(ch=='E')
        {
            if(param!=0)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                symbol_table.ExitScope();
            }
        }
        else if(ch=='Q')
        {
            if(param!=0)
            {
                cout<<"\tNumber of parameters mismatch for the command "<<ch<<endl;
            }
            else
            {
                symbol_table.Terminate();
            }
        }
    }
}