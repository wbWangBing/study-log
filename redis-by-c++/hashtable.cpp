#include <assert.h>
#include <stdlib.h>     // calloc(), free()
#include "hashtable.h"

static void Hash_Table_Init(HashTable* htab , size_t n){
    assert( n > 0 && ( n & (n-1) == 0) );
    htab->mask = n-1;
    htab->tab = (HashNode**)calloc( n , sizeof(sizeof(HashNode)));
    htab->size = 0;
}

static void Hash_Table_Insert(HashTable* htab , HashNode* key){
    size_t pos = key->hcode & htab->mask;
    key->next = htab->tab[pos];
    htab->tab[pos] = key;
    htab->size++;
}

static HashNode** Hash_Table_Lookup(HashTable* htab , HashNode* key , bool (*eq)(HashNode* , HashNode*)){
    if(!htab->tab){
        return NULL;
    }

    size_t pos = key->hcode & htab->mask;
    HashNode** from = &htab->tab[pos];
    for(HashNode* cur = *from ; (cur != NULL ) ; from = &cur->next){
        if(cur->hcode == key->hcode && eq(cur , key)){
            return from;
        }
    }
    return NULL;
}

static HashNode* Hash_Table_Detach(HashTable* htab , HashNode** from){
    HashNode* node = *from;
    *from = node->next;
    htab->size--;
    return node;
}

const size_t k_rehashing_work = 128;

static void Hash_Map_Rehashing(HashMap* hmap){
    size_t haveworked = 0;
    while(haveworked < k_rehashing_work && hmap->older.size > 0){
        HashNode** from = &hmap->older.tab[hmap->migrate_pos];
        if(!*from){
            hmap->migrate_pos++;
            continue;
        }
        Hash_Table_Insert(&hmap->newer , Hash_Table_Detach(&hmap->older , from));
        haveworked++;
    }
    if(hmap->older.size == 0 && hmap->older.tab){
        free(hmap->older.tab);
        hmap->older= HashTable{};
    }
}

static void Hash_Map_Trigger_Rehashing(HashMap* hmap){
    assert(hmap->older.tab == NULL);
    hmap->older = hmap->newer;
    Hash_Table_Init(&hmap->newer , (hmap->newer.mask + 1)*2);
    hmap->migrate_pos = 0;
}

HashNode* Hash_Map_Lookup(HashMap* hmap , HashNode* key , bool (*eq)(HashNode* , HashNode*)){
    Hash_Map_Rehashing(hmap);
    HashNode** from = Hash_Table_Lookup(&hmap->newer , key ,eq);
    if(!from){
        from = Hash_Table_Lookup(&hmap->older , key ,eq);
    }
    return from ? *from : NULL;
}

const size_t k_load_factor = 8;//负载因子

void Hash_Map_Insert(HashMap* hmap , HashNode* key){
    if(!hmap->newer.tab)
    {
        Hash_Table_Init(&hmap->newer , 4);
    }
    Hash_Table_Insert(&hmap->newer , key);

    if(!hmap->older.tab){
        size_t shreshold = (hmap->newer.mask + 1 )* k_load_factor;
        if(hmap->newer.size >= shreshold){
            Hash_Map_Trigger_Rehashing(hmap);
        }
    }
    Hash_Map_Rehashing(hmap);
}
HashNode* Hash_Map_Delete(HashMap* hmap , HashNode* key, bool (*eq)(HashNode* , HashNode*)){
    Hash_Map_Rehashing(hmap);
    if(HashNode** from = Hash_Table_Lookup(&hmap->newer , key ,eq)){
       return Hash_Table_Detach(&hmap->newer , from);
    }
    if(HashNode** from = Hash_Table_Lookup(&hmap->older , key ,eq)){
       return Hash_Table_Detach(&hmap->older , from);
    }
    return NULL;
}

void Hash_Map_Clear(HashMap* hmap){
    free(&hmap->newer.tab);
    free(&hmap->older.tab);
    *hmap = HashMap{};
};

size_t Hash_Map_Size(HashMap *hmap) {
    return hmap->newer.size + hmap->older.size;
}

static bool Hash_Table_Foreach(HashTable* htab , bool (*func)(HashNode* , void*) , void* arg){
    for (size_t i = 0; htab->mask != 0 && i <= htab->mask; i++) {
        for (HashNode *node = htab->tab[i]; node != NULL; node = node->next) {
            if (!func(node, arg)) {
                return false;
            }
        }
    }
    return true;
}
void Hash_Map_Foreach(HashMap *hmap, bool (*func)(HashNode *, void *), void *arg) {
    Hash_Table_Foreach(&hmap->newer, func, arg) && Hash_Table_Foreach(&hmap->older, func, arg);
}
