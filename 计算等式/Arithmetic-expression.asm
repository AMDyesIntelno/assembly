;输出-5+3=-2
;-7+5=-2
;12-7=5
;16+9=25
;...
assume cs:code
data segment
    db -5,-7,12,16,-3,-10
    db 3,5,-7,9,-5,-12
data ends
stack segment
    db 64 dup(0)
stack ends
code segment
main:
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,64
    mov ax,0b87ch;输出位置
    mov es,ax
    xor di,di
    xor si,si
    mov cx,6
send_data_to_print:
    xor ax,ax
    xor dx,dx

    mov al,byte ptr ds:[di];第一个数字
    add dl,al
    push ax
    call print

    mov al,byte ptr ds:[di+6];第二个数字
    cmp al,07fh
    jna print_add
print_add_finish:
    nop
    mov al,byte ptr ds:[di+6]
    add dl,al
    push ax
    call print
    jmp next_step
print_add:
    mov al,43;+
    push ax
    call print
    jmp print_add_finish
next_step:
    mov al,61;=
    push ax
    call print

    push dx;结果
    call print
    inc di
    mov ax,es
    add ax,0ah
    mov es,ax
    xor si,si
    loop send_data_to_print

    mov ax,4c00h
    int 21h

print:
    push bp
    mov bp,sp

    mov ax,word ptr ss:[bp+4]

    cmp ax,43;+
    je print_sym
    cmp ax,61;=
    je print_sym
    cmp ax,07fh
    ja print_fu
    jmp print_num

print_finish:
    xor ax,ax
    mov sp,bp
    pop bp
    ret 2;堆栈平衡

print_sym:;加号或等于号
    mov ah,00000010b
    mov word ptr es:[si],ax
    add si,2
    jmp print_finish


print_fu:;负号
    push ax
    mov ah,00000010b
    mov al,45;-
    mov word ptr es:[si],ax
    add si,2
    pop ax
    sub al,1
    xor al,11111111b
print_num:;数字
    push cx
    push dx
    xor dx,dx
    xor bx,bx
    push bx;push 0
    mov bx,10
dtoc_loop:
    div bx;ax:商,dx:余数
    add dx,030h
    push dx;ascii入栈
    mov cx,ax
    jcxz dtoc_re
    xor dx,dx
    jmp dtoc_loop
dtoc_re:
    pop cx
    jcxz dtoc_finish
    mov al,cl
    mov ah,00000010b
    mov word ptr es:[si],ax
    add si,2
    jmp dtoc_re
dtoc_finish:
    pop dx
    pop cx
    jmp print_finish

code ends
end main