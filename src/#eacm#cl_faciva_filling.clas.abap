CLASS /eacm/cl_faciva_filling DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.
    METHODS carica_faciva.
    METHODS carica_clienti.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /eacm/cl_faciva_filling IMPLEMENTATION.

  METHOD if_apj_rt_run~execute.
    carica_faciva( ).
    carica_clienti( ).
  ENDMETHOD.

  METHOD carica_faciva.


    "seleziono i record che non hanno dati in FACIVA
    "sono sicuramente generati con il vecchio programma

    SELECT FROM /eacm/zprim AS fac
    LEFT JOIN /eacm/faciva AS iva
    ON fac~bukrs = iva~bukrs
    AND fac~gjahr = iva~gjahr
    AND fac~zidfs = iva~zidfs
    FIELDS fac~bukrs, fac~gjahr, fac~zidfs, fac~mwskz, fac~kalsm, fac~waerk,
           fac~zimprv, fac~zimiva
    WHERE fac~mwskz <> @space
*    AND fac~gjahr = 2026
    AND iva~zidfs IS NULL
    INTO TABLE @DATA(lt_zprim).

    DATA ls_faciva TYPE /eacm/faciva.

    LOOP AT lt_zprim INTO DATA(ls_zprim).

      ls_faciva = VALUE /eacm/faciva(
          bukrs = ls_zprim-bukrs
          gjahr = ls_zprim-gjahr
          zidfs = ls_zprim-zidfs
          mwskz = ls_zprim-mwskz
          kalsm = ls_zprim-kalsm
*        percentuale = ls_zprim-
          imponibile = ls_zprim-zimprv
          imposta = ls_zprim-zimiva
          imponibile_vs = ls_zprim-zimprv
          waerk = ls_zprim-waerk
      ).

      SELECT SINGLE FROM /eacm/t_taxrate
      FIELDS msatz
      WHERE bukrs = @ls_faciva-bukrs
      AND mwskz = @ls_faciva-mwskz
      INTO @ls_faciva-percentuale.
      IF sy-subrc = 0 AND ls_faciva-percentuale <> 0.
        INSERT INTO /eacm/faciva VALUES @ls_faciva.

        UPDATE /eacm/facspos
        SET mwskz = @ls_faciva-mwskz, kalsm = @ls_zprim-kalsm, msatz = @ls_faciva-percentuale
        WHERE bukrs = @ls_zprim-bukrs
          AND gjahr = @ls_zprim-gjahr
          AND zidfs = @ls_zprim-zidfs.
      ENDIF.



    ENDLOOP.

  ENDMETHOD.

  METHOD carica_clienti.

    SELECT FROM /eacm/prdo AS do
    INNER JOIN /eacm/zzbsctrans AS tran
    ON do~belnr = tran~belnr
    AND do~gjahr = tran~gjahr
    FIELDS do~gjahr, do~belnr, tran~kunnr
    WHERE kunrg = @space
    INTO TABLE @DATA(lt_do).

    SORT lt_do BY gjahr belnr.
    DELETE ADJACENT DUPLICATES FROM lt_do COMPARING gjahr belnr.
    LOOP AT lt_do INTO DATA(ls_do).

      UPDATE /eacm/prdo
      SET kunrg = @ls_do-kunnr,
        knrza = @ls_do-kunnr
        WHERE belnr = @ls_do-belnr
        AND gjahr = @ls_do-gjahr.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
