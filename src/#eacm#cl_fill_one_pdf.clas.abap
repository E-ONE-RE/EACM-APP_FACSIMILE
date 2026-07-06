CLASS /eacm/cl_fill_one_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS /eacm/cl_fill_one_pdf IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        /eacm/cl_zprim_form=>generate_and_store(
          iv_bukrs = '9730'
          iv_gjahr = '2025'
          iv_zidfs = '0088'
        ).

        out->write( 'PDF generated and stored for S100 / 2026 / 0003.' ).

      CATCH cx_root INTO DATA(lx_root).
        out->write( lx_root->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

