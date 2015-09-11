#include<stdlib.h>
#include<unistd.h>
#include<stdio.h>

int main() {
    int retval = -1;
    setuid(1000);
    setgid(1000);
    while(1) {
        retval = system("/home/silvia/script/issue.sh");
        if (retval != 0) {
            puts("Killed\n");
        }
        sleep(1);
    }

    return 0;
}
