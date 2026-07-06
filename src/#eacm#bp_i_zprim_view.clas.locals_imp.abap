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

ENDCLASS.
