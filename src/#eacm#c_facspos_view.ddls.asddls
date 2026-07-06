@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.allowExtensions: true
define view entity /EACM/C_FACSPOS_VIEW as projection on /EACM/I_FACSPOS_VIEW
{
    key Bukrs,
    key Gjahr,
    key Zidfs,
    key Zclpr,
    key Zcspv,
    key Mwskz,
    key Kalsm,
    @Semantics.amount.currencyCode : 'Waerk'
    Ziprv,
    Msatz,
    @Semantics.amount.currencyCode : 'Zwaer'
    Ziprvvs,
    Waerk,
    Zwaer,
    Zdesc,
    /* Associations */
    _Root: redirected to parent /EACM/C_ZPRIM_VIEW
}
