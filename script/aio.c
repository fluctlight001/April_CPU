#include<stdio.h>
int main(){
    for(int i=0;i<8;i++){
        printf("3'd%d:begin out=8'b",i);
        for(int j=7-i;j>=0;j--){
            printf("0");
        }
        printf("1");
        for(int j=0;j<i;j++){
            printf("0");
        }
        printf("; end\n");
    }
    return 0;
}