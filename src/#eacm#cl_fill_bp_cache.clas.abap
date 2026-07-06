CLASS /eacm/cl_fill_bp_cache DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_run .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /eacm/cl_fill_bp_cache IMPLEMENTATION.


  METHOD if_apj_rt_run~execute.

    SELECT FROM /eacm/bp_cache  "#EC CI_NOWHERE
    FIELDS *
    INTO TABLE @DATA(lt_bp_cache).
    LOOP AT lt_bp_cache INTO DATA(ls_bp_cache).
      TRY.
          DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
          DATA(ls_address) = lo_api->read_with_addresses( ls_bp_cache-business_partner ).
          IF ls_bp_cache-last_change_date = ls_address-bp-last_change_date OR ls_address IS INITIAL.
            CONTINUE.
          ENDIF.
          ls_bp_cache-first_name = ls_address-bp-first_name.
          ls_bp_cache-last_name = ls_address-bp-last_name.
          ls_bp_cache-land1 = ls_address-addresses[ 1 ]-country.
          ls_bp_cache-city = ls_address-addresses[ 1 ]-city_name.
          ls_bp_cache-post_code = ls_address-addresses[ 1 ]-postal_code.
          ls_bp_cache-street = ls_address-addresses[ 1 ]-street_name.
          ls_bp_cache-house_num = ls_address-addresses[ 1 ]-house_number.
          ls_bp_cache-region = ls_address-addresses[ 1 ]-region.
*          ls_bp_cache-stceg = ls_address-bp-.
*          ls_bp_cache-stcd1 = .
          ls_bp_cache-last_change_date = ls_address-bp-last_change_date.
          MODIFY /eacm/bp_cache FROM  @ls_bp_cache.
        CATCH /eacm/cx_api_error INTO DATA(lx).
          DATA(msg) = lx->get_text( ).
          CONTINUE.
      ENDTRY.
    ENDLOOP.

**********************************************************************
    "Fornitori nuovi
    SELECT FROM /eacm/zpraa AS zpraa
    LEFT JOIN /eacm/bp_cache AS bp
    ON zpraa~lifnr = bp~business_partner
    FIELDS DISTINCT lifnr AS business_partner
    WHERE bp~business_partner IS NULL
    INTO TABLE @DATA(lt_bp).

    "Clienti nuovi
    SELECT FROM /eacm/prdo AS do
    LEFT JOIN /eacm/bp_cache AS bp
    ON do~kunrg = bp~business_partner
    FIELDS DISTINCT kunrg AS business_partner
    WHERE bp~business_partner IS NULL
    APPENDING TABLE @lt_bp.

    "Destinatari merci
    SELECT FROM /eacm/prdo AS do
    LEFT JOIN /eacm/bp_cache AS bp
    ON do~zdest = bp~business_partner
    FIELDS DISTINCT zdest AS business_partner
    WHERE bp~business_partner IS NULL
    APPENDING TABLE @lt_bp.

    DELETE lt_bp WHERE business_partner = space.
    SORT lt_bp BY business_partner.
    DELETE ADJACENT DUPLICATES FROM lt_bp COMPARING business_partner.

*    DATA ls_bp_cache TYPE /eacm/bp_cache.

    LOOP AT lt_bp INTO DATA(ls_bp).
      CLEAR ls_bp_cache.

      TRY.
          lo_api = NEW /eacm/cl_api_business_partner( ).
          ls_address = lo_api->read_with_addresses( ls_bp-business_partner ).
          IF ls_address IS INITIAL.
            CONTINUE.
          ENDIF.
          ls_bp_cache-business_partner = ls_bp-business_partner.
          ls_bp_cache-first_name = ls_address-bp-first_name.
          ls_bp_cache-last_name = ls_address-bp-last_name.
          ls_bp_cache-land1 = ls_address-addresses[ 1 ]-country.
          ls_bp_cache-city = ls_address-addresses[ 1 ]-city_name.
          ls_bp_cache-post_code = ls_address-addresses[ 1 ]-postal_code.
          ls_bp_cache-street = ls_address-addresses[ 1 ]-street_name.
          ls_bp_cache-house_num = ls_address-addresses[ 1 ]-house_number.
          ls_bp_cache-region = ls_address-addresses[ 1 ]-region.
*          ls_bp_cache-stceg = ls_address-bp-.
*          ls_bp_cache-stcd1 = .
          ls_bp_cache-last_change_date = ls_address-bp-last_change_date.
          INSERT /eacm/bp_cache FROM  @ls_bp_cache.
        CATCH /eacm/cx_api_error INTO lx.
          msg = lx->get_text( ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
