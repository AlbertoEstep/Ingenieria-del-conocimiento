;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	Modifica el ejercicio anterior para permitir selección múltiple, de forma que al final resulten varios 
;;	hechos (OpcionElegida XXX)

(defrule Bienvenido
	=> 
	(printout t "Hola! Bienvenido al sistema. estas son las opciones:" crlf)
	(printout t "AAA Opcion A" crlf)
	(printout t "BBB Opcion b" crlf)
	(printout t "CCC Opcion c" crlf)
	(bind ?respuesta (read))
	(while (not (or (eq ?respuesta AAA) (eq ?respuesta BBB))) do
		(printout t "Estas son las opciones, indica la opcion escogida escribiendo el codigo del principio de la opcion en mayuscula:" crlf)
		(printout t "AAA Opcion A" crlf)
		(printout t "BBB Opcion b" crlf)
		(bind ?respuesta (read))
	)
	(assert (bienvenido) (OpcionElegida ?respuesta))
)

;; NO HECHO
