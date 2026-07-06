@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_C Generazione facsimile - ZPRFAC'
@Metadata.allowExtensions: true
define view entity /EACM/PRFAC_C_RUN
//provider contract transactional_query
as projection on /EACM/PRFAC_I_RUN
{
    key RunUuid,
    key Bukrs,
    key Gjahr,
    key Lifnr,
    key Waerk,
    key Zamcf,
    key Zidrg,
    Zidfs,
    Zcdaz,
    @Semantics.amount.currencyCode : 'Waerk'
    Zimco,
    @Semantics.amount.currencyCode : 'Waerk'
    Zageca,
    @Semantics.amount.currencyCode : 'Waerk'
    Zageff,
    Zwaen,
    @Semantics.amount.currencyCode : 'Zwaen'
    Zimcoe,
    @Semantics.amount.currencyCode : 'Zwaen'
    Zagecae,
    @Semantics.amount.currencyCode : 'Zwaen'
    Zageffe,
    Kurrf,
    /* Associations */
    @ObjectModel.sort.enabled: false
    @ObjectModel.filter.enabled: false
    _Root: redirected to parent /EACM/PRIM_C_RUN
}
