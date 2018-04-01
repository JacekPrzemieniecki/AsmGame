;/*
; For a very loose definition of "Sprites"
extern DrawRect: PROC
.code

tire_color equ 0


stone_color equ 0d5d5d5h
; rcx X
; rdx Y
DrawStone PROC
sub rsp, 16
mov [rsp], rcx
mov [rsp+8], rdx


mov r10d, stone_color
mov rcx, [rsp]
mov rdx, [rsp+8]
add rdx, 5
mov r8, 64 
mov r9, 29
call DrawRect

mov r10d, stone_color
mov rcx, [rsp]
add rcx, 6 
mov rdx, [rsp+8]
add rdx, 34
mov r8, 47 
mov r9, 12 
call DrawRect


mov r10d, stone_color
mov rcx, [rsp]
add rcx, 3 
mov rdx, [rsp+8]
mov r8, 59 
mov r9, 5 
call DrawRect


mov r10d, stone_color
mov rcx, [rsp]
add rcx, 12 
mov rdx, [rsp+8]
add rdx, 46
mov r8, 20 
mov r9, 16 
call DrawRect

add rsp, 16
ret
DrawStone ENDP

; rcx X
; rdx Y
DrawCar PROC
sub rsp, 16
mov [rsp], rcx
mov [rsp+8], rdx
car_w equ 64
car_h equ 100
tire_w equ 5
tire_h equ 16

mov r10d, tire_color
mov rcx, [rsp]
add rcx, car_w 
mov rdx, [rsp+8]
add rdx, car_h-20
mov r8, tire_w 
mov r9, tire_h 
call DrawRect

mov r10d, tire_color
mov rcx, [rsp]
sub rcx, tire_w 
mov rdx, [rsp+8]
add rdx, car_h-20
mov r8, tire_w 
mov r9, tire_h 
call DrawRect

mov r10d, tire_color
mov rcx, [rsp]
sub rcx, tire_w
mov rdx, [rsp+8]
add rdx, 20-tire_h
mov r8, tire_w 
mov r9, tire_h 
call DrawRect

mov r10d, tire_color
mov rcx, [rsp]
add rcx, car_w
mov rdx, [rsp+8]
add rdx, 20-tire_h
mov r8, tire_w 
mov r9, tire_h 
call DrawRect


mov r10d, 66d939h
mov rcx, [rsp]
mov rdx, [rsp+8]
mov r8, car_w
mov r9, car_h
call DrawRect	

; windshield
mov r10d, 61c8eah
movsxd rcx, dword ptr [r15]
add rcx, 10
movsxd rdx, dword ptr [r15+4]
add rdx, car_h/2+10
mov r8, car_w -20 
mov r9, 10 
call DrawRect

add rsp, 16
ret
DrawCar ENDP

grass_color equ 000ff00h
DrawGrass PROC
sub rsp, 16
mov [rsp], rcx
mov [rsp+8], rdx

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 32
mov rdx, [rsp+8]
add rdx, 10
mov r8, 3
mov r9, 7
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 33
mov rdx, [rsp+8]
add rdx, 15
mov r8, 5
mov r9, 13 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 36
mov rdx, [rsp+8]
add rdx, 20
mov r8, 7
mov r9, 14 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 42
mov rdx, [rsp+8]
add rdx, 30
mov r8, 7
mov r9, 11 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 47
mov rdx, [rsp+8]
add rdx, 36
mov r8, 5
mov r9, 10 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 52
mov rdx, [rsp+8]
add rdx, 42
mov r8, 7
mov r9, 10 
call DrawRect



mov r10d, grass_color
mov rcx, [rsp]
add rcx, 27
mov rdx, [rsp+8]
add rdx, 33
mov r8, 5
mov r9, 12 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 24
mov rdx, [rsp+8]
add rdx, 45
mov r8, 8
mov r9, 11 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 20
mov rdx, [rsp+8]
add rdx, 52
mov r8, 7
mov r9, 7
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 32
mov rdx, [rsp+8]
add rdx, 40
mov r8, 2
mov r9, 8 
call DrawRect


mov r10d, grass_color
mov rcx, [rsp]
add rcx, 24
mov rdx, [rsp+8]
add rdx, 3
mov r8, 3
mov r9, 19
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 20
mov rdx, [rsp+8]
add rdx, 11
mov r8, 4
mov r9, 19 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 16
mov rdx, [rsp+8]
add rdx, 18
mov r8, 4
mov r9, 16
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 12
mov rdx, [rsp+8]
add rdx, 23
mov r8, 4
mov r9, 11 
call DrawRect

mov r10d, grass_color
mov rcx, [rsp]
add rcx, 9
mov rdx, [rsp+8]
add rdx, 28
mov r8, 3
mov r9, 6 
call DrawRect


add rsp, 16
ret
DrawGrass ENDP
END
;*/