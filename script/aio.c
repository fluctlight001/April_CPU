#include<stdio.h>
int main(){
    for(int i=0;i<16;i++){
        printf("wire [31:0] rdata_way0_%d;\n",i);
    }
    for(int i=0;i<16;i++){
        printf("wire [31:0] rdata_way1_%d;\n",i);
    }
    return 0;
}