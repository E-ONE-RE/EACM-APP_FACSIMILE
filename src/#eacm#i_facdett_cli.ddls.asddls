@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Facsimile di dettaglio - totale cliente'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACDETT_CLI
  as select from /EACM/I_FACDETT_BASE

  association to parent /EACM/I_FACDETT_MAIN as _Facs on  $projection.bukrs = _Facs.bukrs
                                                      and $projection.zidfs = _Facs.zidfs
                                                      and $projection.zamcf = _Facs.zamcf


  composition [0..*] of /EACM/I_FACDETT_LIST as _Dettaglio

{

  key bukrs,
      //  key gjahr,
  key zidfs,
  key zamcf,
  key kunrg,
      KunrgName,
      Waerkf,
      @Semantics.amount.currencyCode: 'Waerkf'
      sum( zimppf ) as zimppf,
      @Semantics.amount.currencyCode: 'Waerkf'
      sum( Rata )    as Rata,
      @Semantics.amount.currencyCode: 'Waerkf'
      sum( ziprvf )  as ziprvf,
      _Facs,
      _Dettaglio

}

where
  zidfs <> '0000'

//  and zidfs =  '0674'
//  and zamcf =  '202602'

group by
  bukrs,
  //  gjahr,
  zidfs,
  zamcf,
  kunrg,
  KunrgName,
  Waerkf
