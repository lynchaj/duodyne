/*  test.c  */

#define nelem(x) (sizeof(x)/sizeof(x[0]))

char *unasm(unsigned char *IP, short *length, unsigned int ip);

unsigned char ins[1024];
int length;

void main(void)
{
	int i;

	for (i=0; i<nelem(ins); i++) ins[i] = 0x90;	/* fill with NOP */

	unasm(ins, &length, (short)ins);

}

