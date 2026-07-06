@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '/EACM/C_FACPOS'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/C_FACPOS
  as projection on /EACM/I_FACPOS
{
  key Bukrs,
  key Gjahr,
  key Zidfs,
  key Zclpr,
  key Zcspv,
  key Mwskz,
  key Kalsm,

  @Semantics.amount.currencyCode: 'Waerk'
  Ziprv,

  Msatz,

  @Semantics.amount.currencyCode: 'Waerk'
  Ziprvvs,

  Waerk,

  _Zprim : redirected to parent /EACM/C_ZPRIM
}
