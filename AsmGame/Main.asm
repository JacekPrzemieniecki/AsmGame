;/*
.data 
wnd_class_name db "WndClassName", 0
wnd_name db "TestWindow", 0
debug_string db "Debug Test Test TEst", 10,  0

.data?
exit_program dd ?

input_state dq ?

debug_time dq ?
debug_dt dq ?
debug_frames_skipped dq ?
debug_frames_dropped dq ?
qpt_start dq ?
qpt_freq dq ?
timer_simulated dq ?

.code

;windows.h

SRCCOPY equ 00CC0020h

extern ExitProcess: PROC
extern GetModuleHandleA: PROC
extern RegisterClassA: PROC
extern CreateWindowExA: PROC
extern GetWindowRect: PROC
extern MoveWindow: PROC
extern GetLastError: PROC
extern DefWindowProcA: PROC
extern ShowWindow: PROC
extern Sleep: PROC
extern QueryPerformanceCounter: PROC
extern QueryPerformanceFrequency: PROC
extern OutputDebugStringA: PROC

extern PeekMessageA: PROC
extern GetMessageA: PROC
extern TranslateMessage: PROC
extern DispatchMessageA: PROC

extern VirtualAlloc: PROC

extern GetDC: PROC
extern GetClientRect: PROC
extern StretchDIBits: PROC
extern SetDIBitsToDevice: PROC
extern ChoosePixelFormat: PROC

extern GameUpdate: PROC
extern GameDraw: PROC
extern GameInit: PROC


PUBLIC WinMain

GetTimer PROC
sub rsp, 8h
mov rcx, rsp
sub rsp, 20h
call QueryPerformanceCounter
add rsp, 20h
mov rax, [rsp]
sub rax, [offset qpt_start]
mov rbx, 1000000
mul rbx
div qword ptr [offset qpt_freq]
add rsp, 8h
ret
GetTimer ENDP


; rcx - BitmapInfo*
MakeBitmapInfo PROC
; Fill BitmapInfo
;  DWORD biSize;
;  LONG  biWidth;
;  LONG  biHeight;
;  WORD  biPlanes;
;  WORD  biBitCount;
;  DWORD biCompression;
;  DWORD biSizeImage;
;  LONG  biXPelsPerMeter;
;  LONG  biYPelsPerMeter;
;  DWORD biClrUsed;
;  DWORD biClrImportant;
;ColorTable
;  BYTE rgbBlue;
;  BYTE rgbGreen;
;  BYTE rgbRed;
;  BYTE rgbReserved;
mov dword ptr [rcx], 40 ;biSize
mov dword ptr [rcx+1*4], 1024 ;biWidth
mov dword ptr [rcx+2*4], 1024 ;biHeight
mov word ptr [rcx+3*4], 1 ;biPlanes
mov word ptr [rcx+3*4+2], 32 ;biBitCount
mov dword ptr [rcx+4*4], 0 ;biCompression -- RGB
mov dword ptr [rcx+5*4], 1024*1024*4 ;biSizeImage
mov dword ptr [rcx+6*4], 1000 ;biXPelsPerMeter
mov dword ptr [rcx+7*4], 1000 ;biYPelsPerMeter
mov dword ptr [rcx+8*4], 0 ;biClrUsed
mov dword ptr [rcx+9*4], 0 ;biClrImportant
mov dword ptr [rcx+10*4], 0 ;Color Table

ret
MakeBitmapInfo ENDP

; RCX - DC
; RDX - BB*
; R8 - BitmapInfo
; R9 - HWnd
DrawBackbuffer PROC
sub rsp, 48h

mov [rsp], rcx
mov [rsp+8h], rdx
mov [rsp+10h], r8
mov rcx, r9
lea rdx, [rsp+18h]
sub rsp, 20h
call GetClientRect
add rsp, 20h

; r - l in eax
; t - b in ebx
xor rax, rax
xor rbx, rbx
mov eax, [rsp+18h + 8]
sub eax, [rsp+18h + 0]
mov ebx, [rsp+18h + 12]
sub ebx, [rsp+18h + 4]

mov rcx, [rsp]
mov rdx, [rsp+8h]
mov r8, [rsp+10h]


mov dword ptr [rsp], ebx ;nDestHeight
mov dword ptr [rsp+8h], 0 ;XSrc
mov dword ptr [rsp+10h], 0 ;YSrc
mov dword ptr [rsp+18h], 0 ;nStartScan
mov dword ptr [rsp+20h], 1024 ;cScanLines
mov qword ptr [rsp+28h], rdx ;lpBits
mov qword ptr [rsp+30h], r8 ;lpBitsInfo
mov qword ptr [rsp+38h], 0 ;fuColorUse -- RGB

; DC already in rcx
mov rdx, 0 ;XDest
mov r8, 0 ;YDest
mov r9, rax ;nDestWidth

sub rsp, 20h
call SetDIBitsToDevice
add rsp, 20h

add rsp, 48h
ret
DrawBackbuffer ENDP

; rcx - Input
InitInput PROC
; WSAD bytes
mov qword ptr [rcx], 0
ret
InitInput ENDP

WM_CLOSE equ 16
WM_KEYDOWN equ 100h
WM_KEYUP equ 101h

WinProc PROC 
push rbp
mov rbp, rsp

cmp rdx, WM_CLOSE
je WinProc_WM_CLOSE
cmp rdx, WM_KEYDOWN
je WinProc_WM_KEYDOWN
cmp rdx, WM_KEYUP
je WinProc_WM_KEYUP
jmp WinProc_default

WinProc_WM_CLOSE:
mov dword ptr [exit_program], 1
xor eax, eax
jmp WinProc_end

KEY_ESC equ 1bh
KEY_W equ 57h
KEY_S equ 53h
KEY_A equ 41h
KEY_D equ 44h

WinProc_WM_KEYDOWN:
mov rbx, input_state
cmp r8, KEY_W
je WinProc_WM_KEYDOWN_W
cmp r8, KEY_S
je WinProc_WM_KEYDOWN_S
cmp r8, KEY_A
je WinProc_WM_KEYDOWN_A
cmp r8, KEY_D
je WinProc_WM_KEYDOWN_D
jmp WinProc_end

WinProc_WM_KEYUP:
mov rbx, input_state
cmp r8, KEY_W
je WinProc_WM_KEYUP_W
cmp r8, KEY_S
je WinProc_WM_KEYUP_S
cmp r8, KEY_A
je WinProc_WM_KEYUP_A
cmp r8, KEY_D
je WinProc_WM_KEYUP_D
jmp WinProc_end


WinProc_WM_KEYDOWN_W:
mov byte ptr [rbx], 1
jmp WinProc_end

WinProc_WM_KEYUP_W:
mov byte ptr [rbx], 0
jmp WinProc_end


WinProc_WM_KEYDOWN_S:
mov byte ptr [rbx+1], 1
jmp WinProc_end

WinProc_WM_KEYUP_S:
mov byte ptr [rbx+1], 0
jmp WinProc_end


WinProc_WM_KEYDOWN_A:
mov byte ptr [rbx+2], 1
jmp WinProc_end

WinProc_WM_KEYUP_A:
mov byte ptr [rbx+2], 0
jmp WinProc_end


WinProc_WM_KEYDOWN_D:
mov byte ptr [rbx+3], 1
jmp WinProc_end

WinProc_WM_KEYUP_D:
mov byte ptr [rbx+3], 0
jmp WinProc_end



WinProc_default:
sub rsp, 20h
call DefWindowProcA
add rsp, 20h
jmp WinProc_end

WinProc_end:
mov rsp, rbp
pop rbp
ret
WinProc ENDP

window_w equ 1024
window_h equ 1024

WinMain PROC 
push r15
push r14
push rbx
push rbp 
mov rbp, rsp 
sub rsp, 250h ;80B for stack args + 512B frame
;0-100h for stack args
;100h:
;0:48 BitmapInfo
;48:8 DC
;56:8 HWindow
;64:8 Backbuffer*
;72:8 GameState*
and rsp, not 8 ; align stack to 16 bytes for Win32 calls

mov rcx, rsp
sub rsp, 20h
call QueryPerformanceFrequency
add rsp, 20h
mov rax, [rsp]
mov [offset qpt_freq], rax

mov rcx, rsp
sub rsp, 20h
call QueryPerformanceCounter
add rsp, 20h
mov rax, [rsp]
mov [offset qpt_start], rax


;{
;  4 UINT      style;
;  8 WNDPROC   lpfnWndProc;
;  4 int       cbClsExtra;
;  4 int       cbWndExtra;
;  8 HINSTANCE hInstance;
;  8 HICON     hIcon;
;  8 HCURSOR   hCursor;
;  8 HBRUSH    hbrBackground;
;  8 LPCTSTR   lpszMenuName;
;  8 LPCTSTR   lpszClassName;
;}

mov dword ptr [rsp+0], 0 ;style
mov rax, offset WinProc
mov qword ptr [rsp+8], rax ;lpfnWndProc
mov dword ptr [rsp+16], 0 ;cbClsExtra
mov dword ptr [rsp+20], 0 ;cbWndExtra
mov rcx, 0
sub rsp,20h
call GetModuleHandleA
add rsp,20h
mov rbx, rax
mov qword ptr [rsp+24], rbx;hInstance
mov qword ptr [rsp+32], 0 ;hIcon
mov qword ptr [rsp+40], 0 ;hCursor
mov qword ptr [rsp+48], 0 ;hbrBackground
mov qword ptr [rsp+56], 0 ;lpszMenuName
mov rax, offset wnd_class_name ;lpszClassName
mov qword ptr [rsp+64], rax
mov qword ptr [rsp+72], 0

mov rcx, rsp
sub rsp, 20h
call RegisterClassA
add rsp, 20h

;CreateWindowExA
;  DWORD     dwExStyle,
;  LPCTSTR   lpClassName,
;  LPCTSTR   lpWindowName,
;  DWORD     dwStyle,
;  int       x,
;  int       y,
;  int       nWidth,
;  int       nHeight,
;  HWND      hWndParent,
;  HMENU     hMenu,
;  HINSTANCE hInstance,
;  LPVOID    lpParam

mov rcx, 200h
mov rdx, offset wnd_class_name
mov r8, offset wnd_name
mov r9, 0C00000h
or r9, 080000h
;or r9, 040000h
or r9, 020000h
;or r9, 010000h

sub rsp, 200h
mov qword ptr [rsp+7*8], 0 ;lpParam
mov qword ptr [rsp+6*8], rbx  ;hInstance
mov qword ptr [rsp+5*8], 0 ;hMenu
mov qword ptr [rsp+4*8], 0 ;hWndParent
mov rax, 80000000h 
mov qword ptr [rsp+3*8], window_h ;nHeight
mov qword ptr [rsp+2*8], window_w ;nWidth
mov qword ptr [rsp+1*8], rax ;y
mov qword ptr [rsp+0*8], rax ;x

sub rsp, 20h
call CreateWindowExA
add rsp, 20h
mov qword ptr [rsp+100h+56], rax
mov rcx, rax
mov rdx, 5
sub rsp, 20h
call ShowWindow
add rsp, 20h

mov rcx, qword ptr [rsp+100h+56]
lea rdx, [rsp]
sub rsp, 20h
call GetClientRect
add rsp, 20h

mov eax, [rsp+12] ; height
mov ebx, [rsp+8] ; width

mov r12d, 2048
sub r12d, ebx ; new_w

mov r13d, 2048
sub r13d, eax ; new_h

mov rcx, qword ptr [rsp+100h+56]
lea rdx, [rsp]
sub rsp, 20h
call GetWindowRect
add rsp, 20h

mov rcx, qword ptr [rsp+100h+56]
mov edx, dword ptr [rsp+0]
mov r8d, dword ptr [rsp+4]
mov r9d, r12d
mov [rsp], r13d
mov qword ptr [rsp+8], 1
sub rsp, 20h
call MoveWindow
add rsp, 20h


;Alloc backbuffer
mov rcx, 0
mov rdx, 1024*1024*4 + 1024*4*256
mov r8, 01000h
mov r9, 04h 
sub rsp, 20h
call VirtualAlloc
add rsp, 20h
; Leave 64 lines before and after the backbuffer so we can write
; outside the buffer without segfaults
add rax, 1024*4*128
mov r14, rax

;Alloc GameState and Input
mov rcx, 0
mov rdx, 1024*1024*16 + 1024*4
mov r8, 01000h
mov r9, 04h 
sub rsp, 20h
call VirtualAlloc
add rsp, 20h
mov [offset input_state], rax
mov rcx, rax
add rax, 1024
mov r15, rax

call InitInput
call GameInit

mov rcx, [rsp+100h+56]
sub rsp, 20h
call GetDC
add rsp, 20h
mov qword ptr[rsp+100h + 48], rax

lea rcx, [rsp+100h]
call MakeBitmapInfo
mov dword ptr [exit_program], 0

app_loop:
mov eax, dword ptr [exit_program]
test eax, eax
jnz app_loop_end
message_loop:

lea rcx, [rsp+8]
mov rdx, 0
mov r8, 0
mov r9, 0
mov qword ptr [rsp], 1
sub rsp, 20h
call PeekMessageA
add rsp, 20h
test eax, eax
jz message_loop_end
lea rcx, [rsp+8]
sub rsp, 20h
call TranslateMessage
add rsp, 20h
lea rcx, [rsp+8]
sub rsp, 20h
call DispatchMessageA
add rsp, 20h
jmp message_loop
message_loop_end:


mov rcx, [rsp+100h+48]
mov rdx, r14
lea r8, [rsp+100h]
mov r9, [rsp+100h+56]
call DrawBackbuffer

call GetTimer
mov rbx, [debug_time]
mov [debug_time], rax
sub rax, rbx
cmp rax, 16666
jg fast_enough

mov rcx, debug_frames_dropped
inc rcx
mov debug_dt, rcx

fast_enough:
add rax, rbx
mov rbx, [offset timer_simulated]
mov rcx, rax
sub rax, rbx
cmp rax, 16666
jle skip_update

add rbx, 16666
mov [offset timer_simulated], rbx
mov rcx, [input_state]
call GameUpdate

call GameDraw
jmp skip_update1
skip_update:
mov rax, debug_frames_skipped
inc rax
mov debug_frames_skipped, rax

skip_update1:

mov rcx, 1 
sub rsp, 20h
call Sleep
add rsp, 20h

jmp app_loop
app_loop_end:

mov rsp, rbp
pop rbp
pop rbx
pop r14
pop r15
push 0
call ExitProcess
WinMain ENDP
END
;*/