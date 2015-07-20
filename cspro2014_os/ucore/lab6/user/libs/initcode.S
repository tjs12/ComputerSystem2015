.text
.globl _start
_start:
    # move down the esp register
    # since it may cause page fault in backtrace
    # addiu   $sp, $sp, -0x20

    # call user-program function
    jal     umain
1:  j       1b

