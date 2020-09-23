%{
    #include<set>
    #include<map>
    #include<vector>
    #include<string>
    #include<string.h>
    #include<iostream>
    #include<algorithm>
    #include<unordered_set>
    #include<unordered_map>
    using namespace std;

    #define EPSILON "ε"
    #define EOS "$"

    class Grammar{
    public:
        unordered_map<string,vector<string>> prods;
        unordered_map<string,unordered_set<string>> FIRST,FOLLOW;
        vector<string> ord;
        unordered_map<string,int> rank;
        unordered_set<string> terminals;
        vector<vector<vector<int>>> parseTable;
        bool isLL1 = true;

        int nextVar;

        Grammar(){
            ord.resize(26);
            initOrd();
        }

        void initOrd(){
            int pointer = 0;
            ord[pointer++] = "S";
            rank[("S")] = 0;
            string temp = "";
            for(int i = 'A';i <= 'Z';i++){
                if(i == 'S') continue;
                temp += i;
                ord[pointer++] = temp;
                rank[temp] = pointer - 1;
                temp = "";
            }
        }

        void takeInput(char var, char str[50]){
            string a = "";
            string b = "";
            a += var;
            for(int i = 0;str[i] != '\0';i++){
                b += str[i];
            }
            if(b == "∈") b = EPSILON;
            prods[a].emplace_back(b);
            if(b == EPSILON){
                terminals.insert(b);
                return;
            }
            for(auto u : b){
                if(!(u >= 'A' && u <= 'Z')){
                    string s = "";
                    s += u;
                    terminals.insert(s);
                }
            }
        }

        void removeRedun(){
            for(int i = 0;i < ord.size();i++){
                for(auto itr = prods[ord[i]].begin();itr != prods[ord[i]].end();++itr){
                    if(*itr == *(itr+1)){
                        prods[ord[i]].erase(itr);
                        --itr;
                    }
                }
            }
        }

        void printFor(string idx){
            if(prods[idx].size()){
                cout<<idx<<" →  ";
                bool flag = 0;
                for(auto u : prods[idx]){
                    if(flag) cout<<"|";
                    cout<<u;
                    flag = 1;
                }
                cout<<"\n";
            }
        }

        inline void printProds(){
            for(int i = 0;i < ord.size();i++){
                printFor(ord[i]);
            }
            cout<<"------------\n\n";
        }   

        inline void sortProds(){
            for(auto & u : prods){
                sort(u.second.begin(), u.second.end());
            }
        }

        void remImmLeftRecur(string & curr){
            bool flag = 0;
            for(auto v : prods[curr]){
                if(v[0] == curr[0]){
                    string newStr = curr;
                    string alpha = v.substr(1);
                    newStr += "'";
                    alpha += newStr;
                    prods[newStr].emplace_back(alpha);
                    flag = 1;
                }
            }
            if(flag){
                string newStr = curr;
                newStr += "'";
                ord.insert(ord.begin()+rank[curr]+1,newStr);
                rank[newStr] = rank[curr]+1;
                for(int i = rank[curr]+2;i < ord.size();i++){
                    rank[ord[i]] = i;
                }
                prods[newStr].emplace_back(EPSILON);
                terminals.insert(EPSILON);
                int n = prods[curr].size();
                for(int i = 0;i < n;i++){
                    if(prods[curr][i][0] != curr[0] || prods[curr][i] == EPSILON){
                        string temp = ((prods[curr][i] == EPSILON) ? (newStr): (prods[curr][i] + newStr));
                        prods[curr].emplace_back(temp);
                    }
                }
                for(int i = 0;i < n;i++) prods[curr].erase(prods[curr].begin());
            }
        }

        void remLeftRecur(){
            for(int i = 0;i < ord.size();i++){
                string curr = ord[i];
                if(curr.length() == 2) continue;
                int n = prods[curr].size();
                for(int i = 0;i < n;i++){
                    string u = prods[curr][i];
                    string temp = "";
                    if(u == EPSILON) continue;
                    temp += u[0];
                    if(terminals.find(temp) != terminals.end()) continue;
                    if(rank[temp] < rank[curr]){
                        string gamma = u.substr(1);
                        for(auto delta : prods[temp]){
                            delta = delta + gamma;
                            prods[curr].emplace_back(delta);
                        }
                        prods[curr].erase(prods[curr].begin()+i);
                        i--;
                        n--;
                    }
                }
                remImmLeftRecur(curr);
            }
        }

        inline void checkNext(){
            for(int i = 0;i < ord.size();i++){
                if(prods[ord[i]].size()){
                    nextVar = i;
                }
            }
            nextVar++;
        }

        void remLeftFact(){
            vector<vector<bool>> flag((int)ord.size());
            for(int itr = 0;itr < ord.size();itr++){
                int start = 0;
                int num = prods[ord[itr]].size();
                if(!num) continue;
                flag[itr].resize(num,0);
                int currChar = prods[ord[itr]][0][0];
                for(int i = 1;i <= num;i++){
                    if(i == num || prods[ord[itr]][i][0] != currChar){
                        if(i - start >= 2){
                            for(int j = start;j < i;j++){
                                if(prods[ord[itr]][j].size()>1) prods[ord[nextVar]].emplace_back(prods[ord[itr]][j].substr(1));
                                else prods[ord[nextVar]].emplace_back(EPSILON),terminals.insert(EPSILON);
                                flag[itr][j] = 1;
                            }
                            sort(prods[ord[nextVar]].begin(),prods[ord[nextVar]].end());
                            string newStr = prods[ord[itr]][start].substr(0,1);
                            newStr += ord[nextVar];
                            prods[ord[itr]].emplace_back(newStr);
                            nextVar++;
                        }
                        if(i != num){
                            currChar = prods[ord[itr]][i][0];
                            start = i;
                        }
                    }
                }
            }
            clean(flag);
        }

        void clean(vector<vector<bool>> & flag){
            for(int itr = 0;itr < ord.size();itr++){
                for(int i = 0;i < flag[itr].size();i++){
                    if(flag[itr][i]){
                        prods[ord[itr]].erase(prods[ord[itr]].begin()+i);
                        flag[itr].erase(flag[itr].begin()+i);
                        i--;
                    }
                }
            }
        }

        void initFIRST(){
            for(auto u : prods){
                for(auto v : u.second){
                    if(v == EPSILON) FIRST[v].insert(v);
                    else{
                        for(auto c : v){
                            string temp = "";
                            temp += c;
                            if(terminals.find(temp) != terminals.end()){
                                FIRST[temp].insert(temp);
                            }
                        }
                    }
                }
            }
            terminals.insert(EOS);
            FIRST[EOS].insert(EOS);
        }

        void printFirst(string i,int j){
            cout<<i<<" →  "<<prods[i][j]<<" = {";
            bool flag = 0;
            for(auto u : FIRST[prods[i][j]]){
                if(flag) cout<<", ";
                cout<<u;
                flag = 1;
            }
            cout<<"}\n";
        }

        void createFIRST(){
            for(int i = 0;i < ord.size();i++){
                for(int j = 0;j < prods[ord[i]].size();j++){
                    unordered_set<string> st = getFirst(prods[ord[i]][j]);
                    for(auto u : st) FIRST[prods[ord[i]][j]].insert(u),FIRST[ord[i]].insert(u);
                }
            }
        }

        unordered_set<string> getFirst(string s){
            unordered_set<string> ret;
            if(s == EPSILON){
                ret.insert(s);
                return ret;
            }
            string temp = "";
            temp += s[0];
            if(terminals.find(temp) != terminals.end()){
                ret.insert(temp);
                return ret;
            }
            if(s.size() > 1 && s[1] == '\''){
                temp += "'";
            }
            for(auto i : prods[temp]){
                unordered_set<string> rett = getFirst(i);
                for(auto u : rett) ret.insert(u);
            }
            if(ret.find(EPSILON) != ret.end()){
                string newS = next(s);
                if(newS.size()){
                    ret.erase(ret.find(EPSILON));
                    unordered_set<string> ret1 = getFirst(newS);
                    for(auto u : ret1) ret.insert(u);
                }
            }
            return ret;
        }

        inline string next(string s){
            if(s.size() == 1) return "";
            if(s.size() == 2){
                if(s[1] = '\'') return "";
                return s.substr(2);
            }
        }

        void createFOLLOW(){
            FOLLOW[ord[0]].insert(EOS);
            for(int i = 0;i < 3;i++){
                for(int i = 0;i < ord.size();i++){
                    for(int j = 0;j < prods[ord[i]].size();j++){
                        for(int k = 0;k < prods[ord[i]][j].size();k++){
                            string temp = "";
                            temp += prods[ord[i]][j][k];
                            if(k + 1 < prods[ord[i]][j].size() && prods[ord[i]][j][k+1] == '\''){
                                temp += "'";
                                k++;
                            }
                            if(k+1 == prods[ord[i]][j].size()){
                                for(auto u : FOLLOW[ord[i]]){
                                    FOLLOW[temp].insert(u);
                                }
                            }
                            else{
                                string temp2 = prods[ord[i]][j].substr(k+1);
                                for(auto p : getFirst(temp2)){
                                    if(p == EPSILON){
                                        for(auto u : FOLLOW[ord[i]]){
                                            FOLLOW[temp].insert(u);
                                        }
                                    }
                                    else FOLLOW[temp].insert(p);
                                }
                            }
                        }
                    }
                }
            }
        }

        void buildParseTable(){
            parseTable.resize(ord.size());
            for(auto & u : parseTable) u.resize(terminals.size()-1);
            for(int i = 0;i < ord.size();i++){
                if(prods[ord[i]].size() == 0) continue;
                cout<<"\ncurrent variable ["<<ord[i]<<"]:\n";
                int j = 0;
                for(auto u : terminals){
                    if(u == EPSILON) continue;
                    cout<<"\t current input token = {"<<u<<"}, possible rules are: {";
                    bool flag = 0;
                    for(int k = 0;k < prods[ord[i]].size();k++){
                        if(FIRST[prods[ord[i]][k]].find(u) != FIRST[prods[ord[i]][k]].end()){
                            parseTable[i][j].emplace_back(k);
                            if(parseTable[i][j].size() > 1) isLL1 = false;
                            if(flag) cout<<"|";
                            cout<<ord[i]<<" →  "<<prods[ord[i]][k];
                            flag = 1;
                        }
                        else if(FIRST[prods[ord[i]][k]].find(EPSILON) != FIRST[prods[ord[i]][k]].end() && FOLLOW[ord[i]].find(u) != FOLLOW[ord[i]].end()){
                            parseTable[i][j].emplace_back(k);
                            if(parseTable[i][j].size() > 1) isLL1 = false;
                            if(flag) cout<<"|";
                            cout<<ord[i]<<" →  "<<prods[ord[i]][k];
                            flag = 1;
                        }
                    }
                    cout<<"}\n";
                    j++;
                }
            }
            cout<<"-----\n";
        }

        inline void check(){
            if(isLL1) cout<<"\033[1;32mRESULT: This grammar is LL1\033[0m\n";
            else cout<<"\033[1;31mRESULT: This grammar is not LL1\033[0m\n";
        }
    };

    inline void PRINT(string s){
        cout<<s;
    }

    Grammar gm;
%}

%% 

(%)+(.)*

([A-Z])+[ ]*+["→""->"]+([A-Za-z |∈εx+()/])* {
    strcpy(yytext,yytext);
    char variable = yytext[0];
    int flag = 0;
    char currStr[60] = {'\0'};

    for(int i = 1;yytext[i] != '\0';i++){
        if(yytext[i] == ' ') continue;
        if((yytext[i] >= 'a' && yytext[i] <= 'z') || (yytext[i] >= 'A' && yytext[i] <= 'Z' || yytext[i] == '+' || yytext[i] == 'x' || yytext[i] == '(' || yytext[i] == ')')){
            strncat(currStr,&yytext[i],1);
        }
        else if(!(memcmp(yytext+i,"ε",sizeof("ε")))){
            strncat(currStr,&yytext[i],2);
            i++;
        }
        else if(!(memcmp(yytext+i,"∈",sizeof("∈")))){
            strncat(currStr,&yytext[i],3);
            i+=2;
        }
        else{
            if(strlen(currStr) != 0){
                gm.takeInput(variable,currStr);
            }
            strcpy(currStr,"\0");
        }
    }
    gm.takeInput(variable,currStr);
}
.;

%% 

int main(int argc, char **argv)
{
    FILE * file;
    file = fopen("input.txt","r");
    if(!file)
    {
        printf("could not open the file");
        exit(0);
    }
    yyin=file;
    yylex();
    PRINT("Our grammar:\n");
    gm.printProds();
    gm.sortProds();
    gm.removeRedun();
    gm.remLeftRecur();
    PRINT("After removing left recursion:\n");
    gm.printProds();
    gm.sortProds();
    gm.checkNext();
    gm.remLeftFact();
    PRINT("After removing left factoring:\n");
    gm.printProds();
    gm.initFIRST();
    gm.createFIRST();
    gm.createFOLLOW();
    PRINT("Our parse table:\n");
    gm.buildParseTable();
    gm.check();
    return(0);
}
int yywrap()
{
    return(1);
}
