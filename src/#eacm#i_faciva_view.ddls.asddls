@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACIVA_VIEW
  as select from /eacm/faciva    as faciva

    inner join   /eacm/t_taxrate as tax on  tax.bukrs = faciva.bukrs
                                        and tax.mwskz = faciva.mwskz

  association to parent /EACM/I_ZPRIM_VIEW as _Root on  $projection.Bukrs = _Root.Bukrs
                                                    and $projection.Gjahr = _Root.Gjahr
                                                    and $projection.Zidfs = _Root.Zidfs
{
  key faciva.bukrs         as Bukrs,
  key faciva.gjahr         as Gjahr,
  key faciva.zidfs         as Zidfs,
  key faciva.mwskz         as Mwskz,
  key faciva.kalsm         as Kalsm,
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
