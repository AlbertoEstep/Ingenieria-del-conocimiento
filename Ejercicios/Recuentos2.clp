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
	(not (NumeroHechos ?XXX ?n))
	=>
	(assert (NumeroHechos ?XXX 0))
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

;; Dejamos los hechos HechoContado ?XXX $?h ya que si se inserta algun hecho necesitamos saber si hemos contado o no los otros hechos.

