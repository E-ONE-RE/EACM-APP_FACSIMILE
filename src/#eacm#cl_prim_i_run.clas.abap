CLASS /eacm/cl_prim_i_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
    METHODS handle_paging IMPORTING io_request TYPE REF TO if_rap_query_request.
  PRIVATE SECTION.
ENDCLASS.

CLASS /eacm/cl_prim_i_run IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ) = abap_false.
      RETURN.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter( ).
    TRY.
        DATA(lt_ranges) = lo_filter->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR lt_ranges[].
    ENDTRY.


    DATA lr_uuid TYPE RANGE OF /EACM/PRIM_i_RUN-RunUuid.
    CLEAR: lr_uuid[].

    LOOP AT lt_ranges INTO DATA(ls_range).
      CASE ls_range-name.
        WHEN 'RUNUUID'.
          lr_uuid = CORRESPONDING #( ls_range-range ).
      ENDCASE.
    ENDLOOP.

    "------------------------------------------------------------
    " FILTER
    "------------------------------------------------------------
    DATA(lv_sql_filter) =
      io_request->get_filter( )->get_as_sql_string( ).

*    DATA(lv_crdby) = cl_abap_context_info=>get_user_technical_name( ).
*    DATA cl_fac TYPE REF TO /eacm/cl_facsimile.
*    IF cl_fac IS NOT BOUND.
*      CREATE OBJECT cl_fac EXPORTING i_ranges = lt_ranges.
*    ENDIF.

*    SELECT SINGLE COUNT( * ) FROM /eacm/facrun_act
*    WHERE created_by = @lv_crdby
*    AND action <> 'GO'.
*    IF sy-subrc <> 0 AND lr_uuid[] IS INITIAL.
*      cl_fac->generate( ).
*    ENDIF.

*    cl_fac->delete_action( i_user = lv_crdby ).

*    DATA lr_data TYPE REF TO data.

*    CREATE DATA lr_data TYPE STANDARD TABLE OF ('/EACM/PRIM_C_RUN').
*    ASSIGN lr_data->* TO FIELD-SYMBOL(<lt_table>).


**********************************************************************
    "------------------------------------------------------------
    " SORTING
    "------------------------------------------------------------
    DATA(lt_sort_elements) =
      io_request->get_sort_elements( ).

    DATA lt_sort_criteria TYPE string_table.

    lt_sort_criteria =
      VALUE #(
        FOR ls_sort IN lt_sort_elements
        (
          ls_sort-element_name &&
          COND string(
            WHEN ls_sort-descending = abap_true
            THEN ` descending`
            ELSE ` ascending`
          )
        )
      ).

    DATA(lv_sort_string) =
      COND string(
        WHEN lt_sort_criteria IS INITIAL
        THEN `RUNUUID ascending`
        ELSE concat_lines_of(
               table = lt_sort_criteria
               sep   = `, `
             )
      ).

**********************************************************************

    SELECT * FROM /eacm/prim_i_run
    WHERE runuuid IN @lr_uuid
*    AND runstatus = 'PROGRESS'
*    AND createdby = @lv_crdby
    ORDER BY (lv_sort_string)
    INTO TABLE @DATA(lt_zprim).


    " Numero totale PRIMA del paging
    DATA lv_total_records TYPE int8.
    lv_total_records = lines( lt_zprim ).

*    " Applico paging a lt_zprim
*    handle_paging( io_request ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lv_total_records ).
    ENDIF.

    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(lv_offset)    = io_request->get_paging( )->get_offset( ).

    IF io_request->is_data_requested( ).


      IF lv_page_size <> if_rap_query_paging=>page_size_unlimited.

        DATA lt_paged TYPE STANDARD TABLE OF /eacm/prim_i_run.

        DATA(lv_from) = CONV i( lv_offset + 1 ).
        DATA(lv_to)   = CONV i( lv_offset + lv_page_size ).

        CLEAR lt_paged.
        APPEND LINES OF lt_zprim FROM lv_from TO lv_to TO lt_paged.

        io_response->set_data( lt_paged ).
      ELSE.
        io_response->set_data( lt_zprim ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD handle_paging.
    DATA(offset) = io_request->get_paging(  )->get_offset(  ).
    DATA(page_size) = io_request->get_paging(  )->get_page_size(  ).
    DATA(max_row) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE page_size ).
  ENDMETHOD.
ENDCLASS.
