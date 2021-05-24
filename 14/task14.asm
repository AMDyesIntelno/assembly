assume cs:code
data segment
    db 9,8,7,4,2,0;年月日时分秒
data ends
code segment
main:
    mov ax,data
    mov ds,ax
    mov di,160*12+40*2;di显存输出起始位置
    mov si,0
    mov bx,0b800h
    mov es,bx
    xor ax,ax
    
    call date;年
    mov ax,'/'
    push ax
    call sep

    call date;月
    mov ax,'/'
    push ax
    call sep
    
    call date;日
    mov ax,' '
    push ax
    call sep

    call date;时
    mov ax,':'
    push ax
    call sep

    call date;分
    mov ax,':'
    push ax
    call sep

    call date;秒

    mov ax,4c00h
    int 21h

date:
    mov al,byte ptr ds:[si]
    inc si
    out 70h,al
    in al,71h

    mov ah,al
    mov cl,4
    shr ah,cl;保留前4位
    and al,00001111b;保留后4位

    add al,30h
    add ah,30h;BCD码转ascii码
    
    mov byte ptr es:[di],ah
    add di,2
    mov byte ptr es:[di],al
    add di,2
    ret

sep:
    push bp
    mov bp,sp
    mov ax,ss:[bp+4]
    mov byte ptr es:[di],al
    add di,2
    mov sp,bp
    pop bp
    ret 2

code ends
end main