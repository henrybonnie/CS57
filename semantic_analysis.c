#include "ast.h"
#include "semantic_analysis.h"
#include <stdio.h>
#include <iostream>
#include <string>
#include <cstring>
#include <cstddef>
#include <vector>
#include <algorithm>
#include <iostream>
#include <stack>
using namespace std;

bool body = true;


int semantic_analysis(astNode* root) {
    vector<vector<char*>*>* symbol_tables = new vector<vector<char*>*>();
    
    analyze_node(root, symbol_tables);
    delete(symbol_tables);
    freeNode(root);
    printf("Valid");
}

int analyze_node(astNode* node, vector<vector<char*>*>* symbol_tables) {

    if (node == NULL) {
        return 0;
    }

    switch (node->type){
        case ast_prog: {
            printf("prog\n");
            analyze_node(node->prog.func, symbol_tables);
            break;
        }
        case ast_func: {
            // Add name to symbol table
            printf("func\n");
            vector<char*>* symbol_table = new vector<char*>();
            symbol_tables->push_back(symbol_table);
            if (node->func.param != NULL){
                symbol_table->push_back(node->func.param->var.name);
            }
            analyze_node(node->func.body, symbol_tables);
            symbol_tables->pop_back();
            break;
        }
        case ast_stmt: {
            printf("stmt\n");
            astStmt stmt = node->stmt;
            analyze_stmt(&stmt, symbol_tables);
            break;
		}
        case ast_extern: {
            break;
		}
        case ast_var: {
            printf("var\n");
            vector<char*>* curr_symb_tabl = new vector<char*>();
            curr_symb_tabl = symbol_tables->front();

            vector<vector<char*>*>::iterator z = symbol_tables->begin();

            bool declared = false;

            while (z != symbol_tables->end()) {
                vector<char*>::iterator x = curr_symb_tabl->begin();
                while (x != curr_symb_tabl->end()) {
              
                    if (strcmp(node->var.name, *x) == 0) {
                        declared = true;
                    }
                    x++;
                }
                z++;
                curr_symb_tabl = *z;
            }
            if (declared == false) {
                printf("Error here\n");
                fprintf(stderr, "Error\n");
                exit(EXIT_FAILURE);
            }
            break;
		}
        case ast_cnst: {
            break;
		}
        case ast_rexpr: {
            printf("rexpr\n");
            analyze_node(node->rexpr.lhs, symbol_tables);
            analyze_node(node->rexpr.rhs, symbol_tables);
            break;
		}
        case ast_bexpr: {
            printf("bexpr\n");
            analyze_node(node->bexpr.lhs, symbol_tables);
            analyze_node(node->bexpr.rhs, symbol_tables);
            break;
		}
        case ast_uexpr: {
            printf("uexpr\n");
            analyze_node(node->uexpr.expr, symbol_tables);
            break;
        }
    }
}

int analyze_stmt(astStmt* stmt, vector<vector<char*>*>* symbol_tables) {

    switch (stmt->type) {
        case ast_call:
            printf("Here\n");
            break;
		case ast_ret: {
            printf("ret\n");
            analyze_node(stmt->ret.expr, symbol_tables);
            break;
        }
		case ast_block: {
          //  printf("Block\n");
            if (body == true){
                vector<char*>* curr_symb_tabl = symbol_tables->back();
                body = false;
            } else{
                vector<char*>* curr_symb_tabl = new vector<char*>();

                symbol_tables->push_back(curr_symb_tabl);
            }

            vector<astNode*> stmt_list = *(stmt->block.stmt_list);

            vector<astNode*>::iterator i = stmt_list.begin();
            while (i != stmt_list.end()) {
                analyze_node(*i, symbol_tables);
                i++;
            }
            symbol_tables->pop_back();
            break;
            
		}
        case ast_while: {
            //printf("while\n");
            analyze_node(stmt->whilen.cond, symbol_tables);
            analyze_node(stmt->whilen.body, symbol_tables);
            break;
		}
        case ast_if: {
           // printf("if\n");
            analyze_node(stmt->ifn.cond, symbol_tables);
            analyze_node(stmt->ifn.if_body, symbol_tables);
            analyze_node(stmt->ifn.else_body, symbol_tables);
            break;
		}
        case ast_asgn: {
           // printf("asgn\n");
            analyze_node(stmt->asgn.lhs, symbol_tables);
            analyze_node(stmt->asgn.rhs, symbol_tables);
            break;
		
        }
        case ast_decl: {
            // add statement
          //  printf("decl stmt\n");
            vector<char*>* curr_symb_tabl = new vector<char*>();
            curr_symb_tabl = symbol_tables->back();
                    
            int len = strlen(stmt->decl.name);
            if(len > 0) {
                stmt->decl.name[len - 1] = '\0';
            }

            vector<char*>::iterator x = curr_symb_tabl->begin();
            while (x != curr_symb_tabl->end()) {
              //  printf("String: %s\n", *x);
                if (strcmp(stmt->decl.name, *x) == 0) {
                    fprintf(stderr, "Error\n");
                    exit(EXIT_FAILURE);
                }
                x++;
            }
            curr_symb_tabl->push_back(stmt->decl.name);
            break;
        }
    }
}