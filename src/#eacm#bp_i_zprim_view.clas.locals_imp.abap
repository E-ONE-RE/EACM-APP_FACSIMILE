CLASS lsc_/eacm/i_zprim_view DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified   REDEFINITION.
*    METHODS cleanup         REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/eacm/i_zprim_view IMPLEMENTATION.

  METHOD save_modified.

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

  ENDMETHOD.

*  METHOD cleanup.
*    CLEAR /eacm/bp_i_zprim_view=>gt_print_requests.
*  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR /eacm/bp_i_zprim_view=>gt_print_requests.
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

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      APPEND VALUE #( %tky = <key>-%tky )
        TO failed-/eacm/i_zprim_view.

      APPEND VALUE #(
        %tky = <key>-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'working progress'
        )
      ) TO reported-/eacm/i_zprim_view.

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

ENDCLASS.
