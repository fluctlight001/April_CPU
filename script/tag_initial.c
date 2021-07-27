#include<stdio.h>
int main (){
    freopen("out","w",stdout);
    for(int i=0;i<128;i++){
        printf("tag_way1[%3d] <= 21'b0;\n",i);
    }
    // printf("hello\n");
    return 0;
}