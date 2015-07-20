.globl kern_boot
kern_boot:
    la      $sp, kern_boot
    jal     kern_init
spin:
    j       spin
