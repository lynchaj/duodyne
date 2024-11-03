/* dmaide.h

   Definitions for the Dual DMA IDE board

 */
#ifndef __DMAIDE_H
#define __DMAIDE_H
#include "mytypes.h"
#include "sbc188.h"

// SBC-188 external I/O prefix
#define  CPU_IO_BASE     0x0400

// General definition
#define  SECTOR_SIZE    512

// Dual DMA IDE board jumper setting
#define  IO_DMAIDE   (CPU_IO_BASE | 0x80)

// Primary/Secondary IDE connectors
#define  IO_PRIMARY_IDE    (IO_DMAIDE | 0x00)
#define  IO_SECONDARY_IDE  (IO_DMAIDE | 0x10)

// IDE control registers
#define  IO_PCS0     (IO_PRIMARY_IDE | 0x00)
#define  IO_PCS1     (IO_PRIMARY_IDE | 0x08)
#define  IO_SCS0     (IO_SECONDARY_IDE | 0x00)
#define  IO_SCS1     (IO_SECONDARY_IDE | 0x08)

// DMA acknowledge device codes
#define  IO_P_DMAK   (IO_PRIMARY_IDE | 9)
#define  IO_S_DMAK   (IO_SECONDARY_IDE | 9)


// IDE interface CS0 registers
#define  CS0_DATA    0
#define  CS0_ERR     1
#define  CS0_FEATURE 1
#define  CS0_SEC_CNT 2
#define  CS0_SECTOR  3
#define  CS0_CYL_LSB 4
#define  CS0_CYL_MSB 5
#define  CS0_HEAD    6
#define  CS0_COMMAND 7
#define  CS0_STATUS  7

#define  CS1_CONTROL 6
#define  CS1_STATUS  7
#define  CS1_ADDRESS 7
// 16-bit data is transferred here, a byte at a time
#define  CS1_DATA16  8

// the IDE command codes
#define  IDE_CMD_RECAL        0x10
#define  IDE_CMD_PIO_READ     0x20
#define  IDE_CMD_PIO_WRITE    0x30
#define  IDE_CMD_INIT_PARAM   0x91
#define  IDE_CMD_DMA_READ     0xC8
#define  IDE_CMD_DMA_WRITE    0xCA
#define  IDE_CMD_SPINDOWN     0xE0
#define  IDE_CMD_SPINUP       0xE1
#define  IDE_CMD_IDENT        0xEC
#define  IDE_CMD_SET_FEATURE  0xEF

// Device Control register bits
#define  CTRL_ALWAYS    0x08
// bit 3 must always be asserted when written
#define  CTRL_RESET     0x04
#define  CTRL_nIEN      0x02
// interrupt enable is active when == 0

// the Master/Slave bit (head register)
#define  IDE_MASTER  0x00
#define  IDE_SLAVE   0x10
#define  IDE_LBA     0xE0
#define  IDE_CHS     0xA0

// Status Register Bits
#define  ST_BUSY     0x80
#define  ST_READY    0x40
#define  ST_WFAULT   0x20
#define  ST_SEEKDONE 0x10
#define  ST_DATARQ   0x08
#define  ST_CORR     0x04
#define  ST_INDEX    0x02
#define  ST_ERROR    0x01


// IDE interface Features
#define  SET_8BIT    0x01
#define  RESET_8BIT  0x81
#define  SET_16BIT   RESET_8BIT

// Address Register bits (active when == 0)
#define  nDS0        0x01
#define  nDS1        0x02
#define  nHEAD       0x3C
#define  nWTG        0x40

// Error Register bits
#define  ERR_BADBLK     0x80
#define  ERR_UCORR      0x40
#define  ERR_MEDIA_CHG  0x20
#define  ERR_IDNF       0x10
#define  ERR_MCHG_REQ   0x08
#define  ERR_ABRT       0x04
#define  ERR_TK0NF      0x02
#define  ERR_AMNF       0x01


// Now  the Floppy Disk section of the board
#define  IDE_FDC_MSR       (IO_DMAIDE | 0x0A)
#define  IDE_FDC_DATA      (IO_DMAIDE | 0X0B)
#define  IDE_FDC_LDOR      (IO_DMAIDE | 0x0C)
#define  IDE_FDC_LDCR      (IO_DMAIDE | 0x0D)
#define  IDE_FDC_F8RES     (IO_DMAIDE | 0x1A)
#define  IDE_FDC_TC        (IO_DMAIDE | 0x1B)
#define  IDE_FDC_DACK      (IO_DMAIDE | 0x1C)
#define  IDE_FDC_DACK_TC   (IO_DMAIDE | 0x1D)

#endif // __DMAIDE_H 

