#include <stdio.h>
int main(){
    freopen("out","w",stdout);
    for(int i=0;i<128;i++){
        printf("data_way0[%3d] <= 256'b0;\n",i);
    }
    for(int i=0;i<8;i++){
        printf("%d:%d\n",(i+1)*32-1,i*32);
    }
    return 0;
}