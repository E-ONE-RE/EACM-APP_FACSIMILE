*"* use this source file for your ABAP unit test classes
*"* use this source file for your ABAP unit test classes

CLASS ltc_fac_mail_integration DEFINITION FINAL
  FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS:
      " Inserire una chiave realmente esistente
      lc_bukrs     TYPE /eacm/zprim-bukrs
        VALUE '9730',

      lc_gjahr     TYPE /eacm/zprim-gjahr
        VALUE '2026',

      lc_zidfs     TYPE /eacm/zprim-zidfs
        VALUE '0005',

      " Utilizzare sempre un proprio indirizzo di test
      lc_recipient TYPE string
        VALUE 'roberto.a.costantino@gmail.com',

      lc_sender    TYPE string
        VALUE 'btp.noreply@mailing.bosch.com'.

    METHODS render_and_send
        FOR TESTING.

ENDCLASS.


CLASS ltc_fac_mail_integration IMPLEMENTATION.

  METHOD render_and_send.

    SELECT SINGLE
      FROM /eacm/zprim
      FIELDS
        file_name,
        mime_type,
        attachment,
        file_name_d,
        attachment_d
      WHERE bukrs = @lc_bukrs
        AND gjahr = @lc_gjahr
        AND zidfs = @lc_zidfs
      INTO @DATA(ls_facsimile).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = sy-subrc
      msg = |Facsimile { lc_bukrs }/{ lc_gjahr }/{ lc_zidfs } non trovato|
    ).

    DATA lt_attachments
      TYPE /eacm/cl_fac_mail_builder=>tt_attachments.

    IF ls_facsimile-attachment IS NOT INITIAL.

      APPEND VALUE #(
        file_name = CONV string( ls_facsimile-file_name )
        mime_type = CONV string( ls_facsimile-mime_type )
        content   = ls_facsimile-attachment
      ) TO lt_attachments.

    ENDIF.

    IF ls_facsimile-attachment_d IS NOT INITIAL.

      APPEND VALUE #(
        file_name = CONV string( ls_facsimile-file_name_d )
        mime_type = CONV string( ls_facsimile-mime_type )
        content   = ls_facsimile-attachment_d
      ) TO lt_attachments.

    ENDIF.

    DATA(ls_template) =
      /eacm/cl_fac_mail_builder=>get_template_defaults(
        iv_language = 'E'
      ).

    TRY.

        DATA(lo_message) =
       /eacm/cl_fac_mail_builder=>build_message(
         iv_bukrs         = lc_bukrs
         iv_gjahr         = lc_gjahr
         iv_zidfs         = lc_zidfs
         iv_sender        = lc_sender
         iv_recipient     = lc_recipient
         iv_language      = 'E'
         iv_invoice_date  = '20261015'
         iv_payment_date  = '20261115'
         iv_subject       = ls_template-subject
         iv_body          = ls_template-body
         it_attachments   = lt_attachments
       ).

        cl_abap_unit_assert=>assert_bound(
          act = lo_message
          msg = 'Il builder non ha restituito il messaggio'
        ).

        " Invio sincrono intenzionale per il test:
        " l'eventuale errore SMTP viene restituito immediatamente.
        DATA(lo_monitor) = lo_message->send( ).

        cl_abap_unit_assert=>assert_bound(
          act = lo_monitor
          msg = 'Il servizio mail non ha restituito il monitor'
        ).

      CATCH cx_smtg_email_common INTO DATA(lx_template).

        cl_abap_unit_assert=>fail(
          msg = |Errore nel rendering del template: { lx_template->get_text( ) }|
        ).

      CATCH cx_bcs_mail INTO DATA(lx_mail).

        cl_abap_unit_assert=>fail(
          msg = |Errore nell'invio della mail: { lx_mail->get_text( ) }|
        ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.

