#include <unistd.h>
.text
.globl kernel_execve
kernel_execve:
    move    $s4, $ra
    move    $s5, $fp
    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    # strlen
    addiu   $sp, $sp, -0x10
    move    $fp, $sp
    jal     strlen
    # syscall
    move    $a0, $s0
    move    $a1, $v0
    move    $a2, $s1
    move    $a3, $s2
    li      $v0, SYS_exec
    syscall
    addiu   $sp, $sp, 0x10
    # ret
    move    $ra, $s4
    move    $fp, $s5
    jr      $ra
