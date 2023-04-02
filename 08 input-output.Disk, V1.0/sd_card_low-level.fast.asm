namespace sd_card

section rom

  reset
    push bc
      out $C3
      call idle
      out $C2
      ld bc $0400; .1
      call read_byte
      dec c; jr nz .1
      dec b; jr nz .1
      out $C3
      call idle
      out $C2
      call idle
    pop bc
  ret

  write_byte
    out $C0
  read_byte
    out $C1
    nop
    in $C0
  ret
