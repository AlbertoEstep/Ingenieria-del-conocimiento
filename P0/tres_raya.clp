;;;;;;; JUGADOR DE 3 en RAYA ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Version de 3 en raya clásico: fichas que se pueden poner libremente en cualquier posicion libre (i,j) con 0 < i,j < 4
;;;;;;;;;;;;;;;;;;;;;;; y cuando se han puesto las 3 fichas las jugadas consisten en desplazar una ficha propia
;;;;;;;;;;;;;;;;;;;;;;; de la posición en que se encuentra (i,j) a una contigua
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Hechos para representar un estado del juego

;;;;;;; (Turno X|O)   representa a quien corresponde el turno (X maquina, O jugador)
;;;;;;; (Posicion ?i ?j " "|X|O) representa que la posicion i,j del tablero esta vacia, o tiene una ficha de Clisp o tiene una ficha del contrincante

;;;;;;;;;;;;;;;; Hechos para representar una jugadas

;;;;;;; (Juega X|O ?origen_i ?origen_j ?destino_i ?destino_j) representa que la jugada consiste en desplazar la ficha de la posicion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; (?origen_i,?origen_j) a la posición (?destino_i,?destino_j)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; las fichas que se ponen inicialmente se supondrá que están en el posición (0,0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INICIALIZAR ESTADO

(deffacts Tablero
	(Conectado 1 a horizontal 1 b)
	(Conectado 1 b horizontal 1 c)
	(Conectado 2 a horizontal 2 b)
	(Conectado 2 b horizontal 2 c)
	(Conectado 3 a horizontal 3 b)
	(Conectado 3 b horizontal 3 c)
	(Conectado 1 a vertical 2 a)
	(Conectado 2 a vertical 3 a)
	(Conectado 1 b vertical 2 b)
	(Conectado 2 b vertical 3 b)
	(Conectado 1 c vertical 2 c)
	(Conectado 2 c vertical 3 c)
	(Conectado 1 a diagonal 2 b)
	(Conectado 2 b diagonal 3 c)
	(Conectado 1 c diagonal_inversa 2 b)
	(Conectado 2 b diagonal_inversa 3 a)
)

(deffacts Estado_inicial
	(Posicion 1 a " ")
	(Posicion 1 b " ")
	(Posicion 1 c " ")
	(Posicion 2 a " ")
	(Posicion 2 b " ")
	(Posicion 2 c " ")
	(Posicion 3 a " ")
	(Posicion 3 b " ")
	(Posicion 3 c " ")
	(Fichas_sin_colocar O 3)
	(Fichas_sin_colocar X 3)
)

(defrule Conectado_es_simetrica
	(declare (salience 1))
	(Conectado ?i ?j ?forma ?i1 ?j1)
	=>
	(assert (Conectado ?i1 ?j1 ?forma ?i ?j))
)

(defrule Elige_quien_comienza
	=>
	(printout t "Quien quieres que empieze: (escribre X para la maquina u O para empezar tu) ")
	(assert (Turno (read)))
)

;;;;;;;;;;;;;;;;;;;;;;; RECOGER JUGADA DEL CONTRARIO ;;;;;;;;;;;;;;;;;;;;;;;
(defrule muestra_posicion
	(declare (salience 1))
	(muestra_posicion)
	(Posicion 1 a ?p11)
	(Posicion 1 b ?p12)
	(Posicion 1 c ?p13)
	(Posicion 2 a ?p21)
	(Posicion 2 b ?p22)
	(Posicion 2 c ?p23)
	(Posicion 3 a ?p31)
	(Posicion 3 b ?p32)
	(Posicion 3 c ?p33)
	=>
	(printout t crlf)
	(printout t "   a      b      c" crlf)
	(printout t "   -      -      -" crlf)
	(printout t "1 |" ?p11 "| -- |" ?p12 "| -- |" ?p13 "|" crlf)
	(printout t "   -      -      -" crlf)
	(printout t "   |  \\   |   /  |" crlf)
	(printout t "   -      -      -" crlf)
	(printout t "2 |" ?p21 "| -- |" ?p22 "| -- |" ?p23 "|" crlf)
	(printout t "   -      -      -" crlf)
	(printout t "   |   /  |  \\   |" crlf)
	(printout t "   -      -      -" crlf)
	(printout t "3 |" ?p31 "| -- |" ?p32 "| -- |" ?p33 "|"crlf)
	(printout t "   -      -      -" crlf)
)

(defrule muestra_posicion_turno_jugador
	(declare (salience 10))
	(Turno O)
	=>
	(assert (muestra_posicion))
)

(defrule jugada_contrario_fichas_sin_colocar
	?f <- (Turno O)
	(Fichas_sin_colocar O ?n)
	=>
	(printout t "en que posicion colocas la siguiente ficha" crlf)
	(printout t "escribe la fila (1,2 o 3): ")
	(bind ?fila (read))
	(printout t "escribe la columna (a,b o c): ")
	(bind ?columna (read))
	(assert (Juega O 0 0 ?fila ?columna))
	(retract ?f)
)

(defrule juega_contrario_fichas_sin_colocar_check
	(declare (salience 1))
	?f <- (Juega O 0 0 ?i ?j)
	(not (Posicion ?i ?j " "))
	=>
	(printout t "No puedes jugar en " ?i ?j " porque no esta vacio" crlf)
	(retract ?f)
	(assert (Turno O))
)

(defrule juega_contrario_fichas_sin_colocar_actualiza_estado
	?f <- (Juega O 0 0 ?i ?j)
	?g <- (Posicion ?i ?j " ")
	=>
	(retract ?f ?g)
	(assert (Turno X) (Posicion ?i ?j O) (reducir_fichas_sin_colocar O))
)

(defrule reducir_fichas_sin_colocar
	(declare (salience 1))
	?f <- (reducir_fichas_sin_colocar ?jugador)
	?g <- (Fichas_sin_colocar ?jugador ?n)
	=>
	(retract ?f ?g)
	(assert (Fichas_sin_colocar ?jugador (- ?n 1)))
)

(defrule todas_las_fichas_en_tablero
	(declare (salience 1))
	?f <- (Fichas_sin_colocar ?jugador 0)
	=>
	(retract ?f)
	(assert (Todas_fichas_en_tablero ?jugador))
)

(defrule juega_contrario
	?f <- (Turno O)
	(Todas_fichas_en_tablero O)
	=>
	(printout t "en que posicion esta la ficha que quieres mover?" crlf)
	(printout t "escribe la fila (1,2,o 3): ")
	(bind ?origen_i (read))
	(printout t "escribe la columna (a,b o c): ")
	(bind ?origen_j (read))
	(printout t "a que posicion la quieres mover?" crlf)
	(printout t "escribe la fila (1,2,o 3): ")
	(bind ?destino_i (read))
	(printout t "escribe la columna (a,b o c): ")
	(bind ?destino_j (read))
	(assert (Juega O ?origen_i ?origen_j ?destino_i ?destino_j))
	(printout t "Juegas mover la ficha de "  ?origen_i ?origen_j " a " ?destino_i ?destino_j crlf)
	(retract ?f)
)

(defrule juega_contrario_check_mueve_ficha_propia
	(declare (salience 1))
	?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
	(Posicion ?origen_i ?origen_j ?X)
	(test (neq O ?X))
	=>
	(printout t "No es jugada valida porque en " ?origen_i ?origen_j " no hay una ficha tuya" crlf)
	(retract ?f)
	(assert (Turno O))
)

(defrule juega_contrario_check_mueve_a_posicion_libre
	(declare (salience 1))
	?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
	(Posicion ?destino_i ?destino_j ?X)
	(test (neq " " ?X))
	=>
	(printout t "No es jugada valida porque " ?destino_i ?destino_j " no esta libre" crlf)
	(retract ?f)
	(assert (Turno O))
)

(defrule juega_contrario_check_conectado
	(declare (salience 1))
	(Todas_fichas_en_tablero O)
	?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
	(not (Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j))
	=>
	(printout t "No es jugada valida porque "  ?origen_i ?origen_j " no esta conectado con " ?destino_i ?destino_j crlf)
	(retract ?f)
	(assert (Turno O))
)

(defrule juega_contrario_actualiza_estado
	?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
	?h <- (Posicion ?origen_i ?origen_j O)
	?g <- (Posicion ?destino_i ?destino_j " ")
	=>
	(retract ?f ?g ?h)
	(assert (Turno X) (Posicion ?destino_i ?destino_j O) (Posicion ?origen_i ?origen_j " ") )
)



;;;;;;;;;;; ACTUALIZAR  ESTADO TRAS JUGADA DE CLISP ;;;;;;;;;;;;;;;;;;

(defrule juega_clisp_actualiza_estado
	?f <- (Juega X ?origen_i ?origen_j ?destino_i ?destino_j)
	?h <- (Posicion ?origen_i ?origen_j X)
	?g <- (Posicion ?destino_i ?destino_j " ")
	=>
	(retract ?f ?g ?h)
	(assert (Turno O) (Posicion ?destino_i ?destino_j X) (Posicion ?origen_i ?origen_j " ") )
)


;;;;;;;;;;; CLISP JUEGA SIN CRITERIO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule clisp_juega_sin_criterio_fichas_sin_colocar
	(declare (salience -9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X ?n)
	?g<- (Posicion ?i ?j " ")
	=>
	(printout t "Juego poner ficha en " ?i ?j crlf)
	(retract ?f ?g)
	(assert (Posicion ?i ?j X) (Turno O) (reducir_fichas_sin_colocar X)))

(defrule clisp_juega_sin_criterio
	(declare (salience -9999))
	?f<- (Turno X)
	(Todas_fichas_en_tablero X)
	(Posicion ?origen_i ?origen_j X)
	(Posicion ?destino_i ?destino_j " ")
	(Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j)
	=>
	(assert (Juega X ?origen_i ?origen_j ?destino_i ?destino_j))
	(printout t "Juego mover la ficha de "  ?origen_i ?origen_j " a " ?destino_i ?destino_j crlf)
	(retract ?f)
)

(defrule tres_en_raya
	(declare (salience 9999))
	?f <- (Turno ?X)
	(Posicion ?i1 ?j1 ?jugador)
	(Posicion ?i2 ?j2 ?jugador)
	(Posicion ?i3 ?j3 ?jugador)
	(Conectado ?i1 ?j1 ?forma ?i2 ?j2)
	(Conectado ?i2 ?j2 ?forma ?i3 ?j3)
	(test (neq ?jugador " "))
	(test (or (neq ?i1 ?i3) (neq ?j1 ?j3)))
	=>
	(printout t ?jugador " ha ganado pues tiene tres en raya " ?i1 ?j1 " " ?i2 ?j2 " " ?i3 ?j3 crlf)
	(retract ?f)
	(assert (muestra_posicion))
)


;;;;;;;;;;; EJERCICIOS A REALIZAR ;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; B1) Crear reglas para que el sistema deduzca que dos posiciones están en línea. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Enlinea
  (Conectado ?f1 ?c1 ?forma ?f2 ?c2)
  (Conectado ?f2 ?c2 ?forma ?f3 ?c3)
  (test (or (neq ?f1 ?f3) (neq ?c1 ?c3)))
=>
  (assert (Enlinea ?forma ?f1 ?c1 ?f2 ?c2))
  (assert (Enlinea ?forma ?f1 ?c1 ?f3 ?c3))
)


;;;;;;;;;;; B2) Crear reglas para que el sistema deduzca y mantenga que un jugador tiene dos fichas en la misma en línea. ;

(defrule Comprueba_2_en_Linea
	(declare (salience 9999))
	(logical
		(Enlinea ?forma ?f1 ?c1 ?f2 ?c2)
		(Posicion ?f1 ?c1 ?jugador)
		(Posicion ?f2 ?c2 ?jugador)
	)
	(test (neq ?jugador " "))
	=>
	(assert (2_en_linea ?forma ?f1 ?c1 ?f2 ?c2 ?jugador))
)

;;;;;;;;;;; B3) Crear reglas para deducir y mantener si un jugador puede hacer un movimiento ganador. ;;;;;;;;;;;;;;;;;;;;

(defrule Comprueba_puede_ganar_colocando
	(declare (salience 9999))
	(logical
		(Fichas_sin_colocar ?jugador 1)								;Comprobamos que queda una ficha sin colocar
		(2_en_linea ?forma ?f1 ?c1 ?f2 ?c2 ?jugador)	;Comprobamos que tengamos 2 fichas en linea
		(Enlinea ?forma ?f1 ?c1 ?f ?c)								;Buscamos la otra posicion de la linea
		(Posicion ?f ?c " "))													;Comprobamos que este vacia la posicion
	=>
	(assert (puede_ganar_colocando ?f ?c ?jugador))
)

(defrule Comprueba_puede_ganar_moviendo
	(declare (salience 9999))
	(logical
		(Todas_fichas_en_tablero ?jugador)						;Para poder mover
		(2_en_linea ?forma ?f1 ?c1 ?f2 ?c2 ?jugador)	;Tiene que haber 2 en linea
		(Enlinea ?forma ?f1 ?c1 ?f ?c)								;Capturamos la posicion que esta en linea y falta para ganar
		(Posicion ?f ?c " ")													;Comprobamos que esa posicion este libre
		(Posicion ?f3 ?c3 ?jugador)										;Buscamos la otra ficha del jugador
		(Conectado ?f ?c ?otraforma ?f3 ?c3)					;Comprobamos que este conectada con el hueco
		(test (neq ?forma ?otraforma)))								;Vemos que no sea ninguna de las 2 fichas que estan ya en linea
	=>
	(assert (puede_ganar_moviendo ?f3 ?c3 ?f ?c ?jugador))
)

;;;;;;;;;;; B4) Añadir reglas para que el sistema incluya la estrategia "Si la maquina puede ganar haciendo una jugada, entonces hace esa jugada". ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule clisp_gana_colocando
	(declare (salience 1))
	?f<- (Turno X)
	(puede_ganar_colocando ?fila ?columna X)
	?g<- (Posicion ?fila ?columna " ")
	=>
	(printout t "Juego poner ficha en " ?fila ?columna crlf)
	(retract ?f ?g)
	(assert (Posicion ?fila ?columna X) (Turno O) (reducir_fichas_sin_colocar X))
)

(defrule clisp_gana_moviendo
	(declare (salience 1))
	?f<- (Turno X)
	(puede_ganar_moviendo ?f1 ?c1 ?f2 ?c2 X)
	=>
	(assert (Juega X ?f1 ?c1 ?f2 ?c2))
	(printout t "Juego mover la ficha de "  ?f1 ?c1 " a " ?f2 ?c2 crlf)
	(retract ?f)
)


;;;;;;;;;;; B5) Añadir reglas para que el sistema incluya la estrategia "Si el jugador puede ganar haciendo una jugada y la máquina puede evitarlo, hace la jugada que lo evita". ;;;

(defrule clisp_evita_ganar_colocando
	(declare (salience -4))
	?f<- (Turno X)
	(Fichas_sin_colocar X ?n)
	(puede_ganar_colocando ?fila ?columna O)
	?g<- (Posicion ?fila ?columna " ")
	=>
	(printout t "Juego poner ficha en " ?fila ?columna crlf)
	(retract ?f ?g)
	(assert (Posicion ?fila ?columna X) (Turno O) (reducir_fichas_sin_colocar X))
)

(defrule clisp_evita_ganar_moviendo
	(declare (salience -5))
	?f<- (Turno X)
	(Todas_fichas_en_tablero X)
	(puede_ganar_moviendo ?f1 ?c1 ?f2 ?c2 O)
	(Conectado ?f2 ?c2 ?forma ?f3 ?c3)
	(Posicion ?f3 ?c3 X)
	=>
	(assert (Juega X ?f3 ?c3 ?f2 ?c2))
	(printout t "Juego mover la ficha de "  ?f3 ?c3 " a " ?f2 ?c2 crlf)
	(retract ?f)
)

(defrule clisp_evita_ganar_moviendo2
	(declare (salience -5))
	?f<- (Turno X)
	(Todas_fichas_en_tablero X)
	(puede_ganar_colocando ?f2 ?c2 O)
	(Conectado ?f2 ?c2 ?forma ?f3 ?c3)
	(Posicion ?f3 ?c3 X)
	=>
	(assert (Juega X ?f3 ?c3 ?f2 ?c2))
	(printout t "Juego mover la ficha de "  ?f3 ?c3 " a " ?f2 ?c2 crlf)
	(retract ?f)
)


;;;;;;;;;;; Bonus. ;;;

;; En las reglas siguientes conseguiremos que si el jugador juega primero gane siempre
;; Lo primero que haremos será colocar la primera pieza en el centro del tablero:

(defrule clisp_movimiento_1
	(declare (salience 9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X 3)
	(Fichas_sin_colocar O 3)
	?g<- (Posicion 2 b " ")
	=>
	(printout t "Juego poner ficha en 2 b" crlf)
	(retract ?f ?g)
	(assert (Posicion 2 b X) (Turno O) (reducir_fichas_sin_colocar X))
)

;; De esta forma el primer movimiento del jugador puede ser colocarlo en una esquina o en un lateral.
;; En verdad solo existen dos posibilidades ya que el campo es simetrico.
;;	|   |   |   |				|   |   |   |
;;	|   | X |   |				|   | X |   |
;;	|   |   | O |       |   | O |   |


;; A) CASO ESQUINA:
;;		Provocaremos que el jugador tenga que tapar los siguientes turnos para que no ganemos:
;;	|   | X |   |				|   | X |   |				|   | X |   |      |   | X | O |
;;	|   | X |   |		->	|   | X |   |  ->		|   |	X	|		|  ->  |   | X |   |
;;	|   |   | O |       |   | O | O |				| X |	O |	O |      | X | O | O |

(defrule clisp_movimiento_2_esquina_caso1
	(declare (salience 9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X 2)
	(Fichas_sin_colocar O 2)
	(Posicion 3 ?c O)
	(test (or
		(eq ?c a)
		(eq ?c c)))
	?g<- (Posicion 1 b " ")
	=>
	(printout t "Juego poner ficha en 1 b" crlf)
	(retract ?f ?g)
	(assert (Posicion 1 b X) (Turno O) (reducir_fichas_sin_colocar X))
)

(defrule clisp_movimiento_2_esquina_caso2
	(declare (salience 9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X 2)
	(Fichas_sin_colocar O 2)
	(Posicion 1 ?c O)
	(test (or
		(eq ?c a)
		(eq ?c c)))
	?g<- (Posicion 3 b " ")
	=>
	(printout t "Juego poner ficha en 3 b" crlf)
	(retract ?f ?g)
	(assert (Posicion 3 b X) (Turno O) (reducir_fichas_sin_colocar X))
)

;; A continuacion comprobamos que si movemos la ficha siguiente provocaremos ganar en nuestro siguiente movimiento.
;; Para ello hemos buscado un patron para los cuatro casos y hemos implementado las siguientes reglas.
;; El patron consiste en buscar los dos huecos en linea vacíos y comprobamos que tenemos la situacion buscada.
;; Tenemos en cuenta de no mover la ficha central para bloquear al rival y ganar.

;;	|   | X | O |				| X |   | O |
;;	|   | X |   |		->	|   | X |   |
;;	| X | O | O |				| X | O | O |

(defrule Comprueba_2_En_Linea_blanco
	(declare (salience 9999))
	(logical
		(Todas_fichas_en_tablero X)
		(Todas_fichas_en_tablero O)
		(Conectado ?f1 ?c1 ?forma ?f2 ?c2)
		(Posicion ?f1 ?c1 " ")
		(Posicion ?f2 ?c2 " ")
	)
	=>
	(assert (2_blancos_conectados ?forma ?f1 ?c1 ?f2 ?c2))
)

(defrule mover_ganador
	(declare (salience -2))
	?f<- (Turno X)
	(2_blancos_conectados ?forma ?f1 ?c1 ?f2 ?c2)
	(Conectado ?f1 ?c1 ?otraforma ?f3 ?c3)
	(test (neq ?forma ?otraforma))
	(Posicion ?f3 ?c3 X)
	(test (or (neq ?f3 2) (neq ?c3 b)))
	=>
	(assert (Juega X ?f3 ?c3 ?f1 ?c1))
	(printout t "Juego mover la ficha de "  ?f3 ?c3 " a " ?f1 ?c1 crlf)
	(retract ?f)
)

;; B) CASO LATERAL:
;;		Provocaremos que el jugador tenga que tapar los siguientes turnos para que no ganemos:
;;	| X |   |   |				| X |   |   |				| X |   |   |      | X |   | O |     | X |   |   |
;;	|   | X |   |		->	|   | X |   |  ->		|   |	X	|		|  ->  |   | X |   |  ó  | O | X |   |
;;	|   | O |   |       |   | O | O |				| X |	O |	O |      | X | O | O |     | X | O | O |

(defrule clisp_movimiento_2_lateral_caso1
	(declare (salience 9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X 2)
	(Fichas_sin_colocar O 2)
	(Posicion ?f1 ?c O)
	(test (or
		(and (eq ?f1 3) (eq ?c b))
		(and (eq ?f1 2) (eq ?c c))))
	?g<- (Posicion 1 a " ")
	=>
	(printout t "Juego poner ficha en 1 a" crlf)
	(retract ?f ?g)
	(assert (Posicion 1 a X) (Turno O) (reducir_fichas_sin_colocar X))
)


(defrule clisp_movimiento_2_lateral_caso2
	(declare (salience 9999))
	?f<- (Turno X)
	(Fichas_sin_colocar X 2)
	(Fichas_sin_colocar O 2)
	(Posicion ?f1 ?c O)
	(test (or
		(and (eq ?f1 1) (eq ?c b))
		(and (eq ?f1 2) (eq ?c a))))
	?g<- (Posicion 3 c " ")
	=>
	(printout t "Juego poner ficha en 3 c" crlf)
	(retract ?f ?g)
	(assert (Posicion 3 c X) (Turno O) (reducir_fichas_sin_colocar X))
)

;; Sin embargo lleguemos al paso que lleguemos de los dos posibles, gracias a las reglas previas implementadas
;; de evitar ganar al contrario y ganar automaticamente si existe la posibilidad, ambos casos son resueltos de
;; forma correcta por el algoritmo.

;; Nota: Hemos reflejado en el ejemplo 2 casos de los 8 posibles, pero 4 son analogos al primero y los otros 4
;; son analogos al segundo. Así hemos conseguido que la maquina consiga la victoria si el turno inicial es el
;; suyo.
