INCLUDE Lib.inc
.data
MAX = 80
buffer BYTE MAX+1 DUP(0),0
MENU_STRING BYTE "Enter a command from the list of commands:",0Dh,0Ah,0
MENU_ITEMS_STRING BYTE "Move, FlipBoard, Exit",0Dh,0Ah,0
MOVE_COMMAND BYTE "Move",0
MOVE_COMMAND_FROM BYTE "Move - Enter from position in the form",0Dh,0Ah,"[colNum][rowNum] (i.e. E2): ",0
MOVE_COMMAND_TO BYTE "Move - Enter to position in the form",0Dh,0Ah,"[colNum][rowNum] (i.e. E4): ",0
FLIP_COMMAND BYTE "FlipBoard",0
EXIT_COMMAND BYTE "Exit",0
csbi CONSOLE_SCREEN_BUFFER_INFO<>
.code
main PROC PUBLIC
  ;call printInfo
  ;invoke drawScreen, 1, 6
  ;call fenReverse

  ; Enter a command from the list of commands:
  ; Move, FlipBoard, 
  ; example;;;; user enters move
  ; Move - Enter from position
  ; ;;;;user enters
  ; Move - Enter to position
  ; game loop
game_loop:
  call Clrscr
  invoke drawScreen, 6
  mov edx, OFFSET MENU_STRING
  call WriteString
  mov edx, OFFSET MENU_ITEMS_STRING
  call WriteString

  mov edx, OFFSET buffer
  mov ecx, MAX
  call ReadString

;start if
  ;if buffer == move
  invoke Str_compare, ADDR buffer, ADDR MOVE_COMMAND
  jne compare_flipboard
  ; then

  mov edx, OFFSET MOVE_COMMAND_FROM
  call WriteString
  mov edx, OFFSET buffer
  mov ecx, 3
  call ReadString
  mov al, [buffer+1]
  mov ah, [buffer]
  push eax
  mov edx, OFFSET MOVE_COMMAND_TO
  call WriteString
  mov edx, OFFSET buffer
  mov ecx, 3
  call ReadString
  mov bl, [buffer+1]
  mov bh, [buffer]
  pop eax
  invoke movePiece, ax, bx
  jmp end_if
  

  ;if buffer == flipboard
compare_flipboard:
  invoke Str_compare, ADDR buffer, ADDR FLIP_COMMAND
  jne compare_exit
  ;then
  call fenReverse
  jmp end_if

  ;if buffer == exit
compare_exit:
  invoke Str_compare, ADDR buffer, ADDR EXIT_COMMAND
  jne end_if
  ;then
  jmp end_game

;end if
end_if:
  jmp game_loop

  
end_game:
  invoke GetStdHandle, STD_OUTPUT_HANDLE
  invoke GetConsoleScreenBufferInfo, eax, OFFSET csbi
  mov dh, BYTE PTR csbi.dwSize.Y
  dec dh
  mov dl, 0
  call Gotoxy
  ;call Waitmsg
  exit
main ENDP
END main