;; ===========================================================================================================================
;; ===  PRÁCTICA 1. SISTEMAS INTELIGENTES. 2019-2020                                                                        ==
;; ===  JOSÉ LEOCADIO REJAS MADRIGAL 3C2                                                                                    ==
;; ===========================================================================================================================

;; En los patrones de datos representamos los valores simples entre llaves {} seguidos de la letra s minúscula y los valores
;; múltiples entre llaves seguidos de una letra m minúscula.

;; ===========================================================================================================================
;; ===  VARIABLES GLOBALES                                                                                                  ==
;; ===========================================================================================================================

    ( defglobal  ?*nodosGenerados*         =   0 )
    ( defglobal  ?*profundidad*            =   50 )

;; ===========================================================================================================================
;; ===  HECHOS INICIALES                                                                                                    ==
;; ===========================================================================================================================

;; ===========================================================================================================================
;; ===  REPRESENTACION DEL AEROPUERTO                                                                                       ==
;; ===========================================================================================================================

;; Para representar las distintas zonas del aeropuerto y sus conexiones utilizamos un esquema como el que sigue:

;;                          ( DESDE {origen}s {HASTA {destino}s}m )

    ( deffacts aeropuerto

        ( DESDE PF HASTA P1 HASTA P2 )
        ( DESDE P2 HASTA P4 HASTA PF )
        ( DESDE P4 HASTA P2 HASTA P3 )
        ( DESDE P3 HASTA P4 HASTA P1 )
        ( DESDE P1 HASTA PF HASTA P5 HASTA P3 )
        ( DESDE P5 HASTA PR HASTA P1 HASTA P7 )
        ( DESDE P7 HASTA P5 HASTA P8 )
        ( DESDE P8 HASTA P7 HASTA P6 )
        ( DESDE P6 HASTA P8 HASTA PR )
        ( DESDE PR HASTA P5 HASTA P6 )

;; Aquí se representan las maletas y sus pesos:

;;                          {( M {id}s P {peso}s )}m

        ( M 1 P 12 O PF D P3 )
        ( M 2 P 18 O PF D P5 )
        ( M 3 P 20 O P1 D PR )
        ( M 4 P 14 O P6 D PR )

;; Aquí se representan los vagones con su rango de capacidad:

;;                          ( {VAGON {id}s {peso_minimo}s {peso_maximo}s}}m )

        ( VAGON V1  1 15 )
        ( VAGON V2 16 23 )

;; ===========================================================================================================================
;; ===  ESTADO INICIAL                                                                                                      ==
;; ===========================================================================================================================

;; Aquí se representa el estado inicial con la siguiente estructura:

;;      ( ACCION {accion}s
;;        MAQUINA {posicion_actual}s ANT {posicion_anterior}s
;;        VAGONES {VAGON {id}s POS {posicion_actual}s ANT {posicion_ultima_accion}s}m
;;        MALETAS {M {id}s C {cargado}s}m | cargado (NO, {vagon})
;;        ESTADO NIVEL {nivel}s PADRE {id_antecesor_directo}s )

        ( ACCION INICIAL
          MAQUINA P6 ANT DT
          VAGONES
          VAGON V1 POS P6 ANT DT
          VAGON V2 POS P2 ANT DT
          MALETAS
          M 1 C NO
          M 2 C NO
          M 3 C NO
          M 4 C NO
          ESTADO
          NIVEL 0 
          PADRE <Fact-0> )

    )

(   deffunction camino (?hecho)

    ;; (ACCION -_VAGON MAQUINA PR ANT P5 VAGONES V1 POS P4 ANT P4 VAGON V2 POS PR ANR PR MALETAS ESTADO NIVEL 27 PADRE <Fact-51160>)

    ;; Almacena el hecho identificado con ?hecho en ?hecho_final
	( bind ?hecho_final ( fact-slot-value ?hecho implied ) )
;;  ( printout t ?hecho_final crlf )


    ;; Obtiene el indice de la palabra nivel dentro del hecho ?f almacenado en lista
    ( bind ?indice ( member$ NIVEL ?hecho_final ) )

    ;; Suma uno al indice obtenido para obtener el valor del nivel en el hecho almacenado en ?f y lo guarda en ?n
	( bind ?n ( nth$ ( + ?indice 1 ) ?hecho_final ) )
	;;(printout t "Nivel=" ?n crlf)

    ;; ( bind ?mensaje ( create$ ) )
    ;; ( bind ?salto_de_linea ( format nil "%n") )

    ( bind ?salto_de_linea ( format nil "%n") )
    ( bind ?mensaje ( create$ ) )

    ( bind ?numero ?n )

    ( loop-for-count ( - ?n 0 )

        ;; Obtiene la accion realizada
        ( bind ?accion ( nth$ 1 ?hecho_final ) )

        ( bind ?hecho_final_padre ( nth$ ( length$ ?hecho_final )  ?hecho_final ) )
;;      ( printout t ?hecho_final_padre crlf )

    ;; (ACCION -_VAGON MAQUINA PR ANT P5 VAGONES V1 POS P4 ANT P4 VAGON V2 POS PR ANR PR MALETAS ESTADO NIVEL 27 PADRE <Fact-51160>)

        ( switch ?accion
            ( case ( string-to-field MOVER_M ) then 
                ( bind ?cadena_accion ( create$ MOVER MAQUINA A) )
                ( bind ?lugar ( nth$ 3 ?hecho_final ) )
                ( bind ?numero_accion ( sym-cat ( format nil "ACCION %.2d" ?numero ) ) )
                ( bind ?mensaje ( create$ ?numero_accion : ?cadena_accion ( sym-cat ?lugar ?salto_de_linea ) ?mensaje ) )
            )
            ( case ( string-to-field +_VAGON ) then
                ( bind ?cadena_accion ( create$ ENGANCHAR VAGON EN) )
                ( bind ?lugar ( nth$ 3 ?hecho_final ) )
                ( bind ?numero_accion ( sym-cat ( format nil "ACCION %.2d" ?numero ) ) )
                ( bind ?mensaje ( create$ ?numero_accion : ?cadena_accion ( sym-cat ?lugar ?salto_de_linea ) ?mensaje ) )
            )
            ( case ( string-to-field -_VAGON ) then
                ( bind ?cadena_accion ( create$ DESENGANCHAR VAGON EN) )
                ( bind ?lugar ( nth$ 3 ?hecho_final ) )
                ( bind ?numero_accion ( sym-cat ( format nil "ACCION %.2d" ?numero ) ) )
                ( bind ?mensaje ( create$ ?numero_accion : ?cadena_accion ( sym-cat ?lugar ?salto_de_linea ) ?mensaje ) )
            )
            ( case ( string-to-field +EQUIPL ) then
                ( bind ?cadena_accion ( create$ RECOGER_MALETA EN) )
                ( bind ?lugar ( nth$ 3 ?hecho_final ) )
                ( bind ?numero_accion ( sym-cat ( format nil "ACCION %.2d" ?numero ) ) )
                ( bind ?mensaje ( create$ ?numero_accion : ?cadena_accion ( sym-cat ?lugar ?salto_de_linea ) ?mensaje ) )
            )
            ( case ( string-to-field -EQUIPL ) then
                ( bind ?cadena_accion ( create$ DEJAR_MALETA EN) )
                ( bind ?lugar ( nth$ 3 ?hecho_final ) )
                ( bind ?numero_accion ( sym-cat ( format nil "ACCION %.2d" ?numero ) ) )
                ( bind ?mensaje ( create$ ?numero_accion : ?cadena_accion ( sym-cat ?lugar ?salto_de_linea ) ?mensaje ) )
            )
        )

        ( bind ?numero ( - ?numero 1 ) )
        ( bind ?hecho_final ( fact-slot-value ( fact-index ?hecho_final_padre ) implied ) )
;;      ( printout t ?hecho_final crlf )
    )

    ; ( bind ?accion ( nth$ 1 ?hecho_final ) )

    ; ( bind ?hecho_final_padre ( nth$ ( length$ ?hecho_final )  ?hecho_final ) )

    ( bind ?mensaje ( create$ ( sym-cat ?salto_de_linea ) ?mensaje ) )

    ( printout t ?mensaje ?salto_de_linea ?salto_de_linea crlf )
)


;; ===========================================================================================================================
;; ===  REGLAS                                                                                                              ==
;; ===========================================================================================================================

;; ===========================================================================================================================
;; ===  MOVER MAQUINA                                                                                                       ==
;; ===========================================================================================================================

;; Regla para mover la maquina por el aeropuerto. Se realiza un test para evitar ciclos en el movimiento. Por ejemplo, si la m
;; áquina está en P6 y se mueve a P8, esta regla evita que vuelva a P6 desde P8.

    (defrule MOVER_MAQUINA
	
		(declare (salience 500))

        ?padre <- ( ACCION ?
                    MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES 
                    $?antes_nivel NIVEL ?nivel $?despues_nivel )
                   ( DESDE ?localizacion_actual $? HASTA ?destino_actual $? )
        ( test ( < ?nivel ?*profundidad* ) )
        ( test ( neq ?localizacion_anterior ?destino_actual ) )
    =>
        ( assert  ( ACCION MOVER_M
                    MAQUINA ?destino_actual ANT ?localizacion_actual
                    VAGONES
                    $?antes_nivel NIVEL (+ ?nivel 1) PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  ENGANCHAR VAGON                                                                                                     ==
;; ===========================================================================================================================

;; Esta regla permite enganchar un vagón a la máquina. Se realiza un test para evitar que se ejecute esta regla inmediatamente
;; después de desenganchar el vagón para así evitar ciclos.

    (defrule ENGANCHAR_VAGON

		(declare (salience 700))

        ?padre <- ( ACCION ?accion
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?desenganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( test ( neq ?localizacion_actual MA ) )

        ( test ( neq ?accion -_VAGON ) )

;;      ( test ( neq ?localizacion_actual ?desenganchado ) )


;; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$

        ( test ( not ( subsetp (explode$ "MA") $?vagon_anterior  ) ) )
        ( test ( not ( subsetp (explode$ "MA") $?vagon_posterior ) ) )
    =>
        ( assert  ( ACCION +_VAGON
                    MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS MA ANT ?localizacion_actual $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL (+ ?nivel 1)
                    PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  DESENGANCHAR VAGON                                                                                                  ==
;; ===========================================================================================================================

;; Esta regla funciona practicamente igual que la anterior pero aquí la acción que realiza es la de desenganchar un vagón. Tam
;; bién realiza un test para evitar ejecutarla inmediatamente después de haber enganchado el vagón por la misma razón que la r
;; egla anterior.

    (defrule DESENGANCHAR_VAGON

		(declare (salience 600))

        ?padre <- ( ACCION ?accion
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS MA ANT ?enganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( test ( neq ?accion +_VAGON ) )

;;      ( test ( neq ?localizacion_actual ?enganchado ) )

;; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$
        ( test ( not ( subsetp (create$ ?vagon ) $?maletas ) ) )
    =>
        ( assert ( ACCION -_VAGON
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?localizacion_actual $?vagon_posterior
                   MALETAS $?maletas
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  RECOGER MALETA                                                                                                      ==
;; ===========================================================================================================================

;; Esta regla recoge una maleta cuyo peso se encuentre en los limites de capacidad del vagon apropiado si se encuentra enganch
;; ado a la máquina y ésta se encuentra en la misma localización que la maleta.

    (defrule RECOGER_MALETA
	
		(declare (salience 900))

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta C NO $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )

        ;; Comprobación nivel profundidad maximo
        ( test ( < ?nivel ?*profundidad* ) )

        ;; Seleccion de vagon
        ( VAGON ?vagon ?peso_minimo ?peso_maximo )

        ;; Seleccion de maleta en la misma localizacion que la maquina
        ( M ?maleta P ?peso_maleta O ?localizacion_actual D ?destino )

        ;; Comprobacion para saber si peso maleta esta en los limites impuestos por el vagon seleccionado
        (test ( and ( >= ?peso_maleta ?peso_minimo ) ( <= ?peso_maleta ?peso_maximo ) ) )

    =>
        ( assert ( ACCION +EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON ?vagon POS MA $?vagon_posterior
                   MALETAS $?maletas_anteriores M ?maleta C ?vagon $?maletas_posteriores
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  DEJAR MALETA                                                                                                        ==
;; ===========================================================================================================================

;; Esta regla deja una maleta en su destino si la maleta está cargada en el vagón apropiado y este se encuentra en la posición
;; de entrega de la maleta seleccionada.

    (defrule DEJAR_MALETA
	
		(declare (salience 800))

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta C ?vagon $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( M ?maleta $? D ?localizacion_actual )
    =>
        ( assert ( ACCION -EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON ?vagon POS MA $?vagon_posterior
                   MALETAS $?maletas_anteriores $?maletas_posteriores
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
        ; ( printout t "SE HA DEJADO  LA MALETA "?maleta " en " ?localizacion_actual crlf )
    )

;; ===========================================================================================================================
;; ===  TERMINAR                                                                                                            ==
;; ===========================================================================================================================

;; La ejecución termina cuando no quedan más maletas para transportar.

    (defrule TERMINAR
	
		(declare (salience 1000))

        ?hecho <- ( ACCION $? VAGONES $?vagones MALETAS ESTADO NIVEL ?nivel $? )
;; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$
        ( test ( not ( subsetp (create$ MA ) $?vagones ) ) )
    =>

        ( camino ?hecho )

        ( printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?nivel crlf )
        ( printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nodosGenerados* crlf )
        ( printout t "HECHO OBJETIVO " ?hecho crlf )
        ( printout t crlf )

        ( halt )
    )
