assume cs:code,ds:data
data segment
menu_head               db '*******Setting your name and password*******',13,10,'$'
input_name              db 'Please input your name (0-20 characters): ','$'
input_passwd            db 'Please input your passwotd (0-20 characters): ','$'
reinput_name            db 'Please input your name again: ','$'
reinput_passwd          db 'Please input your password again: ','$'
correct_hint            db 'Account setting is successful!',13,10,'$'
uncorrect_hint          db 'The input is not correct.',13,10,'$'
CRLF                    db 13,10,'$'
input_name_buffer       db 32
                        db ?
                        db 32 dup(?)
input_passwd_buffer     db 32
                        db ?
                        db 32 dup(?)
reinput_name_buffer     db 32
                        db ?
                        db 32 dup(?)
reinput_passwd_buffer   db 32
                        db ?
                        db 32 dup(?)
data ends
code segment
main:
    mov ax,data
    mov ds,ax
    xor dx,dx

    lea dx,menu_head
    push dx
    call print

    lea dx,input_name
    push dx
    call print
    lea dx,input_name_buffer
    push dx
    call get_input

    lea dx,CRLF
    push dx
    call print

    lea dx,input_passwd
    push dx
    call print
    lea dx,input_passwd_buffer
    push dx
    call get_input

    lea dx,CRLF
    push dx
    call print

check_name:
    lea dx,reinput_name
    push dx
    call print
    lea dx,reinput_name_buffer
    push dx
    call get_input

    lea dx,CRLF
    push dx
    call print

    lea dx,input_name_buffer+2
    push dx
    lea dx,reinput_name_buffer+2
    push dx
    call compare
    jcxz check_name_err
    jmp check_passwd


check_name_err:
    lea dx,uncorrect_hint
    push dx
    call print
    jmp check_name



check_passwd:
    lea dx,reinput_passwd
    push dx
    call print
    lea dx,reinput_passwd_buffer
    push dx
    call get_input

    lea dx,CRLF
    push dx
    call print

    lea dx,input_passwd_buffer+2
    push dx
    lea dx,reinput_passwd_buffer+2
    push dx
    call compare
    jcxz check_passwd_err
    jmp finish


check_passwd_err:
    lea dx,uncorrect_hint
    push dx
    call print
    jmp check_passwd

finish:
    lea dx,correct_hint
    push dx
    call print
    mov ax,4c00h
    int 21h

print:
    push bp
    mov bp,sp
    xor ax,ax
    mov ah,9
    mov dx,ss:[bp+4]
    int 21h
    mov sp,bp
    pop bp
    ret 2


get_input:
    push bp
    mov bp,sp
    xor ax,ax
    mov ah,10
    mov dx,ss:[bp+4]
    int 21h
    mov sp,bp
    pop bp
    ret 2

compare:
    push bp
    mov bp,sp
    mov si,ss:[bp+4]
    mov di,ss:[bp+6]
    mov cx,1

compare_loop:
    mov ah,byte ptr ds:[si]
    mov al,byte ptr ds:[di]
    cmp ah,al
    je compare_enter
    jne compare_err
compare_enter:
    inc si
    inc di
    cmp ah,13
    je compare_finish
    jne compare_loop

compare_err:
    mov cx,0
compare_finish:
    mov sp,bp
    pop bp
    ret 4


code ends
end main