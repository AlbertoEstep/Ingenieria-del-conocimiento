;; Autor: Alberto Estepa Fernández
;; Fecha: 7 de abril de 2020

;; Programa en CLIPS que:
;;	- Le pregunte, al usuario que pide asesoramiento, lo que le preguntaría al compañero que hace de experto.
;;	- Realice los razonamientos que haría el compañero que hace de experto
;;	- Le aconseje la rama o las ramas que le aconsejaría el compañero junto con los motivos por lo que se lo aconsejaría.

;(deffacts Ramas
;	(Rama Computacion_y_Sistemas_Inteligentes)
;	(Rama Ingenieria_del_Software)
;	(Rama Ingenieria_de_Computadores)
;	(Rama Sistemas_de_Informacion)
;	(Rama Tecnologias_de_la_Informacion)
;)

(deffunction pregunta (?pregunta $?valores-permitidos)
	(progn$
		(?var ?valores-permitidos)
		(lowcase ?var))
	(format t "%s: " ?pregunta)
	(bind ?respuesta (read))
	(while (numberp ?respuesta) do
		(format t "%s (%s): " ?pregunta (implode$ ?valores-permitidos))
		(bind ?respuesta (read))
	)
	(while (not (member (lowcase ?respuesta) ?valores-permitidos)) do
		(format t "%s (%s) " ?pregunta (implode$ ?valores-permitidos))
		(bind ?respuesta (read))
		(while (numberp ?respuesta) do
			(format t "%s (%s) " ?pregunta (implode$ ?valores-permitidos))
			(bind ?respuesta (read))
		)
	)
	(lowcase ?respuesta)
)

(deffunction pregunta_numerica (?pregunta $?valores-permitidos)
	(format t "%s: " ?pregunta)
	(bind ?respuesta (read))
	(while (and (neq ?respuesta 1)(neq ?respuesta 2)(neq ?respuesta 3)(neq ?respuesta consejo)(neq ?respuesta Consejo)(neq ?respuesta Siguiente)(neq ?respuesta siguiente)) do
		(format t "%s (%s): " ?pregunta (implode$ ?valores-permitidos))
		(bind ?respuesta (read))
	)
	(if (numberp ?respuesta)
		then ?respuesta
		else (lowcase ?respuesta)
	)
)

(deffunction pide_consejo (?respuesta)
	(if (eq ?respuesta consejo)
		then TRUE
		else FALSE
	)
)

(deffunction no_quiere_contestar (?respuesta)
	(if (eq ?respuesta siguiente)
		then TRUE
		else FALSE
	)
)

(defrule Bienvenido
	=> 
	(printout t "Hola! Bienvenido al sistema de asesoramiento de ramas de Ingenieria Informatica, a continuacion le haremos 
	una serie de preguntas para aconsejarle correctamente." crlf)
	(printout t "Si en algun momento desea terminar y pedir consejo, reponda con 'Consejo'." crlf)
	(assert (bienvenido))
)
	

(defrule Pregunta_1
	(bienvenido)
	=>
	(bind ?respuesta (pregunta "Le gustan las Matematicas?  Responde 'Si' o 'No'" si no consejo))
	(if (pide_consejo ?respuesta)
		then (assert (consejo))
		else (assert (matematicas ?respuesta))
	)
)

(defrule Pregunta_2
	(matematicas si)
	=>
	(bind ?respuesta (pregunta_numerica "Indique segun el rango {1, 2, 3} si es trabajador o no (1 poco trabajador - 3 muy trabajador). 
						Si no desea contestar responda 'Siguiente'" 1 2 3 consejo siguiente))
	(if (pide_consejo ?respuesta)
		then (assert (consejo))
		else (if (no_quiere_contestar ?respuesta)
			then (assert (no_contesta_pregunta_2))
			else (assert (grado_trabajador ?respuesta)))
	)
)

(defrule no_contesta_pregunta_2
	?f <- (no_contesta_pregunta_2)
	=>
	(retract ?f)
	(assert (consejo))
)

(defrule Convertir_grado_trabajador_mucho
	?f <- (grado_trabajador ?g)
	(test (= ?g 3))
	=>
	(retract ?f)
	(assert (trabajador mucho))  (assert (consejo))
)

(defrule Convertir_grado_trabajador_medio
	?f <- (grado_trabajador ?g)
	(test (= ?g 2))
	=>
	(retract ?f)
	(assert (trabajador medio))  (assert (consejo))
)

(defrule Convertir_grado_trabajador_poco
	(declare (salience -1))
	?f <- (grado_trabajador ?g)
	(test (= ?g 1))
	=>
	(retract ?f)
	(assert (trabajador poco))  (assert (consejo))
)

(defrule Pregunta_3
	(matematicas no)
	=>
	(bind ?respuesta (pregunta "Le gusta mas el Sofware o el Hardware? Responde 'Software' o 'Hardware'"
		software hardware consejo))
	(if (pide_consejo ?respuesta)
		then (assert (consejo))
		else (assert (informatica ?respuesta))
	)
)

(defrule Pregunta_4
	(informatica software)
	=>
	(printout t "Indique que calificacion media tiene en la carrera actualmente. Si no desea contestar responda 'Siguiente'" crlf)
	(assert (comprobar_respuesta (read)))
)


(defrule comprobar_respuesta_nota
	?f <- (comprobar_respuesta ?nota)
	(test (numberp ?nota))
	(test (and (>= ?nota 5)(<= ?nota 10)))
	=>
	(retract ?f)
	(assert (nota_numerica ?nota))
)

(defrule comprobar_respuesta_nota_consejo
	?f <- (comprobar_respuesta ?nota)
	(test (not (numberp ?nota)))
	(test (or (eq ?nota Consejo)(eq ?nota consejo)))
	=>
	(retract ?f)
	(assert (consejo))
)

(defrule comprobar_respuesta_nota_siguiente
	?f <- (comprobar_respuesta ?nota)
	(test (not (numberp ?nota)))
	(test (or (eq ?nota Siguiente)(eq ?nota siguiente)))
	=>
	(retract ?f)
	(assert (no_contesta_pregunta_4))
)

(defrule no_contesta_pregunta_4
	?f <- (no_contesta_pregunta_4)
	=>
	(retract ?f)
	(assert (consejo))
)

(defrule comprobar_respuesta_nota_fallo
	?f <- (comprobar_respuesta ?nota)
	(test (not (numberp ?nota)))
	(test (and (neq ?nota Siguiente)(neq ?nota siguiente)(neq ?nota Consejo)(neq ?nota consejo)))
	=>
	(retract ?f)
	(printout t "Error, no ha indicado un numero. Indique que calificacion media tiene en la carrera actualmente" crlf)
	(assert (comprobar_respuesta (read)))
)

(defrule comprobar_respuesta_nota_fallo_rango
	?f <- (comprobar_respuesta ?nota)
	(test (numberp ?nota))
	(test (or (< ?nota 5)(> ?nota 10)))
	=>
	(retract ?f)
	(printout t "Error, no ha indicado un numero dentro del rango posible [5-10]. Indique que calificacion media tiene en la carrera actualmente" crlf)
	(assert (comprobar_respuesta (read)))
)

(defrule Convertir_nota_alta
	?f <- (nota_numerica ?n)
	(test (>= ?n 8))
	=>
	(retract ?f)
	(assert (nota alta)) (assert (consejo))
)

(defrule Convertir_nota_media
	?f <- (nota_numerica ?n)
	(test (and 
		(< ?n 8)
		(>= ?n 6.5)))
	=>
	(retract ?f)
	(assert (nota media)) (assert (consejo))
)

(defrule Convertir_nota_baja
	?f <- (nota_numerica ?n)
	(test  (< ?n 6.5))
	=>
	(retract ?f)
	(assert (nota baja)) (assert (consejo))
)

(defrule Pregunta_5
	(informatica hardware)
	=>
	(bind ?respuesta (pregunta "Prefiere trabajar en la empresa publica o en la privada? Responde 'Publica' o 'Privada'"
		publica privada consejo))
	(if (pide_consejo ?respuesta)
		then (assert (consejo))
		else (assert (trabaja ?respuesta)) (assert (consejo))
	)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;					;;;;;;;;;;;;;;
;;;;;;;;;;		CONSEJOS		;;;;;;;;;;;;;;
;;;;;;;;;;					;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule hoja1
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas si)
	?j <- (trabajador ?c)
	(test (or (eq ?c medio) (eq ?c mucho)))
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de CSI ya que dicha rama tendra bastantes asignaturas de matematicas y tendra una carga de trabajo grande." crlf)
	(printout t crlf)
)

(defrule hoja2
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas si)
	?j <- (trabajador poco)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de TI ya que aunque no sera necesaria una gran base de matematicas, 
			existen asignaturas de la rama con carga matematica pero no tendra una carga de trabajo elevada." crlf)
	(printout t crlf)
)

(defrule hoja3
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica hardware)
	?t <- (trabaja publica)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(retract ?t)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de IC ya que dicha rama no sera necesaria una gran base de matematicas, 
			tendra una gran aportacion de hardware y su empleabilidad se enfoca en la empresa publica." crlf)
	(printout t crlf)
)

(defrule hoja4
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica hardware)
	?t <- (trabaja privada)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(retract ?t)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de TI ya que dicha rama no sera necesaria una gran base de matematicas, 
			tendra una gran aportacion de hardware y su empleabilidad se enfoca en la empresa privada." crlf)
	(printout t crlf)
)

(defrule hoja5
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica software)
	?t <- (nota ?alta)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(retract ?t)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de IS ya que dicha rama no sera necesaria una gran base de matematicas, 
			tendra una gran aportacion de software y la dificultad será más elevada que otra rama." crlf)
	(printout t crlf)
)

(defrule hoja6
	(declare (salience 3))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica software)
	?t <- (nota ?c)
	(test (or (eq ?c media) (eq ?c baja)))
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(retract ?t)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de SI ya que dicha rama no sera necesaria una gran base de matematicas, 
			tendra una gran aportacion de software y la dificultad sera menos elevada que otra rama." crlf)
	(printout t crlf)
)

(defrule rama1
	(declare (salience 2))
	?h <- (consejo)
	?g <- (matematicas si)
	=> 
	(retract ?h)
	(retract ?g)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de CSI ya que dicha rama tendra bastantes asignaturas de matematicas. 
			Aunque tambien si es poco trabajador sería mas conveniente elegir la rama de TI. " crlf)
	(printout t crlf)
)

(defrule rama2
	(declare (salience 1))
	?h <- (consejo)
	?g <- (matematicas no)
	=> 
	(retract ?h)
	(retract ?g)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de SI ya que no sera necesaria una gran base de matematicas. 
			Aunque con tan poca informacion no podremos concretar correctamente, le aconsejamos no coger CSI por su alto contenido matematico. " crlf)
	(printout t crlf)
)

(defrule rama2_1
	(declare (salience 2))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica hardware)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de IC ya que dicha rama no sera necesaria una gran base de matematicas y
			tendra una gran aportacion de hardware. Aunque podras elegir TI si te quieres preparar para el sector privado" crlf)
	(printout t crlf)
)


(defrule rama2_2
	(declare (salience 2))
	?h <- (consejo)
	?g <- (matematicas no)
	?j <- (informatica software)
	=> 
	(retract ?h)
	(retract ?g)
	(retract ?j)
	(printout t crlf)
	(printout t "Te aconsejamos escoger la rama de SI ya que dicha rama no sera necesaria una gran base de matematicas, 
			tendra una gran aportacion de software. Ademas si no te importa la dificultad podremos elegir tambien IS" crlf)
	(printout t crlf)
)

(defrule consejo_inicial
	?h <- (consejo)
	=> 
	(retract ?h)
	(printout t crlf)
	(printout t "Aunque no podemos ofrecerte informacion detallada al no haber respondido ninguna pregunta, te aconsejamos CSI debido
			 a que es lo que la mayoria de los alumnos elige" crlf)
	(printout t crlf)
)