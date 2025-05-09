#pragma once

#include<stddef.h>
#include<stdint.h>

struct HashNode {
    HashNode *next = NULL;
    uint64_t hcode = 0;
};

struct HashTable
{
    HashNode **tab = NULL;
    size_t mask = 0;
    size_t size = 0;
};

struct HashMap
{
    HashTable newer;
    HashTable older;
    size_t migrate_pos;
};

HashNode *Hash_Map_Lookup(HashMap* hmap , HashNode* key , bool (*eq)(HashNode* , HashNode*));
void Hash_Map_Insert(HashMap* hamp , HashNode* key );
HashNode *Hash_Map_Delete(HashMap* hmap , HashNode* kye , bool (*eq)(HashNode* , HashNode*));
void Hash_Map_Clear(HashMap* hmap);
void Hash_Map_Foreach(HashMap* hmap , bool (*func)(HashNode* , void*) , void* args);


