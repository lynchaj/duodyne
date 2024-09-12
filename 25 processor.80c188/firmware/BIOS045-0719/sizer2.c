#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include "equates.h1"

struct BiosDataArea *bios_data_area_ptr;

#define B bios_data_area_ptr
#define ofs(x) ((int)&(B->x)-(int)B)
int main(void)
{
	T_CURSOR_POSITION	cursor;

	cursor.b.x = 1;
	cursor.b.y = 2;
	if (cursor.w != 0x0201) return 5;

   printf("size of BIOS_DATA_AREA is %04X\n", sizeof(*bios_data_area_ptr));
//   printf("size of FxDsk is %d.\n", sizeof(FIXED_DISK));
   printf("size of EDD_disk is %d.\n", sizeof(EDD_DISK));
	printf("size of T_CURSOR_POSITION is %d.\n", sizeof(T_CURSOR_POSITION));

	B = malloc(sizeof(*B));
	if ((dword)B==0) return 5;

	B->keyboard_flags_0 = 0;	
	printf("keyboard_flags_0 at 40:%02X\n", ofs(keyboard_flags_0));
	printf("video_mode at 40:%02X\n", ofs(video_mode));
	printf("EGA_data at 40:%02X\n", ofs(EGA_data));
	printf("EMS_start at 40:%02X\n", ofs(EMS_start));
	printf("n_fixed_disks at 40:%02X\n", ofs(n_fixed_disks));

	printf("FPEM_segment at 40:%02X\n", ofs(FPEM_segment));
	printf("cpu_xtal at 40:%02X\n", ofs(cpu_xtal));

	return 0;
}


