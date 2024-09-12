#ifndef __DEBUG_H
#define __DEBUG_H
#include "mytypes.h"

/*#include <_comdef.h>*/

#if defined(_M_IX86)
__declspec(__watcall) extern unsigned inp(unsigned __port);
__declspec(__watcall) extern unsigned inpw(unsigned __port);
__declspec(__watcall) extern unsigned outp(unsigned __port, unsigned __value);
__declspec(__watcall) extern unsigned outpw(unsigned __port,unsigned __value);
#endif

#if defined(__INLINE_FUNCTIONS__) && defined(_M_IX86)
 #pragma intrinsic(inp,inpw,outp,outpw)
#endif


#ifndef SOFT_DEBUG
#define SOFT_DEBUG 1
#endif

#define ADDRESS(s,o) (void*)((dword)(s)<<16|(o))
#define REG_STRING "SSDSESDISIBPSPBXDXCXAXIPCSFL"
#define FLAG_REG	13

/* the state of the machine as saved on a trap */
typedef
struct State {
   word  regSS,
         regDS,
         regES,

         regDI,
         regSI,
         regBP,
         regSP,
         regBX,
         regDX,
         regCX,
         regAX,

         regIP,
         regCS,
         regFLAGS;
} STATE;

typedef
struct Breakpoint {
   union {
      byte *ptr;
      struct {
         word offset;      /* IP of breakpoint */
         word segment;     /* must always be CS in Compact model */
      } w;
   } where;
   byte flag;  /* enable=1, disable=0 */
   byte save;  /* saved opcode */
   word count; /* number of breaks before reentering debugger */
} BREAKPOINT;


__declspec(__cdecl) char *unasm(byte *istream, word *length, word base_IP);
/*char __cdecl *unasm(byte *istream, word *length, word base_IP);*/
word __fastcall len_instr (byte *istream);
word __cdecl unassemble (word ninstr, struct State *state);
dword __cdecl command(struct State *state);

#endif  // __DEBUG_H
