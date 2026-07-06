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

    SELECT * FROM /eacm/prim_i_run
    WHERE runuuid IN @lr_uuid
*    AND runstatus = 'PROGRESS'
*    AND createdby = @lv_crdby
    INTO TABLE @data(lt_zprim).

    handle_paging( io_request ).
    io_response->set_total_number_of_records( lines( lt_zprim ) ).
    io_response->set_data( lt_zprim ).

  ENDMETHOD.

  METHOD handle_paging.
    DATA(offset) = io_request->get_paging(  )->get_offset(  ).
    DATA(page_size) = io_request->get_paging(  )->get_page_size(  ).
    DATA(max_row) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE page_size ).
  ENDMETHOD.
ENDCLASS.
