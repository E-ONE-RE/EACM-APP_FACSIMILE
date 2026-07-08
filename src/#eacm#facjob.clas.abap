CLASS /eacm/facjob DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_run.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS generate_and_store_run
      IMPORTING
        i_uid TYPE /eacm/prim_run-run_uuid
      RAISING
        cx_fp_fdp_error
        cx_fp_form_reader
        cx_fp_ads_util.

    METHODS facsimili_zprim.
    METHODS facsimili_preview.
    METHODS prage_rpd.
    METHODS prage_rpc.
ENDCLASS.



CLASS /eacm/facjob IMPLEMENTATION.

  METHOD if_apj_rt_run~execute.

    facsimili_preview( )..
    facsimili_zprim( ).
    prage_rpd( ).
    prage_rpc( ).

  ENDMETHOD.

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

  ENDMETHOD.

  METHOD facsimili_preview.
* Facsimili generati
    "Come se impostassi un lock sul record
    UPDATE /eacm/prim_run
    SET file_name = 'xxGENxx'
    WHERE file_name = @space.

    SELECT FROM /eacm/prim_run
    FIELDS run_uuid
    WHERE file_name = 'xxGENxx'
    INTO TABLE  @DATA(lt_zprim_run).

    LOOP AT lt_zprim_run INTO DATA(ls_zprim_run).
      TRY.
          generate_and_store_run( ls_zprim_run-run_uuid ).
        CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
          "handle exception
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD facsimili_zprim.
    "Come se impostassi un lock sul record
    UPDATE /eacm/zprim
    SET file_name = 'xxGENxx'
    WHERE file_name = @space.

    SELECT FROM /eacm/zprim
    FIELDS bukrs, gjahr, zidfs
    WHERE file_name = 'xxGENxx'
    INTO TABLE  @DATA(lt_zprim).

    LOOP AT lt_zprim INTO DATA(ls_zprim).
      TRY.
          /eacm/cl_zprim_form=>generate_and_store(
            iv_bukrs = ls_zprim-bukrs
            iv_gjahr = ls_zprim-gjahr
            iv_zidfs = ls_zprim-zidfs
          ).
        CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
          "handle exception
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD prage_rpc.
*Stampa PRAGE - tabella /eacm/rpc
    UPDATE /eacm/rpc
    SET filename = 'xxGENxx',
        filename_age = 'xxGENxx'
    WHERE filename = @space.

    SELECT FROM /eacm/rpc
    FIELDS *
    WHERE filename = 'xxGENxx'
    INTO TABLE  @DATA(lt_rpc).

    DATA(lc_rpc) = NEW /eacm/cl_rpc( ).

    LOOP AT lt_rpc INTO DATA(ls_rpc).
      TRY.
          ls_rpc-filename = |RPD_SET{ ls_rpc-fkdat_yyyy }{ ls_rpc-fkdat_mm }|.
          ls_rpc-attachment = lc_rpc->get_pdf_sorg( EXPORTING i_bukrs = ls_rpc-bukrs i_yyyy = ls_rpc-Fkdat_YYYY i_mm = ls_rpc-fkdat_mm ).
          ls_rpc-att_age = lc_rpc->get_pdf_age( EXPORTING i_bukrs = ls_rpc-bukrs i_yyyy = ls_rpc-Fkdat_YYYY i_mm = ls_rpc-fkdat_mm ).
          ls_rpc-filename_age = |RPD_AGE{ ls_rpc-Fkdat_YYYY }{ ls_rpc-Fkdat_MM }|.
          UPDATE /eacm/rpc FROM @ls_rpc.
        CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
*          "handle exception
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD prage_rpd.
*Stampa PRAGE - tabella /eacm/rpd
    UPDATE /eacm/rpd
    SET filename = 'xxGENxx'
    WHERE filename = @space.

    SELECT FROM /eacm/rpd
    FIELDS *
    WHERE filename = 'xxGENxx'
    INTO TABLE  @DATA(lt_rpd).

    DATA(lc_rpd) = NEW /eacm/cl_rpd( ).

    LOOP AT lt_rpd INTO DATA(ls_rpd).
      TRY.
          ls_rpd-filename = |RPD_SET{ ls_rpd-Fkdat_YYYY }{ ls_rpd-fkdat_mm }|.
          ls_rpd-attachment = lc_rpd->get_rpf( EXPORTING i_yyyy = ls_rpd-Fkdat_YYYY i_mm = ls_rpd-fkdat_mm ).
*          ls_rpd-att_age = lc_rpd->get_rpfage( EXPORTING i_yyyy = ls_rpd-Fkdat_YYYY i_mm = ls_rpd-fkdat_mm ).
*          ls_rpd-filename_age = |RPD_AGE{ ls_rpd-Fkdat_YYYY }{ ls_rpd-Fkdat_MM }|.
*          UPDATE /eacm/rpd FROM @ls_rpd.
        CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
*          "handle exception
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
