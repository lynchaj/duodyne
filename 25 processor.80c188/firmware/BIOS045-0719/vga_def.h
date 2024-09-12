/* vga_def.h	-- table used to set up the HD6445CP4 CRTC from paramaters provided */

const
byte vga_params [] =			/* pairs:  register number, parameter value */
  {	0,	HORIZONTAL_TOTAL - 1,		/* Nht-1 */
	1,	HORIZONTAL_DISPLAYED,		/* Nhd */
	2,	HORIZONTAL_DISPLAYED + HORIZONTAL_FRONT_PORCH,	/* Nhsp Sync Position */
	3,	(VERTICAL_SYNC_WIDTH<<4) | (HORIZONTAL_SYNC_WIDTH & 0x0F),	/* Nvsw, Nhsw */
	4,	VERTICAL_TOTAL - 1,		/* Nvt */
	5,	VERTICAL_TOTAL_ADJUST,		/* Nadj */
	6,	VERTICAL_DISPLAYED,		/* Nvd */
	7,	VERTICAL_DISPLAYED + VERTICAL_FRONT_PORCH,	/* Nvsp */
	
	9,	CHARACTER_HEIGHT - 1,		/* Nr */
	10,	CURSOR_START | CURSOR_BLINK,
	11,	CURSOR_END,
	
	12,	((word)SCREEN_ADDRESS >> 8) & 0xFF,	/* Screen 1 start H */
	13,	SCREEN_ADDRESS & 0xFF,		/* Screen 1 start L */
	
	30,	0,		/* Control 1 */
	31,	0,		/* Control 2 */
	32,	0,		/* Control 3 */

#ifdef VERTICAL_SYNC_POSITION_ADJUST
	27,	VERTICAL_SYNC_POSITION_ADJUST,
	30,	0x08,
#endif	
	0xFF	};	/* end marker */
	

