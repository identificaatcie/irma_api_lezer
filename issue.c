#include<stdlib.h>
#include<unistd.h>
#include<stdio.h>

int main() {
    setuid(1000);
    setgid(1000);
    while(1) {
        system("/home/silvia/script/issue.sh");
        sleep(1);
    }

    return 0;
}
