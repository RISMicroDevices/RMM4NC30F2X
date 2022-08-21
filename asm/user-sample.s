.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    lui     $s0, 0x8040
    lui     $s1, 0x8050

    lui     $s2, 0x8050
    lui     $s3, 0x8060

    lui     $s4, 0xBFD0
    ori     $s4, $s4, 0x04F0    # CoPS CORDIC Operation Register

    lui     $s5, 0xBFD0
    ori     $s5, $s5, 0x04F4    # CoPS CORDIC Status Register

mainloop:

    # memory read
    lw      $t0, 0($s0)
    addiu   $s0, $s0, 4

    sw      $t0, 0($s4)
TEST_CORDIC:
    lw      $a3, 0($s5)
    beqz    $a3, TEST_CORDIC
    nop

    lw      $t1, 0($s4)

WRITEBACK_MEM:
    sw      $t1, 0($s2)
    addiu   $s2, $s2, 4

    bne     $s2, $s3, mainloop
    nop

end:
    jr    $ra
    ori   $zero, $zero, 0 # nop
