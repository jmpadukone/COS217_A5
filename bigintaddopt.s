/* bigintaddopt.s */

        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    MAX_DIGITS, 32768

        .section .rodata

        .section .data

        .section .bss

        .section .text

        .equ    LARGER_STACK_BYTECOUNT, 32

        // Local variable registers
        LLARGER .req x19

        //Parameter registers
        LLENGTH1 .req x20
        LLENGTH2 .req x21

        
BigInt_larger:
        //Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]

        //Store parameters in registers
        mov     LLENGTH1, x0
        mov     LLENGTH2, x1
        
        //long .lLarger

        //if (lLength1 <= lLength2) goto else
        cmp     LLENGTH1, LLENGTH2
        ble     else

        //lLarger = lLength1
        mov     LLARGER, LLENGTH1
        b       endIf

else:
        //lLarger = lLength2
        mov     LLARGER, LLENGTH2
        
endIf:
        //Epilog and return lLarger
        mov     x0, LLARGER
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)



        .equ    ADD_STACK_BYTECOUNT, 64

        // Local variables stack offsets
        ULCARRY .req x19 
        ULSUM   .req x20
        LINDEX  .req x21
        LSUMLENGTH .req x22

        // Parameter stack offsets
        OADDEND1 .req x23
        OADDEND2 .req x24
        OSUM    .req x25

        //Structure field offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        .global BigInt_add
BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]
        str     x22, [sp, 32]
        str     x23, [sp, 40]
        str     x24, [sp, 48]
        str     x25, [sp, 56]
        
        /*lSumLength = BigInt_larger(oAddend1->lLength,
        oAddend2->lLength) */
        mov     x0, OADDEND1
        add     x0, x0, LLENGTH
        mov     x1, OADDEND2
	add     x1, x1, LLENGTH
        bl      BigInt_larger
        mov     LSUMLENGTH, x0

        // if (oSum->lLength <= lSumLength) goto endIf1
        mov     x0, OSUM
	add     x0, x0, LLENGTH
        cmp     x0, LSUMLENGTH
        ble     endIf1

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long))
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     w1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

endIf1:
        //ulCarry = 0
        mov     ULCARRY, 0

        //lIndex = 0
        mov     LINDEX, 0
        
        
addLoop:        
        // if (lIndex >= lSumLength) goto addLoopEnd
        cmp     LINDEX, LSUMLENGTH
        bge     addLoopEnd

        //ulSum = ulCarry
        mov     ULSUM, ULCARRY


        //ulCarry = 0
        mov     ULCARRY, 0



        //ulSum += oAddend1->aulDigits[lIndex]
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endIf2
        mov     x0, OADDEND1
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3] 
        cmp     ULSUM, x0
        bhs     endIf2

        // ulCarry = 1
        mov     ULCARRY, 1
       
        
endIf2:

        //ulSum += oAddend2->aulDigits[lIndex]
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        add     ULSUM, ULSUM, x0

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endIf3
        mov     x0, OADDEND2
        add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        cmp     ULSUM, x0
        bhs     endIf3
        
        // ulCarry = 1 
        mov     ULCARRY, 1
        
endIf3:
        // oSum->aulDigits[lIndex] = ulSum;
        mov     x0, OSUM
	add     x0, x0, AULDIGITS
        mov     x1, LINDEX
        ldr     x0, [x0, x1, lsl 3]
        mov     x0, ULSUM

        //lIndex++
        mov     x0, LINDEX
        add     x0, x0, 1
        mov     LINDEX, x0

        //goto addLoop
        b       addLoop

addLoopEnd:
        //if (ulCarry != 1) goto endIf4
        cmp     ULCARRY, 1
        bne     endIf4

        //if (lSumLength != MAX_DIGITS) goto endIf5
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     endIf5

        //Epilog and return FALSE
        mov     w0, FALSE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endIf5:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     x1, LSUMLENGTH
        ldr     x0, [x0, x1, lsl 3]
        mov     x0, 1
        
        //lSumLength++
        mov     x0, LSUMLENGTH
        add     x0, x0, 1
        mov     LSUMLENGTH, x0

endIf4:
        // oSum->lLength = lSumLength;
        mov     x0, OSUM
        add     x0, x0, LLENGTH
        mov     x0, LSUMLENGTH

        //Epilog and return TRUE
        mov     w0, TRUE
        ldr     x30, [sp]
	ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)













        
