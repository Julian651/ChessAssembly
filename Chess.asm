INCLUDE Lib.inc
.data
; w rnbqkbnr/pppppppp/11111111/11111111/11111111/11111111/PPPPPPPP/RNBQKBNR KQkq - 0 1
; first byte is white or black (0 for white, 1 for black) to move
; next 64 bytes is board state
; byte 65, 66, 67, 68 determines castling
; byte 69, 70 determines en passant
; byte 71,72,73,74 determines half move clock (DWORD)
; byte 75,76,78,79 determines full move clock (DWORD)
; fen BYTE 79 DUP (?)
; default_state BYTE "rnbqkbnrpppppppp11111111111111111111111111111111PPPPPPPPRNBQKBNR",0
fen BYTE 1,"rnbqkbnrpppppppp11111111111111111111111111111111PPPPPPPPRNBQKBNR","KQkq",0,0,0,0,0,0,0,0,0,1
board_view BYTE 1 ; 1 = white, 0 = black
FULL_BLOCK EQU 0DBh
HALF_BLOCK_LOWER EQU 0DCh
HALF_BLOCK_UPPER EQU 0DFh
WHITE_TO_MOVE BYTE "White to move",0Dh,0Ah,0
BLACK_TO_MOVE BYTE "Black to move",0Dh,0Ah,0
BOTTOM_ROW BYTE "ABCDEFGH"
LEFT_COLUMN BYTE "12345678"
.code

;================================================================================
printInfo PROC USES eax ebx ecx edx
  push ebp
  mov ebp, esp
  sub esp, 92

  ; write the player to move
  mov dl, 0
  mov dh, 30
  call Gotoxy
  mov al, [fen]
  .IF al == 0 ; black
    mov edx, OFFSET BLACK_TO_MOVE
    call WriteString
  .ELSE ; white
    mov edx, OFFSET WHITE_TO_MOVE
    call WriteString
  .ENDIF

  ; write the fen representation
  mov ecx, 64
  mov esi, OFFSET fen+1
  mov edi, esp
L1:
  mov eax, ecx
  mov edx, 0
  mov ebx, 8
  idiv ebx
  .IF edx == 0 && ecx != 64
    mov al, 0Dh
    mov [edi], al
    inc edi
    mov al, 0Ah
    mov [edi], al
    inc edi
  .ENDIF
  mov al, [esi]
  mov [edi], al
  inc esi
  inc edi
  loop L1
  mov al, 0Dh
  mov [edi], al
  inc edi
  mov al, 0Ah
  mov [edi], al
  inc edi
  mov al, 0
  mov [edi], al


  mov edx, esp
  call WriteString

  ; write the castling info
  mov ecx, 4
  mov esi, OFFSET fen+65
  add esp, 81
  mov edi, esp
  rep movsb
  mov ax, 0D0Ah
  mov [edi], ax
  add edi, 2
  mov al, 0
  mov [edi], al
  mov edx, esp
  call WriteString

  ; write the en passant info
  mov esi, OFFSET fen+69
  mov eax, [esi]
  and eax, 0A0Dffffh
  .IF ax == 0000h
    or eax, 0A0D3030h
  .ELSE
    or eax, 0A0D0000h
    mov bh, ah
    mov ah, al
    mov al, bh
  .ENDIF
  add esp, 6
  mov edi, esp
  mov [edi], eax
  add edi, 4
  mov al, 0
  mov [edi], al
  mov edx, esp
  call WriteString

  ; write the half move clock info

  ; write the full move clock info



  mov esp, ebp
  pop ebp
  ret

printInfo ENDP

fenReverse PROC
  
  push ebp
  mov ebp, esp
  sub esp, 64

  mov ecx, 64
  mov esi, OFFSET fen+1
  mov edi, esp
  add esi, ecx
  sub esi, 1
L1:
  std
  lodsb
  cld
  stosb
  loop L1
  
  mov ecx, 64
  mov esi, esp
  mov edi, OFFSET fen+1
  rep movsb

  mov cl, board_view
  xor cl, 01h
  mov board_view, cl

  mov esp, ebp
  pop ebp
  
  ret

fenReverse ENDP

drawScreen PROC USES eax ebx,
  tileheight:BYTE

  LOCAL windowSize:SMALL_RECT,
    bufferSize:COORD,
    nHandle:DWORD, x:BYTE, y:BYTE, tilewidth:BYTE
  movzx eax, tileheight
  shl al, 5
  movzx ebx, tileHeight
  shl bl, 3
  add bl, 8
  mov windowSize.Left, 0
  mov windowSize.Top, 0
  dec al
  dec bl
  mov windowSize.Right, ax
  mov windowSize.Bottom, bx
  inc al
  inc bl
  mov bufferSize.X, ax
  mov bufferSize.Y, bx
  invoke GetStdHandle, STD_OUTPUT_HANDLE
  mov nHandle, eax
  lea ebx, windowSize
  invoke SetConsoleScreenBufferSize, nHandle, bufferSize
  invoke SetConsoleWindowInfo, nHandle, TRUE, ebx
  invoke SetConsoleScreenBufferSize, nHandle, bufferSize
  invoke GetLastError
  mov al, tileheight
  shl al, 1
  mov bl, tileheight
  mov cl, tileheight
  shl cl, 3
  dec cl
  mov dl, tileheight
  shl dl, 3
  add dl, 3
  mov x, cl
  mov y, dl
  mov tilewidth, al
  invoke drawCheckerBoard,
    board_view, white + white * 16, gray + gray * 16,
    tilewidth, tileheight, 8, x, y
  invoke drawPieces, yellow, black, black, yellow, white, gray, x, y
  ;invoke drawPieces, white, black, black, white, yellow, gray, x, y
  invoke writeBottomRow, tilewidth, x, y
  invoke writeLeftColumn, tileheight, x, y

  mov al, tileheight
  shl al, 3
  add al, 7
  mov dh, al
  mov dl, 0
  call Gotoxy
  ;call Waitmsg
  
  call printInfo

quit:
  ret

drawScreen ENDP

writeBottomRow PROC,
  tilewidth:BYTE, x:BYTE, y:BYTE
  mov esi, OFFSET BOTTOM_ROW
  .IF board_view == 0
    add esi, 7
  .ENDIF
  mov ecx, 8
  mov dh, y
  ;add dh, BYTE PTR tileheight
  inc dh
  mov al, tilewidth
  shr al, 1
  add al, x
  mov dl, al
  dec dl
L1:
  call Gotoxy
  mov al, [esi]
  call WriteChar
  add dl, tilewidth
  .IF board_view == 0
    dec esi
  .ELSE
    inc esi
  .ENDIF
  loop L1

  ret
writeBottomRow ENDP

writeLeftColumn PROC,
  tileheight:BYTE, x:BYTE, y:BYTE
  mov esi, OFFSET LEFT_COLUMN
  .IF board_view == 0
    add esi, 7
  .ENDIF
  mov ecx, 8
  mov dl, x
  dec dl
  mov al, tileheight
  shr al, 1
  add al, y
  mov dh, al
  sub dh, tileheight
  inc dh
L1:
  call Gotoxy
  mov al, [esi]
  call WriteChar
  sub dh, tileheight
  .IF board_view == 0
    dec esi
  .ELSE
    inc esi
  .ENDIF
  loop L1

  ret
writeLeftColumn ENDP

drawPieces PROC USES edx ecx ebx eax,
   whitePieceColor:BYTE, whiteBorderColor:BYTE, blackPieceColor:BYTE, blackBorderColor:BYTE, whiteTileColor:BYTE, blackTileColor:BYTE, x:BYTE, y:BYTE

  LOCAL tileColor:BYTE
  mov tileColor, 1
  mov al, board_view
  xor tileColor, al
  mov dh, y
  mov dl, x
  inc dl
  inc dl
  ;sub dh, 6
  mov ecx, 8
  mov eax, 0
L1:
  push ecx
  mov ecx, 8
L2:
  mov bl, fen[eax+1]
  .IF bl == 'p'
    push eax
    .IF tileColor == 0
      invoke drawPawn, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawPawn, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'P'
    push eax
    .IF tileColor == 0
      invoke drawPawn, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawPawn, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

  .ELSEIF bl == 'r'
    push eax
    .IF tileColor == 0
      invoke drawRook, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawRook, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'R'
    push eax
    .IF tileColor == 0
      invoke drawRook, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawRook, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

    .ELSEIF bl == 'n'
    push eax
    .IF tileColor == 0
      invoke drawKnight, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawKnight, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'N'
    push eax
    .IF tileColor == 0
      invoke drawKnight, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawKnight, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

    .ELSEIF bl == 'b'
    push eax
    .IF tileColor == 0
      invoke drawBishop, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawBishop, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'B'
    push eax
    .IF tileColor == 0
      invoke drawBishop, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawBishop, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

    .ELSEIF bl == 'q'
    push eax
    .IF tileColor == 0
      invoke drawQueen, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawQueen, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'Q'
    push eax
    .IF tileColor == 0
      invoke drawQueen, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawQueen, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

    .ELSEIF bl == 'k'
    push eax
    .IF tileColor == 0
      invoke drawKing, whitePieceColor, whiteBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawKing, whitePieceColor, whiteBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax
  .ELSEIF bl == 'K'
    push eax
    .IF tileColor == 0
      invoke drawKing, blackPieceColor, blackBorderColor, blackTileColor, dl, dh
    .ELSE
      invoke drawKing, blackPieceColor, blackBorderColor, whiteTileColor, dl, dh
    .ENDIF
    pop eax

  .ENDIF
  add dl, 12
  inc eax
  xor tileColor, 01h
  dec ecx
  cmp ecx, 0
  jnz L2
  mov dl, x
  inc dl
  inc dl
  sub dh, 6
  pop ecx
  xor tileColor, 01h
  dec ecx
  cmp ecx, 0
  jnz L1

  
;  mov ecx, 8
;L1:
;  invoke drawPawn, yellow, green, white, dl, dh
;  sub dh, 6*5
;  invoke drawPawn, black, yellow, green, dl, dh
;  add dh, 6*5
;  add dl, 12
;  loop L1
  
  ret

drawPieces ENDP

drawRook PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE

  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD

  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  dec dl
  invoke drawStraightLine,
    borderback, 10, 1, dl, dh, HALF_BLOCK_UPPER

  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  add dl, 9
  call Gotoxy
  call WriteChar

  sub dl, 8
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  add dl, 7
  call Gotoxy
  call WriteChar

  sub dl, 6
  invoke drawStraightLine,
    fillback, 6, 1, dl, dh, FULL_BLOCK

  push ecx
  mov ecx, 2
L1:
  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  add dl, 5
  call Gotoxy
  call WriteChar
  sub dl, 4
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  dec dl
  loop L1
  pop ecx

  dec dh
  dec dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  add dl, 7
  call Gotoxy
  call WriteChar
  dec dl
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  sub dl, 5
  call Gotoxy
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  add dl, 3
  call Gotoxy
  call WriteChar
  sub dl, 2
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK

  push ecx
  mov ecx, 3
  sub dl, 3
  dec dh
L2:
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER
  add dl, 3
  loop L2
  pop ecx

  
  mov eax, white+black*16
  call SetTextColor
  ret

drawRook ENDP

drawKnight PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE

  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD

  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  invoke drawStraightLine,
    borderback, 6, 1, dl, dh, HALF_BLOCK_UPPER

  dec dh
  dec dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  add dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  dec dh
  sub dl, 6
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  add dl, 4
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  sub dl, 3
  invoke drawStraightLine,
    fillback, 3, 1, dl, dh, FULL_BLOCK
  add dl, 4
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_UPPER
  add dl, 2
  invoke drawStraightLine,
    borderfill, 2, 1, dl, dh, HALF_BLOCK_LOWER
  add dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar

  dec dh
  sub dl, 9
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK
  add dl, 2
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK
  add dl, 2
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  sub dl, 8
  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    borderfill, 2, 1, dl, dh, HALF_BLOCK_UPPER
  add dl, 2
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK
  add dl, 2
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  sub dl, 3
  dec dh
  invoke drawStraightLine,
    borderback, 3, 1, dl, dh, HALF_BLOCK_LOWER
  
  mov eax, white+black*16
  call SetTextColor
  ret

drawKnight ENDP

drawBishop PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE
  
  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD

  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  invoke drawStraightLine,
    borderback, 8, 1, dl, dh, HALF_BLOCK_UPPER

  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  add dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  dec dh
  sub dl, 8
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 6, 1, dl, dh, FULL_BLOCK
  add dl, 6
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar

  dec dh
  sub dl, 8
  call Gotoxy
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 3, 1, dl, dh, FULL_BLOCK
  add dl, 3
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar

  dec dh
  sub dl, 7
  call Gotoxy
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  add dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  
  dec dh
  sub dl, 4
  invoke drawStraightLine,
    borderback, 3, 1, dl, dh, HALF_BLOCK_LOWER


  mov eax, white+black*16
  call SetTextColor
  ret

drawBishop ENDP

drawQueen PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE

  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD
  
  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  invoke drawStraightLine,
    borderback, 8, 1, dl, dh, HALF_BLOCK_UPPER

  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  add dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  dec dh
  sub dl, 7
  call Gotoxy
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  add dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar

  dec dh
  sub dl, 8
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    borderfill, 2, 1, dl, dh, HALF_BLOCK_UPPER
  add dl, 2
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER
  add dl, 2
  invoke drawStraightLine,
    borderfill, 2, 1, dl, dh, HALF_BLOCK_UPPER
  add dl, 2
  call Gotoxy
  mov eax, fillback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar

  dec dh
  sub dl, 8
  call Gotoxy
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  add dl, 2
  call Gotoxy
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    borderfill, 2, 1, dl, dh, HALF_BLOCK_LOWER
  add dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  add dl, 2
  call Gotoxy
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  dec dh
  sub dl, 4
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER
  
  mov eax, white+black*16
  call SetTextColor
  ret

drawQueen ENDP

drawKing PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE

  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD
  
  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  inc dl
  invoke drawStraightLine,
    borderback, 6, 1, dl, dh, HALF_BLOCK_UPPER
  
  dec dh
  dec dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK
  add dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar

  dec dh
  sub dl, 8
  call Gotoxy
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 8, 1, dl, dh, FULL_BLOCK
  add dl, 8
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar

  dec dh
  sub dl, 8
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER
  add dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK
  add dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  inc dl
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER

  dec dh
  sub dl, 5
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK
  add dl, 2
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  inc dl
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar

  dec dh
  sub dl, 3
  invoke drawStraightLine,
    borderback, 2, 1, dl, dh, HALF_BLOCK_LOWER

  
  mov eax, white+black*16
  call SetTextColor
  ret

drawKing ENDP

drawPawn PROC USES eax edx,
  color:BYTE, borderColor:BYTE, backgroundColor:BYTE, x:BYTE, y:BYTE

  LOCAL borderfill:DWORD, borderback:DWORD, fillback:DWORD
  
  movzx ebx, color
  shl bl, 4
  add bl, borderColor
  mov borderfill, ebx
  
  movzx ebx, backgroundColor
  shl bl, 4
  add bl, color
  mov fillback, ebx
  
  sub bl, color
  add bl, borderColor
  mov borderback, ebx

  mov dh, y
  mov dl, x
  invoke drawStraightLine,
    borderback, 8, 1, dl, dh, HALF_BLOCK_UPPER
  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, FULL_BLOCK
  call WriteChar
  add dl, 7
  call Gotoxy
  call WriteChar

  sub dl, 6
  invoke drawStraightLine,
    fillback, 6, 1, dl, dh, FULL_BLOCK
  
  dec dh
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  add dl, 5
  call Gotoxy
  call WriteChar

  sub dl, 4
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  add dl, 3
  call Gotoxy
  call WriteChar

  sub dl, 2
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK

  dec dl
  dec dh
  call Gotoxy
  mov eax, borderfill
  call SetTextColor
  mov al, HALF_BLOCK_LOWER
  call WriteChar
  add dl, 3
  call Gotoxy
  call WriteChar

  sub dl, 2
  invoke drawStraightLine,
    fillback, 2, 1, dl, dh, FULL_BLOCK

  sub dl, 2
  call Gotoxy
  mov eax, borderback
  call SetTextColor
  mov al, HALF_BLOCK_UPPER
  call WriteChar
  add dl, 5
  call Gotoxy
  call WriteChar

  sub dl, 5
  dec dh
  call Gotoxy
  mov al, FULL_BLOCK
  call WriteChar
  add dl, 5
  call Gotoxy
  call WriteChar

  sub dl, 4
  invoke drawStraightLine,
    fillback, 4, 1, dl, dh, FULL_BLOCK

  dec dh
  invoke drawStraightLine,
    borderback, 4, 1, dl, dh, HALF_BLOCK_LOWER

  mov eax, white+black*16
  call SetTextColor
  ret

drawPawn ENDP

; white -> eax = 1
; black -> eax = 0
; not a piece -> eax = 2
isWhite MACRO piece

  .IF piece > 60h && piece < 7Bh
    mov eax, 1
  .ELSEIF piece > 40h && piece < 5Bh
    mov eax, 0
  .ELSE
    mov eax, 2
  .ENDIF

ENDM

; position stored in eax
fenPos MACRO pos
  push ebx
  .IF board_view == 1
      mov bx, pos
    .IF bh > 60h
      sub bh, 61h
    .ELSE
      sub bh, 41h
    .ENDIF
    sub bl, 31h
    movzx eax, bl
    shl eax, 3
    movzx ebx, bh
    add eax, ebx

  .ELSE
      mov bx, pos
    .IF bh > 60h
      mov al, 68h
      sub al, bh
      mov bh, al
    .ELSE
      mov al, 48h
      sub al, bh
      mov bh, al
    .ENDIF
    mov al, 38h
    sub al, bl
    movzx eax, al
    shl eax, 3
    movzx ebx, bh
    add eax, ebx
  .ENDIF

  pop ebx
ENDM

setEnpassant MACRO pos

  push eax
  push ebx
  mov eax, OFFSET fen
  add eax, 69
  mov bx, pos
  mov [eax], bx
  pop ebx
  pop eax

ENDM

changePlayer MACRO
  push eax
  push ebx
  call fenReverse ; flip board on move
  mov al, [fen]
  xor al, 01h
  mov ebx, OFFSET fen
  mov [ebx], al
  pop ebx
  pop eax
ENDM

; al = abs value
absb_sub MACRO r1, r2
  push ebx
  push ecx
  mov al, r1
  mov bl, r2
  sub al, bl
  pushf
  pop cx
  and cl, 10000000b
  .IF cl == 80h
    neg al
  .ENDIF
  pop ecx
  pop ebx
ENDM

; eax = 1 if negative, 0 if not
isnegativeb_sub MACRO r1, r2
  push ebx
  push ecx
  mov al, r1
  mov bl, r2
  sub al, bl
  pushf
  pop cx
  and cl, 10000000b
  .IF cl == 80h
    mov eax, 1
  .ELSE
    mov eax, 0
  .ENDIF
  pop ecx
  pop ebx
ENDM

; al = piece
mGetPiece MACRO pos
  fenPos(pos)
  movzx eax, fen[eax+1]
ENDM

movePiece PROC USES eax ebx ecx,
  from:WORD, to:WORD
  ; example: from = E2, to = E4
  LOCAL piece1:BYTE, piece2:BYTE
  lea eax, piece1
  invoke getPiece, from, eax
  mov bl, piece1
  lea eax, piece2
  invoke getPiece, to, eax
  mov piece1, bl
  isWhite(piece1)
  .IF [fen] == 0 && eax == 1
    jmp quit
  .ELSEIF [fen] == 1 && eax == 0
    jmp quit
  .ENDIF
  
  .IF piece1 == 'p' ; white pawn
    mov ax, from
    mov bx, to
    mov cx, bx
    sub cx, ax
    .IF al == '2' && bl == '4' && ah == bh ; double forward
      push ecx
      mov cl, piece1
      push eax
      push ebx
      dec bl
      lea eax, piece1
      invoke getPiece, bx, eax
      pop ebx
      pop eax
      .IF piece1 == '1' && piece2 == '1'
        invoke setPiece, to, 'p'
        invoke setPiece, from, '1'
        push ebx
        dec bl
        setEnpassant(bx)
        pop ebx
        pop ecx
        jmp valid_move
      .ENDIF
      mov piece1, cl
      pop ecx
    .ELSEIF cl == 1 || cl == 0FFh
      .IF ch == 0 ; same col (forward)
        .IF piece2 == '1'
          invoke setPiece, to, 'p'
          invoke setPiece, from, '1'
          setEnpassant(00h)
          jmp valid_move
        .ENDIF
      .ELSEIF ch == 1 || ch == 0FFh ; diagonal forward
        push eax
        push ebx
        mov bx, WORD PTR fen[69]
        isWhite(piece2)
        .IF eax == 0 ; white
          invoke setPiece, to, 'p'
          invoke setPiece, from, '1'
          setEnpassant(00h)
          jmp valid_move
        .ELSEIF to == bx ; enpassant square
          invoke setPiece, to, 'p'
          push ecx
          push ebx
          mov cl, piece2
          mov bx, to
          dec bx
          invoke setPiece, bx, '1' ; not working - todo check and debug
          invoke setPiece, from, '1'
          mov piece2, cl
          pop ebx
          pop ecx
          pop ebx
          pop eax
          setEnpassant(00h)
          jmp valid_move
        .ENDIF
        pop ebx
        pop eax
      .ENDIF
    .ENDIF

  .ELSEIF piece1 == 'P' ; black pawn
    mov ax, from
    mov bx, to
    mov cx, ax
    sub cx, bx
    .IF al == '7' && bl == '5' && ah == bh ; double forward
      push ecx
      mov cl, piece1
      push eax
      push ebx
      inc bl
      lea eax, piece1
      invoke getPiece, bx, eax
      pop ebx
      pop eax
      .IF piece1 == '1' && piece2 == '1'
        invoke setPiece, to, 'P'
        invoke setPiece, from, '1'
        push ebx
        inc bl
        setEnpassant(bx)
        pop ebx
        pop ecx
        jmp valid_move
      .ENDIF
      mov piece1, cl
      pop ecx
    .ELSEIF cl == 1 || cl == 0FFh
      .IF ch == 0 ; same col (forward)
        .IF piece2 == '1'
          invoke setPiece, to, 'P'
          invoke setPiece, from, '1'
          setEnpassant(00h)
          jmp valid_move
        .ENDIF
      .ELSEIF ch == 1 || ch == 0FFh ; diagonal forward
        push eax
        push ebx
        mov bx, WORD PTR fen[69]
        isWhite(piece2)
        .IF eax == 1 ; black
          invoke setPiece, to, 'P'
          invoke setPiece, from, '1'
          setEnpassant(00h)
          jmp valid_move
        .ELSEIF to == bx ; enpassant square
          invoke setPiece, to, 'P'
          push ecx
          push ebx
          mov cl, piece2
          mov bx, to
          inc bx
          invoke setPiece, bx, '1'
          invoke setPiece, from, '1'
          mov piece2, cl
          pop ebx
          pop ecx
          pop ebx
          pop eax
          setEnpassant(00h)
          jmp valid_move
        .ENDIF
        pop ebx
        pop eax
      .ENDIF
    .ENDIF

  .ELSEIF piece1 == 'B' || piece1 == 'b'
    mov ax, from
    mov bx, to
    absb_sub ah, bh
    push eax
    mov ax, from
    absb_sub al, bl
    mov bl, al
    pop eax
    .IF al == bl ; diagonal
      ; loop through to check if pieces in front
      ; loop while pieces in front at '1'
      ; if there is a piece in front that is not '1' then quit (no move)
      ; when outside loop then can move freely (move)
      ; if fromPos.col - toPos.col < 0 (negative) then it is going right
      ; if fromPos.col - toPos.col > 0 (positive) then it is going to left
      ; if fromPos.row - toPos.row < 0 (negative) then it is going up
      ; if fromPos.row - toPos.row > 0 (positive) then it is going down
      mov ax, from
      mov bx, to
      isnegativeb_sub ah, bh
      push eax
      mov ax, from
      isnegativeb_sub al, bl
      mov ebx, eax
      pop eax
      mov cx, from
      mov dx, to
    L1:
      .IF eax == 1 ; right
        .IF ebx == 1 ; up
          ; get piece at right up
          inc ch
          inc cl
        .ELSE ; down
          inc ch
          dec cl
        .ENDIF
      .ELSE ; left
        .IF ebx == 1 ; up
          ; get piece at right up
          dec ch
          inc cl
        .ELSE ; down
          dec ch
          dec cl
        .ENDIF
      .ENDIF
      push eax
      mGetPiece cx
      ; if color at pos is equal to piece color: quit
      push eax
      push ebx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; if color is same: quit
        jmp quit
      .ELSEIF ebx != 2 && cx != dx ; if piece is not same color and piece is not blank and not at end
        jmp quit
      .ENDIF
      pop ebx
      pop eax

      pop eax
      .IF cx == dx
        invoke setPiece, to, piece1
        invoke setPiece, from, '1'
        setEnpassant(00h)
        jmp valid_move
      .ENDIF
      jmp L1

    .ENDIF

  .ELSEIF piece1 == 'R' || piece1 == 'r'
    mov ax, from
    mov bx, to
    .IF ah == bh && al != bl; up or down
      isnegativeb_sub al, bl
      mov cx, from
      mov dx, to
    L2:
      .IF eax == 1 ; up
        inc cl
      .ELSE ; down
        dec cl
      .ENDIF
      push eax
      mGetPiece cx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; same color as piece 1
        jmp quit
      .ELSEIF ebx != 2 && cx != dx
        jmp quit
      .ENDIF

      .IF cx == dx
         invoke setPiece, to, piece1
         invoke setPiece, from, '1'
         setEnpassant(00h)
         isWhite ax
         mov esi, OFFSET fen
         .IF al == 1 ; white
           add esi, 67
         .ELSE ; black
           add esi, 65
         .ENDIF
         mov ax, from
         .IF ah == 'A' ; if rook is on A file, queen side castling is disabled for whichever color piece
            inc esi
            mov al, 30h
            mov [esi], al
         .ELSEIF ah == 'H' ; if rook is on H file, king side castling is disabled for whichever color piece
            mov al, 30h
            mov [esi], al
         .ENDIF
         jmp valid_move
      .ENDIF
      pop eax
      jmp L2

    .ELSEIF al == bl && ah != bh ; right or left
      isnegativeb_sub ah, bh
      mov cx, from
      mov dx, to
    L3:
      .IF eax == 1 ; right
        inc ch
      .ELSE ; left
        dec ch
      .ENDIF
      push eax
      mGetPiece cx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; same color as piece 1
        jmp quit
      .ELSEIF ebx != 2 && cx != dx
        jmp quit
      .ENDIF

      .IF cx == dx
         invoke setPiece, to, piece1
         invoke setPiece, from, '1'
         setEnpassant(00h)
         isWhite ax
         mov esi, OFFSET fen
         .IF al == 1 ; white
           add esi, 67
         .ELSE ; black
           add esi, 65
         .ENDIF
         mov ax, from
         .IF ah == 'A' ; if rook is on A file, queen side castling is disabled for whichever color piece
            inc esi
            mov al, 30h
            mov [esi], al
         .ELSEIF ah == 'H' ; if rook is on H file, king side castling is disabled for whichever color piece
            mov al, 30h
            mov [esi], al
         .ENDIF
         jmp valid_move
      .ENDIF
      pop eax
      jmp L3
    .ENDIF
  
  .ELSEIF piece1 == 'Q' || piece1 == 'q'
    mov ax, from
    mov bx, to
    absb_sub ah, bh
    push eax
    mov ax, from
    absb_sub al, bl
    mov dl, al
    pop ecx

    mov ax, from
    mov bx, to
    .IF ah == bh && al != bl; up or down
      isnegativeb_sub al, bl
      mov cx, from
      mov dx, to
    L4:
      .IF eax == 1 ; up
        inc cl
      .ELSE ; down
        dec cl
      .ENDIF
      push eax
      mGetPiece cx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; same color as piece 1
        jmp quit
      .ELSEIF ebx != 2 && cx != dx
        jmp quit
      .ENDIF

      .IF cx == dx
         invoke setPiece, to, piece1
         invoke setPiece, from, '1'
         setEnpassant(00h)
         jmp valid_move
      .ENDIF
      pop eax
      jmp L4

    .ELSEIF al == bl && ah != bh ; right or left
      isnegativeb_sub ah, bh
      mov cx, from
      mov dx, to
    L5:
      .IF eax == 1 ; right
        inc ch
      .ELSE ; left
        dec ch
      .ENDIF
      push eax
      mGetPiece cx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; same color as piece 1
        jmp quit
      .ELSEIF ebx != 2 && cx != dx
        jmp quit
      .ENDIF

      .IF cx == dx
         invoke setPiece, to, piece1
         invoke setPiece, from, '1'
         setEnpassant(00h)
         jmp valid_move
      .ENDIF
      pop eax
      jmp L5

    .ELSEIF cl == dl ; diagonal
      ; loop through to check if pieces in front
      ; loop while pieces in front at '1'
      ; if there is a piece in front that is not '1' then quit (no move)
      ; when outside loop then can move freely (move)
      ; if fromPos.col - toPos.col < 0 (negative) then it is going right
      ; if fromPos.col - toPos.col > 0 (positive) then it is going to left
      ; if fromPos.row - toPos.row < 0 (negative) then it is going up
      ; if fromPos.row - toPos.row > 0 (positive) then it is going down
      mov ax, from
      mov bx, to
      isnegativeb_sub ah, bh
      push eax
      mov ax, from
      isnegativeb_sub al, bl
      mov ebx, eax
      pop eax
      mov cx, from
      mov dx, to
    L6:
      .IF eax == 1 ; right
        .IF ebx == 1 ; up
          ; get piece at right up
          inc ch
          inc cl
        .ELSE ; down
          inc ch
          dec cl
        .ENDIF
      .ELSE ; left
        .IF ebx == 1 ; up
          ; get piece at right up
          dec ch
          inc cl
        .ELSE ; down
          dec ch
          dec cl
        .ENDIF
      .ENDIF
      push eax
      mGetPiece cx
      ; if color at pos is equal to piece color: quit
      push eax
      push ebx
      isWhite al
      mov ebx, eax
      isWhite piece1
      .IF eax == ebx ; if color is same: quit
        jmp quit
      .ELSEIF ebx != 2 && cx != dx ; if piece is not same color and piece is not blank and not at end
        jmp quit
      .ENDIF
      pop ebx
      pop eax

      pop eax
      .IF cx == dx
        invoke setPiece, to, piece1
        invoke setPiece, from, '1'
        setEnpassant(00h)
        jmp valid_move
      .ENDIF
      jmp L6

    .ENDIF
  
  .ELSEIF piece1 == 'n' || piece1 == 'N'
    mov bx, from
    add bx, 102h
    cmp bx, to
    jne upper_left
    jmp end_if
  upper_left:
    sub bx, 200h
    cmp bx, to
    jne lower_left
    jmp end_if
  lower_left:
    sub bx, 4
    cmp bx, to
    jne lower_right
    jmp end_if
  lower_right:
    add bx, 200h
    cmp bx, to
    jne left_upper
    jmp end_if
  left_upper:
    add bx, 103h
    cmp bx, to
    jne left_lower
    jmp end_if
  left_lower:
    sub bx, 400h
    cmp bx, to
    jne right_upper
    jmp end_if
  right_upper:
    sub bx, 2
    cmp bx, to
    jne right_lower
    jmp end_if
  right_lower:
    add bx, 400
    cmp bx, to
    jne quit
    jmp end_if
  end_if:
    invoke setPiece, to, piece1
    invoke setPiece, from, '1'
    setEnpassant(00h)
    jmp valid_move
  
  .ELSEIF piece1 == 'K' || piece1 == 'k'
    mov ax, from
    mov bx, to
    absb_sub ah, bh
    push eax
    mov ax, from
    absb_sub al, bl
    mov ebx, eax
    pop eax

    push eax
    push ebx

    isWhite piece1
    mov ecx, eax
    isWhite piece2
    mov edx, eax

    pop ebx
    pop eax
    
     mov esi, OFFSET fen
    .IF cl == 1 ; white piece
      add esi, 67
    .ELSE ; black piece
      add esi, 65
    .ENDIF
    .IF al > 1 ; possible castling
      mov bx, to
      .IF bh == 'G' || bh == 'g' ; king side castling
        ; check to make sure king side castling is allowed
       
        mov al, [esi]
        .IF al == 30h ; castling not allowed
          jmp quit
        .ENDIF

        ; castling is allowed, so determine if there is a correct path there
        dec bh
        mGetPiece bx
        .IF al != '1'
          jmp quit
        .ENDIF
        mov ax, to
        mov ah, 'H'
        push eax
        mGetPiece ax
        invoke setPiece, bx, al
        pop eax
        invoke setPiece, ax, '1'
        invoke setPiece, to, piece1
        invoke setPiece, from, '1'
        setEnpassant(00h)
        mov ax, 3030h
        mov [esi], ax
        jmp valid_move

      .ELSEIF bh == 'C' || bh == 'c' ; queen side castling
        ; check to make sure queen side castlign is allowed
        inc esi
        mov al, [esi]
        .IF al == 30h ; castling not allowed
          jmp quit
        .ENDIF

        ; castling is allowed, so determine if there is a correct path there
        inc bh
        mGetPiece bx
        .IF al != '1'
          jmp quit
        .ENDIF
        mov ax, to
        mov ah, 'A'
        push eax
        mGetPiece ax
        invoke setPiece, bx, al
        pop eax
        invoke setPiece, ax, '1'
        invoke setPiece, to, piece1
        invoke setPiece, from, '1'
        setEnpassant(00h)
        mov ax, 3030h
        mov [esi], ax
        jmp valid_move
      .ENDIF
      jmp quit
    .ELSEIF bl > 1
      jmp quit
    .ELSEIF cl == dl
      jmp quit
    .ENDIF
    invoke setPiece, to, piece1
    invoke setPiece, from, '1'
    setEnpassant(00h)
    mov ax, 3030h
    mov [esi], ax
    jmp valid_move

  .ENDIF
  
quit:
  ret

valid_move:
  changePlayer
  jmp quit

movePiece ENDP

setPiece PROC USES eax ebx,
  pos:WORD, piece:BYTE

  fenPos(pos)
  inc eax
  mov ebx, OFFSET fen
  add eax, ebx
  movzx ebx, piece
  mov [eax], bl

  ret
setPiece ENDP

getPiece PROC USES eax ebx,
  pos:WORD, pPiece:PTR BYTE

  
  fenPos(pos)
  movzx eax, fen[eax+1]
  mov ebx, pPiece
  mov [ebx], eax
  ; example: pos = E2; E = 45h, 45 - 41 = 4; 2 = 1, 1 * 8 + 4 = 12; piece is at pos 12
  ;rnbqkbnr/ppp1pppp/11111111/111p1111/11111111/11111111/PPPPPPPP/RNBQKBNR w KQkq - 0 1
  ret
getPiece ENDP

setCurrentPlayer PROC,
  player:BYTE

  .IF player == TRUE
    ; set player to black
    mov [fen], 0
  .ELSE
    ; set player to white
    mov [fen], 1
  .ENDIF
  ret
setCurrentPlayer ENDP
 
END
