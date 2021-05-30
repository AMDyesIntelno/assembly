assume cs:code, ds:data
data segment
menu                    db 13,10
                        db 'Score Management System',13,10;主菜单,13,10 -> CRLF
                        db '1 -> Input',13,10;获取输入,并自动计算总成绩
                        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)
                        db '3 -> Inquire',13,10;查询
                        db '4 -> Ascending Sort & Print',13,10;将总成绩升序排列并打印
                        db '5 -> Descending Sort & Print',13,10;将总成绩降序排列并打印
                        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
                        db '7 -> Quit',13,10;退出
                        db 'Please input your choice without enter: ','$'
CRLF                    db 13,10,'$'
Score_Sample            db '    id    |    name    |  16x normal score  |  bigwork score  |  final score',13,10,'$'
input_hint              db 'Please input students profile: ',13,10,'$'
error                   db 13,10,'Your choice error,please input again',13,10,'$'
file                    db 'students.txt',0
file_handle             db ?,?;保存文件句柄,共两个字节
buffer                  db 128;输入缓冲
                        db ?
                        db 128 dup(?),'$'
buffer_length           db ?,?;保存缓冲区实际长度,共两个字节
normal_score            db ?,?;保存平时成绩(未平均)
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
    cmp al,'2'
    je Print_All_Score
    cmp al,'7'
    je finish
    call input_choice_error
    jmp main_loop

Input:
    call get_score_input
    call get_final_score
    call save_score_in_file
    jmp main_loop

Print_All_Score:
    xor ax,ax

    mov ah,9
    lea dx,Score_Sample
    int 21h

    call open_file
reading:
    call read_file
    cmp ax,0;EOF
    je read_finish

    mov ah,9
    lea dx,buffer+2
    int 21h

    jmp reading
read_finish:
    call close_file
    jmp main_loop

finish:
    call close_file
    mov ax,4c00h
    int 21h

;------

file_init:;文件初始化
    call open_file
    cmp al,2;返回al=2,说明文件不存在
    je nofile
    jmp closefile
nofile:
    call create_file
closefile:
    call close_file
    ret


main_menu:;打印主菜单
    xor ax,ax
    mov ah,9;Function 09- Output character string
    lea dx,menu
    int 21h
    ret

input_choice:;获取选项
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h

    mov ah,9
    lea dx,CRLF
    int 21h
    ret

input_choice_error:;选项输入错误
    xor ax,ax
    mov ah,9
    lea dx,error
    int 21h
    ret

get_score_input:;获取成绩输入
    xor ax,ax
    mov ah,9
    lea dx,input_hint
    int 21h

    xor ax,ax
    mov ah,10;Function 0Ah - Buffered input
    lea dx,buffer;每一次输入的成绩都会将buffer中的内容重新覆盖
    int 21h
    ret


get_final_score:
    call convert_input_score_to_int;将输入的成绩进行转换
    call calculate_normal_score;计算40%的平时成绩
    call calculate_bigwork_score;计算60%的大作业成绩
    call calculate_final_score;计算总成绩
    ret

save_score_in_file:
    call get_buffer_length_to_cr
    call convert_int_to_char
    call get_buffer_length_to_cr
    lea si,buffer_length
    mov bx,[si]
    mov cx,127
    sub cx,bx
    lea si,buffer+1
    add si,bx
add_space:
    mov byte ptr ds:[si],' '
    inc si
    loop add_space
    mov byte ptr ds:[si],13
    inc si
    mov byte ptr ds:[si],10
    call open_file
    call set_append_mode
    call write_file
    call close_file
    ret


;数据处理
convert_input_score_to_int:;将输入的成绩转换为数值
    push ax
    push bx
    push cx
    push dx

    xor ax,ax
    mov cx,16
    xor dx,dx
    lea si,buffer+13
get_number_posi:
    mov bl,byte ptr ds:[si]
    inc si
    cmp bl,' '
    je convert_number
    jmp get_number_posi
convert_number:
    mov bl,byte ptr ds:[si]
    cmp bl,' '
    je add_all_normal_score
    cmp bl,13
    je save_bigwork_score
    and bl,00001111b;'0'->0
    mov ah,10
    mul ah;ax=al*10
    add al,bl;15=1*10+5
    inc si
    jmp convert_number
add_all_normal_score:
    add dx,ax
    inc si
    xor ax,ax
    dec cx
    jcxz save_normal_score
    jmp convert_number
save_normal_score:
    push si
    lea si,normal_score
    mov [si],dx;保存平时成绩
    pop si
    jmp convert_number
save_bigwork_score:
    lea si,bigwork_score
    mov [si],ax;保存大作业成绩
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret


calculate_normal_score:;40%的平时成绩 x/16*0.4=x/40
    push ax
    push bx
    push dx
;计算整数
    xor dx,dx
    lea si,normal_score
    mov ax,[si]
    mov bx,40
    div bx;ax=ax/40(商)   dx=ax%40(余数)
    lea si,normal_score_integer
    mov [si],ax;保存整数部分
;计算小数
    mov ax,dx
    xor dx,dx
    mov bx,10
    mul bx;ax=dx*10
    mov bx,40
    div bx;ax=ax/40(商)   dx=ax%40(余数)
    lea si,normal_score_decimal
    mov [si],ax;保存小数部分

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
    mul bx;ax=ax*6
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


calculate_final_score:
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


convert_int_to_char:
    lea si,buffer_length
    mov di,[si]
    lea si,buffer+1
    add si,di
    mov byte ptr ds:[si],' ';将回车替换成空格
    inc si
    lea di,final_score_integer;将整数部分转换成字符
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],'.';小数点
    inc si
    lea di,final_score_decimal;将小数部分转换成字符
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],13;CR
    ;inc si
    ;mov byte ptr ds:[si],10;LF
    ret


dtoc:
    push bp
    mov bp,sp
    mov si,ss:[bp+4]
    mov ax,ss:[bp+6]
    mov dx,0
    push dx
    mov bx,10
dtoc_loop:
    div bx;ax:商,dx:余数
    add dx,030h;0->'0'
    push dx;ascii入栈
    mov cx,ax
    jcxz dtoc_re
    mov dx,0
    jmp dtoc_loop
dtoc_re:;用栈将ascii倒序
    pop cx
    jcxz dtoc_ret
    mov byte ptr ds:[si],cl;移动到buffer中
    inc si
    jmp dtoc_re
dtoc_ret:
    mov sp,bp
    pop bp
    ret 4


;文件操作
create_file:;创建文件
    mov ah,3ch;create file
    mov cx,00
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret

open_file:;打开文件
    mov ah,3dh
    mov al,2
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret

read_file:
    lea si,file_handle
    mov bx,[si]
    lea si,buffer+2
    mov dx,si
    mov cx,128
    mov ah,3fh
    int 21h
    ret

write_file:;写入文件
    ;lea si,buffer_length
    ;mov cx,[si]
    mov cx,128
    lea si,file_handle
    mov bx,[si]
    mov ah,40h
    lea dx,buffer+2
    int 21h
    ret

close_file:;关闭文件
    lea si,file_handle
    mov bx,[si]
    mov ah,3eh
    int 21h
    ret

set_append_mode:;将文件指针移动到末尾,即追加模式
    lea si,file_handle
    mov bx,[si]
    mov ah,42h
    mov al,2;origin of move 00h start of file 01h current file position 02h end of file
    xor cx,cx
    xor dx,dx
    int 21h
    ret

get_buffer_length_to_cr:;读取缓冲区字符的长度到CR截止
    push cx
    push bx
    xor cx,cx
    xor bx,bx
    lea si,buffer+2
buffer_length_loop:
    mov bl,byte ptr ds:[si];获取输入的每一个字符
    inc cx;cx保存buffer的长度
    cmp bl,13;CR 回车符
    je save_buffer_length
    inc si
    jmp buffer_length_loop
save_buffer_length:
    lea si,buffer_length
    mov [si],cx
    pop bx
    pop cx
    ret

code ends
end main