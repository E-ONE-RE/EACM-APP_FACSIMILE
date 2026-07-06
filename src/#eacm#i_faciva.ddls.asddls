@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '/EACM/I_FACIVA'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACIVA
  as select from /eacm/faciva as faciv

    association to parent /EACM/I_ZPRIM as _Zprim
          on  $projection.Bukrs = _Zprim.Bukrs
        
      and $projection.Gjahr = _Zprim.Gjahr
      and $projection.Zidfs = _Zprim.Zidfs
{
    key faciv.bukrs as Bukrs,
    key faciv.gjahr as Gjahr,
    key faciv.zidfs as Zidfs,
    key faciv.mwskz as Mwskz,
    key faciv.kalsm as Kalsm,

  faciv.percentuale as Percentuale,
  
  @Semantics.amount.currencyCode: 'Waerk'

  faciv.imponibile as Imponibile,

  @Semantics.amount.currencyCode: 'Waerk'
  faciv.imposta as Imposta,

  waerk as Waerk,
  
  @Semantics.amount.currencyCode: 'Waerk'
    
  imponibile_vs as ImponibileVs,
         
       cast(
      concat(
        concat_with_space(
          cast( faciv.kalsm as abap.char(10) ),
          cast( faciv.mwskz as abap.char(4) ),
          1
        ),
        '%'
      )
      as abap.char(16)
    ) as DescIva,
        
  _Zprim
}
