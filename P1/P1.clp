;; Autor: Alberto Estepa Fernández
;; Fecha: 7 de abril de 2020

;; Programa en CLIPS que:
;;	- Le pregunte, al usuario que pide asesoramiento, lo que le preguntaría al compañero que hace de experto.
;;	- Realice los razonamientos que haría el compañero que hace de experto
;;	- Le aconseje la rama o las ramas que le aconsejaría el compañero junto con los motivos por lo que se lo aconsejaría.

(deffacts Ramas
	(Rama Computacion_y_Sistemas_Inteligentes)
	(Rama Ingenieria_del_Software)
	(Rama Ingenieria_de_Computadores)
	(Rama Sistemas_de_Informacion)
	(Rama Tecnologias_de_la_Informacion)
)

(defrule Bienvenido
	=> 
	(printout t "Hola! Bienvenido al sistema de asesoramiento de ramas de Ingenieria Informatica, a continuacion le haremos 
	una serie de preguntas para aconsejarle correctamente." crlf)
	(printout t "Si en algun momento desea terminar y pedir consejo, reponda con 'consejo'." crlf)
	(assert (bienvenido))
)
	

(defrule Pregunta_1
	(bienvenido)
	=>
	(printout t "Le gustan las Matematicas? Responde 'S' o 'N' si su respuesta es Si o No respectivamente" crlf)
	(assert (matematicas (read)))
)


(defrule Pregunta_2
	(bienvenido)
	(matematicas $?)
	=>
	(printout t "Le gusta mas el Sofware o el Hardware? Responde 'S' o 'H' si su respuesta es Software o Hardware respectivamente" crlf)
	(assert (informatica (read)))
)

(defrule Pregunta_3
	(bienvenido)
	(matematicas $?)
	(informatica $?)
	=>
	(printout t "Indique que calificacion media tiene en la carrera actualmente" crlf)
	(assert (nota_numerica (read)))
)

(defrule Check_nota_correcta
	(declare (salience 9999))
	(nota_numerica ?n)
	(test (numberp ?n))
	=>
	(assert (ckeck_nota))
)

(defrule Check_nota_incorrecta
	(declare (salience 9999))
	?f <- (nota_numerica ?n)
	(test (not (numberp ?n)))
	=>
	(printout t "No ha introducido los parametros correctos" crlf)
	(retract ?f)
)

(defrule Convertir_nota_alta
	?g <- (ckeck_nota)
	?f <- (nota_numerica ?n)
	(test (>= ?n 8))
	=>
	(retract ?f)
	(retract ?g)
	(assert (nota alta))
)

(defrule Convertir_nota_media
	?g <- (ckeck_nota)
	?f <- (nota_numerica ?n)
	(test (and 
		(< ?n 8)
		(>= ?n 6.5)))
	=>
	(retract ?f)
	(retract ?g)
	(assert (nota media))
)

(defrule Convertir_nota_baja
	?g <- (ckeck_nota)
	?f <- (nota_numerica ?n)
	(test  (< ?n 6.5))
	=>
	(retract ?f)
	(retract ?g)
	(assert (nota baja))
)