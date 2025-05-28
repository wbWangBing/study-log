#include<assert.h>
#include"avl.h"

static uint32_t max(uint32_t a, uint32_t b){
    return a > b ? a : b;
}

static void avl_update(AVLNode *node){
    node->height = max(avl_height(node->left), avl_height(node->right)) + 1;
    node->cnt = avl_cnt(node->left) + avl_cnt(node->right) + 1;
}
//左旋
static AVLNode *rot_left(AVLNode *node){
    //记录父节点
    AVLNode *parent = node->parent;
    //右节点将左上移动成为父节点
    AVLNode *new_node = node->right;
    //右节点的左节点将成为node的右节点
    AVLNode* inner = new_node->left;
    if(inner != NULL){
        inner->parent = node; 
    }
    node->right = inner;
    new_node->parent = parent;
    //node将成为new_node的左节点
    new_node->left = node;
    node->parent = new_node;
    //更新节点的高度,先更新子节点的高度，再更新父节点的高度
    avl_update(node);
    avl_update(new_node);
    return new_node;
}

static AVLNode *rot_right(AVLNode *node) {
    AVLNode *parent = node->parent;
    AVLNode *new_node = node->left;
    AVLNode *inner = new_node->right;
    // node <-> inner
    node->left = inner;
    if (inner) {
        inner->parent = node;
    }
    // parent <- new_node
    new_node->parent = parent;
    // new_node <-> node
    new_node->right = node;
    node->parent = new_node;
    // auxiliary data
    avl_update(node);
    avl_update(new_node);
    return new_node;
}

//修复左子树较高
static AVLNode *avl_fix_left(AVLNode *node) {
    // 左子树的右子树较高
    //先对左子树进行左旋，使得是左子树的左子树较高
    if (avl_height(node->left->right) > avl_height(node->left->left)) {
        node->left = rot_left(node->left);
    }
    // 左子树的左子树较高
    //对node进行右旋
    return rot_right(node);
}
//修复右子树较高
static AVLNode *avl_fix_right(AVLNode *node) {
    // 右子树的左子树较高
    if (avl_height(node->right->left) > avl_height(node->right->right)) {
        node->right = rot_right(node->right);
    }
    // 右子树的右子树较高
    return rot_left(node);
}

//修复AVL树
AVLNode* avl_fix(AVLNode *node){
    while(true){
        AVLNode **from = &node;
        AVLNode *parent = node->parent;
        if(parent){
            from = parent->left == node? &parent->left : &parent->right;
        } 
        avl_update(node);
        uint32_t lh = avl_height(node->left);
        uint32_t rh = avl_height(node->right);
        if(lh == rh + 2){
            *from = avl_fix_left(node);
        }else if(rh == lh + 2){
            *from = avl_fix_right(node);
        }
        if(!parent){
            return *from;
        }
        node = parent;
    }
}

//删除节点当其中一个孩子是NULL
static AVLNode *avl_del_easy(AVLNode *node) {
    assert(node->left != NULL || node->right != NULL);
    AVLNode *child = node->left? node->left : node->right;
    AVLNode *parent = node->parent;
    if(child){
        child->parent = parent;
    }
    if(!parent){
        return child;
    }
    AVLNode **from = parent->left == node? &parent->left : &parent->right;
    *from = child;
    return avl_fix(parent);
}

//删除节点
AVLNode *avl_del(AVLNode *node) {
    //如果只有一个子节点或者没有
    if (node->left == NULL || node->right == NULL) {
        return avl_del_easy(node);
    }

    // 左右子树都有,寻找后继节点
    AVLNode *victim = node->right;
    while(victim->left){
        victim = victim->left;
    }
    // victim 一定没有左子树
    // victim 可能有右子树
    //移除后继节点和子树父树的连接
    AVLNode *root = avl_del_easy(victim);
    *victim = *node;
    //被删除节点的左右子树的父节点指向后继节点
    if (victim->left) {
        victim->left->parent = victim;
    }
    if (victim->right) {
        victim->right->parent = victim;
    }
    //被删除节点的父节点的子节点指针，指向后继节点
    AVLNode **from = &root;
    AVLNode *parent = node->parent;
    if (parent) {
        from = parent->left == node ? &parent->left : &parent->right;
    }
    *from = victim;
    return root;
}

AVLNode *avl_offset(AVLNode *node , int64_t offset) {
    int64_t pos = 0;
    while(offset != pos){
        //在右子树中
        if(pos < offset && pos && pos + avl_cnt(node->left) >= offset){
            node = node->right;
            pos += avl_cnt(node->left) + 1;
        //在左子树
        }else if(pos < offset && pos && pos - avl_cnt(node->right) <= offset){
            node = node->left;
            pos -= avl_cnt(node->right) + 1;
        }else{
            //在父节点
            AVLNode *parent = node->parent;
            if(!parent){
                return NULL;
            }
            if(parent->right == node){
                pos -= avl_cnt(node->left) + 1;
            }else{
                pos += avl_cnt(node->right) + 1;
            }
            node = parent;
        }
    }
    return node;
}