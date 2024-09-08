/*************************************************************************
*  debug.c   for the N8VEM  SBC-188
**************************************************************************
*
*   Copyright (C) 2010 John R. Coffman.  All rights reserved.
*   Provided for hobbyist use on the N8VEM SBC-188 board.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*************************************************************************/
#include "sbc188.h"
#include "sio.h"
#include "debug.h"
#include "equates.h"
#include "libc.h"

#define RUB DEL
#define ULONG_MAX 0xFFFFFFFFuL

#pragma intrinsic(inp,inpw,outp,outpw)

#define is_alpha(x) ((x)>='A'&&(x)<='Z')
#define is_separator(x) ((x)<=' ')

typedef
struct Dstate {
   word segment, offset;
   word length;
   int size;
} DSTATE;




static
char ndigit(char ch)
{
    register char c;
    
    c = ch;
    
    if (c >= '0' && c <= '9') c -= '0';
    else if (c >= 'A' && c <= 'Z') c -= ('A'-10);
    else if (c >= 'a' && c <= 'z') c -= ('a'-10);
    else c = RUB;

//    printf("exit ndigit   c = %d\n", (int)c);    
    return c;
}

unsigned long int strtoul(char *cptr, char **endptr, int radix)
{
    signed char sign = 0;
    unsigned long int  value = 0UL;
    char *cp;
    byte digit;
    unsigned long int  max;
    byte maxdigit;
    int errno;

    cp = cptr;    
    errno = 0;
    while (*cp == SP  ||  *cp == HT) ++cp;
    
    if (*cp == '-') sign = -1, ++cp;
    else if (*cp == '+') sign = 1, ++cp;
    
    digit = ndigit(*cp);
//    printf("stage 1   digit=%d\n", (int)digit);
    if (radix == 0) {
        if (digit == 0) {
            radix = 8;
            ++cp;
            if (ndigit(*cp) == 33 /* 'X' */ ) {
                radix = 16;
                digit = ndigit(*++cp);
            }
            else --cp;
        }
        else radix = 10;
    }
    else if (radix == 16  &&  digit == 0  &&  ndigit(cp[1]) == 33) ++cp;
    
//    printf("stage 2   radix=%d\n", (int)radix);
    if (digit >= radix) {	/* invalid digit */
        cp = cptr;
        errno = 1;
    }
    else {
//        printf("stage 3\n");
#if 0
        max = ULONG_MAX / radix;
        maxdigit = ULONG_MAX % radix;
#else
	max = divLS(ULONG_MAX, radix);
	maxdigit = remLS(ULONG_MAX, radix);
#endif

//        printf("stage 4\n");
        value = digit;
        while ( (digit = ndigit(*++cp)) != RUB) {
            if (digit < radix  &&  (value < max || (value == max && digit <= maxdigit)) ) {
#if 0
                value *= radix;
#else
		value = mulLS(value, radix);
#endif
                value += digit;
            }
            else {
                errno = 1;
                value = 0;
                ++cp;
            }
        }
        --cp;
        if (sign<0) value = -(signed int)value;
    }
    if (endptr) *endptr = ++cp;    
    
    return errno ? ULONG_MAX : value;
}


word __fastcall len_instr (byte *stream)
{
	word length, ip;
	
	ip = 0;
/*   check for segment override prefix, repeat or lock prefix */
	while ((*stream & 0xE7)==0x26 || (*stream & 0xFC)==0xF0)  {
		stream ++; ip ++;
	}
	unasm(stream, &length, ip);

	return ip + length;
}


int strncmp(char *a, char *b, int n)
{
	int eq = 0;
	while (n && !eq && (*a || *b) ) {
		if (*a < *b) eq = -1;
		if (*a > *b) eq = 1;
		a++;
		b++;
		--n;
	}
	return eq;
}

char *strstr(char *str, char *pat)
{
	char *cp = str;
	int i = strlen(pat);

	while (*cp && strncmp(cp, pat, i))  cp++;
	if (*cp) return cp;
	return (void*)0L;
}


word unassemble (word ninstr, struct State *state)
{
	word codeseg, instrptr, linstr;
	char *line;
   byte *istream;

	codeseg = state->regCS;
	instrptr = state->regIP;
   istream = ADDRESS(codeseg,instrptr);

	while (ninstr) {
		printf("%04x:%04x  %s\n", codeseg, instrptr,
			  line=unasm(istream, &linstr, instrptr) );
		instrptr += linstr;
/* check for segment override prefix, repeat or lock prefix */
		while ((*istream & 0xE7)==0x26 || (*istream & 0xFC)==0xF0)  {
			printf("           %s\n", unasm(++istream, &linstr, instrptr));
			instrptr += linstr;
		}
		--ninstr;
	}
	return (instrptr - state->regIP);
}

void usage(void)
{
   printf(
      "?,h - print this help message\n"
      "b <ip> - insert breakpoint\n"
      "bc <n> - clear/remove breakpoint\n"
      "bd <n> - disable breakpoint\n"
      "be <n> - enable breakpoint\n"
      "bl - list breakpoints\n"
      "d[b|w] [[<segment>:]<offset>] [L<length>] - dump memory\n"
      "g - go: continue from current location\n"
      "i[b|w] <port> - input from I/O port\n"
      "o[b|w] <port> <datum> - output to I/O port\n"
      "r[<reg> [<value>]] - print/assign all/one register(s)\n"
      "s - step over (call/trap)\n"
      "t - trace execution (single step)\n"
      "u [[<segment>:]<offset>] [L<length>] - unassemble\n"
      "\n"
   );
}

char *uppercase(char *line)
{
   char *cp = line;
   char *tp;

   while (*cp && *cp <= SP) ++cp;
   tp = cp;

   while (*cp) {
      if (*cp >= 'a' && *cp <= 'z') *cp -= 'a'-'A';
      ++cp;
   }

   return tp;
}

char *lowercase(char *line)
{
   char *cp = line;
   char *tp;

   while (*cp && *cp <= SP) ++cp;
   tp = cp;

   while (*cp) {
      if (*cp >= 'A' && *cp <= 'Z') *cp += 'a'-'A';
      ++cp;
   }

   return tp;
}

char regs[] = REG_STRING;

/* see if next param matches a register string */
int ireg(char *line, struct State *state)
{
   int i = 0;
   char *cp = line;

   while (regs[i]) {
      if (cp[0]==regs[i] && cp[1]==regs[i+1]) {
         return i >> 1;
      }
      i += 2;
   }
   return -1;
}


dword get_value(char **line, struct State *state)
{
   char *cp = *line;
   char *rp = regs;
   dword value;
   int i;

   cp = uppercase(cp);
   i = ireg(cp, state);
	if (i >= 0) {
      value = ((word*)state)[i];
      *line += 2;
   }
   else value = strtoul(cp, line, 16);

/***   printf("Value=0x%lx\n", value);	***/
   return value;
}



void output(char *line, struct State *state)
{
   dword port, content;
   char *cp = line;
   int size = 0;  /* byte size */

   if (*cp == 'W') { size = 1; ++cp; }
   else if (*cp == 'B') { size = 0; ++cp; }

   port = get_value(&cp, state);
   if (port == -1) {
      printf("?\n");
      return;
   }
   content = get_value(&cp, state);
   if (content == -1) {
      printf("?\n");
      return;
   }

   if (port < 0xFF && size) port |= 0xFF00;
   else if ((port & 0xFF00) == 0xFF00) size = 1;
   else if (port < 0x0FFF) size = 0;

   size ? outpw((word)port,(word)content)
        : outp((word)port,(word)content);
}

void input(char *line, struct State *state)
{
   dword port;
   word content;
   char *cp = line;
   int size = 0;  /* byte size */

   if (*cp == 'W') { size = 1; ++cp; }
   else if (*cp == 'B') { size = 0; ++cp; }

   port = get_value(&cp, state);
   if (port == -1) {
      printf("?\n");
      return;
   }

   if (port < 0xFF && size) port |= 0xFF00;
   else if ((port & 0xFF00) == 0xFF00) size = 1;
   else if (port < 0x0FFF) size = 0;

   content = size ? inpw((word)port) : inp((word)port);
   printf(size?"%04x\n":"%02x\n", content);
}

static byte fl[] = {11,10,9,7,6,4,2,0};
static char ch[] = "noOVupDNdiEIplMInzZRnaACpoPEncCY";

dword get_flag_value(char **line)
{
	char *cp;
	dword value = -1uL;
	int i;

	*line = uppercase(*line);
	if (strlen(*line) >= 2) {
		cp = strstr(ch, *line);
		if (cp) {
			i = (int)(cp-ch) / 4;
			value = 1uL << fl[i];
		}
		*line = lowercase(*line);
		cp = strstr(ch, *line);
		if (cp) {
			i = (int)(cp-ch) / 4;
			value = 1uL << fl[i];
			value ^= 0xFFFFuL;
		}
	}
	return value;
}


void print_flags(word flags)
{
   int i, j;

   for (i=0; i < sizeof(fl); i++) {
      j = 0;
      if (flags & (1<<fl[i])) j+=2;
      printf("%c%c ", ch[((i<<2)+j)], ch[((i<<2)+j)+1]);
   }
}

void print_regs(struct State *state)
{
   printf("AX=%04x  BX=%04x  CX=%04x  DX=%04x  ",
      state->regAX, state->regBX, state->regCX, state->regDX);
   printf("BP=%04x  SI=%04x  DI=%04x  Flags=%03x\n",
      state->regBP, state->regSI, state->regDI, state->regFLAGS & ~0xF002);
   printf("DS=%04x  ES=%04x  CS:IP=%04x:%04x  SS:SP=%04x:%04x   ",
      state->regDS, state->regES, state->regCS, state->regIP,
      state->regSS, state->regSP);
   print_flags(state->regFLAGS);
   printf("\n");
}

dword get_seg_off(word *Seg, word *Off, char **line, struct State *state)
{
	word Offset, Segment;
	
	*line = uppercase(*line);

	Segment = *Seg;
   Offset = get_value(line, state);
	if (Offset == -1) return -1uL;
	if (**line == ':') {
      Segment = Offset;
      (*line)++;
      Offset = get_value(line, state);
   }
	*Seg = Segment;
	*Off = Offset;
	return ((dword)Segment<<16) + Offset;
}

void Rcmd(char *line, struct State *state)
{
   int reg;
   dword value;
   char *ss = "SS";
   char *sp = "SP";

   line = uppercase(line);
   reg = ireg(line, state);
   if (reg < 0) {
      print_regs(state);
      unassemble(1, state);
   }
   else {
      line += 2;
		if (reg != FLAG_REG)
	      value = get_value(&line, state);
		else
			value = get_flag_value(&line);

      if (value == -1uL) {
         value = ((word*)state)[reg];
         if (reg < FLAG_REG) printf("%04x", ((word*)state)[reg]);
			else print_flags(value);
		   printf("\n");
      }
      else {
			if (reg == FLAG_REG) {
				if ((value & (value-1)))
					((word*)state)[reg] &= value;
				else
					((word*)state)[reg] |= value;
			}
			else if (reg != ireg(ss,state) && reg != ireg(sp,state) )
            ((word*)state)[reg] = value;
         else printf("You may not alter SS or SP\n");
      }
   }
}

void Ucmd(char *line, struct State *state, struct Dstate *ustate)
{
   dword Offset;
   word codeseg, instrptr;
   word ninstr, linstr;
   byte *istream;

   line = uppercase(line);
   if (*line == 'L') {
      line++;
      ustate->length = get_value(&line,state);
   }

   Offset = get_value(&line, state);
   if (Offset == -1) { /* continue the dump */; }
   else if (*line == ':') {
      ustate->segment = Offset;
      line++;
      Offset = get_value(&line, state);
   }
   if (Offset != -1) ustate->offset = Offset;

   line = uppercase(line);
   if (*line == 'L') {
      line++;
      ustate->length = get_value(&line, state);
   }


  	codeseg = ustate->segment;
	instrptr = ustate->offset;
   ninstr = ustate->length;

	while (ninstr) {
      istream = ADDRESS(codeseg,instrptr);
		printf("%04x:%04x  %s\n", codeseg, instrptr,
			  line=unasm(istream, &linstr, instrptr) );
		instrptr += linstr;
/* check for segment override prefix, repeat or lock prefix */
		while ((*istream & 0xE7)==0x26 || (*istream & 0xFC)==0xF0)  {
			printf("           %s\n", unasm(++istream, &linstr, instrptr));
			instrptr += linstr;
		}
		--ninstr;
	}
   ustate->offset = instrptr;
}



void Dcmd(char *line, struct State *state, struct Dstate *dstate)
{
   dword Offset;
   int n, k;
   byte *btp;
   word *wtp;
   word seg, off;
   char ch[17];
   int i;

   if (*line == 'B') { dstate->size = 1; line++; }
   else if (*line == 'W') { dstate->size = 2; line++; }

   line = uppercase(line);
   if (*line == 'L') {
      line++;
      dstate->length = get_value(&line,state);
   }

	seg = dstate->segment;
   Offset = get_seg_off( &seg, &off, &line, state);
   if (Offset == -1L) { /* continue the dump */; }
   else {
		dstate->offset = off;
		dstate->segment = seg;
	}

   line = uppercase(line);
   if (*line == 'L') {
      line++;
      dstate->length = get_value(&line, state);
   }

   n = dstate->length;
   seg = dstate->segment;
   off = dstate->offset;
   k = 0;
   if (dstate->size==1) {
      btp = (void*)( (dword)seg << 16 | (dword)off );
      while (k<n) {
         if (k%16 == 0) {
            printf("%04x:%04x ", seg, off);
            i = 0;
         }
         ch[i++] = (*btp>=' ' && *btp<0x7F) ? *btp : '.';
         printf(" %02x", *btp++);
         off++;
         k++;
         if (k%16 == 8) printf(" ");
         if (k%16 == 0) {
            ch[i] = 0;
            printf("   %s\n", ch);
         }
      }
      ch[i] = 0;
      if (k%16) printf("   %s\n", ch);
   }
   else if (dstate->size == 2) {   /* size==2 */
      wtp = (void*)( (dword)seg << 16 | (dword)off );
      while (k<n) {
         if (k%8 == 0) printf("%04x:%04x ", seg, off);
         printf(" %04x", *wtp++);
         off += 2;
         k++;
         if (k%8 == 0) printf("\n");
      }
      if (k%8) printf("\n");
   }
   else printf("??? dstate->size = %d\n", dstate->size);
   dstate->offset = off;
}

#define ENABLE 1
#define SET    0x80
#define GOFLAG 0x40
#define BPT    0xCC

#if 0
int is_xfer(byte opcode)
{
	return (opcode == 0xE8 			// call near
			||	opcode == 0x9A			// call far
			|| opcode == 0xFF			// call mem or jmp mem
			|| opcode == 0xEB			// jmp short
			|| opcode == 0xE9			// jmp near
			|| opcode == 0xEA			// jmp far
			|| (opcode >= 0xE0 && opcode <= 0xE3)		// loop, loopcond, jcxz
			|| (opcode & 0xF0) == 0x70	// jcond short
			|| opcode == 0xC3			// retn
			|| opcode == 0xC2			// retn x
			|| (opcode >= 0xCA && opcode <= 0xCF)		// retf, retf n, int, iret
			);
}
#endif

#define brk ((BREAKPOINT*)(bios_data_area_ptr->debug_static_ptr))
dword insert_breaks(dword retcode, struct State *state)
{
   int i;

   for (i=0; i<=NBREAK; i++) {
		if (brk[i].flag & SET) {
			if (brk[i].where.w.offset == state->regIP) {
				if ((retcode>>16) == 0) {
					brk[i].flag |= GOFLAG;	/* go or step */
					retcode = 0x10000uL;	/* set for trace */
				}
			}
      	else if (brk[i].flag & ENABLE) {
         	brk[i].where.ptr[0] = BPT;
      	}
		}
   }
	return retcode;
}

/*  State of 'hit' on return:
	hit == 0		didn't hit a breakpoint, probably a trace trap
	hit == 1		hit a breakpoint and no GOFLAG is set
	hit == 2		didn't hit a breakpoint, but a GOFLAG was found
	hit == 3		hit a breakpoint and a GOFLAG was found

	Only hit==2 indicates a trace trap which is a continuation from
	the point where a breakpoint is set.  In this case, ignore the
	trace trap and proceed.
*/
int remove_breaks(struct State *state)
{
   int i;
	int hit = 0;

   for (i=0; i<=NBREAK; i++) {
      if (brk[i].flag & SET) {
         brk[i].where.ptr[0] = brk[i].save;
			if ((brk[i].flag & ENABLE) 
					&& (brk[i].where.w.offset == state->regIP)) {
				hit |= 1;
			}
			if (brk[i].flag & GOFLAG) hit |= 2;
      }
		brk[i].flag &= ~GOFLAG;
   }
   if (!(hit&2)) brk[NBREAK].flag = 0;  /* remove step break */

	return hit;
}

int set_break(dword ip, struct State *state, int n)
{
/* if n=0, set up any empty breakpoint 
   return 0 if able
   return 1 if no slot available
   return 2 if already set */

/* if n=NBREAK, set up the step breakpoint, which is removed
   as soon as the break is taken */
   int i;
//printf("Set break IP = %04x\n", ip);
   for (i=0; i<NBREAK; i++) { /* check for already set */
      if (brk[i].flag & SET)
         if (brk[i].where.w.offset == (word)ip
			   && brk[i].where.w.segment == (word)(ip>>16) ) return 2;
   }
   if (n==0) {
      for (i=0; i<NBREAK; i++) {
         if ((brk[i].flag & SET) == 0) break;
      }
      if (i>=NBREAK) return 1;
      n = i;
   }
   if (n <= NBREAK) {
      brk[n].where.w.offset = (word)ip;
      brk[n].where.w.segment = (word)(ip>>16);
      brk[n].flag = SET | ENABLE;
      brk[n].save = brk[n].where.ptr[0];
      brk[n].count = 0;
      return 0;
   }
   return 1;
}
#define enable_break(n) brk[n].flag|=ENABLE
#define disable_break(n) brk[n].flag&=~ENABLE
void list_breaks(void)
{
   int i;
   for (i=0; i<NBREAK; i++) {
      if (brk[i].flag & SET)
         printf(" %d %c  %04x:%04x\n", i, brk[i].flag&ENABLE ? 'E' : 'd',
            brk[i].where.w.segment, brk[i].where.w.offset
         );
   }
}


void Bcmd(char *line, struct State *state)
{
   char *cp = line;
   dword value = -1;
   char *tp;
   word n;
	word Segment, Offset;

	Segment = state->regCS;
   if (*cp) {
		tp = cp+1;
      value = get_seg_off( &Segment, &Offset, &tp, state);
   }
   n = value;
   switch (*cp) {
      case 'L':   
         list_breaks();
         break;
      case 'E':   
         if (n<NBREAK && (brk[n].flag&SET) )
            brk[n].flag |= ENABLE;
         break;
      case 'D':
         if (n<NBREAK && (brk[n].flag&SET) )
            brk[n].flag &= ~ENABLE;
         break;
      case 'R':
      case 'C':
         if (n<NBREAK)
            brk[n].flag = 0;
         break;
      default:
         if (value != -1L) {
            n = set_break(value, state, 0);
            if (n==0) printf("  ok\n");
            if (n==1) printf("  none available\n");
            if (n==2) printf("  already set\n");
         }
         break;
   }

}


dword command(struct State *state)
{
   char line[80];
   char *cp;
   word ins_length;
   struct Dstate dstate;
   struct Dstate ustate;
   dword retcode;
	int hit;
   int looping = 1;

   dstate.segment = state->regDS;
   dstate.offset = 0;
   dstate.length = 64;
   dstate.size = 1;

   ustate.segment = state->regCS;
   ustate.offset = state->regIP;
   ustate.length = 1;
   ustate.size = 0;

	retcode = 0;
   hit = remove_breaks(state);
	if (hit != 2) {
   	print_regs(state);
   	ins_length = unassemble(1, state);
// printf("Length=%d\n", ins_length);
   	do {
      	printf("-");
      	GETLINE(line);
      	cp = uppercase(line);
// printf(">>%s<<\n", cp);
      	switch (*cp++) {
         	case 0:     break;
         	case 'B':   Bcmd(cp, state); break;
         	case 'D':   Dcmd(cp, state, &dstate); break;
         	case 'G':   if (*cp==0) looping = retcode = 0; break;   /* count=0, code=0 */
         	case 'H':
         	case '?':   usage(); break;
         	case 'I':   input(cp, state); break;
         	case 'O':   output(cp, state); break;
         	case 'R':   Rcmd(cp, state); break;
         	case 'Q':   printf("Do you mean 'G'?\n"); break;
         	case 'S':   if (*cp==0) {
                        	set_break(state->regIP+ins_length, state, NBREAK);
									retcode = ins_length;
									looping = 0;
                     	}
                     	break;
         	case 'T':   if (*cp==0) looping = retcode = 0x10000uL; /* count=1, code=0 */ break;
         	case 'U':   Ucmd(cp, state, &ustate); break;
         	default:    printf("???\n"); break;
      	}
   	} while (looping);
	}
   retcode = insert_breaks(retcode, state);
   return retcode;
}
