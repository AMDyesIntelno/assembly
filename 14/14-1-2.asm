assume cs:code
code segment
main:
    xor ax,ax
    mov al,2
    out 70h,al
    mov al,0
    out 71h,al

    mov ax,4c00h
    int 21h
code ends
end main