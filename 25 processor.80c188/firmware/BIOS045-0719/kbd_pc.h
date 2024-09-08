/* kbd_pc.h */
#ifndef _KBD_PC_H
#define _KBD_PC_H
#include "mytypes.h"

typedef enum {
	KPD=0x81, FUN, FFN, ACT=0x84, CAP, LSH, RSH, LCN, RCN, LAL, RAL, NUM, SCR
} Special;

#define UP 0x80
#define MaskE0 0x01

static const byte trans_no_shift[] = {
000,033,'1','2','3','4','5','6','7','8','9','0','-','=',010,011,
'q','w','e','r','t','y','u','i','o','p','[',']',015,LCN,'a','s',
'd','f','g','h','j','k','l',';','\'','`',LSH,'\\','z','x','c','v', 
'b','n','m',',','.','/',RSH,'*',LAL,' ',CAP,FUN,FUN,FUN,FUN,FUN,
FUN,FUN,FUN,FUN,FUN,NUM,SCR,KPD,KPD,KPD,'-',KPD,KPD,KPD,'+',KPD,
KPD,KPD,KPD,KPD,000,000,000,FFN,FFN,000,000,000,000,000,000,000,
000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,
000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
};
static const byte trans_shifted[] = {
000,033,'!','@','#','$','%','^','&','*','(',')','_','+',010,011,
'Q','W','E','R','T','Y','U','I','O','P','{','}',015,LCN,'A','S',
'D','F','G','H','J','K','L',':','"','~',LSH,'|','Z','X','C','V', 
'B','N','N','<','>','?',RSH,'*',LAL,' ',CAP,FUN,FUN,FUN,FUN,FUN,
FUN,FUN,FUN,FUN,FUN,NUM,SCR,KPD,KPD,KPD,'-',KPD,KPD,KPD,'+',KPD,
KPD,KPD,KPD,KPD,000,000,000,FFN,FFN,000,000,000,000,000,000,000,
000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,
000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
};


/* Keypad starts at scan code 0x47 */

#if 0
static const byte keypad_no_numlock[] = {
000,000,000,000,000,000,000,000,000,000,000,000,000
};
#endif

static const byte keypad_numlock[] = {
'7','8','9','-','4','5','6','+','1','2','3','0','.'
};

static const byte keypad_ctrl[] = {
0x77, 0, 0x84, 0, 0x73, 0, 0x74, 0, 0x75, 0, 0x76, 0, 0
};

#endif /* _KBD_PC_H */
