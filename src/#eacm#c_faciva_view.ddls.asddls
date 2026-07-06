@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.allowExtensions: true
define view entity /EACM/C_FACIVA_VIEW as projection on /EACM/I_FACIVA_VIEW
{
    key Bukrs,
    key Gjahr,
    key Zidfs,
    key Mwskz,
    key Kalsm,
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
    _Root: redirected to parent /EACM/C_ZPRIM_VIEW
}
