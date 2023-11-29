%include "asm_io.inc"

;cantidad de jugadores
LENG    equ     6

segment .data
msg_number      db "Numero pseudoaleatorio :", 0
msg_win         db "Eres el ganador!.",0
continuar_msg db    "Deseas continuar? Si(0). No(1) : ",0

clr db 0x1b, "[2J", 0X1b, "[H"
clrlen  equ $ - clr 

;mensaje para hacer separaciones
line            db "--------------------", 0
;mesaje para indicar las reglas del juego
rules           db "Reglas: ", 10
                db "Pie derecho: 0", 10
                db "Pie izquierdo: 1", 0
;mensaje para mostrar el orden inical de los jugadores
players_list    db "Lista de jugadores: ", 10
                db "0 Daniel ", 10
                db "1 Brayan ", 10
                db "2 Pedro ", 10
                db "3 Jeison ", 10
                db "4 Edwin ", 10
                db "5 Miguel ", 0
; lista de jugadores
dictionary      db " - Daniel : ", 0
                db " - Brayan : ", 0
                db " - Pedro : ", 0
                db " - Jeison : ", 0
                db " - Edwin : ", 0
                db " - Miguel : ", 0
;lista de palabras del juego
words_game      db "za", 0 
                db "pa",0 
                db "tico",0 
                db "co",0 
                db "chi",0 
                db "ni",0 
                db "to",0 
                db "cam",0 
                db "bia",0 
                db "de",0 
                db "pie",0 
                db "ci",0 
                db "to", 0
;macro que genera un numero pseudoaleatorio a partir de un limite
%macro random 1
        pusha

        mov ecx, 0xff

        rdtsc
        xor edx, edx
        and eax, ecx

        imul eax, %1
        mov edi, eax
        idiv ecx

        mov [number], eax
        popa
%endmacro
;Macro que busca y guarda el jugador en la variable hidden dependiendo del numero pseudoaleatorio 
%macro chooseWord 3
        pusha

        mov ecx, 0
        mov ebx, %1
        mov esi, %2 ; 
%%cw01:
        cmp ecx, [%3]
        je %%cw03
        mov al, [ebx]
        cmp al, 0
        je %%cw02
        inc ebx
        jmp %%cw01

%%cw02:
        inc ecx
        inc ebx
        jmp %%cw01

%%cw03:
        mov al,[ebx]
        mov [esi], al
        cmp al, 0
        je %%cw04
        inc ebx
        inc esi
        jmp %%cw03

%%cw04:
        popa
%endmacro
;macro que guarad la palabra que dice el jugador, a partir del turn

%macro clear_screen 0
pusha
        mov eax,4
        mov ebx,1
        mov  ecx,clr
        mov edx, clrlen
        int 0x80
popa
%endmacro
;
; initialized data is put in the data segment here
;


segment .bss
;
; uninitialized data is put in the bss segment
;
number  resd 5
hidden  resd 5
player_word     resd 5
turn    resd 5

Daniel    resd 5
Brayan    resd 5
Pedro     resd 5
Jeison    resd 5
Edwin     resd 5
Miguel    resd 5
players   resd 5

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

start:
        ;mostrar una linea de separacion
        mov eax, line
        call print_string
        call print_nl
        ;mostrar reglas del juego
        mov eax, rules
        call print_string
        call print_nl
        ;mostrar lista de jugadores
        mov eax, players_list
        call print_string
        call print_nl
        ;se genera el numero pseudoaleatorio para definir quien inicia
        random LENG
        ;mostrar numero pseudoaleatorio
        mov eax, msg_number
        call print_string
        mov eax, [number]
        call print_int
        call print_nl
        ;mostrar una linea de separacion
        mov eax, line
        call print_string
        call print_nl
        ;mensaje para continuar
        mov eax, continuar_msg
        call print_string
        call print_nl

        call read_int
        cmp eax, 1
        jge done

        ;inicio en el turno y el contador de jugadores
        mov eax, 0
        mov [turn], eax
        mov [Daniel], eax
        mov [Brayan], eax
        mov [Pedro ], eax
        mov [Jeison], eax
        mov [Edwin ], eax
        mov [Miguel], eax
        mov [players], eax
;verifica a que jugador le toca para validar si ya salio del juego
validate_count:
        mov eax, [number]
        cmp eax , 0
        je daniel
        cmp eax , 1
        je brayan
        cmp eax , 2
        je pedro
        cmp eax , 3
        je jeison
        cmp eax , 4
        je edwin
        cmp eax , 5
        je miguel
;valida si el jugador ya salio del juego
daniel:
        mov eax, [Daniel]
        cmp eax, 2
        jge next_player
        mov eax, [Daniel]
        call print_int
        jmp start_game
;valida si el jugador ya salio del juego
brayan:
        mov eax, [Brayan]
        cmp eax, 2
        jge next_player
        call print_int
        jmp start_game
;valida si el jugador ya salio del juego
pedro: 
        mov eax, [Pedro]       
        cmp eax, 2
        jge next_player
        call print_int
        jmp start_game
;valida si el jugador ya salio del juego
jeison:
        mov eax, [Jeison]
        cmp eax, 2
        jge next_player
        call print_int
        jmp start_game
;valida si el jugador ya salio del juego
edwin:
        mov eax, [Edwin]
        cmp eax, 2
        jge next_player
        call print_int
        jmp start_game
;valida si el jugador ya salio del juego
miguel:
        mov eax, [Miguel]
        cmp eax, 2
        jge next_player
        call print_int
        jmp start_game


start_game:
        ;selecciona y muestra el jugador
        chooseWord dictionary, hidden, number
        mov eax, hidden
        call print_string
        ;selecciona y muestra la frase
        chooseWord words_game, player_word, turn
        mov eax, player_word
        call print_string
        call print_nl
        ;siguiente turno
        mov eax, [turn]
        add eax, 1
        mov [turn], eax
        ;valida si es el turno final
        mov eax, [turn]
        cmp eax, 13
        je end

next_player:
        ;verifica si es el ultimo jugador
        mov eax, [number]
        cmp eax, 5
        je reset_count
        ;siguiente jugador
        add eax, 1
        mov [number], eax
        ;validar el turno final
        jmp validate_count

reset_count: ;asigna 0 a number para volver al primer jugador
        mov eax, 0
        mov [number], eax
        ;valida si es el turno final
        mov eax, [turn]
        cmp eax, 13
        je end
        jmp validate_count
;resetea los turnos y verifica el jugador final para asignarle el punto
end:
        ;resetea los turnos
        call print_nl
        call print_nl
        mov eax, 0
        mov [turn], eax
        ;verifica jugador final
        mov eax, [number]
        cmp eax , 0
        je daniel_add
        cmp eax , 1
        je brayan_add
        cmp eax , 2
        je pedro_add
        cmp eax , 3
        je jeison_add
        cmp eax , 4
        je edwin_add
        cmp eax , 5
        je miguel_add
;adiciona un punto al jugador  
daniel_add:
        mov eax, [Daniel]
        add eax, 1
        mov [Daniel], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;adiciona un punto al jugador      
brayan_add:
        mov eax, [Brayan]
        add eax, 1
        mov [Brayan], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;adiciona un punto al jugador 
pedro_add:
        mov eax, [Pedro]
        add eax, 1
        mov [Pedro], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;adiciona un punto al jugador 
jeison_add:
        mov eax, [Jeison]
        add eax, 1
        mov [Jeison], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;adiciona un punto al jugador 
edwin_add:
        mov eax, [Edwin]
        add eax, 1
        mov [Edwin], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;adiciona un punto al jugador 
miguel_add:
        mov eax, [Miguel]
        add eax, 1
        mov [Miguel], eax
        ;verifica si es eliminado
        cmp eax, 2
        je exit_player
        jmp validate_count
;lleva y contador de los jugadores eliminados y finaliza si ya terminaron todos
exit_player:
        mov eax, [players]
        add eax, 1
        cmp eax, 6
        jge finalize
        mov [players], eax
        jmp validate_count

;pregunta para salir del programa
continue:
        call print_nl
        mov eax, continuar_msg
        call print_string
      
        call read_int            ;stores the character in the eax register
        cmp eax, 1
        jge done 
        jmp start
;Muestra mensaje final
finalize:
        mov eax,msg_win
        call print_string
        jmp continue
;salir del programa
done:
        clear_screen
        popa
        mov     eax, 0            ; return back to C
        leave
        ret


