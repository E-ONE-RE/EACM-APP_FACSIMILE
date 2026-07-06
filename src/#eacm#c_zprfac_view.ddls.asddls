@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.allowExtensions: true
define view entity /EACM/C_ZPRFAC_VIEW as projection on /EACM/I_ZPRFAC_VIEW
{
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
    _Root: redirected to parent /EACM/C_ZPRIM_VIEW
}
