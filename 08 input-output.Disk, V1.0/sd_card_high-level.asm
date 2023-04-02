namespace sd_card

section temp; goto .temp.

  command: bytes $00 $00 $00 $00 $00 $00
  error_flag: bytes $00

section rom

  error_message:
    call lcd.print
    call lcd.newline
    ld a $FF; ld [error_flag] a
  ret

  idle:
    push bc
      ld b $0C; .0
        call read_byte
      djnz .0
    pop bc
  ret

  send_command:
    push bc
      call idle
      ld b $06; .0
        ld a [hl]; inc hl; call write_byte
      djnz .0
    pop bc
  ret

  receive_response:
    push bc
      ld b $00; .0
        call read_byte
        cp $FF; jr nz .1
      djnz .0
      ld hl messages.resp; call error_message
      .1
    pop bc
  ret

  receive_busy:
    push bc
      ld b $00; .0
        call read_byte
        cp $FF; jr z .1
      djnz .0
      ld hl messages.busy; call error_message
      .1
    pop bc
  ret

  initalize:

    xor a; ld [error_flag] a

    # Test for card presence...

    call status
    or a; jr z .present
      ld hl messages.null; call error_message
      ld a $FF; ret
    .present

    # Reset card...

    call reset

    # Send special data packet to disable CRC checking...

    ld hl commands.disable_crc
    call send_command; call idle

    # If we don't receive one bits, something is wrong...

    call read_byte
    cp $FF; jp z .0
      ld hl messages.fuck; call error_message
      ld a $FF; ret
    .0

    # Wait for the card to initalize...or something.

    ld b $00; .1
      ld hl commands.get_status
      call send_command
      call receive_response
      or a; ret z
      push bc
        ld bc $1000; .delay1
        dec c; jr nz .delay1
        dec b; jr nz .delay1
      pop bc
    djnz .1

    # If that failed, let's try it all again...

    ld hl commands.disable_crc
    call send_command; call idle

    ld b $00; .2
      ld hl commands.get_status
      call send_command
      call receive_response
      or a; ret z
      push bc
        ld bc $1000; .delay2
        dec c; jr nz .delay2
        dec b; jr nz .delay2
      pop bc
    djnz .2

    # ...and if that failed, well, fuck...

    ld hl messages.fail; call error_message
    ld a $FF
  ret

  read:
    xor a; ld [error_flag] a
    push st
      push hl
        ld st command
        ld [st+0] $51
        ld [st+1] b
        ld [st+2] c
        ld [st+3] d
        ld [st+4] e
        ld [st+5] $00
        ld hl command
        call send_command
        call receive_response
      pop hl
      or a; jr z .5
        call interpret_command_response
        jr .6
      .5
      push bc
        ld b $00; .0
          call read_byte
          cp $FE; jr z .1
          cp $FF; jr z .2
            call interpret_data_response
          jr .4; .2
        djnz .0
        ld hl messages.data; call error_message
        jr .4; .1
        push hl
          ld bc $0200; .3
            call read_byte
            ld [hl] a; inc hl
          dec c; jr nz .3
          dec b; jr nz .3
        pop hl
        .4
      pop bc
      .6
    pop st
    ld a [error_flag]
  ret

  write:
    ld hl .fuckme
    call lcd.print
    call lcd.newline
    ld a $FF
  ret
  .fuckme; data "sd_card: I don't know how to write!" !00

  interpret_data_response:
    push hl
      or a; jr nz .z
        ld hl data_responses.z; call print_data_response
      .z
      #bit0 a; jr z .0
      #  ld hl data_responses.0; call print_data_response
      #.0
      bit1 a; jr z .1
        ld hl data_responses.1; call print_data_response
      .1
      bit2 a; jr z .2
        ld hl data_responses.2; call print_data_response
      .2
      bit3 a; jr z .3
        ld hl data_responses.3; call print_data_response
      .3
      bit4 a; jr z .4
        ld hl data_responses.4; call print_data_response
      .4
      bit5 a; jr z .5
        ld hl data_responses; call print_data_response
      .5
      bit6 a; jr z .6
        ld hl data_responses; call print_data_response
      .6
      bit7 a; jr z .7
        ld hl data_responses; call print_data_response
      .7
    pop hl
    ld a [error_flag]
  ret

  print_data_response:
    push af
      push hl
        ld hl data_responses.start; call lcd.print
      pop hl
      call lcd.print; call lcd.newline
      ld a $FF; ld [error_flag] a
    pop af
  ret

  data_responses:
        data "Weird Error" !00
    .z; data "Zero Start Byte" !00
    #.0; data "Some Sort of Error" !00
    .1; data '"CC Error"' !00
    .2; data "ECC Failed" !00
    .3; data "Out of Range" !00
    .4; data "Card is Locked" !00
    .start; data "sd_card: data resp.: " !00

  interpret_command_response:
    push hl
      bit0 a; jr z .0
        ld hl command_responses.0; call print_command_response
      .0
      bit1 a; jr z .1
        ld hl command_responses; call print_command_response
      .1
      bit2 a; jr z .2
        ld hl command_responses.2; call print_command_response
      .2
      bit3 a; jr z .3
        ld hl command_responses.3; call print_command_response
      .3
      bit4 a; jr z .4
        ld hl command_responses; call print_command_response
      .4
      bit5 a; jr z .5
        ld hl command_responses.5; call print_command_response
      .5
      bit6 a; jr z .6
        ld hl command_responses.6; call print_command_response
      .6
      bit7 a; jr z .7
        ld hl command_responses.7; call print_command_response
      .7
    pop hl
    ld a [error_flag]
  ret

  print_command_response:
    push af
      push hl
        ld hl command_responses.start; call lcd.print
      pop hl
      call lcd.print; call lcd.newline
      ld a $FF; ld [error_flag] a
    pop af
  ret

  command_responses:
        data "Weird Error" !00
    .0; data "In Idle State" !00
    #.1; data "Erase Reset" !00
    .2; data "Illegal Command" !00
    .3; data "Command CRC Error" !00
    #.4; data "Erase_Seq_Error" !00
    .5; data "Address Error" !00
    .6; data "Parameter Error" !00
    .7; data "Not a response code!" !00
    .start; data "sd_card: com. resp.: " !00

  commands:

    .disable_crc; data !400000000095
    .get_status; data !410000000000

  messages:
    .null; data "sd_card: SD card is not inserted." !00
    .fuck; data "sd_card: SD card is invisible." !00
    .cunt; data "sd_card: Failed to disable CRC." !00
    .fail; data "sd_card: Initalization failed." !00
    .resp; data "sd_card: No response to command." !00
    .busy; data "sd_card: SD card is too busy." !00
    .read; data "sd_card: Error response to read command." !00
    .data; data "sd_card: No data following read command." !00
    .writ; data "sd_card: Error response to write command." !00
    .burn; data "sd_card: Data block rejected by card." !00
    .code; data "Error code: __" !00
