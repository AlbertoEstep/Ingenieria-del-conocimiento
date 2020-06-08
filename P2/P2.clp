;; Autor: Alberto Estepa Fernández
;; Fecha: 9 de junio de 2020


;;	Ejecutado en CLIPSIDE en Windows 10
;;	Anchura del tabulador: 4

;; Desarrollo de un sistema experto que asesore a un estudiante de Ingeniería Informática tal y como lo haría un
;; compañero concreto. La práctica incluye dos tipos de asesorías:
;;  -	Asesorar a un alumno en qué rama matricularse
;;  -	Dadas un conjunto de asignaturas posibles y unos créditos a cumplimentar, aconsejar en cuáles de esas
;;		asignaturas matricularse.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;																							;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;										Explicacion del programa							;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;																							;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Programa modularizado en dos grandes modulos en CLIPS que:
;;  * El primer modulo:
;;		- Le pregunta, al usuario que pide asesoramiento, lo que le preguntaría al compañero que hace de experto.
;;		- Realice los razonamientos que haría el compañero que hace de experto
;;		- Le aconseje la rama o las ramas que le aconsejaría el compañero junto con los motivos por lo que se lo aconsejaría.
;;  * El segundo modulo:
;;		- Incluye razonamiento por defecto para el recomendar asignaturas al usuario
;;		- El sistema justifica claramente al usuario el razonamiento que se ha seguido.

;; Nos hemos basado en la tarea del 13 de marzo realizada para la adquisicion del conocimiento del primer modulo. De aquella
;; forma, aplicamos un algoritmo de aprendizaje y obtuvimos un arbol de clasificacion que usaremos ahora para implementar el
;; modulo del programa.

;; Adjuntamos el arbol de clasificación en la entrega de la practica.

;; Asi, como vemos el experto usa 5 propiedades que ahora comentamos:
;;		-	Gusto por las matematicas (valores posibles {Si, No})
;;		-	Grado de trabajo del usuario (valores posibles {Poco, Medio, Mucho})
;;		-	Preferencia por el Hardware o el Software (valores permitidos {Software, Hardware})
;;		-	Enfoque hacia un sector de empleo (valores permitidos {Publica, Privada})
;;		-	Nota media de la carrera (valores permitidos {Alta (mayor a 8), Media (entre 8 y 6.5), Baja (entre 6.5 y 5)}


;; Siguiendo las recomendaciones, el sistema preguntara de forma discriminada escogiendo las preguntas necesarias para formar
;; el consejo, dependiendo de la respuesta del usuario.
;; Hemos querido solicitar los datos de forma sencilla y ordenada, así como filtrar los datos de entrada para no permitir valores
;; erroneos.
;; Ademas hemos tratado con variables numericas y no numericas y hemos adaptado las numericas a no numericas para obtener una regularizacion
;; de los datos de entrada.
;; En cualquier momento el usuario puede pedir consejo y recibirlo por parte del sistema.
;; Hemos decidido que pueda no contestar a preguntas que pueden ser más intimas del usuario, como la nota media de la carrera o el grado de
;; trabajo del usuario. Así se dará informacion parcial si no llega a contestar dichas preguntas. Las demas preguntas, que son de respuesta
;; de Si o No y no vulneran la intimidad del usuario, no hemos permitido esa funcionalidad.
;; Ademas el consejo a cada eleccion es unica y adaptada a las respuestas dadas por el usuario.

;; Por otra parte, para el modulo sobre asignaturas hemos adquirido un nuevo conocimiento obteniendo un pequeño arbol de
;; clasificacion que usamos para implementar el modulo.

;; El experto usa 3 propiedades:
;;		-	Preferencia por el Hardware o el Software (valores permitidos {Software, Hardware})
;;		-	Preferencia por la programacion (grado de programacion de las asignaturas)(valores permitidos {Alto, Bajo})
;;		-	Preferencia por el nivel de carga de trabajo (valores permitidos {Alta, Baja})
;;
;; De nuevo el sistema preguntara de forma discriminada escogiendo las preguntas necesarias para formar el consejo,
;; dependiendo de la respuesta del usuario. Sin embargo usaremos la lógica por defecto para introducir conocimiento en
;; nuestro sistema. En concreto:
;; 		-	El sistema por defecto asumira que todas las asignaturas poseen mas parte de Software que de Hardware
;; 		-	El sistema por defecto asumira que todas las asignaturas poseen alto grado de programacion
;; 		-	El sistema por defecto asumira que todas las asignaturas poseen alto nivel de trabajo
;;		-	El sistema por defecto asumira que todas las asignaturas tienen 6 creditos.
;;
;; Si se introdujesen hechos que contradicen dicho razonamiento por defecto, el sistema está preparado para retractar dicho
;; razonamiento por defecto y modificar el conocimiento.
;; Por lo demas se ha usado el mismo proceso para desarrollar el modulo de Asignaturas que el de Ramas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffacts HechoInicial
	(Inicio)
)

(defrule main
	?f <- (Inicio)
	=>
	(retract ?f)
	(focus Inicio)
)

(defmodule preguntas (export ?ALL))
	;; Hemos creado varias funciones que nos serviran para el tema de filtro de datos de entrada por el usuario:

	;; Pregunta no numerica:
	(deffunction pregunta (?pregunta $?valores-permitidos)						;; Dada una pregunta y un conjunto de respuestas permitidas
		(progn$
			(?var ?valores-permitidos)
			(lowcase ?var))														;; 	Convertimos las respuestas permitidas a minusculas
		(format t "%s: " ?pregunta)												;;	Imprimimos la pregunta
		(bind ?respuesta (read))												;; 	Captamos la respuesta
		(while (numberp ?respuesta) do											;; 	Si es un numero, volvemos a preguntar
			(format t "%s (%s): " ?pregunta (implode$ ?valores-permitidos))
			(bind ?respuesta (read))
		)
		(while (not (member (lowcase ?respuesta) ?valores-permitidos)) do		;;  Si no es un numero, comprobamos que este en la lista
			(format t "%s (%s) " ?pregunta (implode$ ?valores-permitidos))		;;	de valores permitidos
			(bind ?respuesta (read))
			(while (numberp ?respuesta) do
				(format t "%s (%s) " ?pregunta (implode$ ?valores-permitidos))
				(bind ?respuesta (read))
			)
		)
		(lowcase ?respuesta)													;;	Para el tratamiento de los datos, lo convertimos a minuscula																	;;	minuscula
	)

	;; Pregunta numerica con valores discretos:
	(deffunction pregunta_numerica (?pregunta $?valores-permitidos)				;;	Dada una pregunta y un conjunto de respuestas permitidas
		(format t "%s: " ?pregunta)												;;	Imprimimos la pregunta
		(bind ?respuesta (read))												;; 	Captamos la respuesta
		(while (and (neq ?respuesta 1)(neq ?respuesta 2)(neq ?respuesta 3)
				(neq ?respuesta consejo)(neq ?respuesta Consejo)
				(neq ?respuesta Siguiente)(neq ?respuesta siguiente)) do		;;	Mientras no sean los valores permitidos
			(format t "%s (%s): " ?pregunta (implode$ ?valores-permitidos))		;;	Volver a formular la pregunta
			(bind ?respuesta (read))
		)
		(if (numberp ?respuesta)												;;	Si la respuesta es un numero lo devolvemos
			then ?respuesta														;;	Si es alguna de las variables de control la devolvemos
			else (lowcase ?respuesta)											;;	en minuscula
		)
	)

	(deffunction pregunta_cantidad (?pregunta)									;;	Dada una pregunta
		(format t "%s: " ?pregunta)												;;	Imprimimos la pregunta
		(bind ?respuesta (read))												;; 	Captamos la respuesta
		(while (not (numberp ?respuesta)) do									;;	Mientras no sea un numero
			(format t "%s (Introduce un numero):" ?pregunta)					;;	Volver a formular la pregunta
			(bind ?respuesta (read))
		)																		;;	Si la respuesta es un numero lo devolvemos
		then ?respuesta
	)

	;; Comprobar que pide consejo: (Aunque se puede realizar en una regla solo comprobando (eq ?respuesta consejo), dicho mecanismo es
	;;	mucho mas entendible para el usuario.
	(deffunction pide_consejo (?respuesta)
		(if (eq ?respuesta consejo)
			then TRUE
			else FALSE
		)
	)

	;; Comprobar que no quiere contestar: (Aunque se puede realizar en una regla solo comprobando (eq ?respuesta siguiente), dicho mecanismo
	;;	es mucho mas entendible para el usuario.
	(deffunction no_quiere_contestar (?respuesta)
		(if (eq ?respuesta siguiente)
			then TRUE
			else FALSE
		)
	)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;																			;;;;;;;;;;;
;;;;;;;;;;;;;;;;;						REGLAS DEL PROGRAMA									;;;;;;;;;;;
;;;;;;;;;;;;;;;;;																			;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modulo menu inicial
(defmodule Inicio (import preguntas deffunction pregunta))

	(defrule Bienvenido_inicio
		(declare (salience 1))
		=>
		(printout t "Hola! Bienvenido al sistema de asesoramiento de la UGR sobre la carrera de Ingenieria
		Informatica. A continuacion le haremos  una serie de preguntas para aconsejarle correctamente." crlf)
		(bind ?respuesta (pregunta "Quiere asesoramiento sobre ramas o sobre asignaturas?  Responde 'Ramas', 'Asignaturas'
						o si quiere salir introduce 'Salir'" ramas asignaturas salir))
		(focus ?respuesta)
	)


;; Modulo ramas
(defmodule ramas (import preguntas deffunction ?ALL))

	;; Regla introductoria:
	(defrule Bienvenido
		=>
		(printout t "Hola! Bienvenido al sistema de asesoramiento de ramas de Ingenieria Informatica, a continuacion le haremos
		una serie de preguntas para aconsejarle correctamente." crlf)
		(printout t "Si en algun momento desea terminar y pedir consejo, reponda con 'Consejo'." crlf)
		(assert (bienvenido))
	)

	;; Pregunta numero 1:
	(defrule Pregunta_1
		(bienvenido)
		=>
		(bind ?respuesta (pregunta "Le gustan las Matematicas?  Responde 'Si' o 'No'" si no consejo))
		(if (pide_consejo ?respuesta)
			then (assert (consejo))
			else (assert (matematicas ?respuesta))
		)
	)

	;; Pregunta numero 2: Rama 1 del arbol de clasificacion creado en la adquisicion del conocimiento

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

	;; Opcion de no contestar a dicha pregunta. Seguiriamos preguntando pero la pregunta no contestada ya es hoja del arbol
	;; Asi terminamos preguntas y aconsejamos

	(defrule no_contesta_pregunta_2
		?f <- (no_contesta_pregunta_2)
		=>
		(retract ?f)
		(assert (consejo))
	)

	;; Reglas para convertir caracteristicas numericas en no numericas.

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

	;; Pregunta numero 3: Rama 2 del arbol de clasificacion creado en la adquisicion del conocimiento

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

	;; Pregunta numero 4: Rama 2.1 del arbol de clasificacion creado en la adquisicion del conocimiento

	(defrule Pregunta_4
		(informatica software)
		=>
		(printout t "Indique que calificacion media tiene en la carrera actualmente. Si no desea contestar responda 'Siguiente'" crlf)
		(assert (comprobar_respuesta (read)))
	)

	;; Hemos decidido efectuar en reglas las comprobaciones de entrada de esta pregunta para apoyar la decision de realizar funciones en las
	;; comprobaciones ya que se convierte en algo bastante tedioso y poco entendible

	;; Regla comprobar que es un numero y pertenece al rango de valores posibles

	(defrule comprobar_respuesta_nota
		?f <- (comprobar_respuesta ?nota)
		(test (numberp ?nota))
		(test (and (>= ?nota 5)(<= ?nota 10)))
		=>
		(retract ?f)
		(assert (nota_numerica ?nota))
	)

	;; Regla comprobar que pide consejo

	(defrule comprobar_respuesta_nota_consejo
		?f <- (comprobar_respuesta ?nota)
		(test (not (numberp ?nota)))
		(test (or (eq ?nota Consejo)(eq ?nota consejo)))
		=>
		(retract ?f)
		(assert (consejo))
	)

	;; Regla comprobar que no quiere contestar

	(defrule comprobar_respuesta_nota_siguiente
		?f <- (comprobar_respuesta ?nota)
		(test (not (numberp ?nota)))
		(test (or (eq ?nota Siguiente)(eq ?nota siguiente)))
		=>
		(retract ?f)
		(assert (no_contesta_pregunta_4))
	)

	;; Opcion de no contestar a dicha pregunta. Seguiriamos preguntando pero la pregunta no contestada ya es hoja del arbol
	;; Asi terminamos preguntas y aconsejamos.

	(defrule no_contesta_pregunta_4
		?f <- (no_contesta_pregunta_4)
		=>
		(retract ?f)
		(assert (consejo))
	)

	;; Regla comprobar que no ha introducido ningun valor correcto, vuelve a preguntar

	(defrule comprobar_respuesta_nota_fallo
		?f <- (comprobar_respuesta ?nota)
		(test (not (numberp ?nota)))
		(test (and (neq ?nota Siguiente)(neq ?nota siguiente)(neq ?nota Consejo)(neq ?nota consejo)))
		=>
		(retract ?f)
		(printout t "Error, no ha indicado un numero. Indique que calificacion media tiene en la carrera actualmente" crlf)
		(assert (comprobar_respuesta (read)))
	)

	;; Regla comprobar que no ha introducido ningun numero correcto, vuelve a preguntar

	(defrule comprobar_respuesta_nota_fallo_rango
		?f <- (comprobar_respuesta ?nota)
		(test (numberp ?nota))
		(test (or (< ?nota 5)(> ?nota 10)))
		=>
		(retract ?f)
		(printout t "Error, no ha indicado un numero dentro del rango posible [5-10]. Indique que calificacion media tiene en la carrera actualmente" crlf)
		(assert (comprobar_respuesta (read)))
	)

	;; Reglas para convertir caracteristicas numericas en no numericas.

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

	;; Pregunta numero 5: Rama 2.2 del arbol de clasificacion creado en la adquisicion del conocimiento

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
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;				CONSEJOS				;;;;;;;;;;;;;;
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;; Consejo hoja 1

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
		(assert (cambiar_modulo))
	)

	;;; Consejo hoja 2

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
		(assert (cambiar_modulo))
	)

	;;; Consejo hoja 3

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
		(assert (cambiar_modulo))
	)

	;;; Consejo hoja 4

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
		(assert (cambiar_modulo))
	)

	;;; Consejo hoja 5

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
		(assert (cambiar_modulo))
	)

	;;; Consejo hoja 6

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
		(assert (cambiar_modulo))
	)

	;;; Consejo parcial, hoja 1

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
		(assert (cambiar_modulo))
	)

	;;; Consejo parcial, hoja 2

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
		(assert (cambiar_modulo))
	)

	;;; Consejo parcial, hoja 2 a

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
		(assert (cambiar_modulo))
	)

	;;; Consejo parcial, hoja 2 b

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
		(assert (cambiar_modulo))
	)

	;;; Consejo inicial

	(defrule consejo_inicial
		?h <- (consejo)
		=>
		(retract ?h)
		(printout t crlf)
		(printout t "Aunque no podemos ofrecerte informacion detallada al no haber respondido ninguna pregunta, te aconsejamos CSI debido
			 a que es lo que la mayoria de los alumnos elige" crlf)
		(printout t crlf)
		(assert (cambiar_modulo))
	)

	(defrule cambiar_modulo
		(declare (salience 9997))
		(cambiar_modulo)
		=>
		(printout t crlf "Volvemos al inicio" crlf)
		(printout t crlf crlf)
		(reset)
	)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;				ASIGNATURAS				;;;;;;;;;;;;;;
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modulo asignaturas
(defmodule asignaturas (import preguntas deffunction ?ALL))
	(deftemplate Asignatura
		(field Nombre (type SYMBOL) (default ?NONE))
		(field puntuacion (type NUMBER) (default 0.0))
		(field creditos (type NUMBER) (default 6.0))
	)

	;; Conocimiento base
	(deffacts hechos_asignaturas
		(puntuacion_max -99999)
		(asignatura pdoo)
		(asignatura scd)
		(asignatura so)
		(asignatura ed)
		(asignatura ec)
		(asignatura fis)
		(asignatura alg)
		(asignatura fdb)
		(asignatura ia)
		(asignatura ac)
		(asignatura ig)
		(asignatura ddsi)
		(asignatura mc)
		(asignatura fr)
		(asignatura ise)
		(asignatura aa)
		(asignatura ic)
		(asignatura mca)
		(asignatura mh)
		(asignatura tsi)
		(asignatura practicas)
		(campo_informatica scd hardware seguro)
		(campo_informatica ec hardware seguro)
		(campo_informatica ac hardware seguro)
		(campo_informatica ise hardware seguro)
		(campo_informatica fr hardware seguro)
		(campo_informatica ed hardware seguro)
		(carga_trabajo fis baja seguro)
		(carga_trabajo ddsi baja seguro)
		(carga_trabajo scd baja seguro)
		(carga_trabajo fdb baja seguro)
		(carga_trabajo alg baja seguro)
		(carga_trabajo ac baja seguro)
		(grado_programacion so bajo seguro)
		(grado_programacion fdb bajo seguro)
		(grado_programacion ddsi bajo seguro)
		(grado_programacion mca bajo seguro)
		(grado_programacion mc bajo seguro)
		(creditos practicas 12)
	)

	;; Pregunta número 1: El usuario indica un conjunto de asignaturas de la lista de posibles:
	(defrule Elige_asignaturas
		(not (elegidas))
		=>
  		(printout t "Que asignaturas quiere cursar?" crlf)
  		(printout t "pdoo scd so ed ec fis alg fbd ia ac ig ddsi mc fr ise aa ic mca mh tsi practicas" crlf)
		(bind ?respuesta (explode$ (readline)))
		(assert (elegidas) (eleccion ?respuesta))
	)

	;; Introducimos en el conocimiento las asignaturas elegidas
	(defrule assert_asignaturas
  		?f <- (eleccion ?nombre $?otras)
  		=>
  		(retract ?f)
  		(assert (Asignatura
        			(Nombre ?nombre)
        			(puntuacion 0)
				(creditos 6)))
  		(assert (ComprobarEleccion ?nombre))
  		(assert (eleccion $?otras))
	)

	;; Borramos el hecho eleccion y pasamos a comprar si las asignaturas son correctas
	(defrule borrar_eleccion
  		?f <- (eleccion)
  		=>
  		(retract ?f)
	)

	;; Si no estan en el conimiento base la consideramos incorrecta
	(defrule Comprobar_asignaturas_incorrecta
  		?f <- (ComprobarEleccion ?n)
  		?g <- (Asignatura
        			(Nombre ?n)
        			(puntuacion 0)
				(creditos 6))
		(not (asignatura ?n))
  		=>
  		(retract ?f ?g)
  		(printout t "La opcion " ?n " no es valida." crlf)
	)

	; Retractamos cuando hay algo en contra
	(defrule retracta_creditos
		(declare (salience 5))         											; para retractar antes de inferir cosas erroneamente
		?f <- (Asignatura
        			(Nombre ?n)
        			(puntuacion 0)
				(creditos 6))
		(creditos ?n ?creditos)
		=>
		(retract ?f)
		(printout t "Retractamos que " ?n " tiene 6 creditos, porque sabemos seguro que " ?n " es tiene " ?creditos " creditos seguro " crlf)
		(assert (Asignatura
        			(Nombre ?n)
        			(puntuacion 0)
				(creditos ?creditos)))
	)


	;; Si estan en el conimiento base la consideramos correcta
	(defrule Comprobar_asignaturas_correcta
		(declare (salience 5))
  		?f <- (ComprobarEleccion ?n)
		(asignatura ?n)
  		=>
  		(retract ?f)
		(assert (creditos_no_contados ?n))
  		(printout t "La opcion " ?n " es valida." crlf)
	)

	;; Pregunta número 2: Cuantos creditos se quiere matricular
	(defrule Pregunta_creditos
		(not (creditos_a_matricular ?))
		=>
		(bind ?respuesta (pregunta_cantidad "De cuantos creditos se quiere matricular como minimo?"))
		(assert (creditos_a_matricular ?respuesta) (comprobar_creditos ?respuesta) (comprobar_creditos_suficientes ?respuesta))
	)

	;; Comprobamos que los creditos elegidos esten entre 6 y 72, si no vuelve a pedir dicho numero al usuario
	(defrule Comprobar_creditos_incorrecta
  		?f <- (comprobar_creditos ?respuesta)
		?h <- (comprobar_creditos_suficientes ?respuesta)
  		?g <- (creditos_a_matricular ?respuesta)
  		(test (or (> ?respuesta 72) (< ?respuesta 6) (not (integerp ?respuesta))))
  		=>
  		(retract ?f ?g ?h)
  		(printout t "La eleccion de creditos (" ?respuesta " creditos) no es valida. Introduce un numero entero entre 6 y 72" crlf)
	)

	;; Comprobamos que los creditos elegidos esten entre 6 y 72
	(defrule Comprobar_creditos_correcta
  		?f <- (comprobar_creditos ?respuesta)
		(test (and (< ?respuesta 73) (> ?respuesta 5) (integerp ?respuesta)))
  		=>
  		(retract ?f)
  		(printout t "La eleccion de creditos (" ?respuesta " creditos) es valida." crlf)
	)

	;; Comprobamos que las asignaturas escogidas puedan sumar los creditos introducidos
	(defrule comprobar_creditos_insuficientes
		(declare (salience -1))
		(creditos_a_matricular ?total)
		?f <- (comprobar_creditos_suficientes ?respuesta)
		(not (creditos_no_contados ?n))
		(test (> ?respuesta 0))
		=>
  		(retract ?f)
		(assert (no_suficientes_creditos) (comprobar_creditos_suficientes ?total))
	)

	;; Comprobamos que las asignaturas escogidas puedan sumar los creditos introducidos. En este caso como no suman, vuelve a pedir asignaturas
	(defrule creditos_insuficientes
		(declare (salience 2))
		?f <- (elegidas)
		?g <- (no_suficientes_creditos)
		?h <- (Asignatura
        			(Nombre ?n)
        			(puntuacion 0)
				(creditos ?))
		=>
		(retract ?f ?g)
		(assert (elminar asignaturas))
		(printout t "El numero de creditos es mayor que el sumado por las asignaturas que ha elegido. Vuelve a elegir, pero esta vez mas" crlf)
	)

	;; Elimina las asignaturas escogidas si no suman los suficientes creditos
	(defrule eliminar_asignaturas
		(declare (salience 3))
		(elminar asignaturas)
		?f <- (Asignatura
        			(Nombre ?n)
        			(puntuacion 0)
				(creditos ?))
		=>
		(retract ?f)
	)

	;; Elimina el hecho de control para eliminar las asignaturas escogidas si no suman los suficientes creditos
	(defrule eliminar_eliminar_asignaturas
		(declare (salience 3))
		?f <- (elminar asignaturas)
		(not (Asignatura
        			(Nombre ?)
        			(puntuacion 0)
				(creditos ?)))
		=>
		(retract ?f)
	)

	;; Comprobamos que las asignaturas escogidas puedan sumar los creditos introducidos
	(defrule comprobar_creditos_suficientes
		?f <- (comprobar_creditos_suficientes ?respuesta)
		(Asignatura
        		(Nombre ?n)
        		(puntuacion 0)
			(creditos ?nc))
		?g <- (creditos_no_contados ?n)
		(test (> ?respuesta 0))
		=>
  		(retract ?f ?g)
		(assert (comprobar_creditos_suficientes (- ?respuesta ?nc)))
	)

	;; Comprobamos que las asignaturas escogidas puedan sumar los creditos introducidos. En este caso como suman, sigue adelante
	(defrule creditos_suficientes
		?f <- (comprobar_creditos_suficientes ?respuesta)
		(test (<= ?respuesta 0))
		=>
  		(retract ?f)
		(assert (eliminar_comprobados))
	)

	;; Elimina el hecho de control que sirve para comprobar si las asignaturas se han contado en la suma o no
	(defrule eliminar_comprobados
		(eliminar_comprobados)
		?f <- (creditos_no_contados ?n)
		=>
  		(retract ?f)
	)


	;; Elimina el hecho de control que comprueba asignaturas con los creditos
	(defrule eliminar_eliminar_comprobados
		?f <- (eliminar_comprobados)
		(not (creditos_no_contados ?))
		=>
  		(retract ?f)
		(assert (fase preguntas))
	)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;			Logica por defecto			;;;;;;;;;;;;;;
;;;;;;;;;;										;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Asume que todas las asignaturas tienen mas parte de software que de hardware por defecto
	(defrule software_por_defecto
		(declare (salience -1))
		(asignatura ?nombre)
		(Asignatura
        			(Nombre ?nombre)
        			(puntuacion 0)
				(creditos ?))
		=>
		(assert (campo_informatica ?nombre software por_defecto))
		(printout t "Asumo que " ?nombre " tiene una mayor aportacion de software que de hardware, porque casi todas las asignaturas son de software" crlf)
	)

	; Retractamos cuando hay algo en contra con respecto al software-hardware
	(defrule retracta_software_por_defecto
		(declare (salience 1))        											; para retractar antes de inferir cosas erroneamente
		?f <- (campo_informatica ?nombre software por_defecto)
		(campo_informatica ?nombre hardware seguro)
		=>
		(retract ?f)
		(printout t "Retractamos que " ?nombre " tiene una mayor aportacion de software que de hardware por defecto, porque sabemos seguro que " ?nombre " es de hardware" crlf)
	)


	;; Pregunta numero 1
	(defrule Pregunta_1
		(declare (salience -5))
		(fase preguntas)
		=>
		(bind ?respuesta (pregunta "Le gusta mas el Sofware o el Hardware? Responde 'Software' o 'Hardware'"
			software hardware))
		(assert (prefiere campo_informatica ?respuesta))
	)

	;; Aporta valor a aquellas asignaturas que se correspondan con la pregunta anterior
	(defrule consecuencias_pregunta_1
		(prefiere campo_informatica ?respuesta)
		?g <- (campo_informatica ?nombre ?respuesta ?)
		?f <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		=>
		(retract ?f ?g)
		(bind ?expl (str-cat "Como prefiere " ?respuesta " consideramos que " ?nombre " es buena opcion."))
		(assert (Asignatura
        			(Nombre ?nombre)
        			(puntuacion (+ ?puntuacion 1))
				(creditos ?c)))
		(assert (explicacion ?nombre ?expl))
	)

	;; Asume que todas las asignaturas tienen carga de trabajo alta por defecto
	(defrule carga_de_trabajo_alta_por_defecto
		(declare (salience -1))
		(asignatura ?nombre)
		(Asignatura
        			(Nombre ?nombre)
        			(puntuacion 0)
				(creditos ?))
		=>
		(assert (carga_trabajo ?nombre alta por_defecto))
		(printout t "Asumo que " ?nombre " tiene una carga de trabajo alta, porque casi todas las asignaturas tienen una carga de trabajo alta" crlf)
	)

	; Retractamos cuando hay algo en contra con respecto a la carga de trabajo
	(defrule retracta_carga_de_trabajo_alta_por_defecto
		(declare (salience 1))         											; para retractar antes de inferir cosas erroneamente
		?f <- (carga_trabajo ?nombre alta por_defecto)
		(carga_trabajo ?nombre baja seguro)
		=>
		(retract ?f)
		(printout t "Retractamos que " ?nombre " tiene una carga de trabajo alta, porque sabemos seguro que " ?nombre " tiene una carga de trabajo baja" crlf)
	)

	;; Pregunta numero 2
	(defrule Pregunta_2
		(declare (salience -5))
		(prefiere campo_informatica hardware)
		(fase preguntas)
		=>
		(bind ?respuesta (pregunta "Prefiere una carga de trabajo alta o baja? Responde 'Alta' o 'Baja' (Si quiere salir pida consejo)"
			alta baja consejo))
		(if (pide_consejo ?respuesta)
			then (assert (consejo))
			else (assert (prefiere carga_trabajo ?respuesta))
		)
	)

	;; Aporta valor a aquellas asignaturas que se correspondan con la pregunta anterior
	(defrule consecuencias_pregunta_2
		(prefiere carga_trabajo ?respuesta)
		?g <- (carga_trabajo ?nombre ?respuesta ?)
		?f <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		=>
		(retract ?f ?g)
		(bind ?expl (str-cat "Como prefiere una carga de trabajo " ?respuesta " consideramos que " ?nombre " es buena opcion."))
		(assert (Asignatura
        			(Nombre ?nombre)
        			(puntuacion (+ ?puntuacion 1))
				(creditos ?c)))
		(assert (explicacion ?nombre ?expl))
		(assert (consejo))
	)

	;; Como es rama del arbol de decisión, incluye consejo si no hay asignaturas que se correspondan con la pregunta anterior
	(defrule consecuencias_pregunta_2_sin_casos
		(prefiere carga_trabajo ?respuesta)
		(carga_trabajo ?nombre ?respuesta ?)
		(not (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c)))
		=>
		(assert (consejo))
	)


	;; Asume que todas las asignaturas tienen tienen un grado de programacion alto por defecto
	(defrule grado_programacion_alto_por_defecto
		(declare (salience -1))
		(asignatura ?nombre)
		(Asignatura
        			(Nombre ?nombre)
        			(puntuacion 0)
				(creditos ?))
		=>
		(assert (grado_programacion ?nombre alto por_defecto))
		(printout t "Asumo que " ?nombre " tiene un grado de programacion alto, porque casi todas las asignaturas tienen una grado de programacion alto" crlf)
	)

	; Retractamos cuando hay algo en contra con respecto al grado de programacion
	(defrule retracta_grado_programacion_alto_por_defecto
		(declare (salience 1))         											; para retractar antes de inferir cosas erroneamente
		?f <- (grado_programacion ?nombre alto por_defecto)
		(grado_programacion ?nombre bajo seguro)
		=>
		(retract ?f)
		(printout t "Retractamos que " ?nombre " tiene un grado de programacion alto, porque sabemos seguro que " ?nombre " tiene un grado de programacion bajo" crlf)
	)

	;; Pregunta numero 3
	(defrule Pregunta_3
		(declare (salience -5))
		(prefiere campo_informatica software)
		(fase preguntas)
		=>
		(bind ?respuesta (pregunta "Prefiere una grado de programacion alto o bajo? Responde 'Alto' o 'Bajo' (Si quiere salir pida consejo)"
			alto bajo consejo))
		(if (pide_consejo ?respuesta)
			then (assert (consejo))
			else (assert (prefiere grado_programacion ?respuesta))
		)
	)

	;; Aporta valor a aquellas asignaturas que se correspondan con la pregunta anterior
	(defrule consecuencias_pregunta_3
		(prefiere grado_programacion ?respuesta)
		?g <- (grado_programacion ?nombre ?respuesta ?)
		?f <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		=>
		(retract ?f ?g)
		(bind ?expl (str-cat "Como prefiere una grado de programacion " ?respuesta " consideramos que " ?nombre " es buena opcion."))
		(assert (Asignatura
        			(Nombre ?nombre)
        			(puntuacion (+ ?puntuacion 1))
				(creditos ?c)))
		(assert (explicacion ?nombre ?expl))
		(assert (consejo))
	)

	;; Como es rama del arbol de decisión, incluye consejo si no hay asignaturas que se correspondan con la pregunta anterior
	(defrule consecuencias_pregunta_3_sin_casos
		(prefiere grado_programacion ?respuesta)
		(grado_programacion ?nombre ?respuesta ?)
		(not (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c)))
		=>
		(assert (consejo))
	)

	;; Calcula el máximo entre varias puntuaciones desde un template
	(defrule max_puntuacion
    		(declare (salience 9998))
		(consejo)
		?f <- (puntuacion_max ?max)
		(Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?p)
			(creditos ?c))
		(test (> ?p ?max))
		=>
		(bind ?max ?p)
		(retract ?f)
		(assert (puntuacion_max ?max))
	)

	;; Elimina la fase de preguntas
	(defrule eliminar_fase_preguntas
		(declare (salience 9999))
		(consejo)
		?f <- (fase preguntas)
		=>
		(retract ?f)
	)

	;; Consejo mientras no se completen los creditos
	(defrule consejo
    		(declare (salience 9997))
    		?f <- (consejo)
    		?g <- (puntuacion_max ?puntuacion)
		?h <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		?i <- (creditos_a_matricular ?c_respuesta)
		(test (> (- ?c_respuesta ?c) 0))
    		=>
    		(retract ?f ?g ?h ?i)
		(assert (recomendar ?nombre))
		(assert (creditos_a_matricular (- ?c_respuesta ?c)))
    		(printout t crlf "-- Recomendamos la asignatura " ?nombre crlf)
    		(assert (puntuacion_max -1)(consejo))
	)

	;; Consejo ultima asignatura
	(defrule consejo_ultima
    		(declare (salience 9997))
    		?f <- (consejo)
    		?g <- (puntuacion_max ?puntuacion)
		?h <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		?i <- (creditos_a_matricular ?c_respuesta)
		(test (eq (- ?c_respuesta ?c) 0))
    		=>
    		(retract ?f ?g ?h ?i)
		(assert (recomendar ?nombre))
		(assert (creditos_a_matricular (- ?c_respuesta ?c)))
    		(printout t crlf "-- Recomendamos la asignatura " ?nombre crlf)
		(assert (cambiar_modulo))
	)

	;; Consejo ultima asignatura si se pasan de creditos
	(defrule consejo_pasado
    		(declare (salience 9996))
    		?f <- (consejo)
    		?g <- (puntuacion_max ?puntuacion)
		?h <- (Asignatura
        		(Nombre ?nombre)
        		(puntuacion ?puntuacion)
			(creditos ?c))
		?i <- (creditos_a_matricular ?c_respuesta)
		(test (< (- ?c_respuesta ?c) 0))
    		=>
    		(retract ?f ?g ?h ?i)
		(assert (recomendar ?nombre))
		(assert (creditos_a_matricular (- ?c_respuesta ?c)))
		(bind ?creditos (- ?c ?c_respuesta))
    		(printout t crlf "-- Aunque nos pasamos " ?creditos " creditos de lo pedido, al no existir combinaciones de asignaturas con dichos creditos, la ultima asignatura que le recomendamos es " ?nombre crlf)
		(assert (cambiar_modulo))
	)

	;; Recomendamos asignaturas
	(defrule recomendar
		(declare (salience 9999))
		(recomendar ?nombre)
		?f <- (explicacion ?nombre ?expl)
		=>
		(retract ?f)
		(printout t ?expl crlf)
	)

	;; Elimina hecho de control para parar de recomendar una asignatura
	(defrule eliminar_recomendar
		(declare (salience 9998))
		?f <- (recomendar ?nombre)
		(not (explicacion ?nombre ?))
		=>
		(retract ?f)
	)

	;; Volvemos al inicio
	(defrule cambiar_modulo
		(declare (salience 9997))
		(cambiar_modulo)
		=>
		(printout t crlf "Volvemos al inicio" crlf)
		(printout t crlf crlf)
		(reset)
	)

;; Modulo vacio para salir.
(defmodule salir)
