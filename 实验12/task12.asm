assume cs:code
code segment
main:
    mov ax,cs
    mov ds,ax
    mov si,offset do0;将ds:si指向do0程序

    mov ax,0000h
    mov es,ax
    mov di,0200h;将es:di指向内存0000:0200处

    mov cx,offset do0end-offset do0;将cx设置为do0的代码长度

    cld;DF=0,地址自动增量

    rep movsb

    mov ax,0
    mov es,ax;es指向中断向量表
    mov word ptr es:[0*4],0200h;低地址字存放偏移地址
    mov word ptr es:[0*4+2],0000h;高地址字存放段地址

    mov ax,4c00h
    int 21h

do0:;显示字符串,当do0执行是CS:IP指向0000:0200
    jmp short do0start
    db "divide error!"
do0start:
    mov ax,cs
    mov ds,ax
    mov si,0202h;db "divide error!"的偏移为0202h因为jmp short指令占用了两个字节

    mov ax,0b800h;显存段地址
    mov es,ax
    mov di,12*160+2*34;居中显示

    mov ah,00000010b
    mov cx,13
do0loop:
    mov al,byte ptr ds:[si]
    mov word ptr es:[di],ax
    inc si
    add di,2
    loop do0loop
    
    mov ax,4c00h
    int 21h
do0end:
    nop

code ends
end main
