CLASS /eacm/facjob DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_run.

    "! <p class="shorttext synchronized" lang="en">Società</p>
    DATA p_bukrs TYPE bukrs.

    "! <p class="shorttext synchronized" lang="en">Esercizio</p>
    DATA p_gjahr TYPE gjahr.

    "! <p class="shorttext synchronized" lang="en">ID fattura</p>
    DATA p_zidfs TYPE /eacm/zidfs.

    METHODS facsimili_zprim
      IMPORTING i_bukrs TYPE bukrs
                i_gjahr TYPE gjahr
                i_zidfs TYPE /eacm/zidfs.
    METHODS facsimili_preview.
    METHODS prage_rpd.
    METHODS prage_rpc.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS generate_and_store_run
      IMPORTING
        i_uid TYPE /eacm/prim_run-run_uuid
      RAISING
        cx_fp_fdp_error
        cx_fp_form_reader
        cx_fp_ads_util.

*    METHODS facsimili_zprim.
*    METHODS facsimili_preview.
*    METHODS prage_rpd.
*    METHODS prage_rpc.
ENDCLASS.



CLASS /eacm/facjob IMPLEMENTATION.


  METHOD generate_and_store_run.

    DATA(lo_fdp_api) = cl_fp_fdp_services=>get_instance(
      iv_max_depth          = 1
      iv_service_definition = '/EACM/UI_FACRUN_SRV'
    ).

    DATA(lt_keys) = lo_fdp_api->get_keys( ).

    lt_keys[ name = 'RUNUUID' ]-value = i_uid.

    DATA(lv_data) = lo_fdp_api->read_to_xml_v2(
      it_select = lt_keys
    ).

    DATA(lo_reader) = cl_fp_form_reader=>create_form_reader(
      '/EACM/FR_ZPRIM_RUN'
    ).

    DATA(ls_layout) = lo_reader->get_layout( ).
    DATA rv_pdf TYPE xstring.

    cl_fp_ads_util=>render_pdf(
      EXPORTING
        iv_xml_data   = lv_data
        iv_xdp_layout = ls_layout
        iv_locale     = 'en_US'
      IMPORTING
        ev_pdf        = rv_pdf
    ).

    DATA(lv_pdf) = rv_pdf.

    IF lv_pdf IS INITIAL.
      RETURN.
    ENDIF.

*    DATA(lv_file_name) = |{ iv_bukrs }_{ iv_gjahr }_{ iv_zidfs }_output.pdf|.
    SELECT SINGLE FROM /eacm/prim_run
    FIELDS zcdaz, zamcf
    WHERE run_uuid = @i_uid
    INTO @DATA(ls_zprim).
    DATA(lv_file_name) = |{ ls_zprim-zcdaz }_{ ls_zprim-zamcf }.pdf|.

    UPDATE /eacm/prim_run
      SET file_name  = @lv_file_name,
          mime_type  = 'application/pdf',
          attachment = @lv_pdf
      WHERE Run_Uuid = @i_uid.
    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD facsimili_preview.
* Facsimili generati
    "Come se impostassi un lock sul record


    SELECT FROM /eacm/prim_run
    FIELDS run_uuid
    WHERE file_name = @space
    INTO TABLE  @DATA(lt_zprim_run).

    LOOP AT lt_zprim_run INTO DATA(ls_zprim_run).
      UPDATE /eacm/prim_run
      SET file_name = 'xxGENxx'
      WHERE run_uuid = @ls_zprim_run-run_uuid
      AND file_name = @space.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        TRY.
            generate_and_store_run( ls_zprim_run-run_uuid ).
          CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util INTO DATA(lx_error).
            DATA(msg) = lx_error->get_longtext(  ).
            "handle exception
            UPDATE /eacm/prim_run
            SET file_name = @space
            WHERE run_uuid = @ls_zprim_run-run_uuid.
            COMMIT WORK AND WAIT.
            CONTINUE.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD facsimili_zprim.

    DATA lv_now TYPE timestampl.
    DATA lv_start TYPE timestampl.
    DATA is_persistent TYPE abap_bool.

    is_persistent = abap_false.
    GET TIME STAMP FIELD lv_start.

    WHILE is_persistent = abap_false.

      SELECT SINGLE FROM /eacm/zprim
      FIELDS bukrs, gjahr, zidfs, file_name
      WHERE bukrs = @i_bukrs
      AND gjahr = @i_gjahr
      AND zidfs = @i_zidfs
*    AND file_name = @space
     INTO  @DATA(ls_zprim).
      IF sy-subrc = 0.
        is_persistent = abap_true.
        EXIT.
      ENDIF.

      " Controllo timeout
      GET TIME STAMP FIELD lv_now.

      DATA(lv_elapsed_seconds) =
        cl_abap_tstmp=>subtract(
          tstmp1 = lv_now
          tstmp2 = lv_start
        ).

      IF lv_elapsed_seconds >= 3600.
        " Timeout dopo 1 ora
        EXIT.
      ENDIF.

      " Evita di interrogare continuamente il DB
      WAIT UP TO 5 SECONDS.

    ENDWHILE.

    IF ls_zprim IS NOT INITIAL AND ls_zprim-file_name = space.

      UPDATE /eacm/zprim
      SET file_name = 'xxGENxx'
      WHERE bukrs = @ls_zprim-bukrs
      AND gjahr = @ls_zprim-gjahr
      AND zidfs = @ls_zprim-zidfs
      AND file_name = @space.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        TRY.
            /eacm/cl_zprim_form=>generate_and_store(
              iv_bukrs = ls_zprim-bukrs
              iv_gjahr = ls_zprim-gjahr
              iv_zidfs = ls_zprim-zidfs
            ).
          CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
            "handle exception
            UPDATE /eacm/zprim
            SET file_name = @space
            WHERE bukrs = @ls_zprim-bukrs
            AND gjahr = @ls_zprim-gjahr
            AND zidfs = @ls_zprim-zidfs.
            COMMIT WORK AND WAIT.
        ENDTRY.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD prage_rpc.

*Stampa PRAGE - tabella /eacm/rpc


    SELECT FROM /eacm/rpc
    FIELDS *
    WHERE filename = @space
    INTO TABLE @DATA(lt_rpc).

    DATA(lc_rpc) = NEW /eacm/cl_rpc( ).
    DATA lv_mm TYPE n LENGTH 2.

    LOOP AT lt_rpc INTO DATA(ls_rpc).

      UPDATE /eacm/rpc
      SET filename = 'xxGENxx'
      WHERE bukrs = @ls_rpc-bukrs
        AND fkdat_yyyy  = @ls_rpc-fkdat_yyyy
        AND fkdat_mm = @ls_rpc-fkdat_mm
        AND vkorg = @ls_rpc-vkorg
        AND zcdaz = @ls_rpc-zcdaz
        AND filename = @space.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.

        ls_rpc-mime_type = 'application/pdf'.
        lv_mm = ls_rpc-fkdat_mm.


        IF ls_rpc-zcdaz IS INITIAL AND ls_rpc-vkorg IS INITIAL.
          "completo
          ls_rpc-filename = |PRAGE4_ALL_{ lv_mm }{ ls_rpc-fkdat_yyyy }.pdf|.
          lc_rpc->pdf_completo(
            CHANGING
              c_rpc = ls_rpc
          ).
        ELSE.

          IF ls_rpc-zcdaz IS INITIAL.
            "settore
            ls_rpc-filename = |PRAGE4_{ ls_rpc-vkorg(3) }_{ lv_mm }{ ls_rpc-fkdat_yyyy }.pdf|.
            lc_rpc->pdf_settori(
              CHANGING
                c_rpc = ls_rpc
            ).
          ELSE.
            "agente
            ls_rpc-filename = |PRAGE5_{ ls_rpc-zcdaz }_{ lv_mm }{ ls_rpc-fkdat_yyyy }.pdf|.
            lc_rpc->pdf_agente(
              CHANGING
                c_rpc = ls_rpc
            ).
          ENDIF.

        ENDIF.

        IF ls_rpc-attachment IS INITIAL.
          CLEAR ls_rpc-filename.
        ENDIF.
        UPDATE /eacm/rpc FROM @ls_rpc.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD prage_rpd.

*Stampa PRAGE - tabella /eacm/rpd


    SELECT FROM /eacm/rpd
    FIELDS *
    WHERE filename = @space
    INTO TABLE @DATA(lt_rpd).

    DATA(lc_rpd) = NEW /eacm/cl_rpd( ).
    DATA lv_mm TYPE n LENGTH 2.

    LOOP AT lt_rpd INTO DATA(ls_rpd).

      UPDATE /eacm/rpd
      SET filename = 'xxGENxx'
      WHERE bukrs = @ls_rpd-bukrs
        AND fkdat_yyyy  = @ls_rpd-fkdat_yyyy
        AND fkdat_mm = @ls_rpd-fkdat_mm
        AND vkorg = @ls_rpd-vkorg
        AND zcdaz = @ls_rpd-zcdaz
        AND filename = @space.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.

        ls_rpd-mime_type = 'application/pdf'.
        lv_mm = ls_rpd-fkdat_mm.

        IF ls_rpd-zcdaz IS INITIAL.
          IF ls_rpd-vkorg IS INITIAL AND ls_rpd-zcdaz IS INITIAL.
            "completo
            ls_rpd-filename = |PRAGE3_{ lv_mm }{ ls_rpd-fkdat_yyyy }.pdf|.
            lc_rpd->pdf_completo(
              CHANGING
                c_rpd = ls_rpd
            ).
          ELSEIF ls_rpd-vkorg IS NOT INITIAL.
            "settore
            ls_rpd-filename = |PRAGE7_{ ls_rpd-vkorg }{ lv_mm }{ ls_rpd-fkdat_yyyy }.pdf|.
            lc_rpd->pdf_settori(
              CHANGING
                c_rpd = ls_rpd
            ).
          ENDIF.
        ELSE. "IF ls_rpd-zcdaz IS NOT INITIAL.
          "agente
          DATA(lv_strage) = |{ ls_rpd-zcdaz }%|.
          SELECT SINGLE FROM /eacm/zpraa
          FIELDS kunnr
          WHERE zcdaz LIKE @lv_strage
          INTO @DATA(lv_kunnr).
          IF lv_kunnr IS NOT INITIAL.
            ls_rpd-filename = |{ lv_kunnr }_A_{ ls_rpd-bukrs }_#_1_PROVV_CALC_{ lv_mm }{ ls_rpd-fkdat_yyyy }.pdf|.
          ELSE.
            ls_rpd-filename = |NA_{ ls_rpd-zcdaz }_{ ls_rpd-bukrs }_#_NO_ZPRAA_PRAGE3_{ lv_mm }{ ls_rpd-fkdat_yyyy }.pdf|.
          ENDIF.

          lc_rpd->pdf_agente(
            CHANGING
              c_rpd = ls_rpd
          ).
        ENDIF.

        IF ls_rpd-attachment IS INITIAL.
          CLEAR ls_rpd-filename.
        ENDIF.
        UPDATE /eacm/rpd FROM @ls_rpd.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_apj_rt_run~execute.

    IF p_zidfs IS INITIAL.
      facsimili_preview( ).
      prage_rpd( ).
      prage_rpc( ).
    ELSE.
      facsimili_zprim( EXPORTING i_bukrs = p_bukrs i_gjahr = p_gjahr i_zidfs = p_zidfs ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
