.586
.MODEL FLAT, C

;************************************ SOLUCIÓ BASE *****************************************************

; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C


;Subrutines cridades des de C
public C showCursor, showPlayer, showBoard, moveCursor, moveCursorContinuous, putPiece, CheckAround, CheckLineHVF, CheckLineDS
                         
;Variables utilitzades - declarades en C
extern C row: DWORD, col: DWORD, rowScreen: DWORD, colScreen: DWORD, rowScreenIni: DWORD, colScreenIni: DWORD 
extern C carac: BYTE, tecla: BYTE, colCursor: DWORD, rowCursor: DWORD, player: DWORD, mBoard: BYTE, pos: DWORD, neighbors:DWORD
extern C insert:DWORD, Winner:DWORD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Descripció de les variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
; player:		Variable que indica el jugador al que correspon el torn
; mBoard:		Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:			Índex per a accedir a la matriu mBoard (calculat per calcIndex)
; neighbors:	Indica el nombre de veïns de la casella on està el cursor
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
; rowScreenIni:	Fila de la primera posició de la matriu a la pantalla.
; colScreenIni:	Columna de la primera posició de la matriu a la pantalla.
; insert:		indica si s'ha produït una insert de fitxa al tauler
; Winner;		0:Encara no hi ha guanyador, 1:guanya player 1, 2:guanya player 2, 3: empat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Les subrutines que heu de modificar per la pràctica nivell bàsic son:
; showCursor, showPlayer, showBoard, moveCursor, moveCursorContinuous, calcIndex, CheckAround, putPiece
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO PODEU MODIFICAR AQUESTA RUTINA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
;Ús de la funció:
;Per fer ús de la funció gotoxy cal guardar els valors de rowScreen,colScreen i després fer la crida
;ex:
;  mov [rowScreen],eax	;carrega el valor de eax a la variable "rowScrenn"
;  mov [colScreen],ebx	;carrega el valor de ebx a la variable "colScrenn"
;  call gotoxy			;posicona el cursor a les coodenadres (rowScrenn,colScrenn) de pantalla
;
; Variables utilitzades: 
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO PODEU MODIFICAR AQUESTA RUTINA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
;
;Ús de la funció:
;Per fer ús de la funció printch cal guardar el valor ASCII del caràcter que volem imprimer a pantalla
; a la variable "carac" i després fer la crida a la funció
;ex:
;  mov [carac],al	;guarda el valor del registre al a la variable "carac"
;  call printch		;imprimeix el caracter "carac" a la pantalla a la posició actual del cursor	
;
; Variables utilitzades: 
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATENCIÓ: NO  PODEU MODIFICAR AQUESTA RUTINA. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable tecla.
;
;Ús de la funció:
;Per fer ús de la funció getch cal fer la crida a la funció i després es pot recuperar el valor de
;la tecla pulsada a la variable tecla
;ex:
;  call getch		;captura un caracter de teclat i el guarda a la variable "tecla"
;  mov al,[tecla]	;porta el valor de la variable tecla al registre al
;
; Variables utilitzades: 
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   Push_all

   call getch_C
   mov [tecla],al
 
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la columna indicada per la variable rowCursor, colCursor
; Per mitja de les formules exposades a continuació es converteixen les coordenades del joc (0-9)
; a coordenades de pantalla de la finestra de joc (rowScreen,colScreen).
; Per posicionar el cursor cal cridar la subrutina gotoxy (que es dona feta).
; Aquesta subrutina posiciona el cursor a la posició indicada per les variables
; rowScreen i colScreen. Aquestes variables s’han de calcular per poder cridar gotoxy.
; Per calcular la posició del cursor a pantalla (rowScreen) i (colScreen)
; cal implementar aquestes fórmules:
;
;            rowScreen=rowScreenIni+(rowCursor*2)
;            colScreen=colScreenIni+(colCursor*4)
;
; Variables utilitzades:
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
; rowScreenIni:	Fila de la primera posició de la matriu a la pantalla.
; colScreenIni:	Columna de la primera posició de la matriu a la pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showCursor proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showCursor endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu.
; Calcula l’índex per a accedir a la matriu mBoard en assemblador.
; mBoard[row][col] en C, és [mBoard+pos] en assemblador.
;
;			pos = (row*10 + col ) * TamanyDeDadaEnBytes.
;
; En el nostre cas TamanyDeDadaEnBytes serà 1 perquè mBoard es una matriu de bytes
; i els bytes ocupen una posició de memòria.
; Habitualment les memòries son de 1 byte per dada (8 bits)
;
; Variables utilitzades:
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de a columna on estem realitzant la jugada (0-9)
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp
	;Inici Codi de la pràctica



 	;Fi Codi de la pràctica
	mov esp, ebp
	pop ebp
	ret

calcIndex endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Escriu el valor de cada casella, emmagatzemat a mBoard, en la posició corresponent de pantalla.
; Anirem movent el cursor a cada posició del tauler i cridant la funció gotoxy.
; Mostrarem el valor corresponent de la matriu mBoard en pantalla cridant a la subrutina printch
;
; Per a posicionar el cursor a pantalla cal cridar a la subrutina gotoxy (que es dona feta).
; Aquesta subrutina posiciona el cursor a la posició indicada per les rowScreen i colScreen.
; Per calcular la posició del cursor a pantalla (rowScreen) i (colScreen)
; cal utilitzar aquestes fórmules:
;
;            rowScreen=rowScreenIni+(rowCursor*2)
;            colScreen=colScreenIni+(colCursor*4)
;
; Podem accedir al contingut de cada posició de mBoard[row][col] amb la funció calcIndex que
; retorna "pos", que és l'offset que hem d'utilitzar per descarregar de memòria el contingut de la
; matriu [mBorad+pos] (Cal entendre com es posiciona una matriu a memòria!)
;
; Variables utilitzades:
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
; mBoard:		Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
; rowScreenIni:	Fila de la primera posició de la matriu a la pantalla.
; colScreenIni:	Columna de la primera posició de la matriu a la pantalla.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

showBoard proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina





	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showBoard endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment del cursor a "i" amunt, "k" avall, "j" esquerra, "l" dreta.
; Cridar a la subrutina getch per a llegir una pulsació del teclat a la variable "tecla"
; La rutina accepta les tecles ("i","j","k","l","q","espai") en qualsevol altre cas s'ha de tornar
; a demanar una nova tecla. No sortirem d'aquesta rutina sense una pulsació vàlida.
;	La tecla ‘i’ mou el cursor a amunt, i permet sortir de la rutina.
;	la tecla ‘k’ mou el cursor a avall, i permet sortir de la rutina.
;	la tecla ‘j’ mou el cursor a esquerra, i permet sortir de la rutina.
;	la tecla ‘l’ mou el cursor a dreta, i permet sortir de la rutina.
;	la tecla ‘q’ permet sortir de la rutina.
;	la tecla ‘ ’ permet sortir de la rutina. (i ja es processarà l'event en un altre rutina).
; S’ha de controlar que la nova posició de rowCursor, colCursor no surti de límits del tauler.
; per exemple: si estem a la casella [0,0] i es polsa la tecla "j" (esquerra) no es pot fer el
; moviment, ja que sortiríem del tauler per l'esquerra, i s’ha de tornar a demanar una pulsació vàlida.
; Si pitgem una tecla no vàlida, s’ha de tornar a esperar a una tecla vàlida.
;
; Variables utilitzades:
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp 
	;Inici codi d'alumne de la rutina



	;Fi codi d'alumne de la rutina
   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; S’ha d’anar cridant a la subrutina moveCursor en bucle
; Comprovar que no s'ha seleccionat les tecles ‘ ‘ o 'q'<Quit> (cas en que sortirem de la rutina)
; Si pitgem una tecla no vàlida, s'ha d’esperar a una tecla vàlida.
;
; Variables utilitzades:
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Presenta el número de jugador(1,2) i la fitxa (X,O) a les caselles corresponents
;
;|     Jugador: 1      Fitxa: X   Neighbours:       |
;
; Convertir el valor int de 32 bits de la variable player a un caràcter ascii 
; i el mostra a la posició indicada per rowScreen i colScreen de la pantalla, [29,15]
; Així mateix, s'ha de mostrar el tipus de fitxa del jugador a la posició de la pantalla, [28,28]
;
; Cal cridar a la subrutina gotoxy per a posicionar el cursor a les coordenades [rowScreen,colScreen]
; i a la subrutina printch per a mostrar el caràcter prèviament guardat a la variable "carac".
;
; Variables utilitzades:
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
; player:		Variable que indica el jugador al que correspon el torn
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showPlayer proc
    push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

showPlayer endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta funció suma el nombre de "veïns ocupats" de la posició actual del cursor [rowCursor,colCursor]
; S'ha de sumar el nombre de posicions ocupades al voltant de la posició actual del cursor i guardar
; aquest valor a la variable "neighbors".
; Cal estar alerta, principalment, amb les cel·les del perímetre per no cometre errors d'accés a memòria.
; Una vegada s'ha obtingut el nombre de veïns que té la cel·la s'ha de presentar en pantalla al
; costat de l'etiqueta "Neighbours" [29,44] de la fila de dades de al jugada.
; 
; |     Jugador:       Fitxa:    Neighbours: 8      |    
;
;(Nota: neighbours=8 correspon al cas que totes les posicions al voltat del cursor estan ocupades)
; 
; Aquesta dada es farà servir en la següent tasca per decidir si es pot posar la fitxa, o no, en
; funció del valor de "neighbors", si val zero no es pot fer la inserció, si és diferenet de zero
; es podrà fer la inserció (això es farà a la rutina putPiece)
; 
; Variables utilitzades:
; carac:		Variable on s'emmagatzema el caràcter a imprimir per pantalla
; mBoard:		Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; neighbors:	Indica el nombre de veïns de la casella on està el cursor
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; rowScreen:	Fila on volem posicionar el cursor a la pantalla.
; colScreen:	Columna on volem posicionar el cursor a la pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckAround proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina
	


 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

CheckAround endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situa una fitxa en una posició lliure del tauler de joc si és possible.
; S'ha de crear un bucle de joc on realitzarem la següent seqüència:
;	Mostrar el jugador que té el torn
;	Actualitzar l'estat del tauler de joc
;	Posar la variable "insert" a 0
;	Moviment continu del cursor fins que es polsi "q" o " "
;	Si s'ha polsat "q" sortirem de la rutina
;	Si s'ha polsat " " aleshores avaluarem si la fitxa es pot col·locar a la posició del cursor seleccionada
;		Es podrà col·loca si la casella està lliure (en blanc a mBoard) i té algun veí ocupat (CheckAround).
;		En cas afirmatiu 
;			Col·locar la fitxa del jugador que té el torn
;			Passar el torn a l'altre jugador
;			Posar la variable "insert" a 1 (que usarem en el nivell mig)
;		En cas negatiu no es fa res i es surt de la rutina
;
; La rutina putPiece no és cíclica. Només s'ha d’executar una vegada per col·locar una fitxa i sortir.
; Això és necessari per tal d’aprofitar aquesta rutina en el següent nivell.
; Per tal que es pugui “jugar” de forma repetitiva i, per tant, poder fer proves continues de la rutina
; s’ha implementat la reentrada en el codi C mentre no es polsi la tecla “q” 
;
; Variables utilitzades:
; tecla:		Variable on s'emmagatzema el caràcter llegit del teclat
; player:		Variable que indica el jugador al que correspon el torn
; mBoard:	Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:		Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; neighbors:	Indica el nombre de veïns de la casella on està el cursor
; row:		Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:		Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putPiece proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

putPiece endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Comprova que hi ha un 5 en línia ja sigui horitzontal/vertical o el tauler està ple (full)
; Per iniciar aquesta rutina posarem la variable “Winner” a 0, ja que inicialment considerem que
; no hi ha 5 en línia. A continuació cridarem a la rutina putPiece per fer la inserció una fitxa al tauler
; Si la funció putPiece retorna la variable “insert” a 1, procedirem a comprovar el 5 en línia.
; Es crearà l’algoritme necessari per comprovar si la darrera inserció ha fet que hi hagi 5 en línia
; ja sigui horitzontal o vertical. 
;	En cas afirmatiu actualitzarem la variable “Winner” a 1/2 (en funció del guanyador)
;	En cas negatiu sortirem de la rutina sense actualitzat “Winner”
;Addicionalment comprovarem si el tauler està ple, en aquest cas Winner valdrà 3 (empat) 
;
; La rutina CheckLineHV no és cíclica. Només s'ha d'executar una vegada per comprovar si 
; el darrer moviment a generat un 5 en línia horitzontal o vertical (o tauler ple) i actualitzar la variable “Winner”.
; Això és necessari per tal d’aprofitar aquesta rutina en el següent nivell.
; Per tal que es pugui “jugar” de forma repetitiva i, per tant, poder fer proves continues de la rutina
; s’ha implementat la reentrada en el codi C mentre no es polsi la tecla “q” i “Winner” sigui 0.
;
; Variables utilitzades:
; mBoard:		Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; insert:		Indica si s'ha produït una insert de fitxa al tauler
; Winner:		0:Encara no hi ha guanyador, 1:guanya player 1, 2:guanya player 2, 3: empat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckLineHVF proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

CheckLineHVF endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Comprova que hi ha un 5 en línia en qualsevol direcció
; Crear un bucle de joc, del que només sortirem si Winner=1,2,3 ó tecla='q'
; - Comprovar si Winner a passat a 1,2 ó 3, en aquest cas finalitzarem la rutina
; - Comprovar si tecla passat 'q' en aquest cas finalitzarem la rutina
; - Crida a putPiece per iniciar el joc insertant una fitxa
; - Crida a CheckLineHVF per comprovar si hi ha 5 en línia horitzontal/vertical ço full (fet en el nivell mig)
; - Ara mirem si la variable “insert” és 1 i Winner és 0. En cas afirmatiu procedirem a comprovar diagonals.
;   Es crearà l’algoritme necessari per comprovar si la darrera inserció ha fet que hi hagi 5 en línia
;   diagonal en qualsevol direcció
;	  En cas afirmatiu actualitzarem la variable “Winner” a 1 ó 2 (depen de qui te el torn)
;	  En cas negatiu seguirem sense actualitzat “Winner” (Winner=0)
;
; La rutina CheckLineDS SI és cíclica, i només sortirem si Winner=1,2,3 o tecla='q'.
; En sortir de la rutina el programa en C avaluarà si Winner és 1,2,3 i posa el missatge de Victoria.
;
; Variables utilitzades:
; mBoard:		Matriu de 10x10 enters que conté l'estat del tauler de joc
; pos:			Índex per a accedir a la matriu mBoard (resultat de calcIndex)
; row:			Valor numèric de la fila on estem realitzant la jugada (0-9)
; col:			Valor numèric de la columna on estem realitzant la jugada (0-9)
; rowCursor:	Valor numèric de la fila on volem posar el cursor (0-9)
; colCursor:	Valor numèric de la columna on volem posar el cursor (0-9)
; insert:		Indica si s'ha produït una insert de fitxa al tauler
; Winner:		0:Encara no hi ha guanyador, 1:guanya player 1, 2:guanya player 2, 3: empat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckLineDS proc
	push ebp
	mov  ebp, esp
	;Inici codi d'alumne de la rutina



 	;Fi codi d'alumne de la rutina
	mov esp, ebp
	pop ebp
	ret

CheckLineDS endp


END