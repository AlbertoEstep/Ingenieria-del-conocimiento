;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	Modifica el ejercicio anterior para que en la memoria de trabajo siempre aparezca actualizado el hecho (NumeroHechos XXX n), 
;;	sin que sea necesario “invocar” a ContarHechos.

;; Hechos iniciales
(deffacts hechos_iniciales
	(Hecho XXX a B)
	(Hecho XXX b)
	(Hecho CCC c)
	(Hecho XXX d)
)

(defrule iniciar_contador
	(Hecho ?XXX $?h)
  	(not (ContadorYaIniciado ?XXX))
	=>
	(assert (NumeroHechos ?XXX 0) (ContadorYaIniciado ?XXX))
)

(defrule contar_hecho
	(Hecho ?XXX $?h)
  	(not (HechoContado ?XXX $?h))
	?f <- (NumeroHechos ?XXX ?n)
	=>
	(assert (HechoContado ?XXX $?h))
	(retract ?f)
	(assert (NumeroHechos ?XXX (+ 1 ?n))) 
)

(defrule borrar_contador_ya_iniciado
	(declare (salience -2))
	?f <- (ContadorYaIniciado ?XXX)
	=>
	(retract ?f)
)


(defrule borrar_hecho_contado
	(declare (salience -1))
	?f <- (HechoContado ?XXX $?h)
	=>
	(retract ?f)
)

;; NO TERMINADO, ESTUDIAR QUE CUANDO SE INSERTE UN HECHO SE CUENTE (SI NO ES DE LOS HECHOS DEL PRINCIPIO) 
;; Y ESTUDIAR SI BORRAR LO DEL CONTADOR YA INICIADO YA QUE NO LO HE PROBAO


