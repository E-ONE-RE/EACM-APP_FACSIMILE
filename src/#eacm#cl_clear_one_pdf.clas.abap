CLASS /eacm/cl_clear_one_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS /eacm/cl_clear_one_pdf IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    UPDATE /eacm/zprim
      SET file_name  = '',
          mime_type  = '',
          attachment = ''
      WHERE bukrs = '9730'
        AND gjahr = '2026'
        AND zidfs = '0545'.

    out->write( 'PDF cleared for S100 / 2026 / 0003.' ).
  ENDMETHOD.

ENDCLASS.

