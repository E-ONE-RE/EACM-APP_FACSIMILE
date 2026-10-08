CLASS /eacm/cl_fac_mail_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_apj_rt_run.

    "! Identificativo del batch di invio
    DATA p_run_uuid TYPE sysuuid_c32.

    "! Data fattura
    DATA p_invoice_date TYPE d.

    "! Data pagamento
    DATA p_payment_date TYPE d.

  PRIVATE SECTION.

    CONSTANTS:
      gc_sender            TYPE string
        VALUE 'btp.noreply@mailing.bosch.com',

      gc_language          TYPE sylangu
        VALUE 'E',

      gc_status_queued     TYPE /eacm/fmail_log-status
        VALUE 'Q',

      gc_status_processing TYPE /eacm/fmail_log-status
        VALUE 'P',

      gc_status_success    TYPE /eacm/fmail_log-status
        VALUE 'S',

      gc_status_warning    TYPE /eacm/fmail_log-status
        VALUE 'W',

      gc_status_error      TYPE /eacm/fmail_log-status
        VALUE 'E'.

ENDCLASS.


CLASS /eacm/cl_fac_mail_job IMPLEMENTATION.

  METHOD if_apj_rt_run~execute.

    DATA lv_run_uuid TYPE /eacm/fmail_run-run_uuid.

    TRY.

        cl_system_uuid=>convert_uuid_c32_static(
          EXPORTING
            uuid     = p_run_uuid
          IMPORTING
            uuid_x16 = lv_run_uuid
        ).

      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    " Il job può prendere in carico solamente un batch accodato.
    UPDATE /eacm/fmail_run
      SET status = @gc_status_processing
      WHERE run_uuid = @lv_run_uuid
        AND status   = @gc_status_queued.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    COMMIT WORK AND WAIT.

    " Controllo difensivo sui parametri ricevuti dal job.
    IF p_invoice_date IS INITIAL
       OR p_payment_date IS INITIAL.

      GET TIME STAMP FIELD DATA(lv_parameter_error_at).

      DATA(lv_parameter_error) =
        CONV /eacm/fmail_log-error_text(
          'Data fattura o data pagamento non valorizzata'
        ).

      UPDATE /eacm/fmail_log
        SET status       = @gc_status_error,
            processed_at = @lv_parameter_error_at,
            error_text   = @lv_parameter_error
        WHERE run_uuid = @lv_run_uuid
          AND status   = @gc_status_queued.

      UPDATE /eacm/fmail_run
        SET status = @gc_status_error
        WHERE run_uuid = @lv_run_uuid.

      COMMIT WORK AND WAIT.
      RETURN.

    ENDIF.

    SELECT FROM /eacm/fmail_log
      FIELDS
        run_uuid,
        log_uuid,
        bukrs,
        gjahr,
        zidfs,
        mailaddress,
        file_name,
        file_name_d
      WHERE run_uuid = @lv_run_uuid
        AND status   = @gc_status_queued
      ORDER BY log_uuid
      INTO TABLE @DATA(lt_logs).

    DATA lt_attachments
      TYPE /eacm/cl_fac_mail_builder=>tt_attachments.

    DATA lt_send_status
      TYPE cl_bcs_mail_message=>tyt_status.

    DATA ls_send_status
      TYPE cl_bcs_mail_message=>tys_status.

    DATA lv_mail_status
      TYPE cl_bcs_mail_message=>ty_status.

    DATA lv_effective_status
      TYPE cl_bcs_mail_message=>ty_status.

    DATA lv_target_status
      TYPE /eacm/fmail_log-status.

    DATA lv_error_text TYPE string.
    DATA lv_log_error  TYPE /eacm/fmail_log-error_text.

    "lettura template
    SELECT SINGLE subject,
                  body
      FROM /eacm/fmail_text
      WHERE run_uuid = @lv_run_uuid
      INTO @DATA(ls_mail_text).

    IF sy-subrc <> 0.
      " Impostare a E il run e tutti i relativi log
      " con messaggio 'Testo e-mail non trovato'
      RETURN.
    ENDIF.

    LOOP AT lt_logs INTO DATA(ls_log).

      " Prende in carico la singola mail.
      UPDATE /eacm/fmail_log
        SET status = @gc_status_processing
        WHERE run_uuid = @ls_log-run_uuid
          AND log_uuid = @ls_log-log_uuid
          AND status   = @gc_status_queued.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      COMMIT WORK AND WAIT.

      CLEAR:
        lt_attachments,
        lt_send_status,
        ls_send_status,
        lv_mail_status,
        lv_effective_status,
        lv_error_text,
        lv_log_error.

      lv_target_status = gc_status_error.

      "/ Email di test
      DATA(lo_namespace) =
        xco_cp_system=>namespace->for( '/EACM/' ).
*      DATA(lv_exists) = lo_namespace->exists( ).
      DATA(lv_changeable) = lo_namespace->is_changeable( ).
      IF lv_changeable = abap_true.
        SELECT SINGLE
        FROM /eacm/fmail_run
        FIELDS created_by
        WHERE run_uuid = @ls_log-run_uuid
        INTO @DATA(lv_created_by).

        SELECT SINGLE
        FROM I_BusinessUserBasic
        FIELDS \_WorkplaceAddress-DefaultEmailAddress AS EmailAddress
        WHERE UserID = @lv_created_by
        INTO @ls_log-mailaddress.
      ENDIF.
      "\ Email di test

      TRY.

          SELECT SINGLE FROM /eacm/zprim
            FIELDS
              mime_type,
              attachment,
              attachment_d
            WHERE bukrs = @ls_log-bukrs
              AND gjahr = @ls_log-gjahr
              AND zidfs = @ls_log-zidfs
            INTO @DATA(ls_document).

          IF sy-subrc <> 0.

            lv_error_text =
              'Record del facsimile non trovato'.

          ELSEIF ls_log-mailaddress IS INITIAL.

            lv_error_text =
              'Indirizzo e-mail non valorizzato'.

          ELSEIF ls_document-attachment IS INITIAL.

            lv_error_text =
              'PDF del facsimile non disponibile'.

          ELSEIF ls_document-attachment_d IS INITIAL.

            lv_error_text =
              'PDF del dettaglio facsimile non disponibile'.

          ELSE.

            APPEND VALUE #(
              file_name = CONV string( ls_log-file_name )
              mime_type = CONV string( ls_document-mime_type )
              content   = ls_document-attachment
            ) TO lt_attachments.

            APPEND VALUE #(
              file_name = CONV string( ls_log-file_name_d )
              mime_type = CONV string( ls_document-mime_type )
              content   = ls_document-attachment_d
            ) TO lt_attachments.

            DATA(lo_message) =
              /eacm/cl_fac_mail_builder=>build_message(
                iv_bukrs          = ls_log-bukrs
                iv_gjahr          = ls_log-gjahr
                iv_zidfs          = ls_log-zidfs
                iv_sender         = gc_sender
                iv_recipient      =
                  CONV string( ls_log-mailaddress )
                iv_language       = gc_language
                iv_invoice_date   = p_invoice_date
                iv_payment_date   = p_payment_date
                it_attachments    = lt_attachments
                iv_subject = CONV string( ls_mail_text-subject )
                iv_body    = CONV string( ls_mail_text-body )
              ).

            lo_message->send(
              IMPORTING
                et_status      = lt_send_status
                ev_mail_status = lv_mail_status
            ).

            " Per una sola destinazione lo stato destinatario
            " è più specifico dello stato generale.
            lv_effective_status = lv_mail_status.

            READ TABLE lt_send_status
              INDEX 1
              INTO ls_send_status.

            IF sy-subrc = 0.
              lv_effective_status =
                ls_send_status-status.
            ENDIF.

            CASE lv_effective_status.

              WHEN 'S'.
                lv_target_status = gc_status_success.

              WHEN 'W'.
                lv_target_status = gc_status_warning.

                IF ls_send_status-status_response IS NOT INITIAL.
                  lv_error_text =
                    CONV string(
                      ls_send_status-status_response
                    ).
                ELSE.
                  lv_error_text =
                    'Invio accettato ma ancora in attesa'.
                ENDIF.

              WHEN OTHERS.
                lv_target_status = gc_status_error.

                IF ls_send_status-status_response IS NOT INITIAL.
                  lv_error_text =
                    CONV string(
                      ls_send_status-status_response
                    ).
                ELSE.
                  lv_error_text =
                    |Invio terminato con stato { lv_effective_status }|.
                ENDIF.

            ENDCASE.

          ENDIF.

        CATCH cx_smtg_email_common INTO DATA(lx_template).
          lv_target_status = gc_status_error.
          lv_error_text =
            |Errore template: { lx_template->get_text( ) }|.

        CATCH cx_bcs_mail INTO DATA(lx_mail).
          lv_target_status = gc_status_error.
          lv_error_text =
            |Errore invio: { lx_mail->get_text( ) }|.

      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_processed_at).

      IF strlen( lv_error_text ) > 255.
        lv_log_error = substring(
          val = lv_error_text
          off = 0
          len = 255
        ).
      ELSE.
        lv_log_error = lv_error_text.
      ENDIF.

      UPDATE /eacm/fmail_log
        SET status       = @lv_target_status,
            processed_at = @lv_processed_at,
            error_text   = @lv_log_error
        WHERE run_uuid = @ls_log-run_uuid
          AND log_uuid = @ls_log-log_uuid.

      COMMIT WORK AND WAIT.

    ENDLOOP.

    " Determinazione dello stato complessivo del batch.
    SELECT FROM /eacm/fmail_log
      FIELDS status
      WHERE run_uuid = @lv_run_uuid
      INTO TABLE @DATA(lt_final_statuses).

    DATA:
      lv_has_success TYPE abap_bool,
      lv_has_warning TYPE abap_bool,
      lv_has_error   TYPE abap_bool,
      lv_has_pending TYPE abap_bool.

    LOOP AT lt_final_statuses
      INTO DATA(ls_final_status).

      CASE ls_final_status-status.
        WHEN gc_status_success.
          lv_has_success = abap_true.

        WHEN gc_status_warning.
          lv_has_warning = abap_true.

        WHEN gc_status_error.
          lv_has_error = abap_true.

        WHEN gc_status_queued
          OR gc_status_processing.
          lv_has_pending = abap_true.
      ENDCASE.

    ENDLOOP.

    DATA lv_final_run_status
      TYPE /eacm/fmail_run-status.

    lv_final_run_status = COND #(
      WHEN lt_final_statuses IS INITIAL
        THEN gc_status_error

      WHEN lv_has_pending = abap_true
        THEN gc_status_processing

      WHEN lv_has_error = abap_true
       AND ( lv_has_success = abap_true
          OR lv_has_warning = abap_true )
        THEN gc_status_warning

      WHEN lv_has_error = abap_true
        THEN gc_status_error

      WHEN lv_has_warning = abap_true
        THEN gc_status_warning

      ELSE gc_status_success
    ).

    UPDATE /eacm/fmail_run
      SET status = @lv_final_run_status
      WHERE run_uuid = @lv_run_uuid.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

ENDCLASS.
