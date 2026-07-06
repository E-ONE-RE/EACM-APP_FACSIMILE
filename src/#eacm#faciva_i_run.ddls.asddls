@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_I Generazione facsimile - FACIVA'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/FACIVA_I_RUN
  as select from /eacm/faciva_run as faciva
    inner join   /eacm/t_taxrate  as tax on  tax.bukrs = faciva.bukrs
                                         and tax.mwskz = faciva.mwskz
  association to parent /EACM/PRIM_I_RUN as _Root on $projection.RunUuid = _Root.RunUuid
{
  key faciva.run_uuid      as RunUuid,
  key faciva.bukrs         as Bukrs,
  key faciva.gjahr         as Gjahr,
  key faciva.mwskz         as Mwskz,
  key faciva.kalsm         as Kalsm,
      faciva.zidfs         as Zidfs,
      faciva.percentuale   as Percentuale,
      @Semantics.amount.currencyCode : 'Waerk'
      faciva.imponibile    as Imponibile,
      @Semantics.amount.currencyCode : 'Waerk'
      faciva.imposta       as Imposta,
      @Semantics.amount.currencyCode : 'Waerk'
      faciva.imponibile_vs as ImponibileVs,
      faciva.waerk         as Waerk,
      tax.text1            as DescrIva,
      _Root
}
