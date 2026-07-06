@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '/EACM/I_FACPOS'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACPOS
  as select from /eacm/facspos as fac

    association to parent /EACM/I_ZPRIM as _Zprim
          on  $projection.Bukrs = _Zprim.Bukrs
    
      and $projection.Gjahr = _Zprim.Gjahr
      and $projection.Zidfs = _Zprim.Zidfs
{
  key fac.bukrs as Bukrs,
  key fac.gjahr as Gjahr,
  key fac.zidfs as Zidfs,
  key fac.zclpr as Zclpr,
  key fac.zcspv as Zcspv,
  key fac.mwskz as Mwskz,
  key fac.kalsm as Kalsm,

  @Semantics.amount.currencyCode: 'Waerk'
  fac.ziprv as Ziprv,

  fac.msatz as Msatz,

  @Semantics.amount.currencyCode: 'Waerk'
  fac.ziprvvs as Ziprvvs,

  _Zprim.Waerk as Waerk,

  _Zprim
}
