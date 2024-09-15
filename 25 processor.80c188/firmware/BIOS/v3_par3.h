/* vga_par3.h */

/*  the video parameters for the HD6445CP4 CRTC chip	*/

/* 80x43 @ 60hz   720x480 (525 lines)  */

#define	CHARACTER_HEIGHT		11	/* note condensed 8x8 font */
#define	CHARACTER_WIDTH			9

/* parameters in CHARACTERS				*/
#define	HORIZONTAL_TOTAL		100
#define	HORIZONTAL_DISPLAYED		80
#define	HORIZONTAL_FRONT_PORCH		2	/* determines hor. sync position */
#define	HORIZONTAL_SYNC_WIDTH		12
#define	HORIZONTAL_BACK_PORCH		6	/* use to check:  TOTAL = DISPLAYED + FRONT_PORCH + HSYNC_WIDTH + BACK_PORCH	*/

/* parameters in RASTER LINES				*/
#define	VERTICAL_TOTAL_ADJUST		8
#define	VERTICAL_SYNC_WIDTH		2
#define	CURSOR_START			13
#define CURSOR_END			14
#define CURSOR_BLINK			0x60	/* BLINK ON, RATE = 1/32 VERTICAL SCAN RATE */

/* parameters in CHAR ROWS				*/
#define	VERTICAL_TOTAL			47
#define	VERTICAL_DISPLAYED		43
#define	VERTICAL_FRONT_PORCH		1	/* 12 raster lines in VERTICAL_SYNC_POSITION_ADJUST */

#define VERTICAL_SYNC_POSITION_ADJUST		1


/* parameters in BYTES					*/
#define	SCREEN_ADDRESS			0x0000
#define FONT_ADDRESS			(7 * 4096)


/* end vga_param1.h */
