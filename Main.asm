INCLUDE Lib.inc
.data
.code

main PROC PUBLIC
  mov eax, white + white * 16
  mov ebx, green + green * 16
  invoke drawCheckerBoard,
    eax, ebx, 6, 3, 8, 30, 25
  mov dx, 1c00h
  call Gotoxy
  call Waitmsg
  exit
main ENDP
END main