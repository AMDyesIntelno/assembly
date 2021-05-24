assume cs:code
code segment
main:
    mov ax,10
    shl ax,1
    mov dx,ax
    shl dx,1
    shl dx,1
    add ax,dx

    mov ax,4c00h
    int 21h
code ends
end main