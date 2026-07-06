@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_ZPRFAC_VIEW as select from /eacm/zprfac
association to parent /EACM/I_ZPRIM_VIEW as _Root 
on $projection.Bukrs = _Root.Bukrs
and $projection.Gjahr = _Root.Gjahr
and $projection.Zidfs = _Root.Zidfs
{
    key bukrs as Bukrs,
    key gjahr as Gjahr,
    key lifnr as Lifnr,
    key waerk as Waerk,
    key zamcf as Zamcf,
    key zidrg as Zidrg,
    zidfs as Zidfs,
    zcdaz as Zcdaz,
    @Semantics.amount.currencyCode : 'Waerk'
    zimco as Zimco,
    @Semantics.amount.currencyCode : 'Waerk'
    zageca as Zageca,
    @Semantics.amount.currencyCode : 'Waerk'
    zageff as Zageff,
    zwaen as Zwaen,
    @Semantics.amount.currencyCode : 'Zwaen'
    zimcoe as Zimcoe,
    @Semantics.amount.currencyCode : 'Zwaen'
    zagecae as Zagecae,
    @Semantics.amount.currencyCode : 'Zwaen'
    zageffe as Zageffe,
    kurrf as Kurrf,
    _Root
}
