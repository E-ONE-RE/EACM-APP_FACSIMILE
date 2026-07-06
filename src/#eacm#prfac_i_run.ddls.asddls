@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_I Generazione facsimile - ZPRFAC'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/PRFAC_I_RUN as select from /eacm/prfac_run
association to parent /EACM/PRIM_I_RUN as _Root on $projection.RunUuid = _Root.RunUuid
{
    key run_uuid as RunUuid,
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
