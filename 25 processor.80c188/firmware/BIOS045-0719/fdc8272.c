/* fdc8272.c  -- Intel FDC 8272 driver
							copied from the Intel PL/M code
*/
#include "fdc8272.h"
#include "wd37c65.h"

#define VERIFY_SEEK 1

/* globally available variables */

byte drive_status_change[fdc_general];		/* indicates drive status changed */
byte drive_ready[fdc_general];		/* current status of drive */

/* local variables */
static byte operation_in_progress[fdc_general+1];
static byte operation_complete[fdc_general+1];
		 T_docb* operation_docb_ptr[fdc_general+1];
static T_docb interrupt_docb;
static byte global_drive_no;



static const byte no_result[] =
 {0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0
#if FULL_COMMAND_SET
 											,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
#endif
 };
static const byte immed_result[] =
 {0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0
#if FULL_COMMAND_SET
 											,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
#endif
 };
static const byte overlap_operation[] =
 {0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1
#if FULL_COMMAND_SET
 											,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
#endif
 };
static const byte drive_no_present[] =
 {0,0,1,0,1,1,1,1,0,1,1,0,1,1,0,1
#if FULL_COMMAND_SET
 											,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0
#endif
 };
static const byte possible_error[] =
 {0,0,1,0,0,1,1,1,1,1,1,0,1,1,0,1
#if FULL_COMMAND_SET
 											,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0
#endif
 };
static const byte command_length[] =
 {0,0,9,3,2,9,9,2,1,9,2,0,9,6,0,3
#if FULL_COMMAND_SET
 											,0,9,0,0,0,0,0,0,0,9,0,0,0,9,0,0
#endif
 };
#if 1
/* 'valid_command' is just a boolean, so 'command_length' works just as well */
#define valid_command command_length
#else
static const byte valid_command[] =
 {0,0,1,1,1,1,1,1,1,1,1,0,1,1,0,1
#if FULL_COMMAND_SET
 											,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0
#endif
 };
#endif


/*** initialization for the 8272 FDC driver ***/

void initialize_drivers(void)
{
	byte	drv_no;

	for (drv_no = 0; drv_no <= max_no_drives; drv_no++) {
		drive_ready[drv_no] = false;
		drive_status_change[drv_no] = false;
		operation_in_progress[drv_no] = false;
		operation_complete[drv_no] = false;
	}
	operation_in_progress[fdc_general] = false;
	operation_complete[fdc_general] = false;
	global_drive_no = 0;

} /* end initialize_drivers */



/*** wait until the 8272 FDC is ready to receive command/parameter bytes
	in the command phase.  The 8272 is ready to receive command bytes
	when the RQM flag is high and the DIO flag is low 
***/
byte fdc_ready_for_command(void)
{
	/* time(1) */
	usec12();

	/* wait for master request flag */
	wait_for_RQM;

	/* check data direction flag */
	if DIO_set_for_input
		return ok;

	return error;
}


/*** wait until the 8272 FDC is ready to return data bytes in the result
	phase.  The 8272 is ready to return a result byte when the RQM and DIO
	flags are both high.  The busy flag in the main status register will
	remain set until the last data byte of the result phase has been read
	by the processor.
***/
byte fdc_ready_for_result(void)
{
	/* time(1); */
	usec12();

	/* result phase has ended when the 8272 busy flag is reset */
	if (not fdc_busy) return complete;

	/* wait for master request flag */
	wait_for_RQM;

	/* check data direction flag */
	if DIO_set_for_output
		return ok;

	return error;
}


/*** output a single command/parameter byte to the 8272 FDC.  The "data_byte"
	parameter is the byte to be output to the FDC.
***/
byte output_byte_to_fdc(byte data_byte)
{
	/* check to see if FDC is ready for command */
	if (not fdc_ready_for_command)
		propagate_error;

	output(fdc_data_port, data_byte);

	return ok;
}


/*** input a single result byte from the 8272 FDC.  The "data_byte_ptr"
	parameter is a pointer to the memory location that is to contain
	the input byte.
***/
byte input_byte_from_fdc(byte *data_byte_ptr)
{
#define data_byte *data_byte_ptr
	byte	status;

	/* check to see if FDC is ready */
	status = fdc_ready_for_result();
	if (error_in status)
		propagate_error;

	/* check for result phase complete */
	if (status == complete)
		return complete;

	/* get the data byte input */
	data_byte = input(fdc_data_port);

	return ok;
#undef data_byte
}


void output_controls_to_dma(T_docb *docb_ptr)
{
	static byte dma_mode;	/* 2 = read, 3 = write */
	static address dma_addr;
	static word dma_count;
#define docb (*docb_ptr)
	if (docb.dma_op < 3) {
	/* set DMA mode IN / OUT */
	dma_mode = docb.dma_op;

	/* set DMA address */
	dma_addr = docb.dma_addr;

	/* set DMA byte transfer count */
	dma_count = docb.dma_count;

	/* start the DMA channel for the FDC */
	  /*****/
	}
#undef docb
}


/*** output a high-level disk command to the 8272 FDC.  The number of bytes
	required for each command is contained in the "command_length" table.
	The "docb_ptr" parameter is a pointer to the appropriate disk operation
	control block.
***/
byte output_command_to_fdc(T_docb *docb_ptr)
{
	byte cmd_byte_no;
#define docb (*docb_ptr)
	disable();		/* turn off interrupts */

	/* output all command bytes to the FDC */
	for (cmd_byte_no = 0;
					cmd_byte_no < command_length[command_code];
								cmd_byte_no++) {
		if (error_in output_byte_to_fdc(docb.disk_command[cmd_byte_no])) {
			enable();
			propagate_error;
		}
	}
	enable();		/* turn on interrupts */
	return ok;
#undef docb
}


/*** input the result data from the 8272 FDC during the result phase (after
	command execution).  The "docb_ptr" parameter is a pointer to the
	appropriate disk operation control block.
***/
byte input_result_from_fdc(T_docb *docb_ptr)
{
	byte result_byte_no, temp, status;
#define docb (*docb_ptr)
	disable();
	for (result_byte_no = 0; result_byte_no <= 7; result_byte_no++) {
		status = input_byte_from_fdc( &temp );
		if (error_in status) { enable();  propagate_error; }
		if (status == complete) { enable();  return ok; }
		docb.disk_result[result_byte_no] = temp;
	}
	enable();
	if fdc_busy  return error;
	return ok;
#undef docb
}



/*** cleans up after the execution of a disk operation that has no result
	phase.  The procedure is also used after some disk operation errors.
	"drv" is the drive number, and "cc" is the command code for the disk
	operation.
***/
void operation_clean_up(byte drv, byte cc)
{
	disable();
	operation_in_progress[drv] = false;
	if (not overlap_operation[cc])  global_drive_no = 0;
	enable();
}


/*** execute the disk operation control block specified by the pointer
	parameter "docb_ptr".  The "status_ptr" parameter is a pointer to
	a byte variable that is to contain the status of the requested
	operation when it has been completed.  Six status conditions are
	possible on return:

		0	The specified operation was completed without error.
		1	The FDC is busy and the requested operation cannot be started.
		2	FDC error (further information is contained in the result
			storage portion of the disk operation control block -- as
			described in the 8272 data sheet.
		3	Transfer error during output of the command bytes to the FDC.
		4	Transfer error during input of the result bytes from the FDC.
		5	Invalid FDC command.
***/
byte execute_docb(T_docb *docb_ptr, byte *status_ptr)
{
#define docb (*docb_ptr)
#define status *status_ptr
	byte	drive_no;

	/* check command validity */
	if (not valid_command[command_code])
			return (status = stat_invalid);

	/* determine if command has a drive number field -- if not, set the drive
		number for a general FDC command */
	if (drive_no_present[command_code]) {
			drive_no = extract_drive_no;
	}
	else	drive_no = fdc_general;

	/* an overlapped operation cannot be performed if the FDC is busy */
	if (overlap_operation[command_code] && fdc_busy)
			return (status = stat_busy);

	/* for a non-overlapped operation, check FDC busy or any drive seeking */
	if (not overlap_operation[command_code] && (fdc_busy || any_drive_seeking) )
			return (status = stat_busy);

	/* check for drive operation in progress -- if none, set flag and
		start operation  */
	disable();
	if (operation_in_progress[drive_no]) {
		enable();
		return (status = stat_busy);
	}
	else operation_in_progress[drive_no] = true;

	/* at this point, an FDC operation is about to begin, so:
		1.	reset the operation complete flag
		2.	set the docb pointer for the current operation
		3.	if this is not an overlapped operation, set the global drive
			number for the subsequent result phase interrupt */
	operation_complete[drive_no] = false;
	operation_docb_ptr[drive_no] = docb_ptr;

	if (not overlap_operation[command_code]) global_drive_no = drive_no + 1;
	enable();

	output_controls_to_dma(docb_ptr);
	if (error_in output_command_to_fdc(docb_ptr)) {
		operation_clean_up(drive_no, command_code);
		return (status = stat_command_error);
	}

	/* return immediately if the command has no result phase or completion
		interrupt -- specify */
	if (no_result[command_code]) {
		operation_clean_up(drive_no, command_code);
		return (status = stat_ok);
	}
	if (immed_result[command_code]) {
		if (error_in input_result_from_fdc(docb_ptr)) {
			operation_clean_up(drive_no, command_code);
			return (status = stat_result_error);
		}
	}
	else {
		wait_for_op_complete;
		if (docb.misc == error)
				return (status = stat_result_error);
	}

	if (no_fdc_error)
			return (status = stat_ok);
	return (status = stat_error);
#undef docb
#undef status
}


/*** copy disk command results from the interrupt control block to the
	currently active disk operation control block if a disk operation is
	in progress
***/
void copy_int_result(byte drv)
{
	byte i;
	T_docb *docb_ptr;
#define docb (*docb_ptr)
	if (operation_in_progress[drv]) {
		docb_ptr = operation_docb_ptr[drv];
		for (i=0; i<=6; i++)
			docb.disk_result[i] = interrupt_docb.disk_result[i];
		docb.misc = ok;
		operation_in_progress[drv] = false;
		operation_complete[drv] = true;
	}
#undef docb
}



/***
	long interrupt description
***/
void fdcint(void)		/* called at interrupt level */
{
	byte invalid, drive_no;
	T_docb *docb_ptr;
#define docb (*docb_ptr)

#define result_code ((interrupt_docb.disk_result[0] & result_error_mask) >> 6)
#define result_drive_ready ((interrupt_docb.disk_result[0] & result_ready_mask) == 0)
#define extract_result_drive_no (interrupt_docb.disk_result[0] & result_drive_mask)
#define end_of_interrupt	(0)

/* if the FDC is busy when an interrupt is received, then the result
	phase of the previous non-overlapped operation has begun */
	if fdc_busy {
		if (global_drive_no != 0) {
			docb_ptr = operation_docb_ptr[global_drive_no - 1];
			if (error_in input_result_from_fdc(docb_ptr)) 
					docb.misc = error;
			else	docb.misc = ok;
			operation_in_progress[global_drive_no - 1] = false;
			operation_complete[global_drive_no - 1] = true;
			global_drive_no = 0;
		}
	}
/* if the FDC is not busy, then either an overlapped operation has been
	completed or an unexpected interrupt has occurred (e.g., drive status
	change)  */

	else /* not fdc_busy */ {
		invalid = false;
		while (not invalid) {
			/* perform a Sense Interrupt Status operation -- if errors are detected
				in the actual FDC interface, interrupt processing is discontinued */
			if (error_in output_byte_to_fdc(fdc_cmd_sense_int_status)) goto ignore;
			if (error_in input_result_from_fdc( &interrupt_docb )) goto ignore;

			switch (result_code) {
				case 0:	/* operation complete */
				case 1:	/* abnormal termination */
					drive_no = extract_result_drive_no;
					copy_int_result(drive_no);
					break;
				case 2:	/* invalid command */
					invalid = true;
					break;
				case 3:	/* drive ready change */
					drive_no = extract_result_drive_no;
					copy_int_result(drive_no);
					drive_status_change[drive_no] = true;
					if result_drive_ready
							drive_ready[drive_no] = true;
					else	drive_ready[drive_no] = false;
					break;
			}
		}	/* while */
	}	/* else  not fdc_busy */
ignore:	/* end_of_interrupt */
	;
#undef docb
}


/**********   End of the Intel PL/M Driver Code  *************/

//
//; 360K 5.25" DD floppy
//DTAB1:  db      0DFh, 2, 25h,  2, 9, 2Ah, 0FFh, 50h, 0F6h, 0Fh, 8, 39, 80h
T_param const DD360 = {
	0xDF, 2, 0x25, 2, 9, 0x2A, 0xFF, 0x50, 0xF6, 0x0F, 8, 39, 0x80 };
//
//; 1.2M 5.25" HD floppy
//DTAB2:  db      0DFh, 2, 25h,  2, 15, 1Bh, 0FFh, 54h, 0F6h, 0Fh, 8, 79, 00h
T_param const HD1200 = {
	0xDF, 2, 0x25, 2, 15, 0x1B, 0xFF, 0x54, 0xF6, 0x0F, 8, 79, 0x00  };
//
//; 720K 3.5" floppy
//DTAB3:  db      0DFh, 2, 25h,  2, 9, 2Ah, 0FFh, 50h, 0F6h, 0Fh, 8, 79, 80h
T_param const DD720 = {
	0xDF, 2, 0x25, 2, 9, 0x2A, 0xFF, 0x50, 0xF6, 0x0F, 8, 79, 0x80  };
//
//; 1.44M 3.5" floppy
//DTAB4:  db      0AFh, 2, 25h,  2, 18, 1Bh, 0FFh, 6Ch, 0F6h, 0Fh, 8, 79, 00h
T_param const HD144 = {
	0xAF, 2, 0x25, 2, 18, 0x1B, 0xFF, 0x6C, 0xF6, 0x0F, 8, 79, 0x00  };
//
//; 2.88M 3.5" floppy
//DTAB6:  db      0AFh, 2, 25h,  2, 36, 1Bh, 0FFh, 50h, 0F6h, 0Fh, 8, 79, 0C0h
//
//; 1.28M 3.5" 1K sector floppy
//DTAB7:  db      0AFh, 2, 25h, 3, 8, 35h, 0FFh, 74h, 0F6h, 0Fh, 8, 79, 00h
T_param const HD128 = {
	0xAF, 2, 0x25, 3, 8, 0x35, 0xFF, 0x74, 0xF6, 0x0F, 8, 79, 0x00 };
//


T_param *cache_param;

int fdc_specify(T_floppy *floppy)
{
	byte status;
	T_docb *docb = floppy->docb;
	byte *cmd = docb->disk_command;
	const T_param *param = floppy->param;

#if M68000
	fdc_base_port = floppy->disk.port;
#endif
	if (cache_param == param) return stat_ok;

	wd_set_ldcr((param->osc) >> 6);		/* set the WD control register */
	*cmd++ = fdc_cmd_specify;
	*cmd++ = param->srt_hut;
	*cmd   = param->hlt_nd;
	execute_docb(docb, &status);

	return status;
}

int fdc_recalibrate(T_floppy *floppy)
{
	byte status_r, status_d, st3;
	byte tries = 2;

	do {
		floppy->last_seek = 250;

		fdc_specify(floppy);
		wd_select(floppy);
		floppy->docb->disk_command[0] = fdc_cmd_recalibrate;
		floppy->docb->disk_command[1] = (floppy->disk.slave & 1);
		execute_docb(floppy->docb, &status_r);

		floppy->docb->disk_command[0] = fdc_cmd_sense_drive_status;
		floppy->docb->disk_command[1] = (floppy->disk.slave & 1);
		execute_docb(floppy->docb, &status_d);
		st3 = floppy->docb->disk_result[0];
		st3 &= (st3_rdy | st3_tr0);
		st3 ^= (st3_rdy | st3_tr0) ;

		if ( (status_r | status_d | st3) == 0) {
			floppy->last_seek = 0;
			return stat_ok;
		}
	} while (--tries);

	return stat_error;
}


int fdc_seek(T_floppy *floppy, byte new_cylinder, byte new_head)
{
	byte *cmd;
	byte status, try=0;

	fdc_specify(floppy);
	wd_select(floppy);
	while (new_cylinder != floppy->last_seek) {
		cmd = floppy->docb->disk_command;
		*cmd++ = fdc_cmd_seek;
		*cmd++ = ((new_head & 1)<<2) | (floppy->disk.slave & 1);
		*cmd-- = new_cylinder;
		execute_docb(floppy->docb, &status);

		if (status != stat_ok) {
			fdc_recalibrate(floppy);
			if (++try > 4) return stat_error;
		}
		else {
#if VERIFY_SEEK
			*--cmd = fdc_cmd_read_id;
			execute_docb(floppy->docb, &status);
			if (status == stat_ok) {
				floppy->last_seek = floppy->docb->disk_result[3];
			}
#else
			floppy->last_seek = new_cylinder;
#endif
		}
		if (status != stat_ok || floppy->last_seek != new_cylinder)
			fdc_recalibrate(floppy);
		if (++try > 4) return stat_error;
	}
	return stat_ok;
}


/* effect the BIOS call for floppy disk info */

int fdc_info(dword lba, dword geom, byte disk_no)
{
	if (disk_table[disk_no]) {
		lba = disk_table[disk_no]->lba_cyls;
		geom = *(dword*)&disk_table[disk_no]->geom;
		return 0;
	}
	else 
		lba = geom = 0;
	return -1;
}




