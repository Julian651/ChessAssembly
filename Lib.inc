INCLUDE Irvine32.inc
;OPTION PROC:PRIVATE

;================================================================================

drawStraightLine PROTO,
  color:DWORD,  ; color of the line
  len:DWORD,    ; length of the line
  dir:BYTE,     ; direction to draw (0 to draw up, 1 to draw right)
  x:BYTE,       ; x position to start drawing
  y:BYTE,        ; y position to start drawing
  char:BYTE

;================================================================================

drawSquare PROTO,
  color:DWORD,  ; color of the square
  sidelen:DWORD,; side length of square
  x:BYTE,       ; x position to start drawing
  y:BYTE        ; y position to start drawing

;================================================================================

fillSquare PROTO,
  color:DWORD,  ; color of the square
  sidelen:DWORD,; side length of square
  x:BYTE,       ; x position to start drawing
  y:BYTE        ; y position to start drawing

;================================================================================

drawRect PROTO,
  color:DWORD,    ; color of the rectangle
  widthlen:DWORD, ; width length of rectangle
  heightlen:DWORD,; height length of rectangle
  x:BYTE,         ; x position to start drawing
  y:BYTE          ; y position to start drawing

;================================================================================

fillRect PROTO,
  color:DWORD,    ; color of the rectangle
  widthlen:DWORD, ; width length of rectangle
  heightlen:DWORD,; height length of rectangle
  x:BYTE,         ; x position to start drawing
  y:BYTE          ; y position to start drawing

;================================================================================

drawCheckerBoard PROTO,
  viewas:BYTE,     ; 1 for white, 0 for black
  color1:DWORD,   ; first alternating color of board
  color2:DWORD,   ; second alternating color of board
  sqwidth:DWORD,  ; width length of checker tile
  sqheight:DWORD, ; height length of checker tile
  sqaures:DWORD,  ; number of tiles (i.e. 8 means 8x8 board)
  x:BYTE,         ; x position to start drawing
  y:BYTE          ; y position to start drawing

printInfo PROTO
fenReverse PROTO

drawScreen PROTO,
  tileheight:BYTE

drawPawn PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE

drawRook PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE

drawKnight PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE
  
drawBishop PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE

drawQueen PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE

drawKing PROTO,
  color:BYTE,
  borderColor:BYTE,
  backgroundColor:BYTE,
  x:BYTE,
  y:BYTE

drawPieces PROTO,
  whitePieceColor:BYTE,
  whiteBorderColor:BYTE,
  blackPieceColor:BYTE,
  blackBorderColor:BYTE,
  whiteTileColor:BYTE,
  blackTileColor:BYTE,
  x:BYTE,
  y:BYTE

getPiece PROTO,
  pos:WORD,
  pPiece:PTR BYTE

movePiece PROTO,
  from:WORD,
  to:WORD

setPiece PROTO,
  pos:WORD,
  piece:BYTE

writeBottomRow PROTO,
  tilewidth:BYTE,
  x:BYTE,
  y:BYTE
 
writeLeftColumn PROTO,
  tileheight:BYTE,
  x:BYTE,
  y:BYTE