;; Autor: Alberto Estepa Fernández
;; Fecha: 5 de mayo de 2020

;; Programa en CLIPS que:
;;	pregunte por un animal y responda si ese animal vuela o no, basado en el siguiente conocimiento:
;;		-Las aves casi todas vuelan
;;		-La mayor parte de los animales no vuelan
;;		-Las aves y los mamíferos son animales
;;		-Los gorriones, las palomas, las águilas y los pingüinos son aves
;;		-La vaca, los perros y los caballos son mamíferos
;;		-Los pingüinos no vuelan

;;;;;;;;;;;;;;;;;;Representación ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (ave ?x) representa "x es un ave"
; (animal ?x) representa "?x es un animal"
; (vuela ?x  si|no seguro|por_defecto) representa "?x vuela si|no con esa certeza"

;; Hechos iniciales
;Las aves y los mamíferos son animales
;Los gorriones, las palomas, las águilas y los pingüinos son aves
;La vaca, los perros y los caballos son mamíferos
;Los pingüinos no vuelan

(deffacts datos
	(ave gorrion) (ave paloma) (ave aguila) (ave pinguino)
	(mamifero vaca) (mamifero perro) (mamifero caballo) 
	(vuela pinguino no seguro)
)


; Las aves son animales 
(defrule aves_son_animales
	(ave ?x)
	=>
	(assert (animal ?x))               
	(bind ?expl (str-cat "sabemos que un " ?x " es un animal porque las aves son un tipo de animal"))
	(assert (explicacion animal ?x ?expl))    
)
; añadimos un hecho que contiene la explicación de la deducción

; Los mamiferos son animales (A3)
(defrule mamiferos_son_animales
	(mamifero ?x)
	=>
	(assert (animal ?x))
	(bind ?expl (str-cat "sabemos que un " ?x " es un animal porque los mamiferos son un tipo de animal"))
	(assert (explicacion animal ?x ?expl))
)
; añadimos un hecho que contiene la explicación de la deducción

;;; Casi todos las aves vuela --> puedo asumir por defecto que las aves vuelan
; Asumimos por defecto
(defrule ave_vuela_por_defecto
	(declare (salience -1))   ; para disminuir probabilidad de añadir erróneamente
	(ave ?x)
	=>
	(assert (vuela ?x si por_defecto))
	(bind ?expl (str-cat "asumo que un " ?x " vuela, porque casi todas las aves vuelan"))
	(assert (explicacion vuela ?x ?expl))              
)

; Retractamos cuando hay algo en contra
(defrule retracta_vuela_por_defecto
	(declare (salience 1))	; para retractar antes de inferir cosas erroneamente
	?f <- (vuela ?x ?r por_defecto)
	(vuela ?x ?s seguro)
	=>
	(retract ?f)
	(bind ?expl (str-cat "retractamos que un " ?x ?r " vuela por defecto, porque sabemos seguro que " ?x ?s " vuela"))
	(assert (explicacion retracta_vuela ?x ?expl))    
)
;;; COMETARIO: esta regla también elimina los por defecto cuando ya esta seguro

;; La mayor parte de los animales no vuelan --> puede interesarme asumir por defecto que un animal no va a volar
(defrule mayor_parte_animales_no_vuelan
	(declare (salience -2))  ;;;; es mas arriesgado, mejor después de otros razonamientos
	(animal ?x)
	(not (vuela ?x ? ?))
	=>
	(assert (vuela ?x no por_defecto))
	(bind ?expl (str-cat "asumo que " ?x " no vuela, porque la mayor parte de los animales no vuelan"))
	(assert (explicacion vuela ?x ?expl))
)

; Completar esta base de conocimiento para que el sistema pregunte que de qué animal esta interesado en obtener información sobre si vuela y:
;	-si es uno de los recogidos en el conocimiento indique si vuela o no.
;	-si no es uno de los recogidos pregunte si es un ave o un mamifero y según la respuesta indique si vuela o no.
;	-Si no se sabe si es un mamifero o un ave tambien responda segun el razonamiento por defecto indicado.

;; Regla para pedir un animal al usuario
(defrule Bienvenido
	=> 
	(printout t "Hola! Bienvenido al sistema. Sobre que animal esta interesado en obtener informacion sobre si vuela:" crlf)
	(bind ?respuesta (read))
	(assert (OpcionElegida ?respuesta))
)

;; Regla para ver si el animal vuela (si está en el conocimiento)
(defrule esta_en_el_sistema
	(declare (salience -3))  ;;;; Una vez hechos los razonamientos
	?f <- (OpcionElegida ?animal)
	(vuela ?animal ?respuesta ?)
	=> 
	(retract ?f)
	(bind ?razonamiento (str-cat "Un " ?animal " " ?respuesta " vuela"))
	(printout t ?razonamiento crlf)
)

;; Regla para pedir si el animal es un ave o mamifero (si no está en el conocimiento)
(defrule no_esta_en_el_sistema
	(OpcionElegida ?animal)
	(not (ave ?animal))
	(not (mamifero ?animal))
	=> 
	(printout t "Indique si es es un ave (escriba AVE) o un mamifero (escriba MAMIFERO) o si no sabe (escriba SIGUIENTE):" crlf)
	(bind ?respuesta (read))
	(while (not (or (eq ?respuesta AVE) (eq ?respuesta ave) (eq ?respuesta MAMIFERO) (eq ?respuesta mamifero) (eq ?respuesta SIGUIENTE) (eq ?respuesta siguiente))) do
		(printout t "No lo ha indicado correctamente, indique si es un AVE o un MAMIFERO o SIGUIENTE si no sabe la respuesta:" crlf)
		(bind ?respuesta (read))
	)
	(assert (elegido (lowcase ?respuesta)))
)


;; Regla para razonar sobre el animal si no sabemos si es ave o mamifero (y si no está en el conocimiento)
(defrule responder_siguiente
	?f <- (OpcionElegida ?animal)
	?g <- (elegido ?respuesta)
	(test (eq ?respuesta siguiente))
	=>
	(assert (inferir ?animal) (animal ?animal))
	(retract ?f)
	(retract ?g)
)

;; Regla solucion sobre el animal si no sabemos si es ave o mamifero (y si no está en el conocimiento)
(defrule solucion_siguiente
	(declare (salience -3))  ;;;; Una vez hechos los razonamientos
	?f <- (inferir ?animal)
	(vuela ?animal ?respuesta ?)
	=>
	(bind ?razonamiento (str-cat "Un " ?animal " " ?respuesta " vuela"))
	(printout t ?razonamiento crlf)
	(retract ?f)
)


;; Regla razonar sobre el animal si es ave (y si no está en el conocimiento)
(defrule responder_ave
	?f <- (OpcionElegida ?animal)
	?g <- (elegido ?respuesta)
	(test (eq ?respuesta ave))
	=>
	(assert (ave ?animal) (inferir ?animal))
	(retract ?f)
	(retract ?g)
)

;; Regla razonar sobre el animal si es mamifero (y si no está en el conocimiento)
(defrule responder_mamifero
	?f <- (OpcionElegida ?animal)
	?g <- (elegido ?respuesta)
	(test (eq ?respuesta mamifero))
	=>
	(assert (mamifero ?animal) (inferir ?animal))
	(retract ?f)
	(retract ?g)
)


;; Regla solución sobre el animal si es ave o mamifero (y si no está en el conocimiento)
(defrule solucion
	(declare (salience -3))  ;;;; Una vez hechos los razonamientos
	?f <- (inferir ?animal)
	(vuela ?animal ?respuesta ?)
	=>
	(bind ?razonamiento (str-cat "Un " ?animal " " ?respuesta " vuela"))
	(printout t ?razonamiento crlf)
	(retract ?f)
)

	
;; No podemos saber con la informacion que tenemos si un animal vuela o no de forma segura si no se incorpora en el conocimiento.
;; Si el usuario introduce un animal que no está en el conocimiento y no indica si es ave o mamifero, el sistema lo introduce como animal al sistema y por defecto indicará que
;; 	no vuela, como indica la regla mayor_parte_animales_no_vuelan
;; Si el usuario introduce un animal que no está en el conocimiento e indica que es ave, el sistema lo introduce como ave al sistema y por defecto indicará que
;; 	vuela, como indica la regla ave_vuela_por_defecto
;; Si el usuario introduce un animal que no está en el conocimiento e indica que es mamifero, el sistema lo introduce como mamifero al sistema y por defecto indicará que
;; 	no vuela, por el uso de la regla mamiferos_son_animales y mayor_parte_animales_no_vuelan

