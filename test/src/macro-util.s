# Credits to baldr for this mighty macro: http://www.asmcommunity.net/forums/topic/?id=29732
.macro stdcall function:req,args:vararg
    argc=0
    .ifnb \args
        .irp arg,\args; argc=argc+1; .endr
        argrc=argc
        .rept argc
            argrc=argrc-1
            argc=0
            .irp arg,\args
                .if argrc==argc; push \arg; .endif
                argc=argc+1
            .endr
        .endr
    .endif
    call    \function
.endm
