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

;; ===========================================================================================================================
;; ===  ESTADO INICIAL                                                                                                      ==
;; ===========================================================================================================================

          ( ACCION INICIAL
            MAQUINA P6 ANT PARADA
            RECORRIDO P6
            VAGONES
            VAGON V1 POS P6 ANT PARADO
            VAGON V2 POS RE ANT PARADO
            VAGON V3 POS P8 ANT PARADO
            MALETAS
            M 1 O FA D P3
            M 2 O FA D P5
            M 3 O P1 D RE
            M 4 O P6 D RE
            ESTADO
            NIVEL 0 
            PADRE <f-0> )

    )

;; ===========================================================================================================================
;; ===  REGLAS                                                                                                              ==
;; ===========================================================================================================================

;; ===========================================================================================================================
;; ===  MOVER MAQUINA                                                                                                       ==
;; ===========================================================================================================================

    (defrule MOVER_MAQUINA

        ?padre <- ( ACCION ?
                    MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    RECORRIDO $?recorrido
                    VAGONES 
                    $?antes_nivel NIVEL ?nivel $?despues_nivel )
                   ( DESDE ?localizacion_actual $? HASTA ?destino_actual $? )
        ( test ( < ?nivel ?*profundidad* ) )
        ( test ( neq ?localizacion_anterior ?destino_actual ) )
    =>
        ( assert  ( ACCION MOVER_MAQUINA
                    MAQUINA ?destino_actual ANT ?localizacion_actual
                    RECORRIDO $?recorrido ?destino_actual
                    VAGONES
                    $?antes_nivel NIVEL (+ ?nivel 1) PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  MOVER MAQUINA COPIA 201909141504                                                                                    ==
;; ===========================================================================================================================

    ; (defrule MOVER_MAQUINA

        ; ?padre <- ( ACCION ?
                    ; MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    ; RECORRIDO $?recorrido
                    ; VAGONES 
                    ; $?antes_nivel NIVEL ?nivel $?despues_nivel )
                   ; ( DESDE ?localizacion_actual $? HASTA ?destino_actual $? )
        ; ( test ( < ?nivel ?*profundidad* ) )
        ; ( test ( neq ?localizacion_anterior ?destino_actual ) )
    ; =>
        ; ( assert  ( ACCION MOVER_MAQUINA
                    ; MAQUINA ?destino_actual ANT ?localizacion_actual
                    ; RECORRIDO $?recorrido ?destino_actual
                    ; VAGONES
                    ; $?antes_nivel NIVEL (+ ?nivel 1) PADRE ?padre ) )
        ; ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    ; )

;; ===========================================================================================================================
;; ===  ENGANCHAR VAGON                                                                                                     ==
;; ===========================================================================================================================

    (defrule ENGANCHAR_VAGON

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    RECORRIDO $?recorrido
                    VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?desenganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

        ( test ( neq ?localizacion_actual ENGANCHADO ) )

        ( test ( neq ?localizacion_actual ?desenganchado ) )


;; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$

        ( test ( not ( subsetp (explode$ "ENGANCHADO") $?vagon_anterior  ) ) )
        ( test ( not ( subsetp (explode$ "ENGANCHADO") $?vagon_posterior ) ) )
    =>
        ( assert  ( ACCION ENGANCHAR_VAGON
                    MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    RECORRIDO $?recorrido
                    VAGONES $?vagon_anterior VAGON ?vagon POS ENGANCHADO ANT ?localizacion_actual $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL (+ ?nivel 1)
                    PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  ENGANCHAR VAGON COPIA 201909141505                                                                                  ==
;; ===========================================================================================================================

    ; (defrule ENGANCHAR_VAGON

        ; ?padre <- ( ACCION ?
                    ; MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    ; RECORRIDO $?recorrido
                    ; VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?desenganchado $?vagon_posterior
                    ; MALETAS $?maletas
                    ; ESTADO
                    ; NIVEL ?nivel
                    ; $? )
        ; ( test ( < ?nivel ?*profundidad* ) )

        ; ( test ( neq ?localizacion_actual ENGANCHADO ) )

        ; ( test ( neq ?localizacion_actual ?desenganchado ) )


; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$

        ; ( test ( not ( subsetp (explode$ "ENGANCHADO") $?vagon_anterior  ) ) )
        ; ( test ( not ( subsetp (explode$ "ENGANCHADO") $?vagon_posterior ) ) )
    ; =>
        ; ( assert  ( ACCION ENGANCHAR_VAGON
                    ; MAQUINA ?localizacion_actual ANT ?localizacion_anterior
                    ; RECORRIDO $?recorrido
                    ; VAGONES $?vagon_anterior VAGON ?vagon POS ENGANCHADO ANT ?localizacion_actual $?vagon_posterior
                    ; MALETAS $?maletas
                    ; ESTADO
                    ; NIVEL (+ ?nivel 1)
                    ; PADRE ?padre ) )
        ; ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    ; )


;; ===========================================================================================================================
;; ===  DESENGANCHAR VAGON                                                                                                  ==
;; ===========================================================================================================================

    (defrule DESENGANCHAR_VAGON

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    RECORRIDO $?recorrido
                    VAGONES $?vagon_anterior VAGON ?vagon POS ENGANCHADO ANT ?enganchado $?vagon_posterior
                    MALETAS $?maletas
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )
        ( test ( neq ?localizacion_actual ?enganchado ) )

;; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$
        ( test ( not ( subsetp (create$ ?vagon ) $?maletas ) ) )
    =>
        ( assert ( ACCION DESENGANCHAR_VAGON
                   MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   RECORRIDO $?recorrido
                   VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?localizacion_actual $?vagon_posterior
                   MALETAS $?maletas
                   ESTADO
                   NIVEL (+ ?nivel 1)
                   PADRE ?padre ) )
        ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    )

;; ===========================================================================================================================
;; ===  DESENGANCHAR VAGON COPIA 201909141506                                                                                                 ==
;; ===========================================================================================================================

    ; (defrule DESENGANCHAR_VAGON

        ; ?padre <- ( ACCION ?
                    ; MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    ; RECORRIDO $?recorrido
                    ; VAGONES $?vagon_anterior VAGON ?vagon POS ENGANCHADO ANT ?enganchado $?vagon_posterior
                    ; MALETAS $?maletas
                    ; ESTADO
                    ; NIVEL ?nivel
                    ; $? )
        ; ( test ( < ?nivel ?*profundidad* ) )
        ; ( test ( neq ?localizacion_actual ?enganchado ) )

; subsetp devuelve true o false al comparar dos variables multievaluadas, por eso el uso del explode$
        ; ( test ( not ( subsetp (create$ ?vagon ) $?maletas ) ) )
    ; =>
        ; ( assert ( ACCION DESENGANCHAR_VAGON
                   ; MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                   ; RECORRIDO $?recorrido
                   ; VAGONES $?vagon_anterior VAGON ?vagon POS ?localizacion_actual ANT ?localizacion_actual $?vagon_posterior
                   ; MALETAS $?maletas
                   ; ESTADO
                   ; NIVEL (+ ?nivel 1)
                   ; PADRE ?padre ) )
        ; ( bind ?*nodosGenerados* ( + ?*nodosGenerados* 1 ) )
    ; )

;; ===========================================================================================================================
;; ===  TERMINAR                                                                                                            ==
;; ===========================================================================================================================

    (defrule TERMINAR

        ?padre <- ( MAQUINA $? MALETAS ESTADO NIVEL ?nivel $? )
;;      maleta <- ( MALETA ?maleta $? )

    =>

        ( printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?nivel crlf )
        ( printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nodosGenerados* crlf )
        ( printout t "HECHO OBJETIVO " ?padre crlf )
        ( halt )
    )

;; ===========================================================================================================================
;; ===  TERMINAR COPIA 201909141507                                                                                         ==
;; ===========================================================================================================================

    ; (defrule TERMINAR

        ; ?padre <- ( MAQUINA $? MALETAS ESTADO NIVEL ?nivel $? )
;      maleta <- ( MALETA ?maleta $? )

    ; =>

        ; ( printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?nivel crlf )
        ; ( printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nodosGenerados* crlf )
        ; ( printout t "HECHO OBJETIVO " ?padre crlf )
        ; ( halt )
    ; )