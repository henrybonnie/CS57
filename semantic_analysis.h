#include "ast.h"
#include <stdio.h>
#include <cstddef>
#include <vector>
#include <stack>
using namespace std;

int analyze_node(astNode* node, vector<vector<char*>*>* symbol_tables);

int analyze_stmt(astStmt* stmt, vector<vector<char*>*>* symbol_tables);

int semantic_analysis(astNode* root);



