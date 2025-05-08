
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
    step 1: 读取命令
    step 2: 解析命令
    step 3: 执行命令:
        内置命令则父进程执行
        外部命令则子进程执行
            子进程执行完后，父进程等待子进程执行完成
    step 4: 等待命令执行完成
    step 5: 重复步骤1-4
*/

//定义内置命令所需调用的函数
int wb_cd(char **args);
int wb_help(char **args);
int wb_exit(char **args);

//定义内置函数名称数组
char *builtin_str[] = {
    "cd",
    "help",
    "exit"
};

int (*builtin_func[])(char **) = {
    &wb_cd,
    &wb_help,
    &wb_exit
};

//定义内置命令数组大小
int builtin_num = sizeof(builtin_str) / sizeof(char *);

/*
实现内置函数：wb_cd， wb_help， wb_exit
*/

int wb_cd(char **args){
    if(args[1] == NULL){
        fprintf(stderr, "请输入跳转目的地 \"cd\"\n");
    }else{
        if(chdir(args[1]) != 0){//系统调用chdir
            perror("cd error");
        }
    }
    return 1;
}

int wb_help(char **args){
    printf("王王彬的内置函数\n");
    printf("用法：\n");
    printf("内置命令 (加快速度扩展ing)\n ");
    for(int i = 0; i < builtin_num; i++){
        printf("     %s\n", builtin_str[i]);
    }
    return 1;
}

int wb_exit(char **args){
    return 0;
}

//创建子进程执行系统调用函数
int wb_launch(char **args){
    pid_t pid;
    int status;
    pid = fork();//创建子进程
    if(pid == 0){
        //子进程
        if(execvp(args[0], args) == -1){//系统调用
            perror("execvp error");
        }
    }else if(pid < 0){
        //创建子进程失败
        perror("fork error");
    }else{
        //父进程
        do{
            waitpid(pid, &status, WUNTRACED);//系统调用
        }while(!WIFEXITED(status) && !WIFSIGNALED(status));
    }
    return 1;
}

//解析命令,执行函数
int wb_execute(char **args){
    if(args[0] == NULL){
        //空命令
        return 1;
    }
    for(int i = 0; i < builtin_num; i++){
        if(strcmp(args[0], builtin_str[i]) == 0){
            return (*builtin_func[i])(args);//执行内置函数
        }
    }
    return wb_launch(args);//否则创建子进程执行外部命令
}

//读取命令
char *wb_read_line(void){
    char *line = NULL;
    size_t bufsize = 0;
    if (getline(&line, &bufsize, stdin) == -1)//系统调用
    {
        if (feof(stdin))
        {   
            printf("读取到文件中之符EOF");
            exit(EXIT_SUCCESS);
        }else{
            perror("getline error");
            exit(EXIT_FAILURE);
        }
    }
    return line;
};

//解析命令
#define wb_TOK_BUFSIZE 64
#define wb_TOK_DELIM " \t\r\n\a"
char **wb_split_line(char *line){
    int bufsize = wb_TOK_BUFSIZE, position = 0;
    char **tokens = malloc(bufsize * sizeof(char *));
    char *token;  //指向字符串数组的指针
    if (!tokens){
        fprintf(stderr, "内存分配失败\n");
        exit(EXIT_FAILURE);
    }
    token = strtok(line, wb_TOK_DELIM);//系统调用，内定分隔符分割命令
    while(token != NULL){
        tokens[position] = token;
        position++;
        if(position >= bufsize){
            bufsize += wb_TOK_BUFSIZE;
            tokens = realloc(tokens, bufsize * sizeof(char *));
            if(!tokens){
                fprintf(stderr, "内存分配失败\n");
                exit(EXIT_FAILURE);
            }
        }
        token = strtok(NULL, wb_TOK_DELIM);
    }
    tokens[position] = NULL;
    return tokens;
}

//主循环函数
void wb_loop(void){
    char *line;
    char **args;
    int status;
    char buf[1024];

    do{
        if(getcwd(buf, sizeof(buf)) == NULL) printf("无法获取当前路径 ");//获取当前目录
        printf("%s%s", "orz--" ,buf);
        printf("> ");
        line = wb_read_line();//读取命令
        args = wb_split_line(line);//解析命令
        status = wb_execute(args);//执行命令
        free(line);
        free(args);
    }while(status);
}

int main(int argc, char *argv[]){
    wb_loop();
    return 0;
}