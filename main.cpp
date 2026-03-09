/** Nivell Avançat
* Implementació C de la pràctica.
* Des d'aquest codi es fan les crides a les subrutines d'assemblador que heu de completar.
* ATENCIÓ: Aquest codi és nomès de consulta.
* AQUEST CODI NO ES POT MODIFICAR I NO S'HA DE LLIURAR.
**/
#include <stdio.h>
#include <conio.h>

#include <iostream>
#include <iomanip>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include "globals.h"

extern "C" {
	// Difinició de Subrutines en ASM
	void showCursor();
	void showPlayer();
	void showBoard();
	void moveCursor();
	void moveCursorContinuous();
	void putPiece();
	void CheckAround();
	void CheckLineHVF();
	void CheckLineDS();


	void printChar_C(char c);
	int  clearscreen_C();
	int  printMenu_C();
	int  gotoxy_C(int row_num, int col_num);
	char getch_C();
	int  printBoard_C(int tries);
}

/**
 * Constants.
 **/
#define DIMMATRIX 10
#define PLAYER1 'X'
#define PLAYER2 'O'

 /**
  * Definición de variables globales
  */

char carac,tecla;
int  rowScreenIni = 7;	//Fila inicial del tauler en coordenades de pantalla
int  colScreenIni = 7;	//Columna inicial del tauler en coordenades de pantalla
int  rowScreen;			//Fila en coordenades de pantalla
int  colScreen;			//Columna en coordenades de pantalla
int  rowCursor;			//Fila en que es posiciona el cursor
int  colCursor;			//Columna en que es posiciona el cursor
int  row;				//Fila en coordenades del joc per accedir a la matriu de dades
int  col;				//Columna en coordenades del joc per accedir a la matriu de dades
int  pos;				//És un nombre que representa l'offset necessari per accedir a les dades de mBoard
int  player = 1;		//Indica quin jugador te el torn (1,2). 
						//El juagador 1 fa servir la lletra "X" per jugar
						//El juagador 2 fa servir la lletra "O" per jugar
int  opc;				//Opció del menú escollida
int  neighbors;			//Nombre de veïns d'una posició
int  insert;			//indica si s'ha produït una insert de fitxa al tauler
int  Winner;			//indica si s'ha fet 5 en ratlla


//Mostrar un caràcter
//Quan cridem aquesta funció des d'assemblador el paràmetre s'ha de passar a traves de la pila.
void printChar_C(char c) {
	putchar(c);
}

//Esborrar la pantalla
int clearscreen_C() {
	system("CLS");
	return 0;
}

int migotoxy(int x, int y) { //USHORT x,USHORT y) {
	COORD cp = { y,x };
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cp);
	return 0;
}

//Situar el cursor en una fila i columna de la pantalla
//Quan cridem aquesta funció des d'assemblador els paràmetres (row_num) i (col_num) s'ha de passar a través de la pila
int gotoxy_C(int row_num, int col_num) {
	migotoxy(row_num, col_num);
	return 0;
}


//Imprimir el menú del joc
int printMenu_C() {

	clearscreen_C();
	gotoxy_C(1,1);
	printf("                                 \n");
	printf("  Developed by:                  \n");
	printf("  Nom/Niu 1:                     \n");
	printf("  Nom/Niu 2:                     \n");
	printf(" _______________________________ \n");
	printf("|                               |\n");
	printf("|     MENU 5 IN a ROW  v1.0     |\n");
	printf("|_______________________________|\n");
	printf("|                               |\n");
	printf("|     1.  ShowCursor            |\n");
	printf("|     2.  ShowBoard             |\n");
	printf("|     3.  MoveCursor            |\n");
	printf("|     4.  MoveCursorContinuous  |\n");
	printf("|     5.  ShowPlayer            |\n");
	printf("|     6.  CheckAround           |\n");
	printf("|     7.  PutPiece              |\n");
	printf("|     8.  CheckLine (HV&Full)   |\n");
	printf("|     9.  CheckLine (DS)        |\n");
	printf("|     0.  Exit                  |\n");
	printf("|                               |\n");
	printf("|         OPTION:               |\n");
	printf("|_______________________________|\n");
	return 0;
}


//Llegir una tecla sense espera i sense mostrar-la per pantalla
char getch_C() {
	DWORD mode, old_mode, cc;
	HANDLE h = GetStdHandle(STD_INPUT_HANDLE);
	if (h == NULL) {
		return 0; // console not found
	}
	GetConsoleMode(h, &old_mode);
	mode = old_mode;
	SetConsoleMode(h, mode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT));
	TCHAR c = 0;
	ReadConsole(h, &c, 1, &cc, NULL);
	SetConsoleMode(h, old_mode);

	return c;
}


/**
 * Mostrar el tauler de joc a la pantalla. Les li­nies del tauler.
 * Aquesta funcio es crida des de C i des d'assemblador,
 * i no hi ha definida una subrutina d'assemblador equivalent.
 * No hi ha pas de parametres.
 */
void printBoard_C() {
	int i;

	clearscreen_C();
	gotoxy_C(1, 1);                                                  //ScreenRows   
	printf(" _________________________________________________ \n"); //01
	printf("|                                                 |\n"); //02
	printf("|                 5 IN a ROW                      |\n"); //03
	printf("|    Inserir una fitxa al costat d'una altra      |\n"); //04
	printf("|                                                 |\n"); //05
 //Screen Columns  08  12  16  20  24  28  32  36  40  44   
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //06
	printf("|  0 |   |   |   |   |   |   |   |   |   |   |    |\n"); //07
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //08
	printf("|  1 |   |   |   |   |   |   |   |   |   |   |    |\n"); //09
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //10
	printf("|  2 |   |   |   |   |   |   |   |   |   |   |    |\n"); //11
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //12
	printf("|  3 |   |   |   |   |   |   |   |   |   |   |    |\n"); //13
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //14
	printf("|  4 |   |   |   |   |   |   |   |   |   |   |    |\n"); //15
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //16
	printf("|  5 |   |   |   |   |   |   |   |   |   |   |    |\n"); //17
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //18   
	printf("|  6 |   |   |   |   |   |   |   |   |   |   |    |\n"); //19
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //20
	printf("|  7 |   |   |   |   |   |   |   |   |   |   |    |\n"); //21
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //22
	printf("|  8 |   |   |   |   |   |   |   |   |   |   |    |\n"); //23
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //24
	printf("|  9 |   |   |   |   |   |   |   |   |   |   |    |\n"); //25
	printf("|    +---+---+---+---+---+---+---+---+---+---+    |\n"); //26   
	printf("|      0   1   2   3   4   5   6   7   8   9      |\n"); //27
	printf("|                                                 |\n"); //28
	printf("|     Jugador:       Fitxa:     Neighbours:       |\n"); //29
	printf("|                                                 |\n"); //30
	printf("|     (Q) Quit           (Space) Insert Stone     |\n"); //31
	printf("|     (i) Up   (j) Left  (k) Down   (l) Right     |\n"); //32
	printf("|_________________________________________________|\n"); //33
	printf("|                                                 |\n"); //34
	printf("|                                                 |\n"); //35
	printf("|_________________________________________________|\n"); //36

}

int main(void) {
	opc = 1;

	while (opc != '0') {
		printMenu_C();				//Mostrar menú
		gotoxy_C(21, 17);			//Situar el cursor per la selecció de menú inicial
		opc = getch_C();			//Llegir una opció
		switch (opc) {
		//Opció del Menú --> 1. showCursor   ,posiciona el cursor a l posició 3,3 del tauler
		//Per poder assolir el punt 1 cal implementar la rutina ensamblador: showCursor
		case '1':					
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();			//Mostrar el tauler
			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			getch_C();				//Esperar que es premi una tecla
			break;

		//Opció del Menú --> 2. ShowBoard   ,Mostra el contringur de la matriu de joc al tauler
		case '2':					
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.

			showBoard();			//Presenta el número de jugador a la casella Player

			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;

		//Opció del Menú --> 3. MoveCursor   ,Permet moure el cursor una vegada en qualsevol direcció
		case '3':					
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			showBoard();			//Escriu el valor de cada casella, enmagatzemat a mBoard, en la posició corresponent de pantalla
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			moveCursor();			//Permet moure el cursor UNA vegada en qualsevol direcció
			
			getch_C();				//Captura un caracter per fer una espera i poder veure el moviment únic del cursor	
			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;
		//Opció del Menú --> 4. MoveCursorContinuous   ,Permet moure el cursor repetidament amb l'ajuda de moveCursor
		case '4':					
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			showBoard();			//Escriu el valor de cada casella, enmagatzemat a mBoard, en la posició corresponent de pantalla
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			moveCursorContinuous();	//Subrutina que implementa el moviment continu

			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;
		//Opció del Menú --> 5. ShowPlayer   ,Posiciona la peça del jugador que te el torn
		case '5':					
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			showBoard();			//Escriu el valor de cada casella, enmagatzemat a mBoard, en la posició corresponent de pantalla
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			player = 1;
			showPlayer();			//Subrutina indica quin jugador i tpus de fitxa te el torn

			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;
		//Opció del Menú --> 6. checkAround   ,Comprovar el nombre de veïns que te la posició actual del cursor
		case '6':
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			showBoard();			//Escriu el valor de cada casella, enmagatzemat a mBoard, en la posició corresponent de pantalla
			player = 1;
			showPlayer();			//Subrutina indica quin jugador i tpus de fitxa te el torn
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada


			moveCursorContinuous();	//Subrutina que implementa el moviment continu
			CheckAround();			//Comprovar el nombre de veïns que te la posició actual del cursor
			

			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;
		//Opció del Menú --> 7. PutPiece   ,Posiciona la fitxa del jugador que té el torn, si te alguna fitxa al voltant (adjacent)
		case '7':
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			//Estat inicial de la pulsació a none
			tecla = 'none';			//Inicialment no s'ha polsat cap tecla
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			player = 1;
			while (tecla != 'q') {	//Permet jugar de forma continua mentre no es polsi la 'q'
				putPiece();			//Fa UNA sola jugada i situa UNA fitxa en una posició lliure del tauler de joc
			}

			gotoxy_C(35, 18);		//Situar el cursor a sota del tauler
			printf("Press any key ");
			getch_C();
			break;
		//Opció del Menú --> 8. CheckLine(HV)   , 
		case '8':
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			//Estat inicial de la pulsació a none, i no hi ha 5 en ratlla (winner=0)
			tecla = 'none';			//Inicialment no s'ha polsat cap tecla
			Winner = 0;				//Inicialment no hi ha 5 en ratlla
			player = 1;				//Comença la jugada el player 1
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor

			//Es permet jugar de forma continua mentre no es polsi la 'q' i winner sigui 0
			while ((tecla != 'q') & (Winner == 0)) {
				putPiece();							//Fa UNA sola jugada i situa UNA fitxa en una posició lliure del tauler de joc
				CheckLineHVF();						//Comprova si hi ha 5 en ratlla vertical/horitzontal o el tauler està ple (full)
			}

			gotoxy_C(35, 18);						//Situar el cursor a sota del tauler per posar el missatge de guanyador
			if (Winner == 1) {
				printf("Player 1 Win with X!!");	//Winner igual a 1 indica que ha guanyat el player 1
			}
			else if (Winner == 2) {
				printf("Player 2 Win with O!!");	//Winner igual a 2 indica que ha guanyat el player 2
			}
			else if (Winner == 3) {
				printf("Draw, no winner!!");		//Winner igual a 3 indica que el tauler està ple i no ha guanyat ningú, hi ha empat
			}
			else {
				printf("Press any key ");
			}

			getch_C();
			break;
		//Opció del Menú --> 8. CheckLine(DS)   , 
		case '9':
			clearscreen_C();  		//Esborra la pantalla
			printBoard_C();   		//Mostrar el tauler.
			//Estat inicial de la pulsació a none, i no hi ha 5 en ratlla (winner=0)
			tecla = 'none';			//Inicialment no s'ha polsat cap tecla
			Winner = 0;				//Inicialment no hi ha 5 en ratlla
			//La primera posició on apareixarà el cursor és la (3,3)
			rowCursor = 3;			//Fila inicial on volem que aparegui el cursor
			colCursor = 3;			//Columna inicial on volem que aparegui el cursor
			showCursor();			//Posicionar el cursor a la fila i columna indicada

			player = 1;
			CheckLineDS();							//Permet jugar i comprova si hi ha 5 en ratlla vertical/horitzontal i diagonals

			gotoxy_C(35, 18);						//Situar el cursor a sota del tauler per posar el missatge de guanyador
			if (Winner == 1) {
				printf("Player 1 Win with X!!");	//Winner igual a 1 indica que ha guanyat el player 1
			}
			else if (Winner == 2) {
				printf("Player 2 Win with O!!");	//Winner igual a 2 indica que ha guanyat el player 2
			}
			else if (Winner == 3) {
				printf("Draw, no winner!!");		//Winner igual a 3 indica que el tauler està ple i no ha guanyat ningú, hi ha empat
			}
			else {
				printf("Press any key ");
			}

			getch_C();
		}
	}
	gotoxy_C(19, 1);						//Situar el cursor a la fila 19
	return 0;
}