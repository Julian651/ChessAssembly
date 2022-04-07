INCLUDE Lib.inc
.code

;================================================================================

drawSquare PROC USES eax,
  color:DWORD, sidelen:DWORD, x:BYTE, y:BYTE
  
  invoke drawStraightLine,
    color, sidelen, 0, x, y, 0DBh
  invoke drawStraightLine,
    color, sidelen, 1, x, y, 0DBh
  mov al, BYTE PTR sidelen
  dec al
  add x, al
  invoke drawStraightLine,
    color, sidelen, 0, x, y, 0DBh
  sub y, al
  sub x, al
  invoke drawStraightLine,
    color, sidelen, 1, x, y, 0DBh

  ret

drawSquare ENDP

;================================================================================

drawRect PROC USES eax,
  color:DWORD, widthlen:DWORD, heightlen:DWORD, x:BYTE, y:BYTE

  invoke drawStraightLine,
    color, heightlen, 0, x, y, 0DBh
  invoke drawStraightLine,
    color, widthlen, 1, x, y, 0DBh
  mov al, BYTE PTR widthlen
  dec al
  add x, al
  invoke drawStraightLine,
    color, heightlen, 0, x, y, 0DBh
  mov bl, BYTE PTR heightlen
  dec bl
  sub y, bl
  sub x, al
  invoke drawStraightLine,
    color, widthlen, 1, x, y, 0DBh

  ret

drawRect ENDP

;================================================================================

fillRect PROC USES ecx,
  color:DWORD, widthlen:DWORD, heightlen:DWORD, x:BYTE, y:BYTE

  mov ecx, widthlen
L1:
  invoke drawStraightLine,
    color, heightlen, 0, x, y, 0DBh
  inc x
  loop L1

  ret

fillRect ENDP

fillSquare PROC USES ecx,
  color:DWORD, sidelen:DWORD, x:BYTE, y:BYTE
  
  mov ecx, sidelen
L1:
  invoke drawStraightLine,
    color, sidelen, 0, x, y, 0DBh
  inc x
  loop L1

  ret

fillSquare ENDP

;================================================================================

drawCheckerBoard PROC USES ebx ecx edx,
  viewas:BYTE,
  color1:DWORD, color2:DWORD, sqwidth:DWORD, sqheight:DWORD,
  squares:DWORD, x:BYTE, y:BYTE
  LOCAL flip:DWORD
  mov flip, 0
  mov ecx, 01h
  or flip, ecx
  
  mov ecx, squares
  jmp L3
L1:
  mov DWORD PTR y, ebx
  mov dl, BYTE PTR sqwidth
  add x, dl
L3:
  push ecx
  movzx ebx, y
  mov ecx, squares
L2:
  .IF flip == 0
    invoke fillRect,
      color1, sqwidth, sqheight, x, y
    mov flip, 1
  .ELSE
    invoke fillRect,
      color2, sqwidth, sqheight, x, y
    mov flip, 0
  .ENDIF
  mov dl, BYTE PTR sqheight
  sub y, dl
  loop L2
  xor flip, 01h
  pop ecx
  loop L1

  ret

drawCheckerBoard ENDP

;================================================================================

drawStraightLine PROC USES eax ecx edx,
  color:DWORD, len:DWORD, dir:BYTE, x:BYTE, y:BYTE, char:BYTE
  
  
  mov eax, color
  call SetTextColor

  mov dl, x
  mov dh, y
  mov ecx, len
L1:
  call Gotoxy
  push edx
  push eax
  lea eax, char
  mov edx, eax
  pop eax
  call WriteString
  pop edx

  movzx eax, dir
  test eax, 01h ;if one, draw line right
  jne x_increment;if not one, draw line up
  dec dh
  loop L1
  jmp endloop

x_increment:
  inc dl
  loop L1

endloop:
  mov eax, white + black * 16
  call SetTextColor
  ret

drawStraightLine ENDP
END