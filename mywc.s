/* mywc.s */

        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    EOF, 255
        
        
        .section .rodata
        

countString:
        .string "%7ld %7ld %7ld\n"
checkStr:
        .string "iChar Val: %d\n"

        .section .bss
iChar:
        .skip 4


        .section .data
        
lLineCount:
        .quad 0
lWordCount:
        .quad 0
lCharCount:
        .quad 0
iInWord:
        .word FALSE


        .section .text

        .equ MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

getCharLoop:

        //iChar = getchar()
        bl      getchar
        adr     x1, iChar
        strb    w0, [x1]
        
        // if(iChar == EOF) goto getCharLoopEnd
        adr     x0, iChar
        ldr     x0, [x0]
        mov     x1, EOF
        cmp     x0, x1
        beq     getCharLoopEnd
 
        //CHECKPOINT 2
        adr     x0, checkStr
        adr     x1, iChar
        ldr     x1, [x1]
        bl      printf
        
        //lCharCount++
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        
        //if (isspace(iChar))
        adr     x0, iChar
        ldr     x0, [x0]
        bl      isspace
        cmp     x0, FALSE
        beq     else
        
        //if (iInWord)
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endIf1

        //lWordCount++
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
        //iInWord = FALSE
        mov     x0, FALSE
        adr     x1, iInWord
        str     x0, [x1]

else:
        //if (! iInWord)
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        bne     endIf1
        
        //iInWord = TRUE
        mov     x0, TRUE
        adr     x1, iInWord
        str     x0, [x1]

endIf1:
        //CHECKPOINT 2                                                                                 
        adr     x0, checkStr1
        adr     x1, iChar
        ldr     x1, [x1]
        bl      printf
        
        //if (iChar == '\n')
        adr     x1, iChar
        ldr     x1, [x1]
        cmp     x0, '\n'
        bne     getCharLoop

        //lLineCount++
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        b       getCharLoop

getCharLoopEnd:
        //if (iInWord)
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endIf2

        //lWordCount++
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endIf2: 
        //printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount)
        adr     x0, countString
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf
       
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
        

        

        

        
        
        
        
        
        
        
        

        
     
        
        
