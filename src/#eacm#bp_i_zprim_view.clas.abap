CLASS /eacm/bp_i_zprim_view DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF /eacm/i_zprim_view.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_print_request,
        bukrs TYPE /eacm/zprim-bukrs,
        gjahr TYPE /eacm/zprim-gjahr,
        zidfs TYPE /eacm/zprim-zidfs,
      END OF ty_print_request,
      tt_print_request TYPE SORTED TABLE OF ty_print_request
        WITH UNIQUE KEY bukrs gjahr zidfs.

    CLASS-DATA gt_print_requests TYPE tt_print_request.

    TYPES:
      BEGIN OF ty_mail_request,
        run_uuid    TYPE /eacm/fmail_run-run_uuid,
        log_uuid    TYPE /eacm/fmail_log-log_uuid,
        bukrs       TYPE /eacm/fmail_log-bukrs,
        gjahr       TYPE /eacm/fmail_log-gjahr,
        zamcf TYPE /eacm/fmail_run-zamcf,
        zidfs       TYPE /eacm/fmail_log-zidfs,
        mailaddress TYPE /eacm/fmail_log-mailaddress,
        file_name   TYPE /eacm/fmail_log-file_name,
        file_name_d TYPE /eacm/fmail_log-file_name_d,
        status      TYPE /eacm/fmail_log-status,
        error_text  TYPE /eacm/fmail_log-error_text,
        InvoiceDate TYPE d,
        PaymentDate TYPE d,
        subject     TYPE /eacm/fmail_text-subject,
        body        TYPE /eacm/fmail_text-body,
      END OF ty_mail_request,

      tt_mail_requests TYPE SORTED TABLE OF ty_mail_request
                         WITH UNIQUE KEY run_uuid bukrs gjahr zidfs.

    CONSTANTS:
      gc_mail_status_queued     TYPE /eacm/fmail_run-status VALUE 'Q',
      gc_mail_status_processing TYPE /eacm/fmail_run-status VALUE 'P',
      gc_mail_status_success    TYPE /eacm/fmail_run-status VALUE 'S',
      gc_mail_status_warning    TYPE /eacm/fmail_run-status VALUE 'W',
      gc_mail_status_error      TYPE /eacm/fmail_run-status VALUE 'E'.

    CLASS-DATA gt_mail_requests TYPE tt_mail_requests.

ENDCLASS.



CLASS /eacm/bp_i_zprim_view IMPLEMENTATION.
ENDCLASS.
