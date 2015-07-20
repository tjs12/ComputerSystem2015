		0xffffffff
				0xfffffff0 BIOS
0x00040000 R	 ...
		0xfffc0000




		0x07ffffff
0x00003000 R	 ...
		0x07ffd000			<- maxpa, npage = 0x7ffd
		0x07ffcfff
				 ...		pmm_managed
				0x001b9000
				 ALIGN
				0x001b8fc4	<- freemem
				0x001b8fc3
				 ...		struct Page pages
				0x00119000	<- pages
				 ALIGN
				0x00118968	<- end
				0x00118967
				 ...		kernel (.data .bss, __gdt)
				0x00117000	<- esp used in kern_init
				 ...		bootstack (kernel .data)
				0x00115000	
				 ALIGN
				0x00114bfe
				 ...		kernel (.text)
				0x00100000
0x07efd000	 ...
		0x00100000
		0x000fffff
0x00010000 R	 ...
		0x000f0000




		0x0009ffff
0x00000c00 R	 ...
		0x0009f400
		0x0009f3ff

				0x0000807b
				 ...		e820map
				0x00008000

				0x00007db1
				 ...		bootloader (.text .data, gdt)
				0x00007c00	<- esp used in bootmain
0x0009f400	 ...
		0x00000000
