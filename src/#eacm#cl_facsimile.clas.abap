CLASS /eacm/cl_facsimile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor IMPORTING i_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    METHODS generate.
    METHODS delete_action IMPORTING i_user TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_competence TYPE /EACM/PRIM_i_RUN-Zamcf.
    DATA gv_bldat TYPE /EACM/PRIM_i_RUN-Bldat.
    DATA gr_bukrs TYPE RANGE OF /EACM/PRIM_i_RUN-Bukrs.
    DATA gr_zclpr TYPE RANGE OF /EACM/PRIM_i_RUN-Zclpr.
    DATA gr_vkorg TYPE RANGE OF /EACM/PRIM_i_RUN-Vkorg.
    DATA gr_vtweg TYPE RANGE OF /EACM/PRIM_i_RUN-Vtweg.
    DATA gr_zcdaz TYPE RANGE OF /EACM/PRIM_i_RUN-Zcdaz.
    DATA gv_waerk TYPE /EACM/PRIM_i_RUN-Waerk.

    METHODS delete_persistence_run.
    METHODS get_lock_dp.
    METHODS check_periodicity IMPORTING i_dp        TYPE /EACM/I_zprdp_free
                              RETURNING VALUE(e_OK) TYPE abap_bool.
    METHODS get_country_code.
    METHODS get_iva.
    METHODS facsimile_currency.
    METHODS counting_facsimiles.
    METHODS write_nosplit.
    METHODS write_split.
    METHODS mingar_process.
    METHODS process_documents.
    CLASS-METHODS get_tax_rate
      IMPORTING i_mwskz        TYPE mwskz
                i_bukrs        TYPE bukrs
      RETURNING VALUE(e_msatz) TYPE /eacm/facspos-msatz.

    METHODS get_recanti CHANGING i_zprim TYPE /eacm/prim_run.
    METHODS calc_iva CHANGING i_zprim TYPE /eacm/prim_run.
    METHODS calc_ena IMPORTING i_zpraa TYPE /eacm/zpraa CHANGING i_zprim TYPE /eacm/prim_run.
    METHODS ritenuta CHANGING i_zprim TYPE /eacm/prim_run.
    METHODS fondo_garanzia IMPORTING i_zpraa TYPE /eacm/zpraa CHANGING i_zprim TYPE /eacm/prim_run.

    METHODS get_agent IMPORTING i_agent TYPE /eacm/zpraa-zcdaz RETURNING VALUE(e_zpraa) TYPE /eacm/zpraa.
    METHODS get_min_max_perc_ena
      IMPORTING i_zcdaz     TYPE /eacm/zpraa-zcdaz
                i_gjahr_rif TYPE gjahr
                i_bukrs     TYPE bukrs
                i_ztsoc     TYPE /eacm/zpraa-ztsoc
      EXPORTING e_zpr21     TYPE /eacm/zpr21
                e_zpr22     TYPE /eacm/zpr22.
    METHODS get_imp_ena IMPORTING i_run_uuid TYPE /eacm/prim_run-run_uuid
                                  i_waerk    TYPE /eacm/zprim-waerk
                                  i_zzwaerk  TYPE /eacm/zpr21-zwaerk "valuta Enasarco
                                  i_bukrs    TYPE bukrs
                        EXPORTING e_zimco    TYPE /eacm/zprfac-zimco
                                  e_zimcoe   TYPE /eacm/zprfac-zimcoe.

    METHODS get_zprfac_precedente
      IMPORTING
        i_ZPRIM          TYPE /eacm/prim_run
        I_zpraa          TYPE /eacm/zpraa
        i_gjahr_rif      TYPE gjahr
        i_dt_cessazione  TYPE /eacm/zpr35-zdtfr
      EXPORTING
        i_effettivoprec  TYPE /eacm/zageff
        i_effettivoprece TYPE /eacm/zageff
        i_complessivo    TYPE /eacm/zageca
        i_complessivoe   TYPE /eacm/zageca.
    METHODS get_t059
      IMPORTING
        i_bukrs        TYPE bukrs
        i_lifnr        TYPE lifnr
      RETURNING
        VALUE(e_t059z) TYPE /eacm/t059z.
    METHODS get_fgar
      IMPORTING
        i_zprim          TYPE /eacm/prim_run
      RETURNING
        VALUE(e_zprfgar) TYPE /eacm/zprfgar.
    METHODS get_mingar
      RETURNING
        VALUE(r_result) TYPE /eacm/tt_mingar.
    METHODS mingar_emesso
      IMPORTING
        i_mingar      TYPE /eacm/st_mingar
      RETURNING
        VALUE(emesso) TYPE abap_bool.

    METHODS add_month_to_date IMPORTING i_months         TYPE /eacm/num2
                                        i_olddate        TYPE d
                              RETURNING VALUE(r_newdate) TYPE d.
    METHODS crea_facpos_dp
      IMPORTING
        i_zprim        TYPE /eacm/prim_run
        i_mingar       TYPE /eacm/st_mingar
        i_fine_periodo TYPE /eacm/zdtfi
      EXPORTING
        e_facpos       TYPE /eacm/facpos_run
        e_commission   TYPE /eacm/fac_mg_run.
    METHODS get_iva_row
      CHANGING
        c_facdp TYPE /eacm/facdp_run.
    METHODS get_naz_age
      IMPORTING
        i_dtini          TYPE d
        i_dtfin          TYPE d
        i_lifnr          TYPE lifnr
      RETURNING
        VALUE(e_country) TYPE /eacm/zzage.
    METHODS get_naz_cli
      IMPORTING
        i_dtini          TYPE d
        i_dtfin          TYPE d
        i_kunrg          TYPE kunrg
      RETURNING
        VALUE(e_country) TYPE /eacm/zzage.
    METHODS get_naz_we
      IMPORTING
        i_dtini          TYPE d
        i_dtfin          TYPE d
        i_zdest          TYPE /eacm/zdest
      RETURNING
        VALUE(e_country) TYPE /eacm/zzage.
    METHODS get_naz_soc
      IMPORTING
        i_dtini          TYPE d
        i_dtfin          TYPE d
        i_bukrs          TYPE bukrs
      RETURNING
        VALUE(e_country) TYPE /eacm/zzage.
ENDCLASS.



CLASS /eacm/cl_facsimile IMPLEMENTATION.


  METHOD generate.

    "cancello le tabelle di persistenza dell'elaborazione
    delete_persistence_run( ).
    "estrazione DP e blocco
    get_lock_dp( ).
    get_country_code(  ).
    get_iva( ).
    facsimile_currency( ).
    counting_facsimiles( ).
    process_documents( ).

  ENDMETHOD.


  METHOD delete_persistence_run.

    DELETE FROM /eacm/prim_run.                         "#EC CI_NOWHERE
    DELETE FROM /eacm/facpos_run.                       "#EC CI_NOWHERE
    DELETE FROM /eacm/prfac_run.                        "#EC CI_NOWHERE
    DELETE FROM /eacm/faciva_run.                       "#EC CI_NOWHERE
    DELETE FROM /eacm/facdp_run.                        "#EC CI_NOWHERE
    DELETE FROM /eacm/zprar_run.                        "#EC CI_NOWHERE
    DELETE FROM /eacm/maxena_run.                       "#EC CI_NOWHERE
    DELETE FROM /eacm/maxena_run.                       "#EC CI_NOWHERE

  ENDMETHOD.


  METHOD get_lock_dp.

    SELECT *
    FROM /EACM/I_zprdp_free
    WHERE vkorg IN @gr_vkorg
      AND vtweg IN @gr_vtweg
      AND zclpr IN @gr_zclpr
      AND zcdaz IN @gr_zcdaz
      AND bukrs IN @gr_bukrs
      AND zamco LE @gv_competence
      INTO TABLE @DATA(lt_zprdp_free).

    DATA lt_dp_lock TYPE STANDARD TABLE OF /eacm/facdp_run.
*    lt_dp_lock = CORRESPONDING #( lt_zprdp_free ).

    LOOP AT lt_zprdp_free INTO DATA(ls_dp).

      "data per il cambio del facsimile
      "se il documento non è una fattura ma è un documento successivo alla fattura
      "la data del cambio deve essere quella della fattura da dove partono le provvigioni
      ls_dp-Dtchange = ls_dp-Fkdat. "AL MOMENTO NON GESTITO

      IF check_periodicity( ls_dp ) = abap_true .
        APPEND CORRESPONDING #( ls_dp ) TO lt_dp_lock.
      ENDIF.

    ENDLOOP.

    INSERT /eacm/facdp_run FROM TABLE @lt_dp_lock.

  ENDMETHOD.


  METHOD check_periodicity.
    e_ok = abap_false.

    SELECT SINGLE @abap_true
      FROM /eacm/zpr06
      WHERE bukrs = @i_dp-Bukrs
        AND ztpag = @i_dp-ztpag
        AND zcdaz = @i_dp-zcdaz
        AND ( CASE
            WHEN @i_dp-Anticipo = @abap_false AND @gv_competence+4(2) = '01' THEN zpm01
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '02' THEN zpm02
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '03' THEN zpm03
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '04' THEN zpm04
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '05' THEN zpm05
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '06' THEN zpm06
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '07' THEN zpm07
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '08' THEN zpm08
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '09' THEN zpm09
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '10' THEN zpm10
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '11' THEN zpm11
            WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '12' THEN zpm12


            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '01' THEN zam01
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '02' THEN zam02
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '03' THEN zam03
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '04' THEN zam04
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '05' THEN zam05
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '06' THEN zam06
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '07' THEN zam07
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '08' THEN zam08
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '09' THEN zam09
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '10' THEN zam10
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '11' THEN zam11
            WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '12' THEN zam12
        END = @abap_true )
        INTO @e_ok.
    IF sy-subrc NE 0.
      SELECT SINGLE @abap_true
        FROM /eacm/zpr06
        WHERE bukrs = @i_dp-Bukrs
          AND ztpag = @i_dp-ztpag
          AND ( CASE
              WHEN @i_dp-Anticipo = @abap_false AND @gv_competence+4(2) = '01' THEN zpm01
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '02' THEN zpm02
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '03' THEN zpm03
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '04' THEN zpm04
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '05' THEN zpm05
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '06' THEN zpm06
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '07' THEN zpm07
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '08' THEN zpm08
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '09' THEN zpm09
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '10' THEN zpm10
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '11' THEN zpm11
              WHEN @i_dp-Anticipo = @space AND @gv_competence+4(2) = '12' THEN zpm12


              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '01' THEN zam01
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '02' THEN zam02
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '03' THEN zam03
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '04' THEN zam04
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '05' THEN zam05
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '06' THEN zam06
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '07' THEN zam07
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '08' THEN zam08
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '09' THEN zam09
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '10' THEN zam10
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '11' THEN zam11
              WHEN @i_dp-Anticipo = @abap_true AND @gv_competence+4(2) = '12' THEN zam12
          END = @abap_true )
          INTO @e_ok.
    ENDIF.


  ENDMETHOD.


  METHOD get_country_code.

    DATA lv_country TYPE /eacm/zzage.
    DATA lv_dtini TYPE d.
    DATA lv_dtfin TYPE d.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    SELECT SINGLE FROM I_CalendarDate
    FIELDS FirstDayOfMonthDate, LastDayOfMonthDate
    WHERE CalendarDate = @lv_today
    INTO (@lv_dtini, @lv_dtfin).

    "Nazione agente
    SELECT DISTINCT facrun~zcdaz, zpraa~lifnr
    FROM /eacm/facdp_run AS facrun
    INNER JOIN /eacm/zpraa AS zpraa
    ON zpraa~zcdaz = facrun~zcdaz
    WHERE naz_age = @space
    INTO TABLE @DATA(lt_age).
    LOOP AT lt_age INTO DATA(ls_age).
      lv_country = get_naz_age( EXPORTING i_dtini = lv_dtini i_dtfin = lv_dtfin i_lifnr = ls_age-lifnr ).
      UPDATE /eacm/facdp_run SET naz_age = @lv_country
      WHERE zcdaz = @ls_age-zcdaz
      AND naz_age = @space.
    ENDLOOP.
    FREE lt_age.

    "Nazione cliente
    SELECT DISTINCT kunrg
    FROM /eacm/facdp_run AS facrun
    WHERE naz_cli = @space
    INTO TABLE @DATA(lt_cli).
    LOOP AT lt_cli INTO DATA(ls_cli).
      lv_country = get_naz_cli( EXPORTING i_dtini = lv_dtini i_dtfin = lv_dtfin i_kunrg = ls_cli-kunrg ).
      UPDATE /eacm/facdp_run SET naz_cli = @lv_country
      WHERE kunrg = @ls_cli-kunrg
      AND naz_cli = @space.
    ENDLOOP.
    FREE lt_cli.

    "Nazione destinatario merci
    SELECT DISTINCT zdest
    FROM /eacm/facdp_run AS facrun
    WHERE naz_we = @space
    INTO TABLE @DATA(lt_we).
    LOOP AT lt_we INTO DATA(ls_we).
      lv_country = get_naz_we( EXPORTING i_dtini = lv_dtini i_dtfin = lv_dtfin i_zdest = ls_we-zdest ).
      UPDATE /eacm/facdp_run SET naz_we = @lv_country
      WHERE zdest = @ls_we-zdest
      AND naz_we = @space.
    ENDLOOP.
    FREE lt_we.

    "Nazione società
    SELECT DISTINCT bukrs
    FROM /eacm/facdp_run AS facrun
    WHERE naz_soc = @space
    INTO TABLE @DATA(lt_soc).
    LOOP AT lt_soc INTO DATA(ls_soc).
      lv_country = get_naz_soc( EXPORTING i_dtini = lv_dtini i_dtfin = lv_dtfin i_bukrs = ls_soc-bukrs ).
      UPDATE /eacm/facdp_run SET naz_soc = @lv_country
      WHERE bukrs = @ls_soc-bukrs
      AND naz_soc = @space.
    ENDLOOP.
    FREE lt_soc.

  ENDMETHOD.


  METHOD get_iva.

    SELECT * FROM /eacm/facdp_run
    WHERE mwskz = @space
    INTO TABLE @DATA(lt_facrun).
    LOOP AT lt_facrun ASSIGNING FIELD-SYMBOL(<dpr>).


      get_iva_row(  CHANGING c_facdp =  <dpr> ).
*      SELECT SINGLE kalsm, mwskz, zrtac, zdesc, pdatv, pdatb
*        FROM /eacm/zpr14
*        WHERE znzag = @<dpr>-naz_age
*          AND znmco = @<dpr>-naz_soc
*          AND znzcl = @<dpr>-naz_cli
*          AND lifnr = @<dpr>-lifnr
*          INTO @DATA(l_zpr14).
*      IF sy-subrc EQ 0 AND gv_bldat BETWEEN l_zpr14-pdatv AND l_zpr14-pdatb.
*        <dpr>-kalsm = l_zpr14-kalsm.
*        <dpr>-mwskz = l_zpr14-mwskz.
*        <dpr>-ritac = l_zpr14-zrtac.  "soggetto a ritenuta d'acconto
*
**     verifico se c'è numero della licenza
*        IF l_zpr14-zdesc IS NOT INITIAL AND
*              ( l_zpr14-pdatv(6) <= gv_competence
*            AND l_zpr14-pdatb(6) >= gv_competence ).
*          <dpr>-licnr = l_zpr14-zdesc.
*        ENDIF.
*
*      ELSE.
*        DATA l_zpr12 TYPE /eacm/zpr12.
*        CLEAR l_zpr12.
*
*        SELECT kalsm, mwskz, zrtac, zcdls
*          FROM /eacm/zpr12
*          WHERE znzag = @<dpr>-naz_age
*            AND znmco = @<dpr>-naz_soc
*            AND znzcl = @<dpr>-naz_cli
*            AND znzmc = @<dpr>-naz_we
*            AND zcdls NE @space
*            INTO CORRESPONDING FIELDS OF @l_zpr12.
*
**        DATA(v_dalista) = iva_da_set( i_zpr12 = l_zpr12 i_commission =  i_provv ).
**        IF v_dalista = abap_false.
**          CLEAR l_zpr12.
**        ENDIF.
*        ENDSELECT.
*
*        IF l_zpr12 IS INITIAL.
*          SELECT SINGLE kalsm, mwskz, zrtac
*            FROM /eacm/zpr12
*            WHERE znzag = @<dpr>-naz_age
*              AND znmco = @<dpr>-naz_soc
*              AND znzcl = @<dpr>-naz_cli
*              AND znzmc = @<dpr>-naz_we
*              INTO CORRESPONDING FIELDS OF @l_zpr12.
*          IF sy-subrc NE 0.
*            SELECT SINGLE kalsm, mwskz, zrtac
*              FROM /eacm/zpr12
*            WHERE znzag = @<dpr>-naz_age
*              AND znmco = @<dpr>-naz_soc
*              AND znzcl = @<dpr>-naz_cli
*                INTO CORRESPONDING FIELDS OF @l_zpr12.
*          ENDIF.
*        ENDIF.
*
*        IF l_zpr12 IS NOT INITIAL.
*          <dpr>-kalsm = l_zpr12-kalsm.
*          <dpr>-mwskz = l_zpr12-mwskz.
*          <dpr>-ritac = l_zpr12-zrtac.
*        ENDIF.
*
*      ENDIF.

    ENDLOOP.

    UPDATE /eacm/facdp_run FROM TABLE @lt_facrun.

  ENDMETHOD.


  METHOD facsimile_currency.
    "Se si dovesse riscontrare lentezza si potrebbe inglobare in get_country_code (Nazione agente)

    "la valuta del facsimile viene impostata dal primo valore soddisfatto secondo la lista seguente:
    "1. Anticipi automatici e minimi garantiti
    "2. Valuta inserita in videata di lancio
    "3. Valuta inserita in anagrafica agente
    "4. Valuta del documento

    SELECT DISTINCT run~zcdaz, run~bukrs, waerk, zwaersp, erdat
    FROM /eacm/facdp_run AS run
    INNER JOIN /eacm/zpraa AS zpraa
    ON zpraa~zcdaz = run~zcdaz
    WHERE zwaersp = @space
    INTO TABLE @DATA(lt_valuta).
    LOOP AT lt_valuta INTO DATA(ls_valuta).

      "eventuali anticipi automatici o minimi garantiti danno il valore della valuta al facsimile
      SELECT SINGLE waers                                   "#EC WARNOK
        FROM /eacm/prcn
        WHERE zcdaz EQ @ls_valuta-zcdaz
          AND bukrs EQ @ls_valuta-bukrs
          AND zdtin <= @ls_valuta-erdat "data inizio contratto
          AND ( zdtfi >= @ls_valuta-erdat OR zdtfi = 0 ) "data chiusura contratto
          AND zdatamin <= @gv_competence
          AND zmescong >= @gv_competence
          AND zmingar NE 0
          INTO @ls_valuta-zwaersp.
      IF ls_valuta-zwaersp IS NOT INITIAL.
        UPDATE /eacm/facdp_run SET zwaersp = @ls_valuta-zwaersp
        WHERE zcdaz = @ls_valuta-zcdaz
        AND zwaersp = @space.
        CONTINUE.
      ENDIF.
*
*    "se la valuta è compilata in fase di lancio tutte le provvigioni
*    "vengono convertite in quella richiesta e vanno sullo stesso facsimile
*    IF a_fccur IS NOT INITIAL.
*      e_currency = a_fccur.
*      RETURN.
*    ENDIF.

      "se la valuta in videata di lancio non è compilata vado a prendere la
      "valuta di stampa in anagrafica agente
      SELECT SINGLE FROM /eacm/zpraa
        FIELDS zwage
        WHERE zcdaz = @ls_valuta-zcdaz
        INTO @ls_valuta-zwaersp.
      IF ls_valuta-zwaersp IS NOT INITIAL.
        UPDATE /eacm/facdp_run SET zwaersp = @ls_valuta-zwaersp
        WHERE zcdaz = @ls_valuta-zcdaz
        AND zwaersp = @space.
        CONTINUE.
      ENDIF.

      ls_valuta-zwaersp = ls_valuta-waerk.
      UPDATE /eacm/facdp_run SET zwaersp = @ls_valuta-zwaersp
      WHERE zcdaz = @ls_valuta-zcdaz
      AND zwaersp = @space.

    ENDLOOP.
  ENDMETHOD.


  METHOD counting_facsimiles.

    write_nosplit( ).
    write_split( ).
    mingar_process( ). "DA FARE

  ENDMETHOD.


  METHOD write_nosplit.

    DATA lr_no_split TYPE RANGE OF bukrs.

    SELECT 'I' AS sign, 'EQ' AS option, bukrs AS low
    FROM /eacm/zpr01
    WHERE zsplitiva = @abap_false
    INTO TABLE @lr_no_split.

    SELECT DISTINCT bukrs, zcdaz, zwaersp, lifnr, naz_age, zwaer, Anticipo
    FROM /EACM/I_facrunDPd
    WHERE bukrs IN @lr_no_split
        AND run_uuid IS INITIAL
    INTO TABLE @DATA(lt_prv_nosplit).


    DATA ls_prim_run TYPE /eacm/prim_run.
    DATA lt_facpos_run TYPE STANDARD TABLE OF /eacm/facpos_run.

    LOOP AT lt_prv_nosplit INTO DATA(ls_prv_nosplit).

************************* ZPRIM **************************************
      CLEAR ls_prim_run.
      ls_prim_run-bukrs = ls_prv_nosplit-Bukrs. "Società
      ls_prim_run-gjahr = gv_competence(4). "Esercizio
      TRY.
          ls_prim_run-run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CLEAR ls_prim_run-run_uuid.
      ENDTRY.
      ls_prim_run-lifnr = ls_prv_nosplit-lifnr. "fornitore
      ls_prim_run-zamcf = gv_competence. "Competenza fac-simile
      ls_prim_run-waerk = ls_prv_nosplit-zwaersp. "Divisa del documento commerciale
      ls_prim_run-znzag = ls_prv_nosplit-naz_age. "Nazione agente
      ls_prim_run-bldat = gv_bldat.
      ls_prim_run-zcdaz = ls_prv_nosplit-zcdaz.
      SELECT SINGLE FROM /eacm/zpraa
        FIELDS name1
        WHERE zcdaz = @ls_prim_run-zcdaz
        INTO @ls_prim_run-name1.

      "se è un anticipo
      IF ls_prv_nosplit-Anticipo = abap_true.
        "anticipo
        SELECT SUM( zimansf ), SUM( ziprvvs )
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_nosplit-bukrs
        AND zcdaz = @ls_prv_nosplit-zcdaz
        AND zwaersp = @ls_prv_nosplit-zwaersp
        AND lifnr = @ls_prv_nosplit-lifnr
        AND naz_age = @ls_prv_nosplit-naz_age
        AND zwaer = @ls_prv_nosplit-zwaer
        AND Anticipo = @ls_prv_nosplit-Anticipo
        INTO ( @ls_prim_run-zimprv, @ls_prim_run-zimprvsf ).
*        l_zprim-zimprv = l_pos-ziprv = <ln>-zimansf.
      ELSE.
        "Provv. maturate - in valuta società cambio dt doc
        "provvigione classica
*        l_zprim-zimprv = l_pos-ziprv = <ln>-ziprvsf.
        SELECT SUM( ziprvsf ), SUM( ziprvvs )
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_nosplit-bukrs
        AND zcdaz = @ls_prv_nosplit-zcdaz
        AND zwaersp = @ls_prv_nosplit-zwaersp
        AND lifnr = @ls_prv_nosplit-lifnr
        AND naz_age = @ls_prv_nosplit-naz_age
        AND zwaer = @ls_prv_nosplit-zwaer
        AND Anticipo = @ls_prv_nosplit-Anticipo
        INTO ( @ls_prim_run-zimprv, @ls_prim_run-zimprvsf ).
      ENDIF.

      ls_prim_run-zwaer = ls_prv_nosplit-zwaer. "Valuta Società
      ls_prim_run-zanticipo = ls_prv_nosplit-Anticipo.
      ls_prim_run-run_status = 'PROGRESS'.
      ls_prim_run-created_by = cl_abap_context_info=>get_user_technical_name( ).
      INSERT /eacm/prim_run FROM @ls_prim_run.


************************* FACSPOS **************************************

      CLEAR lt_facpos_run[].

      IF ls_prv_nosplit-Anticipo = abap_true.
        SELECT zclpr, bukrs, mwskz, kalsm,
            SUM( ziprvsf ) AS ziprv, SUM( zimansf ) AS ziprvvs,
            @ls_prim_run-run_uuid  AS run_uuid,
             @ls_prim_run-waerk AS waerk
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_nosplit-bukrs
            AND zcdaz = @ls_prv_nosplit-zcdaz
            AND zwaersp = @ls_prv_nosplit-zwaersp
            AND lifnr = @ls_prv_nosplit-lifnr
            AND naz_age = @ls_prv_nosplit-naz_age
            AND zwaer = @ls_prv_nosplit-zwaer
            AND Anticipo = @ls_prv_nosplit-Anticipo
            GROUP BY zclpr, bukrs, mwskz, kalsm
        INTO CORRESPONDING FIELDS OF TABLE @lt_facpos_run.
      ELSE.
        SELECT zclpr, bukrs, mwskz, kalsm,
            SUM( ziprvsf ) AS ziprv, SUM( ziprvvs ) AS ziprvvs,
            @ls_prim_run-run_uuid  AS run_uuid,
            @ls_prim_run-waerk AS waerk
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_nosplit-bukrs
            AND zcdaz = @ls_prv_nosplit-zcdaz
            AND zwaersp = @ls_prv_nosplit-zwaersp
            AND lifnr = @ls_prv_nosplit-lifnr
            AND naz_age = @ls_prv_nosplit-naz_age
            AND zwaer = @ls_prv_nosplit-zwaer
            AND Anticipo = @ls_prv_nosplit-Anticipo
            GROUP BY zclpr, bukrs, mwskz, kalsm
        INTO CORRESPONDING FIELDS OF TABLE @lt_facpos_run.
      ENDIF.

      LOOP AT lt_facpos_run ASSIGNING FIELD-SYMBOL(<facpos_rund>).
        <facpos_rund>-gjahr = ls_prim_run-gjahr.
        <facpos_rund>-msatz = get_tax_rate( i_bukrs = <facpos_rund>-bukrs i_mwskz = <facpos_rund>-mwskz ).
      ENDLOOP.

      INSERT /eacm/facpos_run FROM TABLE @lt_facpos_run.

******************* FACDP_RUN ****************************************

      UPDATE /eacm/facdp_run SET run_uuid = @ls_prim_run-run_uuid
        WHERE bukrs = @ls_prv_nosplit-bukrs
        AND zcdaz = @ls_prv_nosplit-zcdaz
        AND zwaersp = @ls_prv_nosplit-zwaersp
        AND lifnr = @ls_prv_nosplit-lifnr
        AND naz_age = @ls_prv_nosplit-naz_age
        AND Anticipo = @ls_prv_nosplit-Anticipo.

    ENDLOOP.

  ENDMETHOD.


  METHOD write_split.

    DATA lr_iva_split TYPE RANGE OF bukrs.

    SELECT 'I' AS sign, 'EQ' AS option, bukrs AS low
    FROM /eacm/zpr01
    WHERE zsplitiva = @abap_true
    INTO TABLE @lr_iva_split.

    SELECT DISTINCT bukrs, zcdaz, mwskz, zwaersp, lifnr, naz_age, zwaer, Anticipo
    FROM /EACM/I_facrunDPd
    WHERE bukrs IN @lr_iva_split
        AND run_uuid IS INITIAL
    INTO TABLE @DATA(lt_prv_split).

    DATA ls_prim_run TYPE /eacm/prim_run.
    DATA lt_facpos_run TYPE STANDARD TABLE OF /eacm/facpos_run.

    LOOP AT lt_prv_split INTO DATA(ls_prv_split).

************************* ZPRIM **************************************
      CLEAR ls_prim_run.
      ls_prim_run-bukrs = ls_prv_split-Bukrs. "Società
      ls_prim_run-gjahr = gv_competence(4). "Esercizio
      TRY.
          ls_prim_run-run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CLEAR ls_prim_run-run_uuid.
      ENDTRY.
      ls_prim_run-lifnr = ls_prv_split-lifnr. "fornitore
      ls_prim_run-zamcf = gv_competence. "Competenza fac-simile
      ls_prim_run-waerk = ls_prv_split-zwaersp. "Divisa del documento commerciale
      ls_prim_run-znzag = ls_prv_split-naz_age. "Nazione agente
      ls_prim_run-bldat = gv_bldat.
      ls_prim_run-zcdaz = ls_prv_split-zcdaz.
      SELECT SINGLE FROM /eacm/zpraa
      FIELDS name1
      WHERE zcdaz = @ls_prim_run-zcdaz
      INTO @ls_prim_run-name1.

      "se è un anticipo
      IF ls_prv_split-Anticipo = abap_true.
        "anticipo
        SELECT SUM( zimansf ), SUM( ziprvvs )
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_split-bukrs
        AND zcdaz = @ls_prv_split-zcdaz
        AND zwaersp = @ls_prv_split-zwaersp
        AND lifnr = @ls_prv_split-lifnr
        AND naz_age = @ls_prv_split-naz_age
        AND zwaer = @ls_prv_split-zwaer
        AND Anticipo = @ls_prv_split-Anticipo
        INTO ( @ls_prim_run-zimprv, @ls_prim_run-zimprvsf ).
*        l_zprim-zimprv = l_pos-ziprv = <ln>-zimansf.
      ELSE.
        "Provv. maturate - in valuta società cambio dt doc
        "provvigione classica
*        l_zprim-zimprv = l_pos-ziprv = <ln>-ziprvsf.
        SELECT SUM( ziprvsf ), SUM( ziprvvs )
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_split-bukrs
        AND zcdaz = @ls_prv_split-zcdaz
        AND zwaersp = @ls_prv_split-zwaersp
        AND lifnr = @ls_prv_split-lifnr
        AND naz_age = @ls_prv_split-naz_age
        AND zwaer = @ls_prv_split-zwaer
        AND Anticipo = @ls_prv_split-Anticipo
        INTO ( @ls_prim_run-zimprv, @ls_prim_run-zimprvsf ).
      ENDIF.

      ls_prim_run-zwaer = ls_prv_split-zwaer. "Valuta Società
      ls_prim_run-zanticipo = ls_prv_split-Anticipo.
      ls_prim_run-run_status = 'PROGRESS'.
      ls_prim_run-created_by = cl_abap_context_info=>get_user_technical_name( ).
      INSERT /eacm/prim_run FROM @ls_prim_run.


************************* FACSPOS **************************************

      CLEAR lt_facpos_run[].

      IF ls_prv_split-Anticipo = abap_true.
        SELECT zclpr, bukrs, gjahr, zcspv, mwskz, kalsm,
            SUM( ziprvsf ) AS ziprv, SUM( zimansf ) AS ziprvvs,
            @ls_prim_run-run_uuid  AS run_uuid,
             @ls_prim_run-waerk AS waerk
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_split-bukrs
            AND zcdaz = @ls_prv_split-zcdaz
            AND zwaersp = @ls_prv_split-zwaersp
            AND lifnr = @ls_prv_split-lifnr
            AND naz_age = @ls_prv_split-naz_age
            AND zwaer = @ls_prv_split-zwaer
            AND Anticipo = @ls_prv_split-Anticipo
            AND mwskz = @ls_prv_split-mwskz
            GROUP BY zclpr, bukrs, gjahr, zcspv, mwskz, kalsm
        INTO CORRESPONDING FIELDS OF TABLE @lt_facpos_run.
      ELSE.
        SELECT zclpr, bukrs, gjahr, zcspv, mwskz, kalsm,
            SUM( ziprvsf ) AS ziprv, SUM( ziprvvs ) AS ziprvvs,
            @ls_prim_run-run_uuid  AS run_uuid,
            @ls_prim_run-waerk AS waerk
        FROM /EACM/I_facrunDPd
        WHERE bukrs = @ls_prv_split-bukrs
            AND zcdaz = @ls_prv_split-zcdaz
            AND zwaersp = @ls_prv_split-zwaersp
            AND lifnr = @ls_prv_split-lifnr
            AND naz_age = @ls_prv_split-naz_age
            AND zwaer = @ls_prv_split-zwaer
            AND Anticipo = @ls_prv_split-Anticipo
            AND mwskz = @ls_prv_split-mwskz
            GROUP BY zclpr, bukrs, gjahr, zcspv, mwskz, kalsm
        INTO CORRESPONDING FIELDS OF TABLE @lt_facpos_run.
      ENDIF.

      LOOP AT lt_facpos_run ASSIGNING FIELD-SYMBOL(<facpos_rund>).
        <facpos_rund>-gjahr = ls_prim_run-gjahr.
        <facpos_rund>-msatz = get_tax_rate( i_bukrs = <facpos_rund>-bukrs i_mwskz = <facpos_rund>-mwskz ).
      ENDLOOP.

      INSERT /eacm/facpos_run FROM TABLE @lt_facpos_run.

******************* FACDP_RUN ****************************************

      UPDATE /eacm/facdp_run SET run_uuid = @ls_prim_run-run_uuid
        WHERE bukrs = @ls_prv_split-bukrs
        AND zcdaz = @ls_prv_split-zcdaz
        AND zwaersp = @ls_prv_split-zwaersp
        AND lifnr = @ls_prv_split-lifnr
        AND naz_age = @ls_prv_split-naz_age
        AND Anticipo = @ls_prv_split-Anticipo
        AND mwskz = @ls_prv_split-mwskz.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_recanti.
    DATA lt_zprar TYPE TABLE OF /eacm/zprar_run. "Anticipi recuperati e da recuperare
    DATA ls_zprar TYPE /eacm/zprar_run. "Anticipi recuperati e da recuperare

    "/ preparazione delle classificazioni è il codice iva da estrarre
    DATA rg_zclpr TYPE RANGE OF /eacm/zprar-zclpr.
    DATA rg_mwskz TYPE RANGE OF /eacm/zprar-mwskz.
    CLEAR: rg_zclpr[], rg_mwskz[].

    SELECT DISTINCT 'I' AS sign, 'EQ' AS option, zclpr AS low
    FROM /eacm/facpos_run
    WHERE run_uuid = @i_zprim-run_uuid
    INTO CORRESPONDING FIELDS OF TABLE @rg_zclpr.

    SELECT DISTINCT 'I' AS sign, 'EQ' AS option, mwskz AS low
    FROM /eacm/facpos_run
    WHERE run_uuid = @i_zprim-run_uuid
    INTO CORRESPONDING FIELDS OF TABLE @rg_mwskz.
    "\ preparazione delle classificazioni è il codice iva da estrarre

    "estrazione degli anticipi del facsimile
    SELECT *
      FROM /eacm/zprar
      WHERE zclpr IN @rg_zclpr
        AND zcdaz = @i_zprim-zcdaz
        AND mwskz IN @rg_mwskz
        AND zamco LE @gv_competence
        AND zidfs EQ @space
        AND ztpan NE 'C'
        INTO TABLE @DATA(tl_zprar).


*    DATA l_zprar_save TYPE /eacm/zprar.
*    DATA l_facpos_save TYPE /eacm/facpos_run.
    DATA v_tot_zirec TYPE /eacm/zprdp-zirec.
    DATA v_tot_zirecvs TYPE /eacm/zprdp-zirec.
    CLEAR: v_tot_zirec, v_tot_zirecvs.

    LOOP AT tl_zprar INTO DATA(l_zprar).

      "verifico che non sia stato recuperato da un facsimile precedente
      READ TABLE lt_zprar
        WITH KEY  vkorg = l_zprar-vkorg
                  vtweg = l_zprar-vtweg
                  zclpr = l_zprar-zclpr
                  zcdaz = l_zprar-zcdaz
                  zwaer = l_zprar-zwaer
                  zamco = l_zprar-zamco
                  zprec = l_zprar-zprec
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      TRY.
          cl_exchange_rates=>convert_to_local_currency(
            EXPORTING
              date              = l_zprar-fkdat
              foreign_amount    = l_zprar-zirec
              foreign_currency  = l_zprar-zwaer
              local_currency    = i_zprim-waerk
            IMPORTING
              local_amount      = l_zprar-zirecsf
          ).
        CATCH cx_exchange_rates.
          l_zprar-zirecsf = l_zprar-zirec.
      ENDTRY.

*      "valuta società
*      "utilizzo tb_zprar_save-zwaersp solo per comodità
*      "poi lo imposto con il valore della valuta facsmili
      SELECT SINGLE waers FROM /eacm/t001 WHERE bukrs = @i_zprim-bukrs
      INTO @l_zprar-zwaersp.
      TRY.
          cl_exchange_rates=>convert_to_local_currency(
            EXPORTING
              date              = l_zprar-fkdat
              foreign_amount    = l_zprar-zirec
              foreign_currency  = l_zprar-zwaer
              local_currency    = i_zprim-waerk
            IMPORTING
              local_amount      = l_zprar-zirecvs
          ).
        CATCH cx_exchange_rates.
          l_zprar-zirecsf = l_zprar-zirec.
      ENDTRY.

      "valuta facsmile
      l_zprar-zwaersp = i_zprim-waerk.
      l_zprar-zamcf = i_zprim-zamcf.
      v_tot_zirecvs += l_zprar-zirecvs.
      v_tot_zirec += l_zprar-zirecsf.

      l_zprar-ztpan = 'C'.
*      l_zprar-zidfs = i_zprim-zidfs.
      MOVE-CORRESPONDING l_zprar TO ls_zprar.
      ls_zprar-run_uuid = i_zprim-run_uuid.
      APPEND ls_zprar TO lt_zprar.

*      CLEAR l_facpos_save.
      SELECT SINGLE *
      FROM /eacm/facpos_run
      WHERE run_uuid = @i_zprim-run_uuid
        AND mwskz = @l_zprar-mwskz
        AND zclpr = 'RECANT'
        INTO @DATA(l_facpos_save).
      IF sy-subrc <> 0.
        SELECT SINGLE *                                     "#EC WARNOK
        FROM /eacm/facpos_run
        WHERE run_uuid = @i_zprim-run_uuid
          AND mwskz = @l_zprar-mwskz
          INTO @l_facpos_save.
        IF sy-subrc = 0.
          CLEAR: l_facpos_save-ziprv, l_facpos_save-ziprvvs.
        ENDIF.
      ENDIF.
      IF l_facpos_save IS NOT INITIAL.
        l_facpos_save-zclpr = 'RECANT'.
*        l_zprar-zirecsf = l_zprar-zirecsf * -1.
*        l_zprar-zirecvs = l_zprar-zirecvs * -1.
        l_facpos_save-ziprv += l_zprar-zirecsf * -1.
        l_facpos_save-ziprvvs += l_zprar-zirecvs * -1.
        MODIFY /eacm/facpos_run FROM @l_facpos_save.
      ENDIF.

    ENDLOOP.

    i_zprim-zimran = v_tot_zirec.
    i_zprim-zimransf = v_tot_zirecvs.
    IF lt_zprar[] IS NOT INITIAL.
      INSERT /eacm/zprar_run FROM TABLE @lt_zprar.
    ENDIF.

  ENDMETHOD.


  METHOD process_documents.

    SELECT * FROM /eacm/prim_run
    WHERE run_uuid IS NOT INITIAL
    AND run_status = 'PROGRESS'
    INTO TABLE @DATA(lt_zprim).

    LOOP AT lt_zprim ASSIGNING FIELD-SYMBOL(<im>).
      "Verifica importo minimo

      DATA(ls_zpraa) = get_agent( i_agent =  <im>-zcdaz ).

      "Recupero anticipi
      IF <im>-zanticipo = abap_false.
        get_recanti( CHANGING i_zprim = <im> ).
      ENDIF.

      "calcolo iva
      calc_iva( CHANGING i_zprim = <im> ).

      "calcolo Enasarco
      calc_ena(
        EXPORTING
          i_zpraa = ls_zpraa
        CHANGING
          i_zprim = <im>
      ).

      "Ritenuta d'acconto
      ritenuta( CHANGING i_zprim = <im> ).

      "importo fondo di garanzia (zprim-zimpfondo)
      fondo_garanzia(
        EXPORTING
          i_zpraa = ls_zpraa
        CHANGING
          i_zprim = <im>
      ).

      "totale facsimile
      <im>-ztotfs = <im>-zimprv - <im>-zimran + <im>-zimiva - <im>-zimena - <im>-zimpfondo.

      "cambio da facsimile a valuta società
      SELECT SINGLE FROM /eacm/t001
      FIELDS waers
      WHERE bukrs = @<im>-bukrs
      INTO @DATA(lv_t001_waers).
      TRY.
          cl_exchange_rates=>convert_to_local_currency(
            EXPORTING
              date              = <im>-bldat
              foreign_amount    = <im>-ztotfs
              foreign_currency  = <im>-waerk
              local_currency    = lv_t001_waers
            IMPORTING
              local_amount      = <im>-ztotfssf
          ).
        CATCH cx_exchange_rates.
          CLEAR <im>-ztotfssf.
      ENDTRY.

    ENDLOOP.

    UPDATE /eacm/prim_run FROM TABLE @lt_zprim.

  ENDMETHOD.


  METHOD calc_iva.

    SELECT *
    FROM /eacm/facpos_run
    WHERE run_uuid = @i_zprim-run_uuid
    INTO TABLE @DATA(lt_facpos).

    DATA ls_faciva TYPE /eacm/faciva_run.
    DATA lt_faciva TYPE STANDARD TABLE OF /eacm/faciva_run.
    LOOP AT lt_facpos INTO DATA(ls_facpos).

      CLEAR ls_faciva.
      MOVE-CORRESPONDING i_zprim TO ls_faciva.
      MOVE-CORRESPONDING ls_facpos TO ls_faciva.
      ls_faciva-percentuale = ls_facpos-msatz.
      ls_faciva-imponibile = ls_facpos-ziprv.
      ls_faciva-imponibile_vs = ls_facpos-ziprvvs.
      COLLECT ls_faciva INTO lt_faciva.

    ENDLOOP.

*    DATA t_mwdat TYPE TABLE OF rtax1u15.
*    DATA v_iva TYPE bset-fwste.

    CLEAR i_zprim-zimiva.
    LOOP AT lt_faciva ASSIGNING FIELD-SYMBOL(<faciva>).
      "DA FARE
      <faciva>-imposta = <faciva>-imponibile * <faciva>-percentuale / 100.
*
*      CLEAR v_iva.
*      CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
*        EXPORTING
*          i_bukrs           = liva-bukrs
*          i_mwskz           = liva-mwskz
*          i_waers           = l_zprim-waerk
*          i_wrbtr           = l_faciva-imponibile
*        IMPORTING
*          e_fwste           = v_iva
*        TABLES
*          t_mwdat           = t_mwdat
*        EXCEPTIONS
*          bukrs_not_found   = 1
*          country_not_found = 2
*          mwskz_not_defined = 3
*          mwskz_not_valid   = 4
*          ktosl_not_found   = 5
*          kalsm_not_found   = 6
*          parameter_error   = 7
*          knumh_not_found   = 8
*          kschl_not_found   = 9
*          unknown_error     = 10
*          account_not_found = 11
*          txjcd_not_valid   = 12
*          OTHERS            = 13.
*      IF sy-subrc <> 0.
** Implement suitable error handling here
*      ENDIF.
*      IF v_iva IS INITIAL.
*        READ TABLE t_mwdat INTO DATA(l_mwdat) WITH KEY msatz = l_faciva-percentuale.
*        IF sy-subrc = 0.
*          l_faciva-imposta = v_iva = l_mwdat-wmwst.
*        ENDIF.
*      ELSE.
*        l_faciva-imposta = v_iva.
*      ENDIF.
*
*
*      APPEND l_faciva TO t_faciva.
      i_zprim-zimiva += <faciva>-imposta.

      "non sarà mai un valore corretto se nel facsimile ci sono due ive diverse
      "riporto lo stesso i valori per compatibilità con la vecchia versione anche se non serviranno
      "i campi sarebbero da rimuovere in zprim.
      i_zprim-mwskz = <faciva>-mwskz.
      i_zprim-kalsm = <faciva>-kalsm.
    ENDLOOP.

    INSERT /eacm/faciva_run FROM TABLE @lt_faciva.

  ENDMETHOD.


  METHOD mingar_process.

    DATA(t_mingar) = get_mingar( ).

    DATA v_fine_periodo TYPE /eacm/zdtfi.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    DATA l_imppv TYPE /eacm/zimprv.
*    DATA t_delepos TYPE TABLE OF /eacm/facspos.
    DATA ls_newfacpos TYPE /eacm/facpos_run.
    DATA ls_faccomm TYPE /eacm/fac_mg_run.

    LOOP AT t_mingar INTO DATA(l_mingar).

      "verifica se già stato emesso l'anticipo o il min. garantito
      IF mingar_emesso( l_mingar ) = abap_true.
        CONTINUE.
      ENDIF.

      "data di fine del calcolo
      CONCATENATE l_mingar-zdatamin '01' INTO v_fine_periodo.
      v_fine_periodo = CONV d( CONV i( v_fine_periodo ) - 1 ).
      add_month_to_date(
        EXPORTING
          i_months  = l_mingar-zdurmes
          i_olddate = v_fine_periodo
        RECEIVING
          r_newdate = v_fine_periodo
      ).

      "devo assegnare l'anticipo o il minimo
      IF gv_competence BETWEEN l_mingar-zdatamin AND v_fine_periodo(6).

        "estraggo la sua fattura
        SELECT SINGLE *                                     "#EC WARNOK
        FROM /eacm/prim_run
        WHERE run_uuid IS NOT INITIAL
        AND created_by = @lv_user
        AND bukrs = @l_mingar-bukrs
        AND waerk = @l_mingar-waers
        AND zcdaz = @l_mingar-zcdaz
        INTO @DATA(ls_zprim).
        IF sy-subrc NE 0.
          TRY.
              DATA(lv_run_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              CLEAR lv_run_uuid.
          ENDTRY.
          CLEAR ls_zprim.
          ls_zprim-run_uuid = lv_run_uuid.
          ls_zprim-run_status = 'PROGRESS'.
          ls_zprim-created_by = lv_user.
          ls_zprim-bukrs = l_mingar-bukrs.
          ls_zprim-gjahr = gv_competence(4).
          ls_zprim-zamcf = gv_competence.
          ls_zprim-waerk = l_mingar-waers.
          ls_zprim-zcdaz = l_mingar-zcdaz.
          DATA(l_zpraa) = get_agent( ls_zprim-zcdaz ).
          ls_zprim-lifnr = l_zpraa-lifnr.
          ls_zprim-name1 = l_zpraa-name1.
          SELECT SINGLE waers
            FROM /eacm/t001
            WHERE bukrs = @ls_zprim-bukrs
            INTO @ls_zprim-zwaer.
          INSERT /eacm/prim_run FROM @ls_zprim.
        ENDIF.

        "Calcolo delle provvigioni associate al facsimile
        CLEAR l_imppv.
*        REFRESH t_delepos.
        "Escludo le classificazioni esenti da anticipo o minimo
        DATA lr_esenti TYPE RANGE OF /eacm/zpr08-zclpr.
        SELECT 'E' AS sign, 'EQ' AS option, zclpr AS low
        FROM /eacm/zpr08
        WHERE bukrs = @ls_zprim-bukrs
        INTO TABLE @lr_esenti.

        SELECT SUM( ziprv )
        FROM /eacm/facpos_run
        WHERE run_uuid = @ls_zprim-run_uuid
        AND gjahr = @ls_zprim-gjahr
        AND zclpr IN @lr_esenti
        INTO @l_imppv.

        "Anticipo automatico
        SELECT SINGLE COUNT( * )
        FROM /eacm/zpr08
        WHERE bukrs = @ls_zprim-bukrs
        AND zclpr = @l_mingar-zclpr_m
        AND zant = @abap_true
        AND zcongu = @abap_false.
        IF sy-subrc = 0.

          crea_facpos_dp(
            EXPORTING
              i_zprim = ls_zprim
              i_mingar = l_mingar
              i_fine_periodo = v_fine_periodo
            IMPORTING
              e_facpos = ls_newfacpos
              e_commission = ls_faccomm ).

          "Importo Delta = Anticipo - provvigioni
          ls_faccomm-ziprv = l_mingar-zmingar - l_imppv.

          "Importo provvigione da valuta di stampa facsimile a società
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = v_fine_periodo
                  foreign_amount    = ls_faccomm-ziprv
                  foreign_currency  = ls_zprim-waerk
                  local_currency    = ls_zprim-zwaer
                IMPORTING
                  local_amount      =  ls_faccomm-ziprvvs
              ).
            CATCH cx_exchange_rates.
              ls_faccomm-ziprvvs = ls_faccomm-ziprv.
          ENDTRY.

          "ZMINGAR non deve essere convertito perchè è lui che decide la valuta del facimile
          ls_newfacpos-ziprv = l_mingar-zmingar.
          ls_newfacpos-zclpr = ls_faccomm-zclpr = l_mingar-zclpr_m.
          DELETE FROM /eacm/facpos_run
          WHERE run_uuid = @ls_zprim-run_uuid
          AND gjahr = @ls_zprim-gjahr
          AND zclpr IN @lr_esenti.
          ls_faccomm-run_uuid = ls_zprim-run_uuid.
          ls_newfacpos-run_uuid = ls_zprim-run_uuid.
          INSERT /eacm/facpos_run FROM @ls_newfacpos.
          INSERT /eacm/fac_mg_run FROM @ls_faccomm.


          "/aggiorno importo anticipo
          ls_zprim-zimpant = ls_faccomm-ziprv.
          UPDATE /eacm/prim_run SET zimpant = @ls_zprim-zimpant WHERE run_uuid = @ls_zprim-run_uuid.
          "\aggiorno importo anticipo

        ENDIF.

        "Minimo garantito
        SELECT SINGLE COUNT( * )
        FROM /eacm/zpr08
        WHERE bukrs = @ls_zprim-bukrs
        AND zclpr = @l_mingar-zclpr_m
        AND zming = @abap_true
        AND zcongu = @abap_false.
        IF sy-subrc = 0.

          crea_facpos_dp(
            EXPORTING
              i_zprim = ls_zprim
              i_mingar = l_mingar
              i_fine_periodo = v_fine_periodo
            IMPORTING
              e_facpos = ls_newfacpos
              e_commission = ls_faccomm ).

*          "cosa viene assegnato nel facsimile
          ls_newfacpos-ziprv = l_mingar-zmingar.

          "Il delta lo calcolo sottraendo le provvigioni fatte a quello che darò come minimo o massimo
          ls_faccomm-ziprv = ls_faccomm-ziprvsf = ls_newfacpos-ziprv - l_imppv.

          "Importo provvigione da valuta di stampa facsimile a società
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = v_fine_periodo
                  foreign_amount    = ls_faccomm-ziprv
                  foreign_currency  = ls_zprim-waerk
                  local_currency    = ls_zprim-zwaer
                IMPORTING
                  local_amount      =  ls_faccomm-ziprvvs
              ).
            CATCH cx_exchange_rates.
              ls_faccomm-ziprvvs = ls_faccomm-ziprv.
          ENDTRY.

          ls_newfacpos-zclpr = ls_faccomm-zclpr = l_mingar-zclpr_m.

          DELETE FROM /eacm/facpos_run
          WHERE run_uuid = @ls_zprim-run_uuid
          AND gjahr = @ls_zprim-gjahr
          AND zclpr IN @lr_esenti.
          ls_faccomm-run_uuid = ls_zprim-run_uuid.
          ls_newfacpos-run_uuid = ls_zprim-run_uuid.
          INSERT /eacm/facpos_run FROM @ls_newfacpos.
          INSERT /eacm/fac_mg_run FROM @ls_faccomm.

          "/aggiorno importo anticipo
          ls_zprim-zimpant = ls_faccomm-ziprv.
          UPDATE /eacm/prim_run SET zimpant = @ls_zprim-zimpant WHERE run_uuid = @ls_zprim-run_uuid..
          "\aggiorno importo anticipo

        ENDIF.

      ENDIF.

      "devo calcolare il conguaglio
      IF gv_competence >= l_mingar-zmescong.
        "c'è conguaglio

        SELECT SINGLE * FROM /eacm/prim_run                 "#EC WARNOK
        WHERE run_uuid IS NOT INITIAL
        AND created_by = @lv_user
        AND  bukrs = @l_mingar-bukrs
        AND waerk = @l_mingar-waers
        AND zcdaz = @l_mingar-zcdaz
        INTO @ls_zprim.
        IF sy-subrc NE 0.
          TRY.
              lv_run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              CLEAR lv_run_uuid.
          ENDTRY.
          CLEAR ls_zprim.
          ls_zprim-run_uuid = lv_run_uuid.
          ls_zprim-run_status = 'PROGRESS'.
          ls_zprim-created_by = lv_user.
          ls_zprim-bukrs = l_mingar-bukrs.
          ls_zprim-gjahr = gv_competence(4).
          ls_zprim-zamcf = gv_competence.
          ls_zprim-waerk = l_mingar-waers.
          ls_zprim-zcdaz = l_mingar-zcdaz.
          l_zpraa = get_agent( ls_zprim-zcdaz ).
          ls_zprim-lifnr = l_zpraa-lifnr.
          ls_zprim-name1 = l_zpraa-name1.
          SELECT SINGLE waers
            FROM /eacm/t001
            WHERE bukrs = @ls_zprim-bukrs
            INTO @ls_zprim-zwaer.
          INSERT /eacm/prim_run FROM @ls_zprim.
        ENDIF.

        SELECT SUM( ziprv )
          FROM /eacm/zprdp AS dp
          LEFT OUTER JOIN /eacm/prdo AS do
          ON dp~vkorg = do~vkorg
          AND dp~vtweg = do~vtweg
          AND dp~zclpr = do~zclpr
          AND dp~vbeln = do~vbeln
          AND dp~posnr = do~posnr
          AND dp~zcdaz = do~zcdaz
          AND dp~zidag = do~zidag
          WHERE dp~vkorg = @l_mingar-vkorg
            AND dp~vtweg = @l_mingar-vtweg
            AND dp~zclpr = @l_mingar-zclpr_m
            AND dp~zcdaz = @ls_zprim-zcdaz
            AND dp~bukrs = @ls_zprim-bukrs
            AND zamcf BETWEEN @l_mingar-zdatamin AND @v_fine_periodo(6)
            AND vbtyp = 'M'
            AND dp~zstre NE 'D'
            AND do~zstre NE 'D'
            INTO @DATA(v_pos).
        SELECT SUM( ziprv )
          FROM /eacm/zprdp AS dp
          LEFT OUTER JOIN /eacm/prdo AS do
          ON dp~vkorg = do~vkorg
          AND dp~vtweg = do~vtweg
          AND dp~zclpr = do~zclpr
          AND dp~vbeln = do~vbeln
          AND dp~posnr = do~posnr
          AND dp~zcdaz = do~zcdaz
          AND dp~zidag = do~zidag
          WHERE dp~vkorg = @l_mingar-vkorg
            AND dp~vtweg = @l_mingar-vtweg
            AND dp~zclpr = @l_mingar-zclpr_m
            AND dp~zcdaz = @ls_zprim-zcdaz
            AND dp~bukrs = @ls_zprim-bukrs
            AND zamcf BETWEEN @l_mingar-zdatamin AND @v_fine_periodo(6)
            AND vbtyp = 'O'
            AND dp~zstre NE 'D'
            AND do~zstre NE 'D'
            INTO @DATA(v_neg).


        SELECT SUM( ziprv ) FROM /EACM/I_facrunDPd
        WHERE run_uuid = @ls_zprim-run_uuid
        AND bukrs = @l_mingar-bukrs
        AND zclpr = @l_mingar-zclpr_m
        INTO @DATA(lv_sum_ziprv).

        v_pos += lv_sum_ziprv.

        crea_facpos_dp(
          EXPORTING
            i_zprim = ls_zprim
            i_mingar = l_mingar
            i_fine_periodo = v_fine_periodo
          IMPORTING
            e_facpos = ls_newfacpos
            e_commission = ls_faccomm ).

        "Conguaglio anticipo automatico
        SELECT SINGLE COUNT( * )
        FROM /eacm/zpr08
        WHERE zclpr = @l_mingar-zclpr_cf
        AND zant = @abap_true
        AND zcongu = @abap_true.
        IF sy-subrc = 0.
          "sommo tutto quello che ho dato per fare il conguaglio
          ls_newfacpos-ziprv = ls_faccomm-ziprv = ( v_pos - v_neg ) * -1.

          "Importo provvigione da valuta di stampa facsimile a società
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = v_fine_periodo
                  foreign_amount    = ls_faccomm-ziprv
                  foreign_currency  = ls_zprim-waerk
                  local_currency    = ls_zprim-zwaer
                IMPORTING
                  local_amount      =  ls_faccomm-ziprvvs
              ).
            CATCH cx_exchange_rates.
              ls_faccomm-ziprvvs = ls_faccomm-ziprv.
          ENDTRY.

          ls_newfacpos-zclpr = ls_faccomm-zclpr = l_mingar-zclpr_cf.

          INSERT /eacm/facpos_run FROM @ls_newfacpos.
          INSERT /eacm/fac_mg_run FROM @ls_faccomm.

          "aggiorno importo anticipo
          ls_zprim-zimpant += ls_faccomm-ziprv.
          UPDATE /eacm/prim_run SET zimpant = @ls_zprim-zimpant WHERE run_uuid = @ls_zprim-run_uuid.

        ENDIF.

        "Conguaglio minimo garantito
        SELECT SINGLE COUNT( * )
        FROM /eacm/zpr08
        WHERE zclpr = @l_mingar-zclpr_cf
          AND zming = @abap_true
          AND zcongu = @abap_true.
        IF sy-subrc = 0.

          ls_newfacpos-ziprv = ls_faccomm-ziprv = ( v_pos - v_neg ) * -1.

          "Nel minimo garantito se devo dargli qualcosa faccio il conguaglio altrimenti no
          IF ls_newfacpos-ziprv < 0.
            "se è negativo non devo fare niete. Devo metterlo anche se a zero
            "perchè se non c'è la voce di conguaglio non viene chiuso il minimo garantito sul contratto
            ls_newfacpos-ziprv = ls_faccomm-ziprv = 0.
          ENDIF.

          "Importo provvigione da valuta di stampa facsimile a società
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = v_fine_periodo
                  foreign_amount    = ls_faccomm-ziprv
                  foreign_currency  = ls_zprim-waerk
                  local_currency    = ls_zprim-zwaer
                IMPORTING
                  local_amount      =  ls_faccomm-ziprvvs
              ).
            CATCH cx_exchange_rates.
              ls_faccomm-ziprvvs = ls_faccomm-ziprv.
          ENDTRY.

          ls_newfacpos-zclpr = ls_faccomm-zclpr = l_mingar-zclpr_cf.

          INSERT /eacm/facpos_run FROM @ls_newfacpos.
          INSERT /eacm/fac_mg_run FROM @ls_faccomm.

          "aggiorno importo anticipo
          ls_zprim-zimpant += ls_faccomm-ziprv.
          UPDATE /eacm/prim_run SET zimpant = @ls_zprim-zimpant WHERE run_uuid = @ls_zprim-run_uuid.

        ENDIF.

      ENDIF.

      "Nuovo importo provvigioni
      SELECT SINGLE * FROM /eacm/prim_run                   "#EC WARNOK
      WHERE bukrs = @l_mingar-bukrs
        AND waerk = @l_mingar-waers
        AND zcdaz = @l_mingar-zcdaz
        INTO @ls_zprim.
      IF sy-subrc = 0.

        SELECT SUM( ziprv ) FROM /EACM/I_facrunDPd
        WHERE run_uuid = @ls_zprim-run_uuid
        INTO @lv_sum_ziprv.

        ls_zprim-zimprv = lv_sum_ziprv.

        IF ls_zprim-waerk = ls_zprim-zwaer.
          ls_zprim-zimprvsf = ls_zprim-zimprv.
        ELSE.
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = v_fine_periodo
                  foreign_amount    = ls_zprim-zimprv
                  foreign_currency  = ls_zprim-waerk
                  local_currency    = ls_zprim-zwaer
                IMPORTING
                  local_amount      =  ls_zprim-zimprvsf
              ).
            CATCH cx_exchange_rates.
              CLEAR ls_zprim-zimprvsf.
          ENDTRY.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD calc_ena.

    "agente soggetto a Enasarco e con massimale non raggunto
    IF i_zpraa-zsena = abap_false OR i_zpraa-znoena = abap_true.
      RETURN.
    ENDIF.

*/   se l'agente è cessato l'anno di riferimento è quello di cessazione
    DATA lv_yyyy_riferimento TYPE gjahr.           "anno di cessazione
    CLEAR lv_yyyy_riferimento.
    SELECT SINGLE zdtfr
      FROM /eacm/zpr35
      WHERE bukrs   = @i_zprim-bukrs
        AND zcdaz  = @i_zprim-zcdaz
        INTO @DATA(lv_dt_cessazione).
    IF lv_dt_cessazione IS INITIAL OR lv_dt_cessazione(4) >= gv_competence(4).
      lv_yyyy_riferimento = gv_competence(4).
    ELSE.
      lv_yyyy_riferimento = lv_dt_cessazione(4).
    ENDIF.
*\

    "Miminali, massimali e percentuale
    get_min_max_perc_ena(
      EXPORTING
                       i_zcdaz     = i_zprim-zcdaz
                       i_gjahr_rif = lv_yyyy_riferimento
                       i_bukrs     = i_zprim-bukrs
                       i_ztsoc = i_zpraa-ztsoc
      IMPORTING
        e_zpr21     = DATA(ls_zpr21)
        e_zpr22     = DATA(ls_zpr22)
    ).

    IF ls_zpr21-zimas IS INITIAL OR ls_zpr22-zpage IS INITIAL.
      RETURN.
    ENDIF.

    DATA ls_zprfac TYPE /eacm/prfac_run.
    CLEAR ls_zprfac.

*    Importo di base per calcolo enasarco
    get_imp_ena(
      EXPORTING
        i_run_uuid = i_zprim-run_uuid
        i_waerk = i_zprim-waerk
        i_zzwaerk = ls_zpr21-zwaerk "valuta Enasarco
        i_bukrs = i_zprim-bukrs
      IMPORTING
        e_zimco    = ls_zprfac-zimco "somma delle provvigioni, base per il calcolo in valuta facsimile
        e_zimcoe   = ls_zprfac-zimcoe "somma delle provvigioni, base per il calcolo in valuta Enasarco
    ).

    "importo Enasarco calcolato a carico agente in divisa facsimile
    ls_zprfac-zageca = ls_zprfac-zimco * ls_zpr22-zpage / 100.

    "importo Enasarco calcolato a carico agente in divisa Enasarco
    ls_zprfac-zagecae = ls_zprfac-zimcoe * ls_zpr22-zpage / 100.

    get_zprfac_precedente(
      EXPORTING
        i_zprim          = i_zprim
        i_zpraa          = i_zpraa
        i_gjahr_rif      = lv_yyyy_riferimento
        i_dt_cessazione = lv_dt_cessazione
      IMPORTING
            i_complessivo    = DATA(v_complessivo) "calcolo complessivo (precedente + facsimile)
            i_complessivoe   = DATA(v_complessivoe) "calcolo complessivo (precedente + facsimile) valuta Enasarco
            i_effettivoprec  = DATA(v_effettivoprec) "effettivo precedente
            i_effettivoprece = DATA(v_effettivoprece) "effettivo precedente in valuta Ensarco
    ).

    v_complessivo = ls_zprfac-zageca + v_effettivoprec.
    v_complessivoe = ls_zprfac-zagecae + v_effettivoprece.

    "il massimale si considera per metà poichè è suddiviso per carico ditta e carico agente
    "il valore effettivo non può superare complessivamente il massimale
    DATA v_mass_dec2 TYPE p DECIMALS 2. "massimale arrotondato ai due decimali
    v_mass_dec2 = ls_zpr21-zimas / 2.
    IF v_complessivoe > ( v_mass_dec2 ).

      "Quando supero il massimale basta assegnare quello che manca al raggiungimento
      "che è il massimo che posso assegnare
      "importo Enasarco effettivo a carico agente in divisa facsimile
      ls_zprfac-zageff = v_mass_dec2 - v_effettivoprec.
      "importo Enasarco effettivo a carico agente in divisa Enasarco
      ls_zprfac-zageffe = v_mass_dec2 - v_effettivoprece.

      IF NOT lv_dt_cessazione IS INITIAL AND lv_dt_cessazione(4) LT i_zprim-gjahr.
        INSERT /eacm/maxena_run FROM @( VALUE #( zcdaz = i_zprim-zcdaz ) ).
      ENDIF.
    ELSE.
      "importo Enasarco effettivo a carico agente in divisa facsimile
      ls_zprfac-zageff = v_complessivo - v_effettivoprec.
      "importo Enasarco effettivo a carico agente in divisa Enasarco
      ls_zprfac-zageffe = v_complessivoe - v_effettivoprece.
    ENDIF.



    "cambio tra la valuta facsimile e la valuta enasarco
    ls_zprfac-kurrf = ls_zprfac-zimco / ls_zprfac-zimcoe.
    IF ls_zprfac-kurrf > 1.
      ls_zprfac-kurrf = ls_zprfac-kurrf * -1.
    ENDIF.

    ls_zprfac-run_uuid = i_zprim-run_uuid.
    ls_zprfac-bukrs = i_zprim-bukrs.
    ls_zprfac-gjahr = i_zprim-gjahr.
    ls_zprfac-lifnr = i_zprim-lifnr.
    ls_zprfac-waerk = i_zprim-waerk.
    ls_zprfac-zamcf = i_zprim-zamcf.
    ls_zprfac-zidfs = i_zprim-zidfs.
    ls_zprfac-zcdaz = i_zprim-zcdaz.
    ls_zprfac-zwaen = ls_zpr21-zwaerk.
    "progressivo
*    ls_zprfac-zidrg = get_zprfac_zidrg( EXPORTING t_zprfac = t_zprfac l_zprfac = l_zprfac ).
**********************************************************************
    i_zprim-zibcef = ls_zprfac-zimco.
    i_zprim-zimena = ls_zprfac-zageff.
    i_zprim-zpage = ls_zpr22-zpage.

    INSERT /eacm/prfac_run FROM @ls_zprfac.
  ENDMETHOD.


  METHOD get_tax_rate.
    SELECT SINGLE FROM /eacm/t_taxrate
    FIELDS msatz
    WHERE bukrs = @i_bukrs
    AND mwskz = @i_mwskz
    INTO @e_msatz.
  ENDMETHOD.


  METHOD get_agent.
    SELECT SINGLE *                           "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpraa
      WHERE zcdaz = @i_agent
      INTO @e_zpraa.
  ENDMETHOD.


  METHOD get_min_max_perc_ena.

    DATA lv_fist_day_comp TYPE d.
    CONCATENATE gv_competence '01' INTO lv_fist_day_comp.
    SELECT SINGLE FROM I_CalendarDate
    FIELDS LastDayOfMonthDate
    WHERE CalendarDate = @lv_fist_day_comp
    INTO @DATA(lv_LastDayOfMonthDate).

    "Codice tipo mandato
    SELECT ztman
      FROM /eacm/prcn
      WHERE zcdaz EQ @i_zcdaz
        AND bukrs EQ @i_bukrs
        AND zdtin <= @lv_LastDayOfMonthDate "data inizio contratto
        ORDER BY zdtin
        INTO @DATA(v_zztman).
      "se è chiuso non è importante, prendo l'ultimo agente
*        AND ( zdtfi >= v_scon OR zdtfi = 0 ). "data chiusura contratto
    ENDSELECT.

    SELECT SINGLE zimas, zwaerk
      FROM /eacm/zpr21
      WHERE ztcon = 'EN'
        AND ztsoc = @i_ztsoc
        AND ztman = @v_zztman
        AND gjahr  = @i_gjahr_rif
      INTO CORRESPONDING FIELDS OF @e_zpr21.
    IF sy-subrc NE 0.
      SELECT SINGLE zimas, zwaerk
        FROM /eacm/zpr21
        WHERE ztcon = 'EN'
          AND ztsoc = @i_ztsoc
          AND ztman = @v_zztman
          AND gjahr  = 0
        INTO CORRESPONDING FIELDS OF @e_zpr21.
    ENDIF.

**********************************************************************
    "Pecentuale da applicare per il calcolo del carico dell'agente
    SELECT SINGLE zpage
      FROM /eacm/zpr22
      WHERE ztcon = 'EN'
        AND ztsoc = @i_ztsoc
        AND ztman = @v_zztman
        AND gjahr = @i_gjahr_rif
        INTO CORRESPONDING FIELDS OF @e_zpr22.
    IF sy-subrc NE 0.
      SELECT SINGLE zpage
        FROM /eacm/zpr22
        WHERE ztcon = 'EN'
          AND ztsoc = @i_ztsoc
          AND ztman = @v_zztman
          AND gjahr = 0
          INTO CORRESPONDING FIELDS OF @e_zpr22.
    ENDIF.

    IF e_zpr21-zwaerk IS INITIAL.
      SELECT SINGLE waers
        FROM /eacm/t001
        WHERE bukrs = @i_bukrs
        INTO @e_zpr21-zwaerk.
    ENDIF.

  ENDMETHOD.


  METHOD get_zprfac_precedente.

    DATA lr_gjahr TYPE RANGE OF gjahr.

    IF i_dt_cessazione IS INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = i_zprim-gjahr  ) TO lr_gjahr.
    ELSE.
      APPEND VALUE #( sign = 'I' option = 'GE' low = i_gjahr_rif ) TO lr_gjahr.
    ENDIF.

    "estraggo la zprfac
    SELECT SUM( zageff ), SUM( zageffe )
    FROM /eacm/zprfac
    WHERE gjahr IN @lr_gjahr
      AND bukrs = @i_zprim-bukrs
      AND ( lifnr EQ @i_zprim-lifnr OR
            lifnr EQ @i_zpraa-zcodpre )
    INTO ( @i_effettivoprec, @i_effettivoprece ).

    SELECT SUM( zageff ), SUM( zageffe )
    FROM /eacm/prfac_run
    WHERE gjahr IN @lr_gjahr
      AND bukrs = @i_zprim-bukrs
      AND ( lifnr EQ @i_zprim-lifnr OR
            lifnr EQ @i_zpraa-zcodpre )
    INTO ( @DATA(lv_effettivoprec), @DATA(lv_effettivoprece) ).

    i_effettivoprec += lv_effettivoprec.
    i_effettivoprece += lv_effettivoprece.

  ENDMETHOD.


  METHOD ritenuta.

    "facismili negativi
    IF i_zprim-zimprv <= 0.
      "se le provvigioni sono minori o uguali a zero vado avanti
      "sono se sono permessi i facsimili negativi
      SELECT SINGLE COUNT( * ) FROM /eacm/zpr01
        WHERE bukrs = @i_zprim-bukrs
          AND zritneg = @abap_true.
      IF sy-subrc NE 0.
        "facsimili negativi non abilitati per la società
        RETURN.
      ENDIF.
    ENDIF.

    "Tipo agente soggetto a ritenuta d'acconto
    SELECT SINGLE COUNT( * )
      FROM /eacm/zpr02 AS a
      INNER JOIN /eacm/zpraa AS b
      ON a~ztpag = b~ztpag
      WHERE zsira = @abap_true
        AND zcdaz = @i_zprim-zcdaz.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    "parametrizzazione da zpr14 e zpr12 cod. IVA
    SELECT SINGLE COUNT( * ) FROM /eacm/facdp_run
    WHERE run_uuid = @i_zprim-run_uuid
    AND ritac = @abap_true.
    IF sy-subrc <> 0.  "non soggetto e ritenuta
      RETURN.
    ENDIF.

    SELECT SINGLE FROM /eacm/zpr03
      FIELDS zpara, zpert
      WHERE ztsoc = (
        SELECT ztsoc
        FROM /eacm/zpraa
        WHERE zcdaz = @i_zprim-zcdaz )
      INTO ( @DATA(v_para), @DATA(v_pert) ).

    "se una delle percentuali presenti in zpr03 è vuota vado a leggere l'anagrafica
    "fornitore dalla quale reperisco i dati
    IF v_para IS INITIAL OR v_pert IS INITIAL.
      DATA(l_t059z) = get_t059( i_bukrs = i_zprim-bukrs i_lifnr = i_zprim-lifnr ).
      i_zprim-witht = l_t059z-witht.
      i_zprim-wt_withcd = l_t059z-wt_withcd.
      i_zprim-qsatz = l_t059z-qsatz.
      i_zprim-qproz = l_t059z-qproz.
    ENDIF.

    "percentuale per il calcolo della ritenuta
    IF v_pert IS NOT INITIAL.
      i_zprim-qsatz = v_pert.
    ENDIF.

    "percentuale per la base di calcolo
    IF v_para IS NOT INITIAL.
      i_zprim-qproz = v_para.
      i_zprim-zimprac = ( ( i_zprim-zimprv - i_zprim-zimran ) * v_para / 100 ).
    ELSE.
      i_zprim-qproz = l_t059z-qproz.
      i_zprim-zimprac = ( ( i_zprim-zimprv - i_zprim-zimran ) * i_zprim-qproz / 100 ).
    ENDIF.

    i_zprim-zimrac  = i_zprim-zimprac * i_zprim-qsatz / 100.

  ENDMETHOD.


  METHOD get_t059.
    CLEAR e_t059z.
*    e_t059z-witht = '38'.
*    e_t059z-wt_withcd = '35'.
*    e_t059z-qsatz = '23.0000'.
*    e_t059z-qproz = '50.00'.

    SELECT SINGLE FROM /eacm/t059
    FIELDS witht, wt_withcd, qsatz, qproz
    WHERE bukrs = @i_bukrs
    AND lifnr = @i_lifnr
    INTO CORRESPONDING FIELDS OF @e_t059z.
    IF sy-subrc NE 0.
      SELECT SINGLE FROM /eacm/t059
      FIELDS witht, wt_withcd, qsatz, qproz
      WHERE bukrs = @i_bukrs
      AND lifnr = @space
      INTO CORRESPONDING FIELDS OF @e_t059z.
    ENDIF.

*    SELECT witht INTO @DATA(v_witht)
*      FROM t001wt
*      WHERE bukrs = @i_bukrs.
*
*      SELECT SINGLE land1 INTO @DATA(v_land1)
*            FROM lfa1
*            WHERE lifnr = @i_lifnr.
*
*      DATA vd_datum TYPE sy-datum.
*      CONCATENATE a_competence '01' INTO vd_datum.
*      SUBTRACT 1 FROM vd_datum.
*
*      SELECT SINGLE witht, wt_withcd
*         INTO @DATA(t_lfbw)
*         FROM lfbw
*        WHERE lifnr   EQ @i_lifnr
*          AND bukrs   EQ @i_bukrs
*          AND witht   EQ @v_witht
*          AND ( wt_exdf < @vd_datum OR wt_exdt > @vd_datum OR
*                wt_exdf = '00000000' OR wt_exdt = '00000000' ).
*      CHECK sy-subrc = 0.
*
*      SELECT SINGLE * INTO @e_t059z
*        FROM /eacm/t059
*        WHERE land1     = @v_land1
*          AND witht     = @t_lfbw-witht
*          AND wt_withcd = @t_lfbw-wt_withcd.
*      CHECK sy-subrc = 0.
*
*      EXIT.
*    ENDSELECT.
*
*    CLEAR: v_land1, v_witht.
  ENDMETHOD.


  METHOD fondo_garanzia.

    "Al momento non abbiamo gestito la valuta, ci limitiamo semplicemente a non fare
    "il calcolo se la valuta facsimile non è quella della società
    SELECT SINGLE COUNT(*)
      FROM /eacm/t001
      WHERE bukrs = @i_zprim-bukrs
        AND waers = @i_zprim-waerk.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    "verificare se agente è soggetto a fondo di garanzia
    IF i_zpraa-zsfon = abap_false.
      RETURN.
    ENDIF.

    DATA(l_zprfgar) = get_fgar( i_zprim = i_zprim ).

    "valore accumulato
    SELECT SINGLE client, zfnda FROM /eacm/zprfag
      WHERE zccnt = 'FG'
        AND bukrs = @l_zprfgar-bukrs
        AND zcdaz = @l_zprfgar-zcdaz
      INTO @DATA(l_zprfag).

    "se ho già raggiunto il massimale non faccio alcun calcolo
    IF l_zprfag-zfnda = l_zprfgar-zimpm.
      RETURN.
    ENDIF.

    "fondo calcolato
    i_zprim-zimpfondo = i_zprim-zibcef * l_zprfgar-zvper / 100.

    "se il totale accumulato supera il massimale assegno al calcolo solo la quota necessaria a raggiungere il massimale
    IF ( i_zprim-zimpfondo + l_zprfag-zfnda ) > l_zprfgar-zimpm.
      i_zprim-zfndtrat = l_zprfgar-zimpm.
      i_zprim-zimpfondo = l_zprfgar-zimpm - l_zprfag-zfnda.
    ELSE.
      "totale accumulato
      i_zprim-zfndtrat = i_zprim-zimpfondo + l_zprfag-zfnda.
    ENDIF.

  ENDMETHOD.


  METHOD get_fgar.
    CLEAR e_zprfgar.

    DATA datai TYPE d. "inizio competenza
    DATA dataf TYPE d. "fine competenza

    CONCATENATE i_zprim-zamcf '01' INTO datai.

    SELECT SINGLE FROM I_CalendarDate
    FIELDS LastDayOfMonthDate
    WHERE CalendarDate = @datai
    INTO @dataf.

    SELECT SINGLE *                                         "#EC WARNOK
      FROM /eacm/zprfgar
      WHERE zccnt = 'FG'
        AND bukrs = @i_zprim-bukrs
        AND adatu <= @dataf
        AND datub >= @datai
        AND zcdaz = @i_zprim-zcdaz
        INTO @e_zprfgar.
  ENDMETHOD.


  METHOD delete_action.
    DELETE FROM /eacm/facrun_act WHERE created_by = @i_user.
  ENDMETHOD.


  METHOD get_mingar.

    DATA lv_date TYPE d.
    lv_date = gv_competence && '01'.

    SELECT SINGLE FROM I_CalendarDate
    FIELDS LastDayOfMonthDate
    WHERE CalendarDate = @lv_date
    INTO @DATA(a_competence_date_end).

    "per ogni agente estraggo eventuali minimi garantiti
    SELECT  zcdaz, bukrs, vkorg, vtweg, waers, mwskz,
            zdatamin, zdurmes, zmescong, zclpr_m, zclpr_cf,
            zmingar, zmasgar
      FROM /eacm/prcn
      WHERE zcdaz IN @gr_zcdaz
        AND bukrs IN @gr_bukrs
        AND zdtin <= @a_competence_date_end
        AND ( zdtfi >= @a_competence_date_end OR zdtfi = 0 )
        AND zdatamin <= @gv_competence
        AND zmescong >= @gv_competence
        AND zmingar NE 0
        AND zdtconf = 0 "non c'è conguaglio
        INTO TABLE @r_result.

  ENDMETHOD.


  METHOD mingar_emesso.
    CLEAR emesso.

    "verifico se nella competenza che sto elaborando è già stato emesso un facsimile
    "con la classificazione del minimo/anticipo o del loro conguaglio
    SELECT SINGLE COUNT( * )
      FROM /eacm/zprim AS fs
      INNER JOIN /eacm/facspos AS ps
      ON fs~gjahr = ps~gjahr
      AND fs~zidfs = ps~zidfs
      WHERE fs~bukrs = @i_mingar-bukrs
        AND fs~gjahr = @gv_competence(4)
        AND zamcf = @gv_competence
        AND zcdaz = @i_mingar-zcdaz
        AND ( zclpr = @i_mingar-zclpr_m OR zclpr = @i_mingar-zclpr_cf ).
    IF sy-subrc = 0.
      emesso = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD add_month_to_date.
    SELECT SINGLE FROM I_CalendarDate
    FIELDS CalendarYear, CalendarMonth, CalendarDay
    WHERE CalendarDate = @i_olddate
    INTO @DATA(ls_Calendar).

    DO i_months TIMES.
      IF ls_Calendar-CalendarMonth = 12.
        ls_Calendar-CalendarYear += 1.
        ls_Calendar-CalendarMonth = 1.
      ELSE.
        ls_Calendar-CalendarMonth += 1.
      ENDIF.
    ENDDO.

    r_newdate = ls_Calendar-CalendarYear && ls_Calendar-CalendarMonth && ls_Calendar-CalendarDay.

    SELECT SINGLE COUNT( * )
    FROM I_CalendarDate
    WHERE CalendarDate = @r_newdate.
    IF sy-subrc <> 0.
      SELECT SINGLE FROM I_CalendarDate
      FIELDS LastDayOfMonthDate
      WHERE CalendarYear = @ls_Calendar-CalendarYear
        AND CalendarMonth = @ls_Calendar-CalendarMonth
        INTO @r_newdate.
    ENDIF.
  ENDMETHOD.


  METHOD crea_facpos_dp.

    "preparo la nuova posizione
    CLEAR e_facpos.
    e_facpos-gjahr = i_zprim-gjahr.
    e_facpos-run_uuid = i_zprim-run_uuid.

    "uso E_COMMISSION per passare i dati di calcolo dell'iva
    "non sto preparando E_COMMISSION, lo farò dopo
    "Creazione della riga DP per il delta
    CLEAR e_commission.
    MOVE-CORRESPONDING i_mingar TO e_commission.
    e_commission-lifnr = i_zprim-lifnr.
    e_commission-bldat = gv_bldat.
    e_commission-zamco = i_fine_periodo(6).  "competenza
    e_commission-zclpr = i_mingar-zclpr_m.


    DATA(l_zpraa) = get_agent( i_zprim-zcdaz ).

    e_commission-zamco = l_zpraa-erdat(6).
*    e_commission-ztpag = l_zpraa-ztpag.

    e_commission-zclpr = i_mingar-zclpr_m.
    e_commission-zcdaz = i_zprim-zcdaz.
    e_commission-lifnr = i_zprim-lifnr.
    e_commission-run_uuid = i_zprim-run_uuid.

    "la divisa dell'anticipo sarà uguale a quella del facsimile perchè è primario
    "nella scelta della valuta
    e_commission-waerk =  i_mingar-waers.  "divisa del A/M
    e_commission-zwaersp = i_zprim-waerk. "divisa facsimile
    SELECT SINGLE waers "valuta società
      FROM /eacm/t001
      WHERE bukrs = @i_zprim-bukrs
      INTO @e_commission-zwaer.
*    "Valuta
*    CALL METHOD get_facsimile_changes
*      EXPORTING
*        i_curr_doc       = e_commission-waerk   "divisa documento
*        i_curr_fac       = e_commission-zwaersp "divisa facsimile
*        i_vbeln          = space
*        i_posnr          = 0
*        i_fkdat          = i_fine_periodo
*        i_curr_comp      = e_commission-zzwaer
*      IMPORTING
*        "cambio da valuta facsimile a valuta società
*        e_change_fs_comp = e_commission-kurrvs
*        "cambio da valuta documento a valuta di stampa facsimile
*        e_change_doc_fs  = e_commission-zkurrfp.

    e_facpos-msatz = get_tax_rate( i_bukrs = i_zprim-bukrs i_mwskz = e_facpos-mwskz ).

    DATA lv_facdp_run TYPE /eacm/facdp_run.
    MOVE-CORRESPONDING e_commission TO lv_facdp_run.
    lv_facdp_run-naz_age = get_naz_age( EXPORTING i_dtini = i_fine_periodo i_dtfin = i_fine_periodo i_lifnr = lv_facdp_run-lifnr ).

    lv_facdp_run-naz_cli = get_naz_cli( EXPORTING i_dtini = i_fine_periodo i_dtfin = i_fine_periodo i_kunrg = space ).
    lv_facdp_run-naz_we = get_naz_we( EXPORTING i_dtini = i_fine_periodo i_dtfin = i_fine_periodo i_zdest = space ).
    lv_facdp_run-naz_soc = get_naz_soc( EXPORTING i_dtini = i_fine_periodo i_dtfin = i_fine_periodo i_bukrs = lv_facdp_run-bukrs ).

    get_iva_row(  CHANGING c_facdp =  lv_facdp_run ).
    e_commission-kalsm = lv_facdp_run-kalsm.
    e_commission-mwskz = lv_facdp_run-mwskz.
    e_commission-ritac = lv_facdp_run-ritac.

  ENDMETHOD.


  METHOD constructor.

    LOOP AT i_ranges INTO DATA(ls_range).
      TRANSLATE ls_range-name TO UPPER CASE.
      CASE ls_range-name.
        WHEN 'ZAMCF'.
          gv_competence = ls_range-range[ 1 ]-low.
        WHEN 'BLDAT'.
          gv_bldat = ls_range-range[ 1 ]-low.
        WHEN 'BUKRS'.
          gr_bukrs = CORRESPONDING #( ls_range-range ).
        WHEN 'ZCLPR'.
          gr_zclpr = CORRESPONDING #( ls_range-range ).
        WHEN 'VKORG'.
          gr_vkorg = CORRESPONDING #( ls_range-range ).
        WHEN 'VTWEG'.
          gr_vtweg = CORRESPONDING #( ls_range-range ).
        WHEN 'ZCDAZ'.
          gr_zcdaz = CORRESPONDING #( ls_range-range ).
        WHEN 'WAERK'.
          gv_waerk = ls_range-range[ 1 ]-low.
      ENDCASE.
    ENDLOOP.

*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '800128IT32' ) TO gr_zcdaz. "ELIMINARE
*    gv_competence = '202603'. "ELIMINARE
*    gv_bldat = '20260331'.

  ENDMETHOD.


  METHOD get_imp_ena.
    CLEAR: e_zimco, e_zimcoe.

    SELECT SINGLE waers
      FROM /eacm/t001
      WHERE bukrs = @i_bukrs
      INTO @DATA(lv_t001_waers).

    "valuta Enasarco = valuta società
    IF i_zzwaerk = lv_t001_waers.

      "valuta facsimile - valuta società
      SELECT SUM( ziprvsf ), SUM( ziprvvs )
      FROM /EACM/I_facrunDPd AS dp
      INNER JOIN /eacm/zpr08 AS cl
      ON  cl~bukrs = dp~bukrs
      AND cl~zclpr = dp~zclpr
      WHERE dp~run_uuid = @i_run_uuid
        AND cl~zenas = @abap_false
        INTO ( @e_zimco, @e_zimcoe ).
    ELSE.

      "valuta facsimile - valuta società
      SELECT zwaersp, ziprvsf, fkdat
      FROM /EACM/I_facrunDPd AS dp
      INNER JOIN /eacm/zpr08 AS cl
      ON  cl~bukrs = dp~bukrs
      AND cl~zclpr = dp~zclpr
      WHERE dp~run_uuid = @i_run_uuid
        AND cl~zenas = @abap_false
        INTO TABLE @DATA(lt_dp).

      DATA lv_local_amount TYPE /eacm/zprfac-zimcoe.

      LOOP AT lt_dp INTO DATA(ls_dp).
        e_zimco += ls_dp-ziprvsf.

        TRY.
            cl_exchange_rates=>convert_to_local_currency(
              EXPORTING
                date              = ls_dp-fkdat
                foreign_amount    = ls_dp-ziprvsf
                foreign_currency  = ls_dp-zwaersp
                local_currency    = i_zzwaerk
              IMPORTING
                local_amount      = lv_local_amount
            ).
          CATCH cx_exchange_rates.
            CLEAR lv_local_amount.
        ENDTRY.

        e_zimcoe += lv_local_amount.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_iva_row.
    SELECT SINGLE kalsm, mwskz, zrtac, zdesc, pdatv, pdatb  "#EC WARNOK
      FROM /eacm/zpr14
      WHERE znzag = @c_facdp-naz_age
        AND znmco = @c_facdp-naz_soc
        AND znzcl = @c_facdp-naz_cli
        AND lifnr = @c_facdp-lifnr
        INTO @DATA(l_zpr14).
    IF sy-subrc EQ 0 AND gv_bldat BETWEEN l_zpr14-pdatv AND l_zpr14-pdatb.
      c_facdp-kalsm = l_zpr14-kalsm.
      c_facdp-mwskz = l_zpr14-mwskz.
      c_facdp-ritac = l_zpr14-zrtac.  "soggetto a ritenuta d'acconto

*     verifico se c'è numero della licenza
      IF l_zpr14-zdesc IS NOT INITIAL AND
            ( l_zpr14-pdatv(6) <= gv_competence
          AND l_zpr14-pdatb(6) >= gv_competence ).
        c_facdp-licnr = l_zpr14-zdesc.
      ENDIF.

    ELSE.
      DATA l_zpr12 TYPE /eacm/zpr12.
      CLEAR l_zpr12.


      SELECT kalsm, mwskz, zrtac, zcdls                 "#EC CI_NOORDER
        FROM /eacm/zpr12
        WHERE znzag = @c_facdp-naz_age
          AND znmco = @c_facdp-naz_soc
          AND znzcl = @c_facdp-naz_cli
          AND znzmc = @c_facdp-naz_we
          AND zcdls NE @space
          INTO CORRESPONDING FIELDS OF @l_zpr12.

*        DATA(v_dalista) = iva_da_set( i_zpr12 = l_zpr12 i_commission =  i_provv ).
*        IF v_dalista = abap_false.
*          CLEAR l_zpr12.
*        ENDIF.
      ENDSELECT.

      IF l_zpr12 IS INITIAL.
        SELECT SINGLE kalsm, mwskz, zrtac                   "#EC WARNOK
          FROM /eacm/zpr12
          WHERE znzag = @c_facdp-naz_age
            AND znmco = @c_facdp-naz_soc
            AND znzcl = @c_facdp-naz_cli
            AND znzmc = @c_facdp-naz_we
            INTO CORRESPONDING FIELDS OF @l_zpr12.
        IF sy-subrc NE 0.
          SELECT SINGLE kalsm, mwskz, zrtac                 "#EC WARNOK
            FROM /eacm/zpr12
          WHERE znzag = @c_facdp-naz_age
            AND znmco = @c_facdp-naz_soc
            AND znzcl = @c_facdp-naz_cli
              INTO CORRESPONDING FIELDS OF @l_zpr12.
        ENDIF.
      ENDIF.

      IF l_zpr12 IS NOT INITIAL.
        c_facdp-kalsm = l_zpr12-kalsm.
        c_facdp-mwskz = l_zpr12-mwskz.
        c_facdp-ritac = l_zpr12-zrtac.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD get_naz_age.
    e_country = '0'.
*    SELECT SINGLE land1
*      FROM /eacm/lfa1
*      WHERE lifnr = @i_lifnr
*      INTO @DATA(v_land1).
    DATA v_land1 TYPE /eacm/zpr39-land1.
    CLEAR v_land1.
*    TRY.
*        DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
**        DATA(ls_bp) = lo_api->read_by_id( i_lifnr ).
*        DATA(ls_address) = lo_api->read_with_addresses( i_lifnr ).
*        v_land1 = ls_address-addresses[ 1 ]-country.
*      CATCH /eacm/cx_api_error INTO DATA(lx).
*        DATA(msg) = lx->get_text( ).
*        RETURN.
*    ENDTRY.
    SELECT SINGLE FROM /eacm/bp_cache
    FIELDS land1
    WHERE business_partner = @i_lifnr
      INTO @v_land1.
    IF v_land1 IS NOT INITIAL.
      SELECT SINGLE znzag                                   "#EC WARNOK
        FROM /eacm/zpr39
        WHERE land1 = @v_land1
          AND zdtin <= @i_dtfin
          AND zdtfi >= @i_dtini
          INTO @e_country.
      IF sy-subrc <> 0.
*          SELECT SINGLE xegld INTO @DATA(v_xegld)
        SELECT SINGLE COUNT( * )
        FROM I_Country
        WHERE Country = @v_land1
        AND IsEuropeanUnionMember = @abap_true.
        IF sy-subrc = 0.
          e_country = '1'.
        ELSE.
          e_country = '2'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_naz_cli.
    e_country = '0'.

    DATA v_land1 TYPE /eacm/zpr39-land1.
    CLEAR v_land1.
*    SELECT SINGLE land1
*      FROM /eacm/kna1
*    WHERE kunnr = @i_kunrg
*    INTO @DATA(v_land1).
*    TRY.
*        DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
**        DATA(ls_bp) = lo_api->read_by_id( i_lifnr ).
*        DATA(ls_address) = lo_api->read_with_addresses( i_kunrg ).
*        v_land1 = ls_address-addresses[ 1 ]-country.
*      CATCH /eacm/cx_api_error INTO DATA(lx).
*        DATA(msg) = lx->get_text( ).
*        RETURN.
*    ENDTRY.
    SELECT SINGLE FROM /eacm/bp_cache
    FIELDS land1
    WHERE business_partner = @i_kunrg
      INTO @v_land1.
    IF v_land1 IS NOT INITIAL.
      SELECT SINGLE znzag                                   "#EC WARNOK
        FROM /eacm/zpr39
        WHERE land1 = @v_land1
              AND zdtin <= @i_dtfin
              AND zdtfi >= @i_dtini
              INTO @e_country.
      IF sy-subrc <> 0.
        SELECT SINGLE COUNT( * )
          FROM I_Country
          WHERE Country = @v_land1
          AND IsEuropeanUnionMember = @abap_true.
        IF sy-subrc = 0.
          e_country = '1'.
        ELSE.
          e_country = '2'.
        ENDIF.
      ENDIF.
      "potrebbe essere initial in ZPR39???? non lo so, riporto il codice
      IF e_country IS INITIAL.
        e_country = '0'.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_naz_we.
    e_country = '0'.
*    SELECT SINGLE land1
*      FROM /eacm/kna1
*    WHERE kunnr = @i_zdest
*    INTO @DATA(v_land1).
    DATA v_land1 TYPE /eacm/zpr39-land1.
    CLEAR v_land1.
*    TRY.
*        DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
**        DATA(ls_bp) = lo_api->read_by_id( i_lifnr ).
*        DATA(ls_address) = lo_api->read_with_addresses( i_zdest ).
*        v_land1 = ls_address-addresses[ 1 ]-country.
*      CATCH /eacm/cx_api_error INTO DATA(lx).
*        DATA(msg) = lx->get_text( ).
*        RETURN.
*    ENDTRY.
    SELECT SINGLE FROM /eacm/bp_cache
    FIELDS land1
    WHERE business_partner = @i_zdest
      INTO @v_land1.
    IF v_land1 IS NOT INITIAL.
      SELECT SINGLE znzag                                   "#EC WARNOK
        FROM /eacm/zpr39
        WHERE land1 = @v_land1
              AND zdtin <= @i_dtfin
              AND zdtfi >= @i_dtini
              INTO @e_country.
      IF sy-subrc <> 0.
        SELECT SINGLE COUNT( * )
          FROM I_Country
          WHERE Country = @v_land1
          AND IsEuropeanUnionMember = @abap_true.
        IF sy-subrc = 0.
          e_country = '1'.
        ELSE.
          e_country = '2'.
        ENDIF.
      ENDIF.
      "potrebbe essere initial in ZPR39???? non lo so, riporto il codice
      IF e_country IS INITIAL.
        e_country = '0'.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_naz_soc.
    e_country = '0'.
    SELECT SINGLE land1
      FROM /eacm/t001
    WHERE bukrs = @i_bukrs
    INTO @DATA(v_land1).
    IF sy-subrc = 0.
      SELECT SINGLE znzag                                   "#EC WARNOK
        FROM /eacm/zpr39
        WHERE land1 = @v_land1
              AND zdtin <= @i_dtfin
              AND zdtfi >= @i_dtini
              INTO @e_country.
      IF sy-subrc <> 0.
        SELECT SINGLE COUNT( * )
          FROM I_Country
          WHERE Country = @v_land1
          AND IsEuropeanUnionMember = @abap_true.
        IF sy-subrc = 0.
          e_country = '1'.
        ELSE.
          e_country = '2'.
        ENDIF.
      ENDIF.
      "potrebbe essere initial in ZPR39???? non lo so, riporto il codice
      IF e_country IS INITIAL.
        e_country = '0'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
