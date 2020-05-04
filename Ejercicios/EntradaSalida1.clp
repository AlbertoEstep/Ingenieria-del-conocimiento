;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	Crea un trozo de codigo que escriba en un fichero los valores de un vector (WRITE ?x1 ?x2 ...?xn), con n indefinido.


;; Hechos iniciales
(deffacts hechos_iniciales
	(WRITE a b c d e f)
)

(defrule escribir
	?f <- (WRITE ?palabra $?despues)
	=>
	(open "datos.txt" datos "a")
	(printout datos ?palabra " ")
	(close datos)
	(retract ?f)
	(assert (WRITE $?despues))
)

(defrule borrarWRITE
	(declare (salience -1))
	?f <- (WRITE)
	=>
	(retract ?f)
)


