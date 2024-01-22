#include <8052.h>
 
void delay(void);
 
void main(void)
{
    while(1)
    {
         P1 = 0xFF; // Turn ON all LED's connected to Port1
         delay();
         P1 = 0x00; // Turn OFF all LED's connected to Port1
         delay();
    }
}
 
void delay(void)
{
    int i,j;
    for(i=0;i<0xff;i++)
         for(j=0;j<0xff;j++);
}
