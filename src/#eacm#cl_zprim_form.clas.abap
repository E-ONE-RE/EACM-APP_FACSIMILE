CLASS /eacm/cl_zprim_form DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS generate_and_store
      IMPORTING
        iv_bukrs TYPE /eacm/zprim-bukrs
        iv_gjahr TYPE /eacm/zprim-gjahr
        iv_zidfs TYPE /eacm/zprim-zidfs
      RAISING
        cx_fp_fdp_error
        cx_fp_form_reader
        cx_fp_ads_util.
  PRIVATE SECTION.
    CLASS-METHODS get_pdf
      IMPORTING
                iv_bukrs      TYPE /eacm/zprim-bukrs
                iv_gjahr      TYPE /eacm/zprim-gjahr
                iv_zidfs      TYPE /eacm/zprim-zidfs
      RETURNING VALUE(rv_pdf) TYPE xstring
      RAISING
                cx_fp_fdp_error
                cx_fp_form_reader
                cx_fp_ads_util.
ENDCLASS.



CLASS /eacm/cl_zprim_form IMPLEMENTATION.

  METHOD get_pdf.
    DATA(lo_fdp_api) = cl_fp_fdp_services=>get_instance(
      iv_max_depth          = 1
      iv_service_definition = '/EACM/SV_ZPRIM'
    ).

    DATA(lt_keys) = lo_fdp_api->get_keys( ).

    lt_keys[ name = 'BUKRS' ]-value = iv_bukrs.
    lt_keys[ name = 'GJAHR' ]-value = iv_gjahr.
    lt_keys[ name = 'ZIDFS' ]-value = iv_zidfs.

    DATA(lv_data) = lo_fdp_api->read_to_xml_v2(
      it_select = lt_keys
    ).

    IF lv_data IS INITIAL.
      CLEAR rv_pdf.
      RETURN.
    ENDIF.

    DATA(lo_reader) = cl_fp_form_reader=>create_form_reader(
      '/EACM/FR_ZPRIM'
    ).

    DATA(ls_layout) = lo_reader->get_layout( ).

    cl_fp_ads_util=>render_pdf(
      EXPORTING
        iv_xml_data   = lv_data
        iv_xdp_layout = ls_layout
        iv_locale     = 'en_US'
      IMPORTING
        ev_pdf        = rv_pdf
    ).
  ENDMETHOD.


  METHOD generate_and_store.
    DATA(lv_pdf) = get_pdf(
      iv_bukrs = iv_bukrs
      iv_gjahr = iv_gjahr
      iv_zidfs = iv_zidfs
    ).

    IF lv_pdf IS INITIAL.
      RETURN.
    ENDIF.

*    DATA(lv_file_name) = |{ iv_bukrs }_{ iv_gjahr }_{ iv_zidfs }_output.pdf|.
    SELECT SINGLE FROM /eacm/zprim
    FIELDS zcdaz, zamcf
    WHERE bukrs = @iv_bukrs
    AND gjahr = @iv_gjahr
    AND zidfs = @iv_zidfs
    INTO @DATA(ls_zprim).
    DATA(lv_file_name) = |{ ls_zprim-zcdaz }_{ ls_zprim-zamcf }_{ iv_zidfs }.pdf|.

    UPDATE /eacm/zprim
      SET file_name  = @lv_file_name,
          mime_type  = 'application/pdf',
          attachment = @lv_pdf
      WHERE bukrs = @iv_bukrs
        AND gjahr = @iv_gjahr
        AND zidfs = @iv_zidfs.
  ENDMETHOD.

ENDCLASS.

