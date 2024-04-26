;the code takes an input as a date such as 4/25/2024
;it then prints "The date 4/25/2024 falls on a Thursday" for this example


section .data
extern printf

msg db 'Enter date: ', 10, 0
msgLen equ $-msg
format db 'The date: %d/%d/%d ', 0

formatSun db 'The date: %d/%d/%d falls on a Sunday', 10, 0
formatMon db 'The date: %d/%d/%d falls on a Monday', 10, 0
formatTue db 'The date: %d/%d/%d falls on a Tuesday', 10, 0
formatWed db 'The date: %d/%d/%d falls on a Wednesday', 10, 0
formatThu db 'The date: %d/%d/%d falls on a Thursday', 10, 0
formatFri db 'The date: %d/%d/%d falls on a Friday', 10, 0
formatSat db 'The date: %d/%d/%d falls on a Saturday', 10, 0


section .bss
date resb 256
month resb 1
day resb 1
year resw 1
key resb 1
remainder resd 1
temp resb 1
temp2 resd 1

section .text
global main

main:

    push ebp
    mov ebp, esp

    mov eax, 4      ;print first string
    mov ebx, 1
    mov ecx, msg
    mov edx, msgLen
    int 80h

    mov eax, 3      ;read first input
    mov ebx, 0
    mov ecx, date
    mov edx, 255
    int 80h

    mov byte[date + eax -1], 0

    xor esi, esi
    xor eax, eax
    xor ebx, ebx
    jmp convertMonth
;---------------------------------------------------------------------------------------------------
clear:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    ret

;input is month/day/year. it converts month to integer and stores it in eax, once a '/' is detected, program then moves eax to variable "month"
;does the same for day and year, storing it in each respective variable

convertMonth:
    cmp byte[date + esi], 47
    je monthVar

    movzx ebx, byte[date + esi]
    sub ebx, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convertMonth

monthVar:
    mov [month], eax
    inc esi
    call clear

convertDay:
    cmp byte[date + esi], 47
    je dayVar

    movzx ebx, byte[date + esi]
    sub ebx, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convertDay

dayVar:
    mov [day], eax
    inc esi
    call clear

convertYear:
    cmp byte[date + esi], 0
    je yearVar

    movzx ebx, byte[date + esi]
    sub ebx, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convertYear

yearVar:
    mov [year], eax
    inc esi
    call clear
;---------------------------------------------------------------------------------------------------
;determines if the year is a leap year or a common year. 
;if leap year, program jumps to leapYear function to determine the key for the month 
;(keys for Jan and Feb are different on leap years)
;definition for "key" is below
yearType:
    mov eax, [year]
    mov ecx, 4
    div ecx
    cmp edx, 0
    jne commonYear
    call clear

    mov eax, [year]
    mov ecx, 100
    div ecx
    cmp edx, 0
    jne leapYear
    call clear

    mov eax, [year]
    mov ecx, 400
    div ecx
    cmp edx, 0
    jne commonYear
    call clear

    jmp leapYear

commonYear:
    call clear
    jmp monthKey

leapYear:                   
    mov al, byte[month]
    mov bl, 1
    cmp al, bl
    je key0
    inc bl
    cmp al, bl
    je key3
    call clear
;---------------------------------------------------------------------------------------------------
;each month has a number called a key for the calculation of which day of the week it is. 
;Common Year: Jan-1, Feb-4, Mar-4, Apr-0, May-2, Jun-5, Jul-0, Aug-3, Sep-6, Oct-1, Nov-4, Dec-6
;Leap year: Jan-0, Feb-3

;monthKey determines which month it is, and jumps to key1-6 to update the key variable
monthKey:
    mov al, byte[month]
    mov bl, 1

    cmp al, bl    ;jan
    je key1
    inc bl
    cmp al, bl    ;feb
    je key4
    inc bl
    cmp al, bl    ;march
    je key4
    inc bl
    cmp al, bl    ;april
    je key0
    inc bl
    cmp al, bl    ;may
    je key2
    inc bl
    cmp al, bl    ;june
    je key5
    inc bl
    cmp al, bl    ;july
    je key0
    inc bl
    cmp al, bl    ;august
    je key3
    inc bl
    cmp al, bl    ;september
    je key6
    inc bl
    cmp al, bl    ;october
    je key1
    inc bl
    cmp al, bl    ;november
    je key4
    inc bl
    cmp al, bl    ;december
    je key6

key0:
    mov eax, 0
    mov [key], eax
    call clear
    jmp dayOfWeek
key1:
    mov eax, 1
    mov [key], eax
    call clear
    jmp dayOfWeek
key2:
    mov eax, 2
    mov [key], eax
    call clear
    jmp dayOfWeek
key3:
    mov eax, 3
    mov [key], eax
    call clear
    jmp dayOfWeek
key4:
    mov eax, 4
    mov [key], eax
    call clear
    jmp dayOfWeek
key5:
    mov eax, 5
    mov [key], eax
    call clear
    jmp dayOfWeek
key6:
    mov eax, 6
    mov [key], eax
    call clear
    jmp dayOfWeek

;(last 2 digits of year + quotient of last 2 digits/4 + day + month key) - 1 (mod 7)
;remainder of this calculation is the day of the week
;Sat-0, Sun-1, Mon-2, Tue-3, Wed-4, Thu-5, Fri-6
dayOfWeek:      
    mov ax, word[year]  ;subtracts 2000 from the year to result in last 2 digits of the year
    sub ax, 2000
    mov [temp], ax
    mov al, [temp]
    mov bl, al    ;save last 2 digits in ebx before eax is changed due to dividing
    mov cl, 4
    div cl
    add al, bl    ;add last 2 digits and floor of quotient
    xor ebx, ebx
    mov bl, byte[day]
    add al, bl    ;add day to sum
    mov bl, byte[key]
    add al, bl    ;add key to sum
    sub al, 1   ;subtract 1
    mov [temp2], al 
    mov eax, [temp2]
    mov ecx, 7      
    div ecx     ;divide by 7, remainder (mod 7) is day of week
    mov [remainder], edx
    call clear
    jmp print
;---------------------------------------------------------------------------------------------------
print:
    mov eax, [remainder]    ;determine which printf format to use by determining which day of the week
    mov ebx, 0              ;the remainder represents
    cmp eax, ebx
    je printSat
    inc ebx
    cmp eax, ebx
    je printSun
    inc ebx
    cmp eax, ebx
    je printMon
    inc ebx
    cmp eax, ebx
    je printTue
    inc ebx
    cmp eax, ebx
    je printWed
    inc ebx
    cmp eax, ebx
    je printThu
    inc ebx
    cmp eax, ebx
    je printFri


printSat:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatSat
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printSun:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatSun
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printMon:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatMon
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printTue:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatTue
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printWed:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatWed
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printThu:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatThu
    call printf
    add esp, 20

    mov eax, 1
    mov ebx, 0
    int 80h

printFri:
    mov al, byte[month]
    mov bl, byte[day]
    mov cx, word[year]
    push ecx
    push ebx
    push eax
    push formatFri
    call printf
    add esp, 20 

    mov eax, 1
    mov ebx, 0
    int 80h
