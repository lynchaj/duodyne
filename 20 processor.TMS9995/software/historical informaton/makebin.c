#include <stdlib.h>
#include <fcntl.h>

main()
{
	int bin, mnu, mdx, unx;
	char c;

	bin = open("ROM.bin", O_RDWR);
	mnu = open("menu.out", O_RDONLY);
	mdx = open("mdexldr.out", O_RDONLY);
	unx = open("unixldr.out", O_RDONLY);

	if( bin==-1 || mnu==-1 || mdx==-1 || unx==-1) {
		write(2, "Could not open files\n", 21);
		exit(1);
	}

	lseek(mnu, 16, SEEK_SET);
	lseek(bin, 0x1500, SEEK_SET);
	while( read(mnu, &c, 1)==1) write(bin, &c, 1);

	lseek(mdx, 16, SEEK_SET);
	lseek(bin, 0x7800, SEEK_SET);
	while( read(mdx, &c, 1)==1) write(bin, &c, 1);

	lseek(unx, 16, SEEK_SET);
	lseek(bin, 0x7b00, SEEK_SET);
	while( read(unx, &c, 1)==1) write(bin, &c, 1);
	
	close(bin); close(mnu); close(mdx); close(unx);
}