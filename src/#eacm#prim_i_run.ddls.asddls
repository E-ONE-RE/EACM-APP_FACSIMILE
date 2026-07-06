@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Generazione facsimile - ZPRIM'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/PRIM_I_RUN
  as select from /eacm/prim_run as prim
    inner join   /eacm/t001     as t001 on t001.bukrs = prim.bukrs
  composition [0..*] of /EACM/FACPOS_I_RUN         as _Positions
  composition [0..*] of /EACM/PRFAC_I_RUN          as _Enasarco
  composition [0..*] of /EACM/FACIVA_I_RUN         as _IVA

  association [0..1] to /EACM/I_BUSINESS_PARTNER_C as _Supplier on $projection.Lifnr = _Supplier.BusinessPartner

{
  key prim.run_uuid                                       as RunUuid,
      prim.run_status                                     as RunStatus,
      prim.created_by                                     as CreatedBy,
      prim.vkorg                                          as Vkorg,
      prim.vtweg                                          as Vtweg,
      prim.zclpr                                          as Zclpr,
      prim.bukrs                                          as Bukrs,
      prim.gjahr                                          as Gjahr,
      prim.zidfs                                          as Zidfs,
      prim.lifnr                                          as Lifnr,
      prim.zcdaz                                          as Zcdaz,
      prim.zamcf                                          as Zamcf,
      prim.bldat                                          as Bldat,
      prim.waerk                                          as Waerk,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zimprv                                         as Zimprv,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zimena                                         as Zimena,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zibcef                                         as Zibcef,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zimprac                                        as Zimprac,
      prim.qproz                                          as Qproz,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zimrac                                         as Zimrac,
      prim.qsatz                                          as Qsatz,
      @Semantics.amount.currencyCode : 'Waerk'
      prim.zimiva                                         as Zimiva,
      @Semantics.amount.currencyCode : 'Waerk'
      cast(prim.ztotfs - prim.zimrac as /eacm/ztotfs)     as Ztotfs,

      cast(
        case
          when prim.ztotfs > 0 then 'FATTURA'
          else 'NOTA DEBITO'
        end
        as abap.char(15)
      )                                                   as TipoDoc,
      prim.zpage                                          as Zpage,

      prim.file_name                                      as FileName,
      @Semantics.mimeType: true
      prim.mime_type                                      as MimeType,
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
      }
      prim.attachment                                     as Attachment,
      t001.butxt                                          as Butxt,
      t001.city                                           as City,
      t001.post_code                                      as Post_code,
      concat_with_space(t001.street , t001.house_num, 1 ) as Street,
      t001.land1                                          as Country,
      t001.region                                         as Region,
      t001.stceg                                          as Stceg,
      t001.stcd1                                          as Stcd1,
      _Positions,
      _Enasarco,
      _IVA,
      _Supplier
}
