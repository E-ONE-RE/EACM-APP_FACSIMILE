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

ENDCLASS.



CLASS /eacm/bp_i_zprim_view IMPLEMENTATION.
ENDCLASS.
