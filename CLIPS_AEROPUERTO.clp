;; ===========================================================================================================================
;; ===  PRÁCTICA 1. SISTEMAS INTELIGENTES. 2019-2020 
;; ===                                                                         ==
;; ===========================================================================================================================
;; En los patrones de datos representamos los valores simples entre corchetes {} seguido de la letra s minúscula
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;; ===========================================================================================================================
;; ===  VARIABLES GLOBALES                                                                                                  ==
;; ===========================================================================================================================

    ( defglobal  ?*nodosGenerados*         =   0 )
    ( defglobal  ?*profundidad*            =   50 )

;; ===========================================================================================================================
;; ===  HECHOS INICIALES                                                                                                    ==
;; ===========================================================================================================================

;; En los patrones de datos representamos los valores simples entre llaves {} seguidos de la letra s minúscula y los valores
;; múltiples entre llaves seguidos de una letra m minúscula.

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
        ( DESDE P1 HASTA P5 HASTA P3 HASTA PF )
        ( DESDE P5 HASTA P1 HASTA P7 HASTA PR )
        ( DESDE P7 HASTA P5 HASTA P8 )
        ( DESDE P8 HASTA P7 HASTA P6 )
        ( DESDE P6 HASTA P8 HASTA PR )
        ( DESDE PR HASTA P6 HASTA P5 )

;; Aquí se representan las maletas y sus pesos:

;;                          ( M {id}s {P {peso}s}m )

        ( M 1 P 12 )
        ( M 2 P 18 )
        ( M 3 P 20 )
        ( M 4 P 14 )

;; Aquí se representa el peso máximo de las maletas "ligeras":

;;                          ( PESO_MAXIMO {peso}s )

        ( PESO_MAXIMO 15 )

;; ===========================================================================================================================
;; ===  ESTADO INICIAL                                                                                                      ==
;; ===========================================================================================================================

;; Aquí se representa el estado inicial con la siguiente estructura:

;;      ( ACCION {accion}s
;;        MAQUINA {posicion_actual}s ANT {posicion_anterior}s
;;        VAGONES {VAGON {id}s POS {posicion_actual}s ANT {posicion_ultima_accion}s}m
;;        MALETAS {M {id}s O {origen}s D {destino}s}m
;;        ESTADO NIVEL {nivel}s PADRE {id_antecesor_directo}s )

        ( ACCION INICIAL
          MAQUINA P6 ANT DT
          VAGONES
          VAGON V1 POS P6 ANT DT
          VAGON V2 POS P2 ANT DT
          MALETAS
          M 1 O PF D P3
          M 2 O PF D P5
          M 3 O P1 D PR
          M 4 O P6 D PR
          ESTADO
          NIVEL 0 
          PADRE <Fact-0> )

    )

;; ===========================================================================================================================
;; ===  REGLAS                                                                                                              ==
;; ===========================================================================================================================

;; ===========================================================================================================================
;; ===  MOVER MAQUINA                                                                                                       ==
;; ===========================================================================================================================

;; Regla para mover la maquina por el aeropuerto. Se realiza un test para que evitar ciclos en el movimiento. Por ejemplo, si 
;; la máquina está en P6 y se mueve a P8, esta regla evita que vuelva a P6 desde P8.

    (defrule MOVER_MAQUINA

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

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?desenganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( test ( neq ?localizacion_actual MA ) )

        ( test ( neq ?localizacion_actual ?desenganchado ) )


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

;; Esta regla funciona practicamente igual que al anterior pero aquí la acción que realizar es la de desenganchar un vagón. Ta
;; mbién realiza un test para evitar ejecutarla inmediatamente después de haber enganchado el vagón por la misma razón que la
;; regla anterior.

    (defrule DESENGANCHAR_VAGON

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON ?vagon POS MA ANT ?enganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )
        ( test ( neq ?localizacion_actual ?enganchado ) )

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
;; ===  RECOGER MALETA LIGERA                                                                                               ==
;; ===========================================================================================================================

;; Esta regla recoge una maleta que no sobrepase el peso máximo para considerarla ligera si el vagón apropiado se encuentra en
;; ganchado a la máquina y ésta se encuentra en la misma localización que la maleta.

    (defrule RECOGER_MALETA_LIGERA

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON V1 POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta O ?localizacion_actual D ?destino $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( M ?maleta P ?peso_maleta )

        ( PESO_MAXIMO ?peso_maximo )

        ( test ( <= ?peso_maleta ?peso_maximo ) )

    =>
        ( assert ( ACCION +EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON V1 POS MA $?vagon_posterior
                   MALETAS $?maletas_anteriores M ?maleta O V1 D ?destino $?maletas_posteriores
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  DEJAR MALETA LIGERA                                                                                                 ==
;; ===========================================================================================================================

;; Esta regla deja ua maleta ligera en su destino si la maleta está cargada en el vagón apropiado y este se encuentra en la po
;; sición de entrega de la maleta seleccionada.

    (defrule DEJAR_MALETA_LIGERA

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON V1 POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta O V1 D ?localizacion_actual $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )
    =>
        ( assert ( ACCION -EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON V1 POS MA $?vagon_posterior
                   MALETAS $?maletas_anteriores $?maletas_posteriores
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
        ; ( printout t "SE HA DEJADO  LA MALETA "?maleta " en " ?localizacion_actual crlf )
    )

;; ===========================================================================================================================
;; ===  RECOGER MALETA PESADA                                                                                               ==
;; ===========================================================================================================================

    (defrule RECOGER_MALETA_PESADA

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON V2 POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta O ?localizacion_actual D ?destino $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( M ?maleta P ?peso_maleta )

        ( PESO_MAXIMO ?peso_maximo )

        ( test ( >  ?peso_maleta ?peso_maximo ) )

    =>
        ( assert ( ACCION +EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON V2 POS MA $?vagon_posterior
                   MALETAS $?maletas_anteriores M ?maleta O V2 D ?destino $?maletas_posteriores
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  DEJAR MALETA PESADA                                                                                                 ==
;; ===========================================================================================================================

    (defrule DEJAR_MALETA_PESADA

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON V2 POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta O V2 D ?localizacion_actual $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )
    =>
        ( assert ( ACCION -EQUIPL
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   VAGONES $?vagon_anterior VAGON V2 POS MA $?vagon_posterior
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

    (defrule TERMINAR

        ?padre <- ( ACCION $? MALETAS ESTADO NIVEL ?nivel $? )
;;      maleta <- ( MALETA ?maleta $? )

    =>

        ( printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?nivel crlf )
        ( printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nodosGenerados* crlf )
        ( printout t "HECHO OBJETIVO " ?padre crlf )
        ( halt )
    )
