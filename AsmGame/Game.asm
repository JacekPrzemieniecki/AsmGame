;/*
extern DrawStone: PROC
extern DrawGrass: PROC
extern DrawCar: PROC

.data
_bg_color equ 082764ah
_bg_color1 equ 082764ah + 0f0f0fh
bg_color dd _bg_color,
_bg_color,
_bg_color1,
_bg_color1,
_bg_color1,
_bg_color1,
_bg_color,
_bg_color,

.data?
rng_state dd ?

.code

window_h equ 1024
window_w equ 1024
blue equ   00000ffh
green equ 000ff00h
red equ  0ff0000h
black equ 0
white equ 0ffffffh

car_w equ 64
car_h equ 100
car_speed equ 6

world_speed equ 6

GS_PlayerPos equ 0
GS_Collision equ GS_PlayerPos + 8
GS_Tint equ GS_Collision + 8
GS_GrassCount equ 16
GS_GrassX equ GS_Tint + 8 ; 8
GS_GrassY equ GS_GrassX + GS_GrassCount*4 ; 72
GS_StoneCount equ 12
GS_StonesX equ GS_GrassY + GS_GrassCount*4
GS_StonesY equ GS_StonesX + GS_StoneCount*4


RngNext PROC
mov eax, rng_state
mov ebx, eax
shl eax, 13
xor eax, ebx
mov ebx, eax
shr eax, 17
xor eax, ebx
mov ebx, eax
shl eax, 15
xor eax, ebx
mov rng_state, eax
ret
RngNext ENDP

; rcx
GameInit PROC
mov dword ptr [r15], (window_w - car_w)/2
mov dword ptr [r15+4], 100 
mov dword ptr [r15+8], 1024
mov qword ptr [r15+GS_Tint], 255
mov rng_state, 854325
mov dword ptr [r15+GS_StonesX], 100
mov dword ptr [r15+GS_StonesY], 400

mov rdi, GS_GrassCount
GameInit_grass_loop:
dec rdi

call RngNext
and eax, 1024-1
mov dword ptr [r15+rdi*4+GS_GrassX], eax
call RngNext
and eax, 1024-1
mov dword ptr [r15+rdi*4+GS_GrassY], eax

test rdi, rdi
jnz GameInit_grass_loop

mov rdi, GS_StoneCount
GameInit_stone_loop:
dec rdi

call RngNext
and eax, window_w-1
mov [r15+rdi*4+GS_StonesX], eax

call RngNext
and eax, window_h-1
add eax, 2048 ; delay when the stones start appearing
mov [r15+rdi*4+GS_StonesY], eax

test rdi, rdi
jnz GameInit_stone_loop

mov dword ptr [r15+GS_Collision], 0

ret
GameInit ENDP

; rcx - StonesX*
; rdx - StonesY*
; r8d - PlayerX
; r9d - PlayerY
; r15 - GameState
UpdateStones PROC
sub rsp, 16
mov rdi, GS_StoneCount
UpdateStones_loop:
dec rdi
mov ebx, [rdx+rdi*4] ; Y
sub ebx, world_speed
cmp ebx, -63
jg UpdateStones_dont_reset
call RngNext
and eax, window_w-1
mov [rcx+rdi*4], eax
mov ebx, window_h

UpdateStones_dont_reset:
mov [rdx+rdi*4], ebx
mov eax, [rcx+rdi*4]

; Collision detection
; eax - stone X
; ebx - stone Y
; r8d - Player X
; r9d - Player Y
stone_w equ 64
stone_h equ 64
mov [rsp], eax
mov [rsp+4], rbx
; move the stone to player-relative coords
sub eax, r8d 
sub ebx, r9d 

cmp eax, car_w
jge Update_stones_no_collision

add eax, stone_w
cmp eax, 0
jle Update_stones_no_collision

cmp ebx, car_h
jge Update_stones_no_collision

add ebx, stone_h
cmp ebx, 0
jle Update_stones_no_collision

mov dword ptr [r15 + GS_Collision], 1

Update_stones_no_collision:

test rdi, rdi
jnz UpdateStones_loop

add rsp, 16
ret
UpdateStones ENDP


; rcx - GrassX*
; rdx - GrassY*
UpdateGrass PROC
mov rdi, GS_GrassCount
UpdateGrass_loop:
dec rdi
mov ebx, [rdx+rdi*4] ; Y
sub ebx, world_speed
cmp ebx, -63
jg UpdateGrass_dont_reset
call RngNext
and eax, 1024-1
mov [rcx+rdi*4], eax
mov ebx, 1024

UpdateGrass_dont_reset:
mov [rdx+rdi*4], ebx
test rdi, rdi
jnz UpdateGrass_loop
ret
UpdateGrass ENDP

; rcx - Input
GameUpdate PROC

mov ebx, 0
mov edx, 0
mov al, [rcx]
test al, al
jz GameUpdate_not_up
add edx, car_speed
GameUpdate_not_up:
mov al, [rcx+1]
test al, al
jz GameUpdate_not_down
sub edx, car_speed
GameUpdate_not_down:
mov al, [rcx+2]
test al, al
jz GameUpdate_not_left
sub ebx, car_speed
GameUpdate_not_left:
mov al, [rcx+3]
test al, al
jz GameUpdate_not_right
add ebx, car_speed
GameUpdate_not_right:

mov eax, [r15]
add eax, ebx
mov [r15], eax

mov eax, [r15+4]
add eax, edx
mov [r15+4], eax

lea rcx, [r15+GS_GrassX]
lea rdx, [r15+GS_GrassY]
call UpdateGrass

lea rcx, [r15+GS_StonesX]
lea rdx, [r15+GS_StonesY]
mov r8d, [r15+GS_PlayerPos]
mov r9d, [r15+GS_PlayerPos+4]
call UpdateStones

mov eax, [r15+GS_Collision]
test eax, eax
jz GameUpdate_no_collision

call GameInit

GameUpdate_no_collision:
mov eax, [r15+GS_Tint]
test eax, eax
jz GameUpdate_no_tint
sub eax, 3
test eax, eax
jg GameUpdate_still_tinted
xor eax, eax
GameUpdate_still_tinted:
mov [r15+GS_Tint], eax

GameUpdate_no_tint:

ret
GameUpdate ENDP
; r10d - Color
; r14 - BackBuffer*
; rcx - X
; rdx - Y
; r8 - Size_X
; r9 - Size_Y
DrawRect PROC
push rbp
mov rbp, rsp
cmp rcx, 0
jge DrawRect_X_above_0
add r8, rcx
mov rcx, 0

DrawRect_X_above_0:
mov rax, 1024
sub rax, rcx
cmp rax, r8
cmovle r8, rax

cmp r8, 0
jle DrawRect_end

cmp rdx, 0
jge DrawRect_Y_above_0
add r9, rdx
mov rdx, 0

DrawRect_Y_above_0:
mov rax, 1024
sub rax, rdx
cmp rax, r9
cmovle r9, rax

cmp r9, 0
jle DrawRect_end

; rdi - y_cursor
mov rdi, 0
DrawRect_loop_y:
cmp rdi, r9
je DrawRect_loop_y_end
mov r11, rdi
add r11, rdx
imul r11, window_h ; yoffset in pixels
add r11, rcx
imul r11, 4 ; x+y offset in bytes
add r11, r14

; rsi - x_cursor
mov rsi, 0
DrawRect_loop_x:
cmp rsi, r8
je DrawRect_loop_x_end
mov dword ptr [r11 + rsi*4], r10d
inc r12
inc rsi
jmp DrawRect_loop_x
DrawRect_loop_x_end:

inc rdi
jmp DrawRect_loop_y
DrawRect_loop_y_end:
DrawRect_end:

mov rsp, rbp
pop rbp
ret
DrawRect ENDP

; r15 - GameState
; r14 - BackBuffer
GameDraw PROC
sub rsp, 8
mov rax, 0
mov rsi, 1024
clear_loop:
mov rdi, 1024 / 2
mov rbx, 0
mov rcx, 16
test rsi, 2
cmovz rbx, rcx
lea rcx, [bg_color]
movdqa xmm0, [rbx+rcx]
clear_line_loop:
sub rdi, 2
movntdq [r14+rax], xmm0
add rax, 16 
test rdi, rdi
jnz clear_line_loop
dec rsi
test rsi, rsi
jnz clear_loop


; Draw car
tire_w equ 5
tire_h equ 16

mov rdi, GS_GrassCount
draw_grass_loop:
dec rdi
mov [rsp], rdi
movsxd rcx, dword ptr [r15+rdi*4+GS_GrassX]
movsxd rdx, dword ptr [r15+rdi*4+GS_GrassY]
call DrawGrass
mov rdi, [rsp]
test rdi, rdi
jnz draw_grass_loop

mov rdi, GS_StoneCount
draw_stones_loop:
dec rdi
mov [rsp], rdi

movsxd rcx, dword ptr [r15+rdi*4+GS_StonesX]
movsxd rdx, dword ptr [r15+rdi*4+GS_StonesY]
call DrawStone
mov rdi, [rsp]
test rdi, rdi
jnz draw_stones_loop


movsxd rcx, dword ptr [r15]
movsxd rdx, dword ptr [r15+4]
call DrawCar

mov ecx, dword ptr [r15+GS_Tint] 
and ecx, 0ffh
call DrawTint


add rsp, 8
ret
GameDraw ENDP

tint_color equ red
; r14 - Backbuffer
; rcx - TintAmount (0-255)
DrawTint PROC
test rcx, rcx
jz DrawTint_skip

imul r8d, ecx, tint_color and 0ffh
imul r9d, ecx, tint_color and 0ff00h
imul r10d, ecx, tint_color and 0ff0000h

COMMENT @
mov bl, al
imul ebx, ecx
shr ebx, 8
and ebx, 0ffh
or edx, ebx
xor ebx, ebx
shr eax, 8

mov bl, al
imul ebx, ecx
shr ebx, 8
and ebx, 0ffh
shl ebx, 8
or edx, ebx
xor ebx, ebx
shr eax, 8

mov bl, al
imul ebx, ecx
shr ebx, 8
and ebx, 0ffh
shl ebx, 16 
or edx, ebx
xor ebx, ebx
mov r8d, edx
@

mov ebx, 255
sub ebx, ecx
mov ecx, ebx

mov rdi, 1024*1024
DrawTint_loop:
dec rdi
xor edx, edx
xor ebx, ebx
mov edx, [r14+rdi*4]

mov eax, edx
and eax, 0ffh
imul eax, ecx
add eax, r8d
shr eax, 8
and eax, 0ffh
or ebx, eax

mov eax, edx
and eax, 0ff00h
imul eax, ecx
add eax, r9d
shr eax, 8
and eax, 0ff00h
or ebx, eax

mov eax, edx
and eax, 0ff0000h
imul eax, ecx
add eax, r10d
shr eax, 8
and eax, 0ff0000h
or ebx, eax

mov [r14+rdi*4], ebx

test rdi, rdi
jnz DrawTint_loop

DrawTint_skip:
ret
DrawTint ENDP

END
;*/