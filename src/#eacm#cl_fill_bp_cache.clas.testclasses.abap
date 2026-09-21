*"* use this source file for your ABAP unit test classes


*"* use this source file for your ABAP unit test classes
CLASS ltc_fill_bp_cache DEFINITION FINAL
  FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO /eacm/cl_fill_bp_cache.

    METHODS:
      setup,
      test_run FOR TESTING.

ENDCLASS.
CLASS ltc_fill_bp_cache IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW /eacm/cl_fill_bp_cache( ).
  ENDMETHOD.

  METHOD test_run.

*    DATA lt_parameters TYPE if_apj_rt_types=>tt_job_parameters.

    " Popola eventuali parametri necessari

    TRY.
        mo_cut->run( ).

      CATCH cx_apj_rt_content.
        "handle exception
    ENDTRY.

    " Verifiche
    cl_abap_unit_assert=>assert_true(
      act = abap_true ).

  ENDMETHOD.

ENDCLASS.
