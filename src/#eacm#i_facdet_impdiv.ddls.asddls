@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dettaglio facsimile in valuta'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACDET_IMPDIV
  as select from /eacm/zprdp as dp

    inner join   /eacm/zprim as im on  im.zidfs = dp.zidfs
                                   and im.zamcf = dp.zamcf

    inner join   /eacm/prdo  as do on  dp.vkorg = do.vkorg
                                   and dp.vtweg = do.vtweg
                                   and dp.zclpr = do.zclpr
                                   and dp.vbeln = do.vbeln
                                   and dp.posnr = do.posnr
                                   and dp.zcdaz = do.zcdaz
                                   and dp.zidag = do.zidag

    inner join   /eacm/zpr08 as cl on  dp.bukrs = cl.bukrs
                                   and dp.zclpr = cl.zclpr

{

  key dp.vkorg,
  key dp.vtweg,
  key dp.zclpr,
  key dp.vbeln,
  key dp.posnr,
  key dp.zcdaz,
  key dp.zidag,
  key dp.zidrg,
      dp.bukrs,
      dp.gjahr,
      
      im.zidfs,
      im.zamcf,

      do.kunrg,
      do.vbtyp,
      do.bldat,
      do.z_zwaer, //Valuta società
      do.ztprv,

      do.waerk, //Divisa documento
      @Semantics.amount.currencyCode: 'waerk'
      do.zlord,
      @Semantics.amount.currencyCode: 'waerk'
      do.zimpp,
      @Semantics.amount.currencyCode: 'waerk'
      do.zimco,
      @Semantics.amount.currencyCode: 'waerk'
      do.ziman,
      @Semantics.amount.currencyCode: 'waerk'
      dp.ziprv,

      im.waerk as Waerkf, //Divisa facsimile
      @Semantics.amount.currencyCode: 'Waerkf'
      currency_conversion(
       amount             => do.zlord,
       source_currency    => do.waerk,
       target_currency    => im.waerk,
       exchange_rate_date => im.bldat,
       exchange_rate_type => 'M'
      )        as zlordf,
      @Semantics.amount.currencyCode: 'Waerkf'
      currency_conversion(
       amount             => do.zimpp,
       source_currency    => do.waerk,
       target_currency    => im.waerk,
       exchange_rate_date => im.bldat,
       exchange_rate_type => 'M'
      )        as zimppf,
      @Semantics.amount.currencyCode: 'Waerkf'
      currency_conversion(
       amount             => do.zimco,
       source_currency    => do.waerk,
       target_currency    => im.waerk,
       exchange_rate_date => im.bldat,
       exchange_rate_type => 'M'
      )        as zimcof,
      @Semantics.amount.currencyCode: 'Waerkf'
      currency_conversion(
       amount             => do.ziman,
       source_currency    => do.waerk,
       target_currency    => im.waerk,
       exchange_rate_date => im.bldat,
       exchange_rate_type => 'M'
      )        as zimanf,
      @Semantics.amount.currencyCode: 'Waerkf'
      currency_conversion(
       amount             => dp.ziprv,
       source_currency    => do.waerk,
       target_currency    => im.waerk,
       exchange_rate_date => im.bldat,
       exchange_rate_type => 'M'
      )        as ziprvf,
      cl.zcaan as AnticipoManuale

}
where
      dp.zidfs <> '0000'

//  and dp.zidfs =  '0674'
//  and dp.zamcf =  '202602' //928IT20
