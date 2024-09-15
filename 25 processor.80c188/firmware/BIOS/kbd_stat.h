/* kbd_stat.h */
#ifndef _KBD_STAT_H
#define _KBD_STAT_H

#define MaskRightShift		000001
#define MaskLeftShift		000002
#define MaskCtrlOn			000004
#define MaskAltOn				000010
#define MaskScrollLock		000020
#define MaskNumLock			000040
#define MaskCapsLock			000100
#define MaskInsertMode		000200

#define MaskLeftCtrl			000400
#define MaskLeftAlt			001000
#define MaskRightCtrl		002000
#define MaskRightAlt			004000
#define MaskScrollDown		010000
#define MaskNumLockDown		020000
#define MaskCapsLockDown	040000
#define MaskSysReqDown		0100000

#define MaskAnyShift			(MaskRightShift|MaskLeftShift)
#define MaskEitherCtrl			(MaskLeftCtrl|MaskRightCtrl)
#define MaskEitherAlt			(MaskLeftAlt|MaskRightAlt)

#define MaskCtrlAlt (MaskCtrlOn|MaskAltOn)

#endif /* _KBD_STAT_H */

