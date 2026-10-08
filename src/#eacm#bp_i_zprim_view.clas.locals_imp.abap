CLASS lsc_/eacm/i_zprim_view DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified   REDEFINITION.
*    METHODS cleanup         REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_/eacm/i_zprim_view IMPLEMENTATION.

  METHOD save_modified.

    " ==========================================================
    " GESTIONE STAMPE
    " ==========================================================
    LOOP AT /eacm/bp_i_zprim_view=>gt_print_requests
         INTO DATA(ls_request).

      GET TIME STAMP FIELD DATA(lv_now).

      DATA(ls_start_info) =
        VALUE cl_apj_rt_api=>ty_start_info(
          timestamp = cl_abap_tstmp=>add_to_short(
            tstmp = lv_now
            secs  = 5 ) ).

      DATA(lt_job_parameters) =
        VALUE cl_apj_rt_api=>tt_job_parameter_value(
          ( name = 'P_BUKRS'
            t_value = VALUE #(
              ( sign = 'I' option = 'EQ'
                low = ls_request-bukrs ) ) )

          ( name = 'P_GJAHR'
            t_value = VALUE #(
              ( sign = 'I' option = 'EQ'
                low = ls_request-gjahr ) ) )

          ( name = 'P_ZIDFS'
            t_value = VALUE #(
              ( sign = 'I' option = 'EQ'
                low = ls_request-zidfs ) ) )
        ).

      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name    = '/EACM/TMPL_FACJOB'
              iv_job_text             =
                |Stampa fattura { ls_request-bukrs }/{ ls_request-gjahr }/{ ls_request-zidfs }|
              is_start_info           = ls_start_info
              it_job_parameter_value  = lt_job_parameters
          ).

        CATCH cx_apj_rt INTO DATA(lx_apj).
          APPEND VALUE #(
            Bukrs = ls_request-bukrs
            Gjahr = ls_request-gjahr
            Zidfs = ls_request-zidfs
            %msg  = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = lx_apj->get_text( ) )
          ) TO reported-/eacm/i_zprim_view.
      ENDTRY.

    ENDLOOP.

    " ==========================================================
    " GESTIONE INVIO E-MAIL
    " ==========================================================
    IF /eacm/bp_i_zprim_view=>gt_mail_requests[] IS NOT  INITIAL.

      DATA lt_run_uuids TYPE SORTED TABLE OF /eacm/fmail_run-run_uuid
                        WITH UNIQUE KEY table_line.

      DATA lt_log_rows TYPE STANDARD TABLE OF /eacm/fmail_log
                       WITH EMPTY KEY.

      DATA lv_has_queued     TYPE abap_bool.
      DATA lv_run_status     TYPE /eacm/fmail_run-status.
      DATA lv_run_uuid_c32   TYPE sysuuid_c32.
      DATA lv_schedule_error TYPE string.
      DATA lv_log_error      TYPE /eacm/fmail_log-error_text.
      DATA lv_failed_at      TYPE /eacm/fmail_log-processed_at.

      " Può esserci più di una action nella stessa LUW:
      " elaboriamo separatamente ogni RunUuid.
      LOOP AT /eacm/bp_i_zprim_view=>gt_mail_requests
           INTO DATA(ls_mail_request).

        INSERT ls_mail_request-run_uuid
          INTO TABLE lt_run_uuids.

      ENDLOOP.

      LOOP AT lt_run_uuids INTO DATA(lv_run_uuid).

        READ TABLE /eacm/bp_i_zprim_view=>gt_mail_requests
          WITH KEY run_uuid = lv_run_uuid
          INTO DATA(ls_first_request).

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        GET TIME STAMP FIELD lv_now.

        CLEAR:
          lt_log_rows,
          lv_has_queued,
          lv_run_status,
          lv_run_uuid_c32,
          lv_schedule_error,
          lv_log_error.

        LOOP AT /eacm/bp_i_zprim_view=>gt_mail_requests
             INTO ls_mail_request
             WHERE run_uuid = lv_run_uuid.

          APPEND VALUE #(
            client       = sy-mandt
            run_uuid     = ls_mail_request-run_uuid
            log_uuid     = ls_mail_request-log_uuid
            bukrs        = ls_mail_request-bukrs
            gjahr        = ls_mail_request-gjahr
            zidfs        = ls_mail_request-zidfs
            mailaddress  = ls_mail_request-mailaddress
            file_name    = ls_mail_request-file_name
            file_name_d  = ls_mail_request-file_name_d
            status       = ls_mail_request-status
            processed_at = COND #(
              WHEN ls_mail_request-status =
                   /eacm/bp_i_zprim_view=>gc_mail_status_error
              THEN lv_now
            )
            error_text   = ls_mail_request-error_text
          ) TO lt_log_rows.

          IF ls_mail_request-status =
             /eacm/bp_i_zprim_view=>gc_mail_status_queued.

            lv_has_queued = abap_true.

          ENDIF.

        ENDLOOP.

        lv_run_status = COND #(
          WHEN lv_has_queued = abap_true
          THEN /eacm/bp_i_zprim_view=>gc_mail_status_queued
          ELSE /eacm/bp_i_zprim_view=>gc_mail_status_error
        ).

        DATA(ls_run_row) = VALUE /eacm/fmail_run(
          client     = sy-mandt
          run_uuid   = lv_run_uuid
          created_at = lv_now
          created_by = cl_abap_context_info=>get_user_technical_name( )
          status     = lv_run_status
          gjahr      = ls_first_request-gjahr
          zamcf      = ls_first_request-zamcf
        ).

        INSERT /eacm/fmail_run FROM @ls_run_row.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DATA(ls_mail_text) =
          VALUE /eacm/fmail_text(
            client   = sy-mandt
            run_uuid = lv_run_uuid
            subject  = ls_first_request-subject
            body     = ls_first_request-body
          ).

        INSERT /eacm/fmail_text FROM @ls_mail_text.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        INSERT /eacm/fmail_log
          FROM TABLE @lt_log_rows.

        " Se tutte le righe erano già errate, il batch viene
        " registrato ma non viene pianificato alcun job.
        IF lv_has_queued = abap_false.
          CONTINUE.
        ENDIF.

        TRY.

            cl_system_uuid=>convert_uuid_x16_static(
              EXPORTING
                uuid     = lv_run_uuid
              IMPORTING
                uuid_c32 = lv_run_uuid_c32
            ).

            ls_start_info =
              VALUE cl_apj_rt_api=>ty_start_info(
                timestamp = cl_abap_tstmp=>add_to_short(
                  tstmp = lv_now
                  secs  = 5
                )
              ).

            lt_job_parameters =
              VALUE cl_apj_rt_api=>tt_job_parameter_value(

                ( name = 'P_RUN_UUID'
                  t_value = VALUE #(
                    ( sign   = 'I'
                      option = 'EQ'
                      low    = lv_run_uuid_c32 )
                  )
                )

                ( name = 'P_INVOICE_DATE'
                  t_value = VALUE #(
                    ( sign   = 'I'
                      option = 'EQ'
                      low    = ls_first_request-InvoiceDate )
                  )
                )

                ( name = 'P_PAYMENT_DATE'
                  t_value = VALUE #(
                    ( sign   = 'I'
                      option = 'EQ'
                      low    = ls_first_request-PaymentDate )
                  )
                )

              ).

            cl_apj_rt_api=>schedule_job(
              EXPORTING
                iv_job_template_name   = '/EACM/TMPL_FACMAIL'
                iv_job_text            =
                  |Invio e-mail facsimili { lv_run_uuid_c32 }|
                is_start_info          = ls_start_info
                it_job_parameter_value = lt_job_parameters
            ).

          CATCH cx_uuid_error INTO DATA(lx_uuid).
            lv_schedule_error = lx_uuid->get_text( ).

          CATCH cx_apj_rt INTO lx_apj.
            lv_schedule_error = lx_apj->get_text( ).

        ENDTRY.

        IF lv_schedule_error IS INITIAL.

          APPEND VALUE #(
            Bukrs = ls_first_request-bukrs
            Gjahr = ls_first_request-gjahr
            Zidfs = ls_first_request-zidfs
            %msg  = new_message_with_text(
              severity = if_abap_behv_message=>severity-information
              text     =
                |Invio e-mail pianificato. Run { lv_run_uuid_c32 }|
            )
          ) TO reported-/eacm/i_zprim_view.

          CONTINUE.

        ENDIF.

        " Errore nella pianificazione: il log rimane consultabile.
        GET TIME STAMP FIELD lv_failed_at.

        lv_log_error = lv_schedule_error.

        DATA(lv_status_error) =
          /eacm/bp_i_zprim_view=>gc_mail_status_error.

        UPDATE /eacm/fmail_run
          SET status = @lv_status_error
          WHERE run_uuid = @lv_run_uuid.

        UPDATE /eacm/fmail_log
          SET status       = @lv_status_error,
              processed_at = @lv_failed_at,
              error_text   = @lv_log_error
          WHERE run_uuid = @lv_run_uuid
            AND status   = 'Q'.

        APPEND VALUE #(
          Bukrs = ls_first_request-bukrs
          Gjahr = ls_first_request-gjahr
          Zidfs = ls_first_request-zidfs
          %msg  = new_message_with_text(
            severity = if_abap_behv_message=>severity-warning
            text     =
              |Richiesta registrata, ma il job non è stato pianificato: { lv_schedule_error }|
          )
        ) TO reported-/eacm/i_zprim_view.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

*  METHOD cleanup.
*    CLEAR /eacm/bp_i_zprim_view=>gt_print_requests.
*  ENDMETHOD.

  METHOD cleanup_finalize.

    CLEAR /eacm/bp_i_zprim_view=>gt_print_requests.
    CLEAR /eacm/bp_i_zprim_view=>gt_mail_requests.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_I_ZPRIM_VIEW DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR /eacm/i_zprim_view RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR /eacm/i_zprim_view RESULT result.

*    METHODS onDelete FOR MODIFY
*      IMPORTING keys FOR ACTION /eacm/i_zprim_view~onDelete RESULT result.

*    METHODS onDownload FOR MODIFY
*      IMPORTING keys FOR ACTION /eacm/i_zprim_view~onDownload RESULT result.

*    METHODS onPosting FOR MODIFY
*      IMPORTING keys FOR ACTION /eacm/i_zprim_view~onPosting RESULT result.

    METHODS onSendMail FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/i_zprim_view~onSendMail RESULT result.
    METHODS onPrint FOR MODIFY
      keys FOR ACTION /eacm/i_zprim_view~onPrint
      RESULT result.
    METHODS GetDefaultsForonSendMail FOR READ
       keys FOR FUNCTION /eacm/i_zprim_view~GetDefaultsForonSendMail RESULT result.

ENDCLASS.

CLASS lhc_I_ZPRIM_VIEW IMPLEMENTATION.

*  METHOD get_instance_authorizations.
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*      APPEND VALUE #(
*        %tky    = <key>-%tky
*        %update = if_abap_behv=>auth-allowed
*        %delete = if_abap_behv=>auth-allowed
*      ) TO result.
*    ENDLOOP.
*  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

*  METHOD onDelete.
*  ENDMETHOD.

*  METHOD onDownload.
*  ENDMETHOD.

*  METHOD onPosting.
*  ENDMETHOD.

  METHOD onSendMail.

    READ ENTITIES OF /eacm/i_zprim_view IN LOCAL MODE
      ENTITY /eacm/i_zprim_view
      FIELDS (
        Bukrs
        Gjahr
        Zamcf
        Zidfs
        Mailaddress
        FileName
        FileNameD
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_zprim)
      FAILED DATA(ls_read_failed)
      REPORTED DATA(ls_read_reported).

    APPEND LINES OF
      ls_read_failed-/eacm/i_zprim_view
      TO failed-/eacm/i_zprim_view.

    APPEND LINES OF
      ls_read_reported-/eacm/i_zprim_view
      TO reported-/eacm/i_zprim_view.

    IF lt_zprim IS INITIAL.
      RETURN.
    ENDIF.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_parameters) = keys[ 1 ]-%param.

    IF ls_parameters-InvoiceDate IS INITIAL
       OR ls_parameters-PaymentDate IS INITIAL.

      LOOP AT keys ASSIGNING FIELD-SYMBOL(<invalid_key>).

        APPEND VALUE #(
          %tky = <invalid_key>-%tky
        ) TO failed-/eacm/i_zprim_view.

        APPEND VALUE #(
          %tky = <invalid_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Inserire entrambe le date'
          )
        ) TO reported-/eacm/i_zprim_view.

      ENDLOOP.

      RETURN.

    ENDIF.

    TRY.
        DATA(lv_run_uuid) =
          cl_system_uuid=>create_uuid_x16_static( ).

      CATCH cx_uuid_error INTO DATA(lx_run_uuid).

        LOOP AT lt_zprim ASSIGNING FIELD-SYMBOL(<failed_zprim>).

          APPEND VALUE #(
            %tky = <failed_zprim>-%tky
          ) TO failed-/eacm/i_zprim_view.

          APPEND VALUE #(
            %tky = <failed_zprim>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = lx_run_uuid->get_text( )
            )
          ) TO reported-/eacm/i_zprim_view.

        ENDLOOP.

        RETURN.

    ENDTRY.

    IF ls_parameters-Subject IS INITIAL
       OR ls_parameters-Body IS INITIAL.

      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

        APPEND VALUE #( %tky = <key>-%tky )
          TO failed-/eacm/i_zprim_view.

        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Oggetto e corpo della mail sono obbligatori'
          )
        ) TO reported-/eacm/i_zprim_view.

      ENDLOOP.

      RETURN.
    ENDIF.

    LOOP AT lt_zprim ASSIGNING FIELD-SYMBOL(<zprim>).

      DATA lv_status     TYPE /eacm/fmail_log-status.
      DATA lv_error_text TYPE /eacm/fmail_log-error_text.

      lv_status =
        /eacm/bp_i_zprim_view=>gc_mail_status_queued.

      CLEAR lv_error_text.

      IF <zprim>-Mailaddress IS INITIAL.

        lv_status =
          /eacm/bp_i_zprim_view=>gc_mail_status_error.

        lv_error_text =
          'Indirizzo e-mail del destinatario non presente'.

      ELSEIF <zprim>-FileName IS INITIAL
          OR <zprim>-FileNameD IS INITIAL.

        lv_status =
          /eacm/bp_i_zprim_view=>gc_mail_status_error.

        lv_error_text =
          'Facsimile o dettaglio facsimile non disponibile'.

      ENDIF.


      TRY.
          DATA(lv_log_uuid) =
            cl_system_uuid=>create_uuid_x16_static( ).

        CATCH cx_uuid_error INTO DATA(lx_log_uuid).

          APPEND VALUE #(
            %tky = <zprim>-%tky
          ) TO failed-/eacm/i_zprim_view.

          APPEND VALUE #(
            %tky = <zprim>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = lx_log_uuid->get_text( )
            )
          ) TO reported-/eacm/i_zprim_view.

          CONTINUE.

      ENDTRY.

      INSERT VALUE #(
        run_uuid    = lv_run_uuid
        log_uuid    = lv_log_uuid
        bukrs       = <zprim>-Bukrs
        gjahr       = <zprim>-Gjahr
        zamcf       = <zprim>-Zamcf
        zidfs       = <zprim>-Zidfs
        mailaddress = <zprim>-Mailaddress
        file_name   = <zprim>-FileName
        file_name_d = <zprim>-FileNameD
        status      = lv_status
        error_text  = lv_error_text
        InvoiceDate = ls_parameters-InvoiceDate
        PaymentDate = ls_parameters-PaymentDate
        subject = ls_parameters-Subject
        body    = ls_parameters-Body
      ) INTO TABLE
        /eacm/bp_i_zprim_view=>gt_mail_requests.

      APPEND VALUE #(
        %tky = <zprim>-%tky
        %param = VALUE #(
          RunUuid = lv_run_uuid
        )
      ) TO result.

      IF lv_error_text IS NOT INITIAL.

        APPEND VALUE #(
          %tky = <zprim>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-warning
            text     = lv_error_text
          )
        ) TO reported-/eacm/i_zprim_view.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD onPrint.


*    LOOP AT keys INTO DATA(ls_key).
*      INSERT VALUE #(
*        bukrs = ls_key-bukrs
*        gjahr = ls_key-gjahr
*        zidfs = ls_key-zidfs
*      ) INTO TABLE /eacm/bp_i_zprim_view=>gt_print_requests.
*    ENDLOOP.

    DATA lv_attachment     TYPE /eacm/zprim-attachment.
    DATA lv_attachment_d     TYPE /eacm/zprim-attachment_d.
    DATA lt_successful_keys LIKE keys.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      CLEAR lv_attachment.

      READ ENTITIES OF /eacm/i_zprim_view IN LOCAL MODE
        ENTITY /eacm/i_zprim_view
        FIELDS ( Bukrs Gjahr Zidfs Zcdaz Zamcf )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_zprim)
        FAILED   DATA(ls_read_failed)
        REPORTED DATA(ls_read_reported).

      APPEND LINES OF ls_read_failed-/eacm/i_zprim_view
        TO failed-/eacm/i_zprim_view.

      APPEND LINES OF ls_read_reported-/eacm/i_zprim_view
        TO reported-/eacm/i_zprim_view.

      LOOP AT lt_zprim INTO DATA(ls_zprim).

        TRY.

            " Adattare i parametri alla firma reale del metodo.
            lv_attachment = /eacm/cl_zprim_form=>get_pdf(
              iv_bukrs = ls_zprim-Bukrs
              iv_gjahr = ls_zprim-Gjahr
              iv_zidfs = ls_zprim-Zidfs
              iv_service_definition = '/EACM/SV_ZPRIM'
              iv_formname  = '/EACM/FR_ZPRIM'
            ).

            IF lv_attachment IS INITIAL.

              APPEND VALUE #(
                %tky = <key>-%tky
              ) TO failed-/eacm/i_zprim_view.

              APPEND VALUE #(
                %tky = <key>-%tky
                %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = 'Il facsimile è stato generato senza contenuto PDF'
                )
              ) TO reported-/eacm/i_zprim_view.

              CONTINUE.

            ENDIF.

* Dettaglio **********************************************************
            lv_attachment_d = /eacm/cl_zprim_form=>get_pdf(
              iv_bukrs = ls_zprim-Bukrs
              iv_gjahr = ls_zprim-Gjahr
              iv_zidfs = ls_zprim-Zidfs
              iv_service_definition = '/EACM/FACDETT_SRV'
              iv_formname  = '/EACM/FR_ZPRIM_DETT'
            ).
            IF strlen( ls_zprim-zcdaz ) >= 4.
              DATA(lv_vkorg) = substring(
                  val = ls_zprim-zcdaz
                  off = strlen( ls_zprim-zcdaz ) - 4
                  len = 4
                ).
            ELSE.
              CLEAR lv_vkorg.
            ENDIF.

            DATA(lv_file_name_d) = |RIEP-{ ls_zprim-zcdaz }-{ lv_vkorg }-{ ls_zprim-zamcf }-{ ls_zprim-zidfs }.pdf|.

**********************************************************************
            MODIFY ENTITIES OF /eacm/i_zprim_view IN LOCAL MODE
              ENTITY /eacm/i_zprim_view
                UPDATE FIELDS ( Attachment FileName MimeType AttachmentD FileNameD )
                WITH VALUE #(
                  (
                    %tky       = <key>-%tky
                    Attachment = lv_attachment
                    FileName   =
                      |FACSIMILE_{ ls_zprim-Zcdaz }_{ ls_zprim-zamcf }_{ ls_zprim-Zidfs }.pdf|
                    MimeType   = 'application/pdf'
                    AttachmentD = lv_attachment_d
                    FileNameD = lv_file_name_d
                  )
                )
              FAILED   DATA(ls_update_failed)
              REPORTED DATA(ls_update_reported).

            APPEND LINES OF
              ls_update_failed-/eacm/i_zprim_view
              TO failed-/eacm/i_zprim_view.

            APPEND LINES OF
              ls_update_reported-/eacm/i_zprim_view
              TO reported-/eacm/i_zprim_view.

            IF ls_update_failed-/eacm/i_zprim_view IS INITIAL.
              APPEND <key> TO lt_successful_keys.
            ENDIF.

          CATCH cx_root INTO DATA(lx_error).
            DATA(msg) = lx_error->get_text( ).
            APPEND VALUE #(
              %tky = <key>-%tky
            ) TO failed-/eacm/i_zprim_view.

            APPEND VALUE #(
              %tky = <key>-%tky
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     =
                  |Errore durante la generazione del facsimile: { lx_error->get_text( ) }|
              )
            ) TO reported-/eacm/i_zprim_view.

        ENDTRY.
      ENDLOOP.
    ENDLOOP.

    IF lt_successful_keys IS NOT INITIAL.

      READ ENTITIES OF /eacm/i_zprim_view IN LOCAL MODE
        ENTITY /eacm/i_zprim_view
          ALL FIELDS
          WITH CORRESPONDING #( lt_successful_keys )
        RESULT lt_zprim.

      result = VALUE #(
        FOR ls_zprim_loop IN lt_zprim
        (
          %tky   = ls_zprim_loop-%tky
          %param = ls_zprim_loop
        )
      ).

    ENDIF.

  ENDMETHOD.

  METHOD GetDefaultsForonSendMail.

    DATA(ls_template) =
    /eacm/cl_fac_mail_builder=>get_template_defaults(
      iv_language = sy-langu
    ).

    result = VALUE #(
      FOR ls_key IN keys
      (
        %tky = ls_key-%tky
        %param = VALUE #(
          Subject = ls_template-subject
          Body    = ls_template-body
        )
      )
    ).

  ENDMETHOD.

ENDCLASS.
