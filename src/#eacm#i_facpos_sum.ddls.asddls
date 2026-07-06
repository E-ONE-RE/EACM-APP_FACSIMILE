@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '/EACM/I_FACPOS_SUM'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACPOS_SUM
  as select from /eacm/facspos as fac
    inner join /eacm/zprim as hdr
      on  hdr.bukrs = fac.bukrs
      and hdr.gjahr = fac.gjahr
      and hdr.zidfs = fac.zidfs
{
  key fac.bukrs as Bukrs,
  key fac.gjahr as Gjahr,
  key fac.zidfs as Zidfs,

  hdr.waerk as Waerk,

  @Semantics.amount.currencyCode: 'Waerk'
  sum( fac.ziprv ) as ZiprvTot
}
group by
  fac.bukrs,
  fac.gjahr,
  fac.zidfs,
  hdr.waerk
