assume cs:codesg
datasg segment
    db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends
codesg segment
main:
    mov ax,datasg
    mov ds,ax
    mov si,0
    call letterc

    mov ax,4c00h
    int 21h

letterc:
    mov ch,0
    mov cl,byte ptr ds:[si]
    jcxz letterc_return
    cmp cx,61h;'a'
    jb letterc_loop
    cmp cx,7ah;'z'
    ja letterc_loop
    and byte ptr ds:[si],11011111b
letterc_loop:
    inc si
    jmp letterc
letterc_return:
    ret

codesg ends
end main
