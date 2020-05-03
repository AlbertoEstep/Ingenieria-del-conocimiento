;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	Cuando aparezca el hecho (ContarHechos XXX), añada un hecho (NumeroHechos XXX n), siendo n el número de hechos de tipo XXX.

;; Hechos iniciales
(deffacts hechos_iniciales
	(Hecho XXX a B)
	(Hecho XXX b)
	(Hecho CCC c)
	(Hecho XXX d)
	(ContarHechos XXX)
	(ContarHechos CCC)
	(ContarHechos DDD)
)

(defrule iniciar_contador
	(ContarHechos ?XXX)
	=>
	(assert (NumeroHechos ?XXX 0))
)

(defrule contar_hecho
	(Hecho ?XXX $?h)
	(ContarHechos ?XXX)
  	(not (HechoContado ?XXX $?h))
	?f <- (NumeroHechos ?XXX ?n)
	=>
	(assert (HechoContado ?XXX $?h))
	(retract ?f)
	(assert (NumeroHechos ?XXX (+ 1 ?n))) 
)

(defrule borrar_contar_hechos
	(declare (salience -1))
	?f <- (ContarHechos ?XXX)
	=>
	(retract ?f)
)

(defrule borrar_hecho_contado
	(declare (salience -2))
	?f <- (HechoContado ?XXX $?h)
	=>
	(retract ?f)
)


