#pragma once

#include<stddef.h>
#include<stdint.h>

struct AVLNode{
    AVLNode *left = NULL;
    AVLNode *right = NULL;
    AVLNode *parent = NULL;
    uint32_t height = 0;
    uint32_t cnt = 0;
};

inline void avl_init(AVLNode *node){
    node->left = node->right = node->parent = NULL;
    node->height = 1;
    node->cnt = 1;
}

inline uint32_t avl_height(AVLNode *node){
    return node == NULL ? 0 : node->height;
}
inline uint32_t avl_cnt(AVLNode *node){
    return node == NULL? 0 : node->cnt;
}

AVLNode* avl_fix(AVLNode *node);
AVLNode *avl_delete(AVLNode *node);
AVLNode *avl_offset(AVLNode *node);