/* ega9a.h -- EGA 720x368  9-bit characters */

/*  requires 16.257Mhz oscillator frequency */
/*  resulting horizontal scan rate is 18.432Khz */
/*  resulting vertical scan rate is 50Hz */

#define RED		8
#define GREEN	4
#define BLUE	2
#define BRIGHT	1
#define BLACK	0
#define AMBER	(RED+GREEN)
#define WHITE	(RED+GREEN+BLUE)
#define CYAN	(GREEN+BLUE)
#define MAGENTA (RED+BLUE)
#define YELLOW	(BRIGHT+AMBER)


#define HorizontalTotal					98
#define HorizontalDisplayed			80
#define YPitch								80
#define HorizontalSyncAt				87
#define HorizontalSyncWidth			4
#define VerticalTotal					26
#define VerticalDisplayed				25
#define VerticalLineAdjust		2	/* should be 4, but 2 looks better for me */
#define VerticalSyncWidth				1
#define VerticalSyncAt					26
#define Interlace							0
#define DisplayEnableBegin				6
#define DisplayEnableEnd				86
#define RefreshCyclesPerLine			3
#define CharacterWidth					8
#define CharacterWidthTotal			9
#define CharacterBoxHeight				14
#define CharacterHeight					14
#define CursorSolid						0
#define CursorOff							1
#define CursorBlinkFast					2
#define CursorBlinkSlow					3
#define CursorMode						CursorBlinkFast
#define CursorStartLine					12
#define CursorEndLine					13
#define UnderlinePosition				(CharacterHeight-1)
#define MonochromeForegroundColor	GREEN
#define BackgroundColor					Black
#define GraphicMode						0x80
#define TextMode							0
#define ColorMode							0x40
#define MonochromeMode					0
#define PixelRepeat						0x20
#define DoubleWide						0x10
#define HorizontalScroll				CharacterWidth
#define CharsetAddress					(8*1024)
#define TextStartAddress				(0*1024)
#define AttributeOffset					(2*1024)
#define DRAMSize							64		/* must be 64, adjusted later if 16K DRAM */
/* for register 24:    */
#define BlockCopy							0x80
#define BlockFill							0x00
#define BlockOperationMask				0x80
#define ReverseMonoScreen				0x40
#define BlinkRateFast					0x20
#define VerticalSmoothScrollMask		0x1F


0,		/* hor. total - 1 */  			HorizontalTotal-1,
1,		/* hor. displayed */				HorizontalDisplayed,
2,		/* hor. sync position */		HorizontalSyncAt,
3,		/* vert/hor sync width */		(VerticalSyncWidth<<4)|(HorizontalSyncWidth+1),
4,		/* vert total */					VerticalTotal,
5,		/* vert total adjust */ 		VerticalLineAdjust,
6,		/* vert. displayed */			VerticalDisplayed,
7,		/* vert. sync postition */		VerticalSyncAt,
8,		/* interlace mode */				Interlace,
34,	/* display enable begin */		DisplayEnableBegin,
35,	/* display enable end */		DisplayEnableEnd,
36,	/* refresh rate */ 				RefreshCyclesPerLine,
9,		/* char box height - 1 */		CharacterBoxHeight-1,
23,	/* char pixel display - 1 */	CharacterHeight-1,
10,	/* cursor mode, start line */	(CursorMode<<5)|CursorStartLine,
11,	/* cursor end line */			CursorEndLine,
22,	/* char hor size cntrl */		(CharacterWidth<<4)|CharacterWidthTotal,
25,	/* gr/txt, color/mono, pxl-rpt, dbl-wide; horiz. scroll */
		TextMode | ColorMode |                    HorizontalScroll,
26,	/* fg/bg colors (monochr) */	(GREEN<<4) | BLACK,
27,	/* row addr display incr */	YPitch-HorizontalDisplayed,
28,	/* char set addr; RAM size (64/16) */	((CharsetAddress/8192)<<5) | ((DRAMSize/64)<<4),
29,	/* underline position */		UnderlinePosition,
20,	/* attribute start addr hi */	((TextStartAddress+AttributeOffset) >> 8),			/* 0x0800 = 2048 */
21,	/* attribute start addr lo */	((TextStartAddress+AttributeOffset) & 255),
12,	/* display start addr hi */	(TextStartAddress >> 8),
13,	/* display start addr lo */	(TextStartAddress & 255),
24,	/* copy/fill, reverse, blink rate; vertical scroll */
		BlockFill | (ReverseMonoScreen&0) | BlinkRateFast | (0 & VerticalSmoothScrollMask),
14,	/* cursor position hi */		(TextStartAddress >> 8),
15,	/* cursor position lo */		(TextStartAddress & 255),
//	32,		/* block copy src hi */			0,
//	33,		/* block copy src lo */			0, 		/* 33 */
//	18,		/* update address hi */			0,
//	19,		/* update address lo */			0,			/* 19 */
//	30,		/* word count - 1 */				0, 		/* 30 */
//	31,		/* data */							0,
// 16,		/* light pen vertical */		0,
// 17,		/* light pen horizontal */		0,
