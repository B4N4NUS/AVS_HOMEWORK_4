; file.asm - использование файлов в NASM
extern printf
extern fprintf

extern PerimeterRectangle
extern PerimeterTriangle

extern RECTANGLE
extern TRIANGLE

;----------------------------------------------
;// Вывод параметров прямоугольника в файл
;void OutRectangle(void *r, FILE *ofst) {
;    fprintf(ofst, "It is Rectangle: x = %d, y = %d. Perimeter = %g\n",
;            *((int*)r), *((int*)(r+intSize)), PerimeterRectangle(r));
;}
global OutRectangle
OutRectangle:
section .data
    .outfmt db "It is Rectangle: x = %d, y = %d. Perimeter = %g",10,0
section .bss
    .prect  resq  1
    .FILE   resq  1       ; временное хранение указателя на файл
    .p      resq  1       ; вычисленный периметр прямоугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.prect], rdi          ; сохраняется адрес прямоугольника
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Вычисление периметра прямоугольника (адрес уже в rdi)
    call    PerimeterRectangle
    movsd   [.p], xmm0          ; сохранение (может лишнее) периметра

    ; Вывод информации о прямоугольнике в консоль
;     mov     rdi, .outfmt        ; Формат - 1-й аргумент
;     mov     rax, [.prect]       ; адрес прямоугольника
;     mov     esi, [rax]          ; x
;     mov     edx, [rax+4]        ; y
;     movsd   xmm0, [.p]
;     mov     rax, 1              ; есть числа с плавающей точкой
;     call    printf

    ; Вывод информации о прямоугольнике в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt        ; Формат - 2-й аргумент
    mov     rax, [.prect]        ; адрес прямоугольника
    mov     edx, [rax]          ; x
    mov     ecx, [rax+4]        ; y
    movsd   xmm0, [.p]
    mov     rax, 1              ; есть числа с плавающей точкой
    call    fprintf

leave
ret

;----------------------------------------------
; // Вывод параметров треугольника в файл
; void OutTriangle(void *t, FILE *ofst) {
;     fprintf(ofst, "It is Triangle: a = %d, b = %d, c = %d. Perimeter = %g\n",
;            *((int*)t), *((int*)(t+intSize)), *((int*)(t+2*intSize)),
;             PerimeterTriangle(t));
; }
global OutTriangle
OutTriangle:
section .data
    .outfmt db "It is Triangle: a = %d, b = %d, c = %d. Perimeter = %g",10,0
section .bss
    .ptrian  resq  1
    .FILE   resq  1       ; временное хранение указателя на файл
    .p      resq  1       ; вычисленный периметр треугольника
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.ptrian], rdi        ; сохраняется адрес треугольника
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Вычисление периметра треугольника (адрес уже в rdi)
    call    PerimeterTriangle
    movsd   [.p], xmm0          ; сохранение (может лишнее) периметра

    ; Вывод информации о треугольнике в консоль
;     mov     rdi, .outfmt        ; Формат - 1-й аргумент
;     mov     rax, [.ptrian]       ; адрес треугольника
;     mov     esi, [rax]          ; a
;     mov     edx, [rax+4]        ; b
;     mov     ecx, [rax+8]        ; c
;     movsd   xmm0, [.p]
;     mov     rax, 1              ; есть числа с плавающей точкой
;     call    printf

    ; Вывод информации о треугольнике в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt        ; Формат - 2-й аргумент
    mov     rax, [.ptrian]      ; адрес треугольника
    mov     edx, [rax]          ; x
    mov     ecx, [rax+4]        ; b
    mov      r8, [rax+8]        ; c
    movsd   xmm0, [.p]
    mov     rax, 1              ; есть числа с плавающей точкой
    call    fprintf

leave
ret

;----------------------------------------------
; // Вывод параметров текущей фигуры в файл
; void OutShape(void *s, FILE *ofst) {
;     int k = *((int*)s);
;     if(k == RECTANGLE) {
;         OutRectangle(s+intSize, ofst);
;     }
;     else if(k == TRIANGLE) {
;         OutTriangle(s+intSize, ofst);
;     }
;     else {
;         fprintf(ofst, "Incorrect figure!\n");
;     }
; }
global OutShape
OutShape:
section .data
    .erShape db "Incorrect figure!",10,0
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov eax, [rdi]
    cmp eax, [RECTANGLE]
    je rectOut
    cmp eax, [TRIANGLE]
    je trianOut
    mov rdi, .erShape
    mov rax, 0
    call fprintf
    jmp     return
rectOut:
    ; Вывод прямоугольника
    add     rdi, 4
    call    OutRectangle
    jmp     return
trianOut:
    ; Вывод треугольника
    add     rdi, 4
    call    OutTriangle
return:
leave
ret

;----------------------------------------------
; // Вывод содержимого контейнера в файл
; void OutContainer(void *c, int len, FILE *ofst) {
;     void *tmp = c;
;     fprintf(ofst, "Container contains %d elements.\n", len);
;     for(int i = 0; i < len; i++) {
;         fprintf(ofst, "%d: ", i);
;         OutShape(tmp, ofst);
;         tmp = tmp + shapeSize;
;     }
; }
global OutContainer
OutContainer:
section .data
    numFmt  db  "%d: ",0
section .bss
    .pcont  resq    1   ; адрес контейнера
    .len    resd    1   ; адрес для сохранения числа введенных элементов
    .FILE   resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi   ; сохраняется указатель на контейнер
    mov [.len],   esi     ; сохраняется число элементов
    mov [.FILE],  rdx    ; сохраняется указатель на файл

    ; В rdi адрес начала контейнера
    mov rbx, rsi            ; число фигур
    xor ecx, ecx            ; счетчик фигур = 0
    mov rsi, rdx            ; перенос указателя на файл
.loop:
    cmp ecx, ebx            ; проверка на окончание цикла
    jge .return             ; Перебрали все фигуры

    push rbx
    push rcx

    ; Вывод номера фигуры
    mov     rdi, [.FILE]    ; текущий указатель на файл
    mov     rsi, numFmt     ; формат для вывода фигуры
    mov     edx, ecx        ; индекс текущей фигуры
    xor     rax, rax,       ; только целочисленные регистры
    call fprintf

    ; Вывод текущей фигуры
    mov     rdi, [.pcont]
    mov     rsi, [.FILE]
    call OutShape     ; Получение периметра первой фигуры

    pop rcx
    pop rbx
    inc ecx                 ; индекс следующей фигуры

    mov     rax, [.pcont]
    add     rax, 16         ; адрес следующей фигуры
    mov     [.pcont], rax
    jmp .loop
.return:
leave
ret

