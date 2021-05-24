assume cs:code
code segment
main:
    xor ax,ax
    mov al,2
    out 70h,al;将2送入70h端口
    in al,71h;读取CMOS的2号单元
    
    mov ax,4c00h
    int 21h
code ends
end main