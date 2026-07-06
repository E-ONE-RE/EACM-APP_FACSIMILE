CLASS lhc_PRIM_I_RUN DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    CLASS-DATA gt_zprim TYPE STANDARD TABLE OF /eacm/zprim.
    CLASS-DATA gt_facspos TYPE STANDARD TABLE OF /eacm/facspos.
    CLASS-DATA gt_zprfac TYPE STANDARD TABLE OF /eacm/zprfac.
    CLASS-DATA gt_faciva TYPE STANDARD TABLE OF /eacm/faciva.
    CLASS-DATA gt_zprdp TYPE STANDARD TABLE OF /eacm/zprdp.

    CLASS-DATA gt_zprim_run TYPE STANDARD TABLE OF /eacm/prim_run.
    CLASS-DATA gt_delete_run TYPE STANDARD TABLE OF /eacm/prim_run.
    CLASS-DATA gv_action TYPE /eacm/prim_run-run_status.
    CLASS-DATA gt_generate_ranges  TYPE if_rap_query_filter=>tt_name_range_pairs.

  PRIVATE SECTION.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /eacm/prim_i_run RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR /eacm/prim_i_run RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE /eacm/prim_i_run.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/prim_i_run.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/prim_i_run.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/prim_i_run RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /eacm/prim_i_run.

    METHODS rba_Enasarco FOR READ
      IMPORTING keys_rba FOR READ /eacm/prim_i_run\_Enasarco FULL result_requested RESULT result LINK association_links.

    METHODS rba_Iva FOR READ
      IMPORTING keys_rba FOR READ /eacm/prim_i_run\_Iva FULL result_requested RESULT result LINK association_links.

    METHODS rba_Positions FOR READ
      IMPORTING keys_rba FOR READ /eacm/prim_i_run\_Positions FULL result_requested RESULT result LINK association_links.

    METHODS cba_Enasarco FOR MODIFY
      IMPORTING entities_cba FOR CREATE /eacm/prim_i_run\_Enasarco.

    METHODS cba_Iva FOR MODIFY
      IMPORTING entities_cba FOR CREATE /eacm/prim_i_run\_Iva.

    METHODS cba_Positions FOR MODIFY
      IMPORTING entities_cba FOR CREATE /eacm/prim_i_run\_Positions.

    METHODS onSave FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/prim_i_run~onSave RESULT result.
    METHODS onGenerate FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/prim_i_run~onGenerate.

    METHODS verificaIntervallo IMPORTING i_competenza        TYPE /eacm/zprim-zamcf
                               RETURNING VALUE(r_successful) TYPE abap_bool.

ENDCLASS.

CLASS lhc_PRIM_I_RUN IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA(stop) = 'stop'.
  ENDMETHOD.

  METHOD update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      SELECT SINGLE *                         "#EC CI_ALL_FIELDS_NEEDED
        FROM /eacm/prim_i_run
        WHERE runuuid = @<ls_entity>-RunUuid
        INTO @DATA(ls_update).

      READ TABLE gt_zprim_run
        ASSIGNING FIELD-SYMBOL(<ls_buffer>)
        WITH KEY run_uuid = <ls_entity>-RunUuid.
      IF sy-subrc <> 0.
        APPEND CORRESPONDING #( ls_update ) TO  gt_zprim_run ASSIGNING <ls_buffer>.
      ENDIF.

      <ls_buffer>-run_uuid = <ls_entity>-RunUuid.

      IF <ls_entity>-%control-RunStatus = if_abap_behv=>mk-on.
        <ls_buffer>-run_status = <ls_entity>-RunStatus.
      ENDIF.

      IF <ls_entity>-%control-Zidfs = if_abap_behv=>mk-on.
        <ls_buffer>-zidfs = <ls_entity>-Zidfs.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    gv_action = 'DELETE'.

    DELETE gt_delete_run WHERE run_uuid <> space.
    LOOP AT keys INTO DATA(ls_key).
*      READ TABLE gt_delete_run
*        ASSIGNING FIELD-SYMBOL(<ls_buffer>)
*        WITH KEY run_uuid = ls_key-RunUuid.
*      IF sy-subrc <> 0.
      APPEND VALUE #(
        run_uuid = ls_key-RunUuid
      ) TO gt_delete_run.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.

*    DATA lt_db TYPE STANDARD TABLE OF /eacm/prim_run.
*
*    LOOP AT keys INTO DATA(ls_key).
*      READ TABLE gt_zprim_run INTO DATA(ls_zprim_run) WITH KEY run_uuid = ls_key-RunUuid.
*      IF sy-subrc = 0.
*        APPEND ls_zprim_run TO lt_db.
*      ENDIF.
*    ENDLOOP.
*
*    result = CORRESPONDING #( lt_db MAPPING
*      RunUuid   = run_uuid
*      RunStatus = run_status
*      CreatedBy = created_by
*      Vkorg     = vkorg
*      Vtweg     = vtweg
*      Zclpr     = zclpr
*      Bukrs     = bukrs
*      Gjahr     = gjahr
*      Zidfs     = zidfs
*      Lifnr     = lifnr
*      Zcdaz     = zcdaz
*      Zamcf     = zamcf
*      Bldat     = bldat
*      Waerk     = waerk
*      Zimprv    = zimprv
*      Zimena    = zimena
*      Zimrac    = zimrac
*      Zimiva    = zimiva
*      Ztotfs    = ztotfs
*    ).

    DATA lt_db TYPE STANDARD TABLE OF /eacm/prim_run.

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE gt_zprim_run INTO DATA(ls_zprim_run)
        WITH KEY run_uuid = ls_key-RunUuid.

      IF sy-subrc = 0.
        APPEND ls_zprim_run TO lt_db.
      ELSE.
        SELECT SINGLE *
          FROM /eacm/prim_run
          WHERE run_uuid = @ls_key-RunUuid
          INTO @DATA(ls_db).

        IF sy-subrc = 0.
          APPEND ls_db TO lt_db.
        ENDIF.
      ENDIF.

    ENDLOOP.

    result = CORRESPONDING #( lt_db MAPPING
      RunUuid   = run_uuid
      RunStatus = run_status
      CreatedBy = created_by
      Vkorg     = vkorg
      Vtweg     = vtweg
      Zclpr     = zclpr
      Bukrs     = bukrs
      Gjahr     = gjahr
      Zidfs     = zidfs
      Lifnr     = lifnr
      Zcdaz     = zcdaz
      Zamcf     = zamcf
      Bldat     = bldat
      Waerk     = waerk
      Zimprv    = zimprv
      Zimena    = zimena
      Zimrac    = zimrac
      Zimiva    = zimiva
      Ztotfs    = ztotfs
    ).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Enasarco.
  ENDMETHOD.

  METHOD rba_Iva.
  ENDMETHOD.

  METHOD rba_Positions.
  ENDMETHOD.

  METHOD cba_Enasarco.
  ENDMETHOD.

  METHOD cba_Iva.
  ENDMETHOD.

  METHOD cba_Positions.
  ENDMETHOD.

  METHOD onSave.

    gv_action = 'SAVE'.
    DATA lv_check_range TYPE abap_boolean.
*    CLEAR: lv_check_range, gt_zprim_run[].
    CLEAR: lv_check_range.

    LOOP AT keys INTO DATA(ls_key).

      SELECT SINGLE * FROM /eacm/prim_run     "#EC CI_ALL_FIELDS_NEEDED
      WHERE run_uuid = @ls_key-RunUuid
      INTO @DATA(ls_prim_run).

      IF ls_prim_run-zidfs IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      "estrazione del numero facsimile
      IF lv_check_range = abap_false.
        IF NOT verificaintervallo( i_competenza = ls_prim_run-zamcf ).
          "LANCIARE L'ERRORE
          CONTINUE.
        ENDIF.
        lv_check_range = abap_true.
      ENDIF.


      TRY.
          CALL METHOD cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = '/EACM/FACS'
              toyear      = ls_prim_run-zamcf(4)
            IMPORTING
              number      = DATA(lv_number)
              returncode  = DATA(lv_returncode)
          ).
          IF lv_returncode IS NOT INITIAL.
            "LANCIA ERRORE
            RETURN.
          ENDIF.
          ls_prim_run-zidfs = lv_number.    "NUOVO NUMERO FACSIMILE
        CATCH cx_root INTO DATA(lo_root).
          DATA(lv_err) = lo_root->get_text( ).
          "LANCIA ERRORE
          RETURN.
      ENDTRY.

      MODIFY ENTITIES OF /eacm/prim_i_run IN LOCAL MODE
        ENTITY /eacm/prim_i_run
          UPDATE FIELDS ( RunStatus Zidfs )
          WITH VALUE #(
            (
              %tky      = ls_key-%tky
              RunStatus = 'SAVED'
              Zidfs     = ls_prim_run-zidfs
            )
          )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-/eacm/prim_i_run TO failed-/eacm/prim_i_run.
      APPEND LINES OF lt_reported-/eacm/prim_i_run TO reported-/eacm/prim_i_run.

    ENDLOOP.

*    MODIFY ENTITIES OF /eacm/prim_i_run IN LOCAL MODE
*      ENTITY /eacm/prim_i_run
*        UPDATE FIELDS ( RunStatus Zidfs )
*        WITH VALUE #(
*          FOR key IN keys
*          (
*            %tky = key-%tky
*            RunStatus = 'SAVED'
*            Zidfs = '0099'
*          )
*        )
*      FAILED failed
*      REPORTED reported.

    READ ENTITIES OF /eacm/prim_i_run IN LOCAL MODE
      ENTITY /eacm/prim_i_run
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDMETHOD.

  METHOD verificaintervallo.
    DATA lv_object   TYPE cl_numberrange_objects=>nr_attributes-object.
    DATA lt_interval TYPE cl_numberrange_intervals=>nr_interval.

    lv_object = '/EACM/FACS'.
    TRY.

        CALL METHOD cl_numberrange_intervals=>read
          EXPORTING
            object       = lv_object
            nr_range_nr1 = ' '
            nr_range_nr2 = ' '
            subobject    = ' '
          IMPORTING
            interval     = lt_interval.
      CATCH cx_nr_object_not_found.
        r_successful = abap_false.
      CATCH cx_nr_subobject.
        r_successful = abap_false.
      CATCH cx_number_ranges.
        r_successful = abap_false.
    ENDTRY.

    READ TABLE lt_interval WITH KEY toyear = i_competenza(4)
    TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND VALUE #(
         nrrangenr = '01'
         toyear = i_competenza(4)
         fromnumber = '0001'
         tonumber   = '9999'
         procind    = 'I'
       ) TO lt_interval.

*   create intervals
      TRY.

          CALL METHOD cl_numberrange_intervals=>create
            EXPORTING
              interval  = lt_interval
              object    = lv_object
              subobject = ' '
            IMPORTING
              error     = DATA(lv_error)
              error_inf = DATA(ls_error)
              error_iv  = DATA(lt_error_iv)
              warning   = DATA(lv_warning).
          IF lv_error = abap_true.
            r_successful = abap_false.
          ELSE.
            r_successful = abap_true.
          ENDIF.
        CATCH cx_number_ranges.
          r_successful = abap_false.
      ENDTRY.
    ELSE.
      r_successful = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD onGenerate.


    DATA(lv_error) = abap_false.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      CLEAR lhc_prim_i_run=>gt_generate_ranges.

      DATA(ls_param) = <ls_key>-%param.

      IF <ls_key>-%param-Zamcf IS INITIAL.

        lv_error = abap_true.

        APPEND VALUE #(
          %cid        = <ls_key>-%cid
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-/eacm/prim_i_run.

        APPEND VALUE #(
          %cid                    = <ls_key>-%cid
          %msg                    = new_message_with_text(
                                      severity = if_abap_behv_message=>severity-error
                                      text     = 'La competenza facsimile è obbligatoria' )
          %op-%action-onGenerate  = if_abap_behv=>mk-on
          %element-Zamcf          = if_abap_behv=>mk-on
        ) TO reported-/eacm/prim_i_run.
      ELSE.
        APPEND VALUE #(
          name = 'ZAMCF'
          range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Zamcf ) )
        ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF <ls_key>-%param-Bldat IS INITIAL.

        lv_error = abap_true.

        APPEND VALUE #(
          %cid        = <ls_key>-%cid
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-/eacm/prim_i_run.

        APPEND VALUE #(
          %cid                    = <ls_key>-%cid
          %msg                    = new_message_with_text(
                                      severity = if_abap_behv_message=>severity-error
                                      text     = 'La data documento è obbligatoria' )
          %op-%action-onGenerate  = if_abap_behv=>mk-on
          %element-Bldat          = if_abap_behv=>mk-on
        ) TO reported-/eacm/prim_i_run.
      ELSE.
        APPEND VALUE #(
          name = 'BLDAT'
          range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Bldat ) )
        ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF ls_param-Bukrs IS NOT INITIAL.
        APPEND VALUE #(
        name = 'BUKRS'
        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Bukrs ) )
      ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF ls_param-Zclpr IS NOT INITIAL.
        APPEND VALUE #(
        name = 'ZCLPR'
        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Zclpr ) )
      ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF ls_param-Vkorg IS NOT INITIAL.
        APPEND VALUE #(
        name = 'VKORG'
        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Vkorg ) )
      ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF ls_param-Vtweg IS NOT INITIAL.
        APPEND VALUE #(
        name = 'VTWEG'
        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Vtweg ) )
      ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

      IF ls_param-Zcdaz IS NOT INITIAL.
        APPEND VALUE #(
        name = 'ZCDAZ'
        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Zcdaz ) )
      ) TO lhc_prim_i_run=>gt_generate_ranges.
      ENDIF.

*      IF ls_param- IS NOT INITIAL.
*        APPEND VALUE #(
*        name = 'WAERK'
*        range = VALUE #( ( sign = 'I' option = 'EQ' low = ls_param-Zclpr ) )
*      ) TO lhc_prim_i_run=>gt_generate_ranges.
*      ENDIF.

    ENDLOOP.

    IF lv_error = abap_true.
      RETURN.
    ENDIF.

    lhc_prim_i_run=>gv_action = 'GENERATE'.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_FACIVA_I_RUN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/faciva_i_run.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/faciva_i_run.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/faciva_i_run RESULT result.

    METHODS rba_Root FOR READ
      IMPORTING keys_rba FOR READ /eacm/faciva_i_run\_Root FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_FACIVA_I_RUN IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Root.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_FACPOS_I_RUN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/facpos_i_run.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/facpos_i_run.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/facpos_i_run RESULT result.

    METHODS rba_Root FOR READ
      IMPORTING keys_rba FOR READ /eacm/facpos_i_run\_Root FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_FACPOS_I_RUN IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Root.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_PRFAC_I_RUN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/prfac_i_run.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/prfac_i_run.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/prfac_i_run RESULT result.

    METHODS rba_Root FOR READ
      IMPORTING keys_rba FOR READ /eacm/prfac_i_run\_Root FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_PRFAC_I_RUN IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Root.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_PRIM_I_RUN DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

  PRIVATE SECTION.

    METHODS get_zprfac_zidrg
      IMPORTING
        t_zprfac        TYPE /eacm/tt_zprfac
        l_zprfac        TYPE /eacm/zprfac
      RETURNING
        VALUE(r_result) TYPE /eacm/zidrg.

    METHODS insert_mingar
      IMPORTING
        i_mg_run TYPE /eacm/tt_fac_mg_run.

ENDCLASS.

CLASS lsc_PRIM_I_RUN IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    IF lhc_PRIM_I_RUN=>gv_action IS NOT INITIAL.

      CASE lhc_PRIM_I_RUN=>gv_action.
        WHEN 'GENERATE'.
          DATA(lo_facsimile) = NEW /eacm/cl_facsimile(
            i_ranges = lhc_prim_i_run=>gt_generate_ranges
          ).

          lo_facsimile->generate( ).
        WHEN 'SAVE'.
          LOOP AT lhc_PRIM_I_RUN=>gt_zprim_run INTO DATA(ls_update).
            UPDATE /eacm/prim_run
              SET run_status = @ls_update-run_status,
                  zidfs      = @ls_update-zidfs
              WHERE run_uuid = @ls_update-run_uuid
              AND zidfs = 0.
            IF sy-subrc = 0.
              "ZPRIM
              SELECT * FROM /eacm/prim_run
              WHERE run_uuid = @ls_update-run_uuid
              INTO TABLE @DATA(lt_prim_run).
              DATA lt_zprim TYPE STANDARD TABLE OF /eacm/zprim.
              lt_zprim = CORRESPONDING #( lt_prim_run ).
              INSERT /eacm/zprim FROM TABLE @lt_zprim.
            ENDIF.
          ENDLOOP.



*          "ZFACSPOS
*          SELECT * FROM /eacm/facpos_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @DATA(lt_FACPOS_RUN).

*          "ZPRFAC
*          SELECT * FROM /eacm/prfac_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @DATA(lt_PRFAC_RUN).
**          DATA lt_zprfac TYPE STANDARD TABLE OF /eacm/zprfac.
**          lt_zprfac = CORRESPONDING #( lt_PRFAC_RUN ).
**          INSERT /eacm/zprfac FROM TABLE @lt_zprfac.

*          "ZFACIVA
*          SELECT * FROM /eacm/faciva_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @DATA(lt_faciva_run).
**          DATA lt_faciva TYPE STANDARD TABLE OF /eacm/faciva.
**          lt_faciva = CORRESPONDING #( lt_faciva_run ).
**          INSERT /eacm/faciva FROM TABLE @lt_faciva.

**          "ZPRDP
*          SELECT * FROM /eacm/facdp_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @DATA(lt_facdp_run).

*          "ZPRAR
*          SELECT * FROM /eacm/zprar_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @DATA(lt_zprar_run).

*          "ZPRDP per minimi garantiti e anticipi automatici
*          DATA lt_mg_run TYPE STANDARD TABLE OF /eacm/fac_mg_run.
*          SELECT * FROM /eacm/fac_mg_run
*          WHERE run_uuid IS NOT INITIAL
*          INTO TABLE @lt_mg_run.

          LOOP AT lt_prim_run INTO DATA(ls_prim_run).

*            "/aggiornamento del numero facsimile sulle varie tabelle
*            READ TABLE lt_FACPOS_RUN INTO DATA(ls_FACPOS_RUN) INDEX 1. "#EC CI_NOORDER
*            ls_FACPOS_RUN-zidfs = ls_prim_run-zidfs.
*            MODIFY lt_FACPOS_RUN FROM ls_FACPOS_RUN TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
*            UPDATE /eacm/FACPOS_RUN SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
*
*            READ TABLE lt_PRFAC_RUN INTO DATA(ls_PRFAC_RUN) INDEX 1. "#EC CI_NOORDER
*            ls_PRFAC_RUN-zidfs = ls_prim_run-zidfs.
*            MODIFY lt_PRFAC_RUN FROM ls_PRFAC_RUN TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
*            UPDATE /eacm/PRFAC_RUN SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
*
*            READ TABLE lt_faciva_run INTO DATA(ls_faciva_run) INDEX 1. "#EC CI_NOORDER
*            ls_faciva_run-zidfs = ls_prim_run-zidfs.
*            MODIFY lt_faciva_run FROM ls_faciva_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
*            UPDATE /eacm/faciva_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
*
*            READ TABLE lt_zprar_run INTO DATA(ls_zprar_run) WITH KEY run_uuid = ls_prim_run-run_uuid.
*            IF sy-subrc = 0.
*              ls_zprar_run-zidfs = ls_prim_run-zidfs.
*              MODIFY lt_zprar_run FROM ls_zprar_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
*              UPDATE /eacm/zprar_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
*            ENDIF.
*
*            READ TABLE lt_mg_run INTO DATA(ls_mg_run) WITH KEY run_uuid = ls_prim_run-run_uuid.
*            IF sy-subrc = 0.
*              ls_mg_run-zidfs = ls_prim_run-zidfs.
*              MODIFY lt_mg_run FROM ls_mg_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
*              UPDATE /eacm/fac_mg_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
*            ENDIF.
*            "/aggiornamento del numero facsimile sulle varie tabelle
**********************************************************************
            "/aggiornamento del numero facsimile sulle varie tabelle

            "ZFACSPOS
            "seleziono i dati dalla mia tabella di esecuzione
            SELECT * FROM /eacm/facpos_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @DATA(lt_FACPOS_RUN).
            "aggiungo il numero di facsimile a parità di uid
            READ TABLE lt_FACPOS_RUN INTO DATA(ls_FACPOS_RUN) INDEX 1. "#EC CI_NOORDER
            ls_FACPOS_RUN-zidfs = ls_prim_run-zidfs.
            MODIFY lt_FACPOS_RUN FROM ls_FACPOS_RUN TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
            "aggiorno la tabella di persistanza del data - in verità potrei evitarlo
            UPDATE /eacm/FACPOS_RUN SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
            "salvo sulla tabella ufficiale
            DATA lt_FACSPOS TYPE STANDARD TABLE OF /eacm/FACSPOS.
            lt_FACSPOS = CORRESPONDING #( lt_FACPOS_RUN ).
            INSERT /eacm/FACSPOS FROM TABLE @lt_FACSPOS.

            "ZPRFAC
            SELECT * FROM /eacm/prfac_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @DATA(lt_PRFAC_RUN).
            READ TABLE lt_PRFAC_RUN INTO DATA(ls_PRFAC_RUN) INDEX 1. "#EC CI_NOORDER
            ls_PRFAC_RUN-zidfs = ls_prim_run-zidfs.
            MODIFY lt_PRFAC_RUN FROM ls_PRFAC_RUN TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
            UPDATE /eacm/PRFAC_RUN SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
            DATA lt_zprfac TYPE STANDARD TABLE OF /eacm/zprfac.
            lt_zprfac = CORRESPONDING #( lt_PRFAC_RUN ).
            LOOP AT lt_zprfac ASSIGNING FIELD-SYMBOL(<fac>).
              <fac>-zidrg = get_zprfac_zidrg( EXPORTING t_zprfac = lt_zprfac l_zprfac = <fac> ).
            ENDLOOP.
            INSERT /eacm/zprfac FROM TABLE @lt_zprfac.

            "ZFACIVA
            SELECT * FROM /eacm/faciva_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @DATA(lt_faciva_run).
            READ TABLE lt_faciva_run INTO DATA(ls_faciva_run) INDEX 1. "#EC CI_NOORDER
            ls_faciva_run-zidfs = ls_prim_run-zidfs.
            MODIFY lt_faciva_run FROM ls_faciva_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
            UPDATE /eacm/faciva_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
            DATA lt_faciva TYPE STANDARD TABLE OF /eacm/faciva.
            lt_faciva = CORRESPONDING #( lt_faciva_run ).
            INSERT /eacm/faciva FROM TABLE @lt_faciva.

            "ZPRAR
            SELECT * FROM /eacm/zprar_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @DATA(lt_zprar_run).
            READ TABLE lt_zprar_run INTO DATA(ls_zprar_run) WITH KEY run_uuid = ls_prim_run-run_uuid.
            IF sy-subrc = 0.
              ls_zprar_run-zidfs = ls_prim_run-zidfs.
              MODIFY lt_zprar_run FROM ls_zprar_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
              UPDATE /eacm/zprar_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
              DATA lt_zprar TYPE STANDARD TABLE OF /eacm/zprar.
              lt_zprar = CORRESPONDING #( lt_zprar_run ).
              MODIFY /eacm/zprar FROM TABLE @lt_zprar.
            ENDIF.

            "ZPRDP per minimi garantiti e anticipi automatici
            DATA lt_mg_run TYPE STANDARD TABLE OF /eacm/fac_mg_run.
            SELECT * FROM /eacm/fac_mg_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @lt_mg_run.

            READ TABLE lt_mg_run INTO DATA(ls_mg_run) WITH KEY run_uuid = ls_prim_run-run_uuid.
            IF sy-subrc = 0.
              ls_mg_run-zidfs = ls_prim_run-zidfs.
              MODIFY lt_mg_run FROM ls_mg_run TRANSPORTING zidfs WHERE run_uuid = ls_prim_run-run_uuid.
              UPDATE /eacm/fac_mg_run SET zidfs = @ls_prim_run-zidfs WHERE run_uuid = @ls_prim_run-run_uuid.
              insert_mingar( EXPORTING i_mg_run = lt_mg_run ).
            ENDIF.
            "/aggiornamento del numero facsimile sulle varie tabelle

            "aggiornamento ZPRDP
*          "ZPRDP
            SELECT * FROM /eacm/facdp_run
            WHERE run_uuid = @ls_prim_run-run_uuid
            INTO TABLE @DATA(lt_facdp_run).
            LOOP AT lt_facdp_run INTO DATA(ls_facdp_run)
            WHERE run_uuid = ls_prim_run-run_uuid.

              UPDATE /eacm/zprdp
              SET zidfs = @ls_prim_run-zidfs,
                  zamcf = @ls_prim_run-zamcf,
                  zdtsf = @ls_prim_run-bldat
                  WHERE vkorg = @ls_facdp_run-vkorg
                  AND vtweg = @ls_facdp_run-vtweg
                  AND zclpr = @ls_facdp_run-zclpr
                  AND vbeln = @ls_facdp_run-vbeln
                  AND posnr = @ls_facdp_run-posnr
                  AND zcdaz = @ls_facdp_run-zcdaz
                  AND zidag = @ls_facdp_run-zidag
                  AND zidrg = @ls_facdp_run-zidrg.
            ENDLOOP.

          ENDLOOP.

*          "aggiornamento FACSPOS
*          DATA lt_FACSPOS TYPE STANDARD TABLE OF /eacm/FACSPOS.
*          lt_FACSPOS = CORRESPONDING #( lt_FACPOS_RUN ).
*          INSERT /eacm/FACSPOS FROM TABLE @lt_FACSPOS.

*          "aggiornamento ZPRFAC
*          DATA lt_zprfac TYPE STANDARD TABLE OF /eacm/zprfac.
*          lt_zprfac = CORRESPONDING #( lt_PRFAC_RUN ).
*          LOOP AT lt_zprfac ASSIGNING FIELD-SYMBOL(<fac>).
*            <fac>-zidrg = get_zprfac_zidrg( EXPORTING t_zprfac = lt_zprfac l_zprfac = <fac> ).
*          ENDLOOP.
*          INSERT /eacm/zprfac FROM TABLE @lt_zprfac.

*          "aggiornamento FACIVA
*          DATA lt_faciva TYPE STANDARD TABLE OF /eacm/faciva.
*          lt_faciva = CORRESPONDING #( lt_faciva_run ).
*          INSERT /eacm/faciva FROM TABLE @lt_faciva.

*          "aggiornamento ZPRAR.
*          DATA lt_zprar TYPE STANDARD TABLE OF /eacm/zprar.
*          lt_zprar = CORRESPONDING #( lt_zprar_run ).
*          MODIFY /eacm/zprar FROM TABLE @lt_zprar.

*          insert_mingar( EXPORTING i_mg_run = lt_mg_run ).

          SELECT * FROM /eacm/maxena_run                "#EC CI_NOWHERE
          INTO TABLE @DATA(lt_maxena).
          LOOP AT lt_maxena INTO DATA(ls_maxena).
            UPDATE /eacm/zpraa
            SET znoena = @abap_true
            WHERE zcdaz = @ls_maxena-zcdaz.
          ENDLOOP.

*          LOOP AT lt_prim_run INTO ls_prim_run.
*            TRY.
*                /eacm/cl_zprim_form=>generate_and_store(
*                  iv_bukrs = ls_prim_run-bukrs
*                  iv_gjahr = ls_prim_run-gjahr
*                  iv_zidfs = ls_prim_run-zidfs
*                ).
*              CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
*                "handle exception
*                CONTINUE.
*            ENDTRY.
*          ENDLOOP.

        WHEN 'DELETE'.
          "cancellazione riga da DELETE
          LOOP AT lhc_PRIM_I_RUN=>gt_delete_run INTO DATA(ls_delete).

            DELETE FROM /eacm/prim_run WHERE run_uuid = @ls_delete-run_uuid.
            DELETE FROM /eacm/facpos_run WHERE run_uuid = @ls_delete-run_uuid.
            DELETE FROM /eacm/prfac_run WHERE run_uuid = @ls_delete-run_uuid.
            DELETE FROM /eacm/faciva_run WHERE run_uuid = @ls_delete-run_uuid.
            DELETE FROM /eacm/facdp_run WHERE run_uuid = @ls_delete-run_uuid.

          ENDLOOP.
      ENDCASE.


**********************************************************************
      DATA(lv_crdby) = cl_abap_context_info=>get_user_technical_name( ).
      MODIFY /eacm/facrun_act FROM @(
        VALUE #( created_by = lv_crdby  action = lhc_PRIM_I_RUN=>gv_action )
      ).
      CLEAR lhc_PRIM_I_RUN=>gv_action.
**********************************************************************
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
*    SELECT FROM /eacm/zprim
*    FIELDS bukrs, gjahr, zidfs
*    WHERE Attachment IS NULL
*    and zidfs = '0551'
*    INTO TABLE @DATA(lt_zprim).
*
*    LOOP AT lt_zprim INTO DATA(ls_zprim).
*      TRY.
*          /eacm/cl_zprim_form=>generate_and_store(
*            iv_bukrs = ls_zprim-bukrs
*            iv_gjahr = ls_zprim-gjahr
*            iv_zidfs = ls_zprim-zidfs
*          ).
*        CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
*          "handle exception
*          CONTINUE.
*      ENDTRY.
*    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.


  METHOD get_zprfac_zidrg.
    SELECT MAX( zidrg )
      FROM /eacm/zprfac
      WHERE bukrs = @l_zprfac-bukrs
        AND gjahr = @l_zprfac-gjahr
        AND lifnr = @l_zprfac-lifnr
        AND waerk = @l_zprfac-waerk
        AND zamcf = @l_zprfac-zamcf
         INTO @r_result.

    WHILE sy-subrc = 0.
      r_result += 1.
      READ TABLE t_zprfac WITH KEY
        bukrs = l_zprfac-bukrs
        gjahr = l_zprfac-gjahr
        lifnr = l_zprfac-lifnr
        waerk = l_zprfac-waerk
        zamcf = l_zprfac-zamcf
        zidrg = r_result
        TRANSPORTING NO FIELDS.
    ENDWHILE.
  ENDMETHOD.


  METHOD insert_mingar.

    LOOP AT i_mg_run INTO DATA(ls_mg_run).

      DATA l_zprdo TYPE /eacm/prdo.
      DATA l_zprdp TYPE /eacm/zprdp.
      DATA v_date TYPE d.

      CLEAR l_zprdo.
      MOVE-CORRESPONDING ls_mg_run TO l_zprdo.

*      DATA v_numki TYPE /eacm/zpr08-numki.
      DATA v_numki TYPE cl_numberrange_runtime=>nr_interval.
      CLEAR v_numki.

      SELECT SINGLE posnr, numki, zdesc
        FROM /eacm/zpr08
        WHERE bukrs = @l_zprdo-bukrs
          AND zclpr = @l_zprdo-zclpr
          INTO (@l_zprdo-posnr, @v_numki, @l_zprdo-maktx ).

      TRY.
          CALL METHOD cl_numberrange_runtime=>number_get
            EXPORTING
              nr_range_nr = v_numki
              object      = '/EACM/PRVG'
            IMPORTING
              number      = DATA(lv_number)
              returncode  = DATA(lv_rcode).
        CATCH cx_nr_object_not_found.
          CLEAR l_zprdo-vbeln.
        CATCH cx_number_ranges.
          CLEAR l_zprdo-vbeln.
      ENDTRY.
      l_zprdo-vbeln = lv_number.

      l_zprdo-zidag = 1.
      l_zprdo-gjahr = ls_mg_run-zamco(4).
*      IF ls_mg_run-ziprv > 0.
*        l_zprdo-vbtyp = 'M'.
      l_zprdo-zimco = l_zprdo-zimmg = ls_mg_run-ziprv. "Taxable orders
*      ELSE.
*        l_zprdo-vbtyp = 'O'.
*        l_zprdo-zimco = l_zprdo-zimmg = ls_mg_run-ziprv * -1. "Taxable orders
*      ENDIF.

      CONCATENATE ls_mg_run-zamco '01' INTO v_date.
      SELECT SINGLE FROM I_CalendarDate
      FIELDS LastDayOfMonthDate
      WHERE CalendarDate = @v_date
      INTO @l_zprdo-fkdat.

      l_zprdo-belnr = l_zprdo-vbeln.
*      l_zprdo-bldat = a_bldat.
      l_zprdo-zvgdt = l_zprdo-fkdat.
      l_zprdo-matnr = l_zprdo-zclpr.
      l_zprdo-ztprv = 'FATT'.
      l_zprdo-zstre = 'C'. "già maturata
      SELECT SINGLE FROM /eacm/zpraa
      FIELDS ztpag
      WHERE zcdaz = @ls_mg_run-zcdaz
      INTO @l_zprdo-ztpag.
      l_zprdo-zaucr = cl_abap_context_info=>get_user_technical_name( ).
      l_zprdo-zdtcr = cl_abap_context_info=>get_system_date( ).
      l_zprdo-zorcr = cl_abap_context_info=>get_system_time( ).
      l_zprdo-tcode = 'FACRUN'.
      l_zprdo-zwaer = l_zprdo-waerk.
      l_zprdo-kurrf = 1.

      CLEAR l_zprdp.
      MOVE-CORRESPONDING ls_mg_run TO l_zprdp.
      IF l_zprdo-vbtyp = 'O'.
        l_zprdp-ziprvsf = abs( l_zprdp-ziprvsf ).
        l_zprdp-ziprvvs = abs( l_zprdp-ziprvvs ).
        l_zprdp-ziprv = abs( l_zprdp-ziprv ).
      ENDIF.
      l_zprdp-vbeln = l_zprdp-belnr = l_zprdo-vbeln.
      l_zprdp-posnr = l_zprdo-posnr.
      l_zprdp-zidag = l_zprdp-zidrg = l_zprdo-zidag.
      l_zprdp-gjahr = l_zprdo-gjahr.
      l_zprdp-fkdat = l_zprdo-fkdat.
      l_zprdp-bldat = l_zprdo-bldat.
      l_zprdp-matnr = l_zprdo-matnr.
      l_zprdp-zamcr = l_zprdp-zamco = l_zprdp-zamcf = ls_mg_run-zamco.
      l_zprdp-zwaer = l_zprdo-zwaer.
      l_zprdp-zdtsf = l_zprdp-fkdat.
      l_zprdp-zaucr = cl_abap_context_info=>get_user_technical_name( ).
      l_zprdp-zdtcr = cl_abap_context_info=>get_system_date( ).
      l_zprdp-zorcr = cl_abap_context_info=>get_system_time( ).
      l_zprdp-tcode = 'FACRUN'.
      l_zprdp-zinc = l_zprdp-zipro = l_zprdp-ziprv.

      INSERT /eacm/prdo FROM @l_zprdo.
      IF sy-subrc NE 0.

      ENDIF.
      INSERT /eacm/zprdp FROM @l_zprdp.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
