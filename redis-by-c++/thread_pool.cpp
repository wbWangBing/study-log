
#include<assert.h>
#include"thread_pool.h"

static void* worker(void* arg) {//这个函数在线程池中的每个线程运行，为实际上运行任务的函数，worker函数不停监听是否有待处理任务
    ThreadPool* thread_pool = (ThreadPool*)arg;
    while(true){
        pthread_mutex_lock(&thread_pool->mu);
        while(thread_pool->work_queue.empty()){
            pthread_cond_wait(&thread_pool->not_empty , &thread_pool->mu);
        }
        Work work = thread_pool->work_queue.front();
        thread_pool->work_queue.pop_front();

        work.f(work.arg);

    }
}

void thread_pool_init(ThreadPool* thread_pool , size_t num_threads){//线程池初始化的时候，让每个线程运行worker函数
    assert(num_threads > 0);
    int rv = pthread_mutex_init(&thread_pool->mu , NULL);
    assert(rv == 0);
    rv = pthread_cond_init(&thread_pool->not_empty , NULL);
    assert(rv == 0);
    thread_pool->threads.resize(num_threads);
    for(int i = 0 ; i < num_threads ; i++){
        int rv = pthread_create(&thread_pool->threads[i] , NULL , &worker , thread_pool);
    }

}

//任务队列添加任务函数
void thread_pool_queue(ThreadPool* thread_pool , void (*f)(void*) , void* arg){
    pthread_mutex_lock(&thread_pool->mu);
    thread_pool->work_queue.push_back(Work{f,arg});
    pthread_cond_signal(&thread_pool->not_empty);
    pthread_mutex_unlock(&thread_pool->mu);
}