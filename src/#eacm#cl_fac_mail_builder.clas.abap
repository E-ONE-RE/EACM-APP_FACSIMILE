CLASS /eacm/cl_fac_mail_builder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attachment,
        file_name TYPE string,
        mime_type TYPE string,
        content   TYPE xstring,
      END OF ty_attachment,

      tt_attachments TYPE STANDARD TABLE OF ty_attachment
        WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_template,
        subject TYPE string,
        body    TYPE string,
      END OF ty_template.

    CONSTANTS gc_template_id TYPE string
      VALUE '/EACM/FACSIMILE_MAIL'.

    CLASS-METHODS build_message
      IMPORTING
        iv_bukrs          TYPE /eacm/zprim-bukrs
        iv_gjahr          TYPE /eacm/zprim-gjahr
        iv_zidfs          TYPE /eacm/zprim-zidfs
        iv_sender         TYPE string
        iv_recipient      TYPE string
        iv_language       TYPE sylangu DEFAULT 'E'
        iv_template_id    TYPE string DEFAULT gc_template_id
        it_attachments    TYPE tt_attachments OPTIONAL
        iv_invoice_date   TYPE d OPTIONAL
        iv_payment_date   TYPE d OPTIONAL
        iv_subject        TYPE string
        iv_body           TYPE string
      RETURNING
        VALUE(ro_message) TYPE REF TO cl_bcs_mail_message
      RAISING
        cx_bcs_mail
        cx_smtg_email_common.

    CLASS-METHODS get_template_defaults
      IMPORTING
        iv_language        TYPE sylangu
      RETURNING
        VALUE(rs_template) TYPE ty_template.

  PRIVATE SECTION.
    CLASS-METHODS replace_date_tokens
      IMPORTING
        iv_invoice_date TYPE d
        iv_payment_date TYPE d
      CHANGING
        cv_text         TYPE string.
ENDCLASS.


CLASS /eacm/cl_fac_mail_builder IMPLEMENTATION.

  METHOD build_message.

    SELECT SINGLE
      AgentName,
      CommissionPeriod
      FROM /eacm/i_fac_mail_tpl
      WHERE Bukrs = @iv_bukrs
        AND Gjahr = @iv_gjahr
        AND Zidfs = @iv_zidfs
      INTO @DATA(ls_mail_data).

    DATA(lv_subject) = iv_subject.
    DATA(lv_body)    = iv_body.

    DATA(lv_agent_name) =
      CONV string( ls_mail_data-AgentName ).

    DATA(lv_commission_period) =
      CONV string( ls_mail_data-CommissionPeriod ).

    REPLACE ALL OCCURRENCES OF `[[AGENT_NAME]]`
      IN lv_subject WITH lv_agent_name.
    REPLACE ALL OCCURRENCES OF `[[AGENT_NAME]]`
      IN lv_body WITH lv_agent_name.

    REPLACE ALL OCCURRENCES OF `[[COMMISSION_PERIOD]]`
      IN lv_subject WITH lv_commission_period.
    REPLACE ALL OCCURRENCES OF `[[COMMISSION_PERIOD]]`
      IN lv_body WITH lv_commission_period.

    replace_date_tokens(
      EXPORTING
        iv_invoice_date = iv_invoice_date
        iv_payment_date = iv_payment_date
      CHANGING
        cv_text         = lv_body
    ).

    ro_message =
      cl_bcs_mail_message=>create_instance( ).

    ro_message->set_sender( CONV #( iv_sender ) ).
    ro_message->add_recipient( CONV #( iv_recipient ) ).
    ro_message->set_subject( CONV #( lv_subject ) ).

    ro_message->set_main(
      cl_bcs_mail_textpart=>create_text_plain(
        iv_content = lv_body
      )
    ).

    LOOP AT it_attachments INTO DATA(ls_attachment).

      IF ls_attachment-content IS INITIAL
         OR ls_attachment-file_name IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_mime_type) = COND string(
        WHEN ls_attachment-mime_type IS INITIAL
          THEN `application/pdf`
        ELSE ls_attachment-mime_type
      ).

      ro_message->add_attachment(
        cl_bcs_mail_binarypart=>create_instance(
          iv_content      = ls_attachment-content
          iv_content_type = CONV #( lv_mime_type )
          iv_filename     = ls_attachment-file_name
        )
      ).

    ENDLOOP.

  ENDMETHOD.

  METHOD replace_date_tokens.

    DATA lv_invoice_date_text TYPE string.
    DATA lv_payment_date_text TYPE string.

    IF iv_invoice_date IS NOT INITIAL.
      lv_invoice_date_text =
        |{ iv_invoice_date DATE = USER }|.
    ENDIF.

    IF iv_payment_date IS NOT INITIAL.
      lv_payment_date_text =
        |{ iv_payment_date DATE = USER }|.
    ENDIF.

    REPLACE ALL OCCURRENCES OF
      '[[INVOICE_DATE]]'
      IN cv_text
      WITH lv_invoice_date_text.

    REPLACE ALL OCCURRENCES OF
      '[[PAYMENT_DATE]]'
      IN cv_text
      WITH lv_payment_date_text.

  ENDMETHOD.

  METHOD get_template_defaults.

    DATA(lv_newline) = cl_abap_char_utilities=>newline.

    rs_template-subject =
      `Facsimile competenza [[COMMISSION_PERIOD]] e tabulato liquidate`.

    rs_template-body =
        |Buongiorno [[AGENT_NAME]],{ lv_newline }{ lv_newline }|
     && |in allegato inviamo il facsimile di cui in oggetto con il relativo |
     && |tabulato delle liquidate.{ lv_newline }{ lv_newline }|
     && |Rimaniamo in attesa di ricevere la fattura entro il [[INVOICE_DATE]].{ lv_newline }|
     && |Il pagamento verrà effettuato con valuta [[PAYMENT_DATE]].{ lv_newline }{ lv_newline }|
     && |Distinti Saluti{ lv_newline }|
     && |C/HRR1-IG - Coordinamento Agenti|.

  ENDMETHOD.

ENDCLASS.
