;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	Crea un trozo de código que muestre al usuario un conjunto de opciones y recoja la elección del usuario añadiendo 
;;	el hecho (OpcionElegida  XXX), siendo XXX la etiqueta utilizada para la opción elegida. Debe detectar errores en 
;;	la entrada y volver a solicitar la elecciónen caso de error.

(defrule Bienvenido
	=> 
	(printout t "Hola! Bienvenido al sistema. estas son las opciones:" crlf)
	(printout t "AAA Opcion A" crlf)
	(printout t "BBB Opcion b" crlf)
	(bind ?respuesta (read))
	(while (not (or (eq ?respuesta AAA) (eq ?respuesta BBB))) do
		(printout t "Estas son las opciones, indica la opcion escogida escribiendo el codigo del principio de la opcion en mayuscula:" crlf)
		(printout t "AAA Opcion A" crlf)
		(printout t "BBB Opcion b" crlf)
		(bind ?respuesta (read))
	)
	(assert (bienvenido) (OpcionElegida ?respuesta))
)
