@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_I Generazione facsimile - FACSPOS'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/FACPOS_I_RUN as select from /eacm/facpos_run as pos

left outer join /eacm/zpr08 as zpr
    on pos.zclpr = zpr.zclpr
    
association to parent /EACM/PRIM_I_RUN as _Root on $projection.RunUuid = _Root.RunUuid
{
    key pos.run_uuid as RunUuid,
    key pos.zclpr as Zclpr,
    pos.bukrs as Bukrs,
    pos.gjahr as Gjahr,
    pos.zidfs as Zidfs,
    pos.zcspv as Zcspv,
    pos.mwskz as Mwskz,
    pos.kalsm as Kalsm,
    @Semantics.amount.currencyCode : 'Waerk'
    pos.ziprv as Ziprv,
    pos.msatz as Msatz,
    @Semantics.amount.currencyCode : 'Waerk'
    pos.ziprvvs as Ziprvvs,
    pos.waerk as Waerk,
    zpr.zdesc as Zdesc,
    _Root
}
