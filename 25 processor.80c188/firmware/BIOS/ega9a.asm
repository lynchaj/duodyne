;========================================================================
; ega9a.asm -- EGA 720x368  9-bit characters */
;========================================================================

;/*  requires 16.257Mhz oscillator frequency */
;/*  resulting horizontal scan rate is 18.432Khz */
;/*  resulting vertical scan rate is 50Hz */

%define RED		8
%define GREEN	4
%define BLUE	2
%define BRIGHT	1
%define BLACK	0
%define AMBER	(RED+GREEN)
%define WHITE	(RED+GREEN+BLUE)
%define CYAN	(GREEN+BLUE)
%define MAGENTA (RED+BLUE)
%define YELLOW	(BRIGHT+AMBER)


%define HorizontalTotal					98
%define HorizontalDisplayed			80
%define YPitch								80
%define HorizontalSyncAt				87
%define HorizontalSyncWidth			4
%define VerticalTotal					26
%define VerticalDisplayed				25
%define VerticalLineAdjust		2	/* should be 4, but 2 looks better for me */
%define VerticalSyncWidth				1
%define VerticalSyncAt					26
%define Interlace							0
%define DisplayEnableBegin				6
%define DisplayEnableEnd				86
%define RefreshCyclesPerLine			3
%define CharacterWidth					8
%define CharacterWidthTotal			9
%define CharacterBoxHeight				14
%define CharacterHeight					14
%define CursorSolid						0
%define CursorOff							1
%define CursorBlinkFast					2
%define CursorBlinkSlow					3
%define CursorMode						CursorBlinkFast
%define CursorStartLine					12
%define CursorEndLine					13
%define UnderlinePosition				(CharacterHeight-1)
%define MonochromeForegroundColor	GREEN
%define BackgroundColor					Black
%define GraphicMode						0x80
%define TextMode							0
%define ColorMode							0x40
%define MonochromeMode					0
%define PixelRepeat						0x20
%define DoubleWide						0x10
%define HorizontalScroll				CharacterWidth
%define CharsetAddress					(8*1024)
%define TextStartAddress				(0*1024)
%define AttributeOffset					(2*1024)
%define DRAMSize							64				/* or 16 */
;;; for register 24:    */
%define BlockCopy							0x80
%define BlockFill							0x00
%define BlockOperationMask				0x80
%define ReverseMonoScreen				0x40
%define BlinkRateFast					0x20
%define VerticalSmoothScrollMask		0x1F



UpperLeft	equ		0x0000
LowerRight	equ		((VerticalDisplayed-1)<<8)+HorizontalDisplayed
