@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Facsimile VAT'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/C_FACIVA
  as projection on /EACM/I_FACIVA
  {
    key Bukrs,
    key Gjahr,
    key Zidfs,
    key Mwskz,
    key Kalsm,
    Percentuale,
  @Semantics.amount.currencyCode: 'Waerk'
    
    Imponibile,
            @Semantics.amount.currencyCode: 'Waerk'
    
    Imposta,
            @Semantics.amount.currencyCode: 'Waerk'
    
    ImponibileVs,
    Waerk,
    DescIva,
    
    
    
      _Zprim : redirected to parent /EACM/C_ZPRIM
    
  
}
