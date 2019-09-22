            INICIAL____________
MOVER_M     MOVER_MAQUINA A 
+_VAGON     ENGANCHAR_VAGON EN
-_VAGON     DESENGANCHAR_VAGON EN
+EQUIPL     RECOGER_MALETA MX EN
-EQUIPL     DEJAR_MALETA MX EN




(deffunction camino (?indice)

    ;; Almacena el hecho identificado con ?f en ?lista
    ;;(bind ?lista (fact-slot-value ?f implied))
	(bind ?hecho_final (fact-slot-value ?indice implied))

    ;; Obtiene el indice de la palabra nivel dentro del hecho ?f almacenado en lista
  ;;(bind ?l2 (member$ NIVEL ?lista))
    (bind ?l2 (member$ NIVEL ?lista))

    ;; Suma uno al indice obtenido para obtener el valor del nivel en el hecho almacenado en ?f y lo guarda en ?n
	(bind ?n (nth (+ ?l2 1) ?lista)) 

	;;(printout t "Nivel=" ?n crlf)

    ;; Obtiene el hecho, se almacena la direccion del hecho
	(bind ?dir (nth (length ?lista) ?lista))
	
    ;; Obtiene la direccion
    (bind ?mov (subseq$ ?lista (+ ?l2 3) (- (length ?lista) 2))) 
	
    ;; Une el hecho y la direccion tomada
    (bind ?path (create$ ?dir ?mov))
	
    ;;(printout t ?dir "    " ?mov crlf)

	(loop-for-count (- ?n 1)

        ;; Obtiene el hecho padre...
		(bind ?lista (fact-slot-value (fact-index ?dir) implied))

		(bind ?dir (nth (length ?lista) ?lista))
		(bind ?l2 (member$ nivel ?lista))
		(bind ?mov (subseq$ ?lista (+ ?l2 3) (- (length ?lista) 2)))
		(bind ?path (create$ ?dir ?mov ?path)) 
	)

	(printout t "Camino: " ?path crlf)
)





















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

        ( M 1 P 12 )
        ( M 2 P 18 )
        ( M 3 P 20 )
        ( M 4 P 14 )

;; ===========================================================================================================================
;; ===  ESTADO INICIAL                                                                                                      ==
;; ===========================================================================================================================

        ( ACCION INICIAL
          MAQUINA P6 ANT DT
          VAGONES
          VAGON V1 POS P6 ANT DT
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

    (defrule RECOGER_MALETA_LIGERA

        ?padre <- ( ACCION ?
                    MAQUINA  ?localizacion_actual ANT ?localizacion_anterior
                    VAGONES $?vagon_anterior VAGON V1 POS MA $?vagon_posterior
                    MALETAS $?maletas_anteriores M ?maleta O ?localizacion_actual D ?destino $?maletas_posteriores
                    ESTADO
                    NIVEL ?nivel
                    $? )
        ( test ( < ?nivel ?*profundidad* ) )

    =>
        ( assert ( ACCION +EQUIPA
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
        ( assert ( ACCION -EQUIPA
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
