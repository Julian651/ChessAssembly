INCLUDE Lib.inc
.code
; if dir is 0, draw line up, if dir is 1, draw line right
drawStraightLine PROC USES eax ecx ebx edx,
  ;color:DWORD, len:DWORD, dir:BYTE, x:BYTE, y:BYTE
  push ebp
  mov ebp, esp
  sub esp, 4
  mov BYTE PTR [ebp-4], ' '
  mov eax, color
  call SetTextColor

  mov dl, x
  mov dh, y
  mov ecx, len
L1:
  call Gotoxy
  push edx
  push ecx
  mov ecx, ebp
  sub ecx, 4
  mov edx, ecx
  pop ecx
  call WriteString
  pop edx

  movzx ebx, dir
  test ebx, 00h ;if zero, draw line up
  jne x_increment;if zero, draw line right
  dec dh
  loop L1
  jmp endloop

x_increment:
  inc dl
  loop L1

endloop:
  mov eax, white + black * 16
  call SetTextColor
  mov esp, ebp
  pop ebp
  ret

drawStraightLine ENDP
END