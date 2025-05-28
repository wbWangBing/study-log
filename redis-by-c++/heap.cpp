#include"heap.h"

static size_t heap_parent(size_t pos){
    return (pos + 1)/2 - 1;
}
static size_t heap_left(size_t pos){
    return pos * 2 + 1;
}

static size_t heap_right(size_t pos){
    return pos * 2 + 2;
}

static void heap_up(HeapItem* heap, size_t pos){
    HeapItem temp = heap[pos];
    while(pos > 0 && temp.val < heap[heap_parent(pos)].val){
        heap[pos] = heap[heap_parent(pos)];
        *heap[pos].ref = pos;
        pos = heap_parent(pos);
    }
    heap[pos] = temp;
    *heap[pos].ref = pos;
}

static void heap_down(HeapItem* heap, size_t pos, size_t len){
    HeapItem temp = heap[pos];
    while(true){
        size_t left = heap_left(pos);
        size_t right = heap_right(pos);
        size_t min_pos = pos;
        uint64_t min_val = temp.val;
        if(left < len && min_val > heap[left].val){
            pos = left;
        }
        if(right < len && min_val > heap[right].val){
            pos = right;
        }
        if(pos == min_pos){
            break;
        }
        heap[pos] = heap[min_pos];
        *heap[pos].ref = pos;
        pos = min_pos;
    }
    heap[pos] = temp;
    *heap[pos].ref = pos;
}

void heap_update(HeapItem* heap, size_t pos, size_t len){
    if(pos > 0 && heap[pos].val < heap[heap_parent(pos)].val){
        heap_up(heap, pos);
    }else{
        heap_down(heap, pos, len);
    }
}