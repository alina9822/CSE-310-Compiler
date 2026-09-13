#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#define ull unsigned long long

#include <bits/stdc++.h>
#include <fstream>
#include <iostream>


extern FILE *logout;
extern FILE *errorout; // necessary
// extern FILE *errorout;

using namespace std;

// ofstream errorout;

// ofstream log_file ("log.txt");

extern char *stTOch(string str);
// {
//     int i;
//     int s=str.length()+5;
//     char *ch=(char *)malloc(s * sizeof(char));
//     for(i=0;str[i]!='\0';i++)
//         ch[i]=str[i];
//     ch[i]='\0';
//     //printf("%s\n",ch);

//     return ch;
// }

class SymbolInfo
{
    string name, type;
    string dataType;

    SymbolInfo *next;
    vector<SymbolInfo *> childList;

    int hash_id, hash_pos;
    int start_line;
    int end_line;
    bool leaf;
    int arr_size;//-1 if variable

    bool is_function;
    bool is_defined;
    bool is_array;

    struct param{
    string p_name;
    string p_type;
    }temp_par;

    vector<param> temp_par_list;//to hold the parameters of funtion

public:
    SymbolInfo()
    {
        next = NULL;
    }
    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
        leaf = false;
        is_function=false;
        is_defined=false;
        is_array=false;
    }

    void addParameter(string name,string type)
    {
        temp_par.p_name=name;
        temp_par.p_type=type;
        
        temp_par_list.push_back(temp_par);
    }
    vector<param> getParameterList()
    {
        return temp_par_list;
    }
    int getParameterListSize()
    {
        return temp_par_list.size();
    }

    string getParameterType(int index)
    {
        return temp_par_list.at(index).p_type;
    }
    void setParameterName(int index,string name)
    {
        temp_par_list.at(index).p_name=name;
    }

    void setArrSize(int size)
    {
        arr_size=size;
    }
    int getArrSize()
    {
        return arr_size;
    }

    void setName(string name)
    {
        this->name = name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    void setStartLine(int sl)
    {
        start_line = sl;
    }
    void setEndLine(int el)
    {
        end_line = el;
    }
    int getStartLine()
    {
        return start_line;
    }

    int getEndLine()
    {
        return end_line;
    }

    void setLeaf(bool leaf)
    {
        this->leaf = leaf;
    }

    bool isLeaf()
    {
        return leaf;
    }

    void setFunction(bool func)
    {
        is_function=func;
    }

    bool isFunction()
    {
        return is_function;
    }

    void setDefined(bool def)
    {
        is_defined=def;
    }

    bool isDefined()
    {
        return is_defined;
    }

    void setArray(bool arr)
    {
        is_array=arr;
    }

    bool isArray()
    {
        return is_array;
    }

    void setChildList(vector<SymbolInfo *> list)
    {
        childList = list;
    }

    vector<SymbolInfo *> getChildList()
    {
        return childList;
    }

    void setDataType(string dataType)
    {
        this->dataType = dataType;
    } 
    string getDataType()
    {
        return dataType;
    }

    void setNext(SymbolInfo *newNext)
    {
        next = newNext;
    }
    void setHashId(int hash_id)
    {
        this->hash_id = hash_id;
    }
    void setHashPos(int hash_pos)
    {
        this->hash_pos = hash_pos;
    }

    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }
   
    SymbolInfo *getNext()
    {
        return next;
    }
    int getHashId()
    {
        return hash_id;
    }
    int getHashPos()
    {
        return hash_pos;
    }
    ~SymbolInfo()
    {
        //     delete next;
        // delete childList;
    }
};

class ScopeTable
{
private:
    int scope_id;
    long long bucket_size;

    SymbolInfo **scope_hash_table;
    ScopeTable *parent_scope_table;

public:
    ScopeTable(long long bucket_size, ScopeTable *parent, int scope_id)
    {
        this->bucket_size = bucket_size;
        this->scope_id = scope_id;
        parent_scope_table = parent;

        scope_hash_table = new SymbolInfo *[bucket_size]; // contains all type of symbol
        for (int i = 0; i < bucket_size; i++)
            scope_hash_table[i] = NULL;

        cout << "\tScopeTable# " << scope_id << " created" << endl;
    }

    bool Insert(SymbolInfo *new_symbol)
    {
        string name = new_symbol->getName();
        int hash_id = hashVal(name);
        // cout<<name<<hash_id<<endl;

        SymbolInfo *current_symbol = scope_hash_table[hash_id];
        int pos = 0;

        if (current_symbol == NULL)
        {
            scope_hash_table[hash_id] = new SymbolInfo;
            scope_hash_table[hash_id] = new_symbol;
            scope_hash_table[hash_id]->setHashId(hash_id);
            scope_hash_table[hash_id]->setHashPos(pos);
        }
        else
        {
            if (this->LookUp(name) != NULL)
            {
                // errorout << "\t'" << name << "' already exists in the current ScopeTable" << endl;
                //fprintf(errorout, "\t%s already exisits in the current ScopeTable\n", stTOch(name));
                // delete current_symbol;
                cout<<name<<" already exists in the current symbol table"<<endl;
                delete new_symbol;
                return false;
            }

            pos++;
            while (current_symbol->getNext() != NULL)
            {
                pos++;
                current_symbol = current_symbol->getNext();
            }
            current_symbol->setNext(new_symbol);
            new_symbol->setHashId(hash_id);
            new_symbol->setHashPos(pos);
        }
        cout << "\t"
             << "Inserted in ScopeTable# " << scope_id << " at position " << hash_id + 1 << ", " << pos + 1 << endl;
        // delete current_symbol;
        return true;
    }

    SymbolInfo *LookUp(string name)
    {
        int hash_id = hashVal(name);

        SymbolInfo *current_symbol = scope_hash_table[hash_id];

        if (current_symbol == NULL)
        {
            return NULL;
        }
        else
        {
            if (current_symbol->getName() == name)
            {
                return current_symbol;
            }

            while (current_symbol->getNext() != NULL)
            {
                current_symbol = current_symbol->getNext();
                if (current_symbol->getName() == name)
                {
                    return current_symbol;
                }
            }
        }

        return NULL;
    }

    bool Delete(string name)
    {
        int hash_id = hashVal(name);
        int id, pos;

        SymbolInfo *current_symbol = scope_hash_table[hash_id];

        if (LookUp(name) == NULL)
        {
            cout << "\tNot found in the current ScopeTable" << endl;
            return false;
        }

        if (current_symbol->getName() == name)
        {
            if (current_symbol->getNext() != NULL)
            {
                scope_hash_table[hash_id] = current_symbol->getNext();

                id = current_symbol->getHashId();
                pos = current_symbol->getHashPos();
                cout << "\tDeleted '" << name << "' from ScopeTable# " << scope_id << " at position " << id + 1 << ", " << pos + 1 << endl;

                delete current_symbol;
                return true;
            }
            else
            {
                id = current_symbol->getHashId();
                pos = current_symbol->getHashPos();
                cout << "\tDeleted '" << name << "' from ScopeTable# " << scope_id << " at position " << id + 1 << ", " << pos + 1 << endl;

                delete current_symbol;
                scope_hash_table[hash_id] = NULL;
                return true;
            }
        }

        SymbolInfo *parent_symbol;
        while (current_symbol->getName() != name)
        {
            parent_symbol = current_symbol;
            current_symbol = current_symbol->getNext();
        }
        if (current_symbol->getNext() == NULL)
        {
            parent_symbol->setNext(NULL);

            id = current_symbol->getHashId();
            pos = current_symbol->getHashPos();
            cout << "\tDeleted '" << name << "' from ScopeTable# " << scope_id << " at position " << id + 1 << ", " << pos + 1 << endl;

            delete current_symbol;
            return true;
        }
        else
        {
            parent_symbol->setNext(current_symbol->getNext());
            current_symbol->setNext(NULL);

            id = current_symbol->getHashId();
            pos = current_symbol->getHashPos();
            cout << "\tDeleted '" << name << "' from ScopeTable# " << scope_id << " at position " << id + 1 << ", " << pos + 1 << endl;

            delete current_symbol;
            return true;
        }

        return false;
    }

    void Print()
    {
        cout << "\tScopeTable# " << scope_id << endl;
        fprintf(logout, "\tScopeTable# %d\n", scope_id);
        for (int i = 0; i < bucket_size; i++)
        {
            bool newline = false;
            SymbolInfo *current_symbol = scope_hash_table[i];

            if (current_symbol != NULL)
            {
                cout << "\t" << i + 1 << "--> ";
                fprintf(logout, "\t%d--> ", i + 1);
                newline = true;
            }

            while (current_symbol != NULL)
            {
                cout << "<" << current_symbol->getName() << "," << current_symbol->getType() << "> ";
                // string str1=current_symbol->getType();
                // char *ch1=stTOch(str1);
                if(current_symbol->isFunction())
                {
                    fprintf(logout, "<%s, FUNCTION, %s> ", stTOch(current_symbol->getName()), stTOch(current_symbol->getType()));

                }
                else if(current_symbol->isArray())
                {
                    fprintf(logout, "<%s, ARRAY, %s> ", stTOch(current_symbol->getName()), stTOch(current_symbol->getType()));

                }
                else
                {
                    fprintf(logout, "<%s, %s> ", stTOch(current_symbol->getName()), stTOch(current_symbol->getType()));
                }
                
                current_symbol = current_symbol->getNext();
            }

            if (newline)
            {
                cout << endl;
                fprintf(logout, "\n");
            }
        }
    }

    void setParent(ScopeTable *parent)
    {
        parent_scope_table = parent;
    }

    ScopeTable *getParent() const
    {
        return parent_scope_table;
    }

    void setScopId(int scope_id)
    {
        this->scope_id = scope_id;
    }
    int getScopId()
    {
        return scope_id;
    }

    static ull SDBMHash(string str)
    {
        ull hash = 0;
        ull i = 0;
        ull len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }
    ull hashVal(string str)
    {
        ull hash = 0;
        hash = SDBMHash(str) % bucket_size;
        return hash;
    }
    // ~ScopeTable()
    // {
    //     delete scope_hash_table;
    //     delete parent_scope_table;
    // }
};

class SymbolTable
{
private:
    ScopeTable *current_scope;
    int bucket_size;
    int scope_num = 0;

public:
    SymbolTable(int bucket_size)
    {
        this->bucket_size = bucket_size;
        scope_num++;
        current_scope = new ScopeTable(bucket_size, NULL, scope_num);
    }
    void EnterScope()
    {
        scope_num++;
        current_scope = new ScopeTable(bucket_size, current_scope, scope_num);
    }

    void Terminate()
    {
        while (current_scope != NULL)
        {
            ScopeTable *parent_of_current = current_scope->getParent();
            cout << "\tScopeTable# " << current_scope->getScopId() << " removed" << endl;
            delete current_scope;
            current_scope = parent_of_current;
        }
    }
    void ExitScope()
    {
        if (current_scope == NULL)
            return;
        else if (current_scope->getParent() == NULL)
        {
            cout << "\tScopeTable# " << current_scope->getScopId() << " cannot be removed" << endl;
        }
        else
        {
            // scope_num--;
            ScopeTable *parent_of_current = current_scope->getParent();
            cout << "\tScopeTable# " << current_scope->getScopId() << " removed" << endl;
            delete current_scope;
            current_scope = parent_of_current;
        }
    }

    bool Insert(SymbolInfo *new_symbol)
    {
        if (current_scope == NULL)
        {
            scope_num++;
            current_scope = new ScopeTable(bucket_size, NULL, scope_num);
        }

        return current_scope->Insert(new_symbol);
    }

    bool Remove(string name)
    {
        if (current_scope != NULL)
        {
            return current_scope->Delete(name);
        }
        else
            return false;
    }

    SymbolInfo *LookUp(string name)
    {
        ScopeTable *scope = current_scope;
        while (scope != NULL)
        {
            SymbolInfo *symbol = scope->LookUp(name);
            if (symbol != NULL)
            {
                cout << "\t'" << symbol->getName() << "' found in ScopeTable# " << scope->getScopId() << " at position " << symbol->getHashId() + 1 << ", " << symbol->getHashPos() + 1 << endl;
                return symbol;
            }
            else
                scope = scope->getParent();
        }
        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        return NULL;
    }

     SymbolInfo *LookUpCurrentScope(string name)
    {
        ScopeTable *scope = current_scope;
        
            SymbolInfo *symbol = scope->LookUp(name);
            if (symbol != NULL)
            {
                cout << "\t'" << symbol->getName() << "' found in ScopeTable# " << scope->getScopId() << " at position " << symbol->getHashId() + 1 << ", " << symbol->getHashPos() + 1 << endl;
                return symbol;
            }
            else
                scope = scope->getParent();
        
        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        return NULL;
    }

    void PrintCurrentScopeTable()
    {
        if (current_scope != NULL)
            current_scope->Print();
    }

    void PrintAllScopeTable()
    {
        ScopeTable *scope = current_scope;
        while (scope != NULL)
        {
            scope->Print();
            scope = scope->getParent();
        }
    }

    void fileWork(FILE *f)
    {
        errorout = f;
    }

    ~SymbolTable()
    {
        //     delete current_scope;
    }
};
#endif

