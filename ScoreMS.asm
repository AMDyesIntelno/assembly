assume cs:code, ds:data
data segment
menu1   db 'Score Management System',13,10;主菜单,13,10 -> CRLF
        db '1 -> Input',13,10;获取输入,并自动计算总成绩
        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)
        db '3 -> Inquire',13,10;查询
        db '4 -> Ascending Sort',13,10;将总成绩升序排列并打印
        db '5 -> Descending Sort',13,10;将总成绩降序排列并打印
        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
        db '7 -> Quit',13,10;退出
        db 'Please input your choice: ',13,10,'$'
data ends
code segment
main:
    mov ax,data
    mov ds,ax
    call main_menu
    mov ax,4c00h
    int 21h




main_menu:;打印主菜单
    mov ah,9
    mov dx,offset menu1
    int 21h
    ret
code ends
end main