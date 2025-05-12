#pragma once

#include<stddef.h>
#include<pthread.h>
#include<vector>
#include<deque>

struct Work{
    void (*f)(void *) = NULL;//要完成的函数
    void *arg = NULL;//函数参数
};

struct ThreadPool
{
    std::vector<pthread_t> threads;//工作线程组
    std::deque<Work> work_queue;//任务队列
    pthread_mutex_t mu;//竞争区锁
    pthread_cond_t not_empty;//条件变量
};

void thread_pool_init(ThreadPool* thread_pool , size_t num_threads);
void thread_pool_queue(ThreadPool* thread_pool , void (*f)(void*) , void*arg);