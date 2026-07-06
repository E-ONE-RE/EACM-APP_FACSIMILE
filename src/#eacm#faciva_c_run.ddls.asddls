@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_C Generazione facsimile - FACIVA'
@Metadata.allowExtensions: true
define view entity /EACM/FACIVA_C_RUN
  //provider contract transactional_query
  as projection on /EACM/FACIVA_I_RUN
{
  key RunUuid,
  key Bukrs,
  key Gjahr,
  key Mwskz,
  key Kalsm,
      Zidfs,
      Percentuale,
      @Semantics.amount.currencyCode : 'Waerk'
      Imponibile,
      @Semantics.amount.currencyCode : 'Waerk'
      Imposta,
      @Semantics.amount.currencyCode : 'Waerk'
      ImponibileVs,
      Waerk,
      DescrIva,
      /* Associations */
      @ObjectModel.sort.enabled: false
      @ObjectModel.filter.enabled: false
      _Root : redirected to parent /EACM/PRIM_C_RUN
}
