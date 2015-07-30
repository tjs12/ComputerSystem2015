#include <cstdio>
using namespace std;

const int LEN = 16;
int main() {
    for (int x, count = 0; scanf("%x", &x) == 1; )
        for (int i = 0; i < LEN; i++) {
            printf("%d", (x >> LEN-1 - i) & 1);
            if (!(++count % 8))
               printf("\n");
        }
    return 0;
}
