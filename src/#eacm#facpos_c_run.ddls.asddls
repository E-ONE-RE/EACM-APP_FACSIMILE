@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_C Generazione facsimile - FACSPOS'
@Metadata.allowExtensions: true
define view entity /EACM/FACPOS_C_RUN
//provider contract transactional_query
as projection on /EACM/FACPOS_I_RUN
{
    key RunUuid,
    key Zclpr,
    Bukrs,
    Gjahr,
    Zidfs,
    Zcspv,
    Mwskz,
    Kalsm,
    @Semantics.amount.currencyCode : 'Waerk'
    Ziprv,
    Msatz,
    @Semantics.amount.currencyCode : 'Waerk'
    Ziprvvs,
    Waerk,
    Zdesc,
    /* Associations */
    @ObjectModel.sort.enabled: false
    @ObjectModel.filter.enabled: false
    _Root: redirected to parent /EACM/PRIM_C_RUN
}
