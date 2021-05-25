assume cs:code, ds:data
data segment
menu                    db 13,10
                        db 'Score Management System',13,10;主菜单,13,10 -> CRLF
                        db '1 -> Input',13,10;获取输入,并自动计算总成绩
                        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)
                        db '3 -> Inquire',13,10;查询
                        db '4 -> Ascending Sort',13,10;将总成绩升序排列并打印
                        db '5 -> Descending Sort',13,10;将总成绩降序排列并打印
                        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
                        db '7 -> Quit',13,10;退出
                        db 'Please input your choice without enter: ','$'
CRLF                    db 13,10,'$'
input_hint              db 'Please input students profile: ',13,10,'$'
error                   db 13,10,'Your choice error,please input again',13,10,'$'
file                    db 'students.txt',0
file_handle             db ?,?;保存文件句柄,共两个字节
buffer                  db 128;输入缓冲
                        db ?
                        db 128 dup(?)
buffer_length           db ?,?;保存缓冲区实际长度,共两个字节
normal_score            db ?,?;保存平时成绩
bigwork_score           db ?,?;保存大作业成绩
normal_score_integer    db ?,?;保存40%平时成绩的整数部分
normal_score_decimal    db ?,?;保存40%平时成绩的小数部分
bigwork_score_integer   db ?,?;保存60%大作业成绩的整数部分
bigwork_score_decimal   db ?,?;保存60%大作业成绩的小数部分
final_score_integer     db ?,?;保存总成绩的整数部分
final_score_decimal     db ?,?;保存总成绩的小数部分
data ends
stack segment
    db 128 dup(0)
stack ends
code segment
;http://spike.scu.edu.au/~barry/interrupts.html
;http://bbc.nvg.org/doc/Master%20512%20Technical%20Guide/m512techb_int21.htm
main:
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,128
    xor ax,ax
    xor si,si

    call file_init
main_loop:
    call main_menu
    call input_choice
    cmp al,'1'
    je Input
    cmp al,'7'
    je finish
    call input_choice_error
    jmp main_loop
Input:
    call get_str_input
    call convert_str_to_int
    call calculate_normal_score
    call calculate_bigwork_score
    call calculate_final_score
    call get_buffer_length
    call write_file_func
    jmp main_loop
finish:
    call close_file_func
    mov ax,4c00h
    int 21h

;------

main_menu:;打印主菜单
    xor ax,ax
    mov ah,9;Function 09- Output character string
    mov dx,offset menu
    int 21h
    ret

input_choice_error:;选项输入错误
    xor ax,ax
    mov ah,9
    lea dx,error
    int 21h
    ret

input_choice:;获取选项
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h

    mov ah,9
    mov dx,offset CRLF
    int 21h
    ret

get_str_input:;获取成绩输入
    xor ax,ax
    mov ah,9
    lea dx,input_hint
    int 21h

    xor ax,ax
    mov ah,10;Function 0Ah - Buffered input
    mov dx,offset buffer;每一次输入的成绩都会将buffer中的内容重新覆盖
    int 21h
    ret





;数据处理
convert_str_to_int:;将输入的成绩转换为数值
    push ax
    push bx
    push cx
    push dx

    xor ax,ax
    mov cx,16
    xor dx,dx
    mov si,offset buffer+13
convert_str_to_int_loop1:
    mov bl,byte ptr ds:[si]
    cmp bl,' '
    je convert_str_to_int_loop1_finish
    inc si
    jmp convert_str_to_int_loop1
convert_str_to_int_loop1_finish:
    inc si;此时si指向了第一个成绩
convert_str_to_int_loop2:
    mov ah,10
    mov bl,byte ptr ds:[si]
    cmp bl,' '
    je add_normal_score
    cmp bl,13
    je convert_str_to_int_loop2_finish
    and bl,0b00001111;'0'->0
    mul ah;ax=al*10
    add al,bl
    inc si
    jmp convert_str_to_int_loop2
add_normal_score:
    add dx,ax
    inc si
    xor ax,ax
    dec cx
    jcxz add_normal_score_finish
    jmp convert_str_to_int_loop2
add_normal_score_finish:
    push si
    lea si,normal_score
    mov [si],dx;保存平时成绩
    pop si
    jmp convert_str_to_int_loop2
convert_str_to_int_loop2_finish:
    xor ah,ah
    lea si,bigwork_score
    mov [si],ax;保存大作业成绩
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret


calculate_normal_score:;40%的平时成绩
    push ax
    push bx
    push dx

    xor dx,dx
    mov bx,4
    lea si,normal_score
    mov ax,[si]
    mul bx;ax=ax*4
    mov bx,10
    div bx;ax=ax/10(商)   dx=ax%10(余数)
    lea si,normal_score_integer
    mov [si],ax;保存整数部分
    lea si,normal_score_decimal
    mov [si],dx;保存小数部分,除10的余数直接就是小数

    pop dx
    pop bx
    pop ax
    ret


calculate_bigwork_score:;60%的大作业成绩
    push ax
    push bx
    push dx

    xor dx,dx
    mov bx,6
    lea si,bigwork_score
    mov ax,[si]
    mul bx;ax=ax*4
    mov bx,10
    div bx;ax=ax/10(商)   dx=ax%10(余数)
    lea si,bigwork_score_integer
    mov [si],ax;保存整数部分
    lea si,bigwork_score_decimal
    mov [si],dx;保存小数部分,除10的余数直接就是小数

    pop dx
    pop bx
    pop ax
    ret


calculate_bigwork_score:
    push ax
    push bx
    push cx
    push dx

    mov cx,10
    xor dx,dx
    lea si,normal_score_decimal
    mov ax,[si]
    lea si,bigwork_score_decimal
    mov bx,[si]
    add ax,bx
    div cx;ax=ax/10(商)   dx=ax%10(余数)
    lea si,final_score_decimal
    mov [si],dx
    lea si,normal_score_integer
    mov bx,[si]
    add ax,bx;小数进位
    lea si,bigwork_score_integer
    mov bx,[si]
    add ax,bx
    lea si,final_score_integer
    mov [si],ax

    pop dx
    pop cx
    pop bx
    pop ax
    ret


;文件操作
file_init:;文件初始化
    call open_file_func
    cmp al,2;
    je create_file
    jmp create_file_finish
create_file:
    call create_file_func
create_file_finish:
    call set_file_position_func
    ret

create_file_func:;创建文件
    mov ah,3ch;create file
    mov cx,00
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret

open_file_func:;打开文件
    mov ah,3dh
    mov al,2
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret

write_file_func:;写入文件
    lea si,buffer_length
    mov cx,[si]
    lea si,file_handle
    mov bx,[si]
    mov ah,40h
    mov dx,offset buffer+2
    int 21h
    ret

close_file_func:;关闭文件
    lea si,file_handle
    mov bx,[si]
    mov ah,3eh
    int 21h
    ret

set_file_position_func:;将文件指针移动到末尾,即追加模式
    lea si,file_handle
    mov bx,[si]
    mov ah,42h
    mov al,2;origin of move 00h start of file 01h current file position 02h end of file
    xor cx,cx
    xor dx,dx
    int 21h
    ret

get_buffer_length:;读取缓冲区字符的实际长度
    push cx
    push bx
    xor cx,cx
    xor bx,bx
    mov si,offset buffer+2
get_buffer_length_loop:
    mov bl,byte ptr ds:[si];获取输入的每一个字符
    cmp bl,13;CR 回车符
    je return_buffer_length
    inc cx;cx保存buffer的长度
    inc si
    jmp get_buffer_length_loop
return_buffer_length:
    add cx,2
    mov byte ptr ds:[si+1],10;[si+1]=LF
    lea si,buffer_length
    mov [si],cx
    pop bx
    pop cx
    ret

code ends
end main