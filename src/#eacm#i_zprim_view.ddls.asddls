@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_ZPRIM_VIEW
  as select from /eacm/zprim
  composition [0..*] of /EACM/I_FACSPOS_VIEW as _Positions
  composition [0..*] of /EACM/I_ZPRFAC_VIEW  as _Enasarco
  composition [0..*] of /EACM/I_FACIVA_VIEW  as _IVA
{
  key bukrs           as Bukrs,
  key gjahr           as Gjahr,
  key zidfs           as Zidfs,
      lifnr           as Lifnr,
      zamcf           as Zamcf,
      waerk           as Waerk,
      @Semantics.amount.currencyCode : 'Waerk'
      //      ztotfs     as Ztotfs,
      cast(ztotfs - zimrac as /eacm/ztotfs) as Ztotfs,
      @Semantics.amount.currencyCode : 'Waerk'
      zimprv          as Zimprv,
      @Semantics.amount.currencyCode : 'Waerk'
      zimran          as Zimran,
      mwskz           as Mwskz,
      kalsm           as Kalsm,
      @Semantics.amount.currencyCode : 'Waerk'
      zimiva          as Zimiva,
      @Semantics.amount.currencyCode : 'Waerk'
      zimena          as Zimena,
      @Semantics.amount.currencyCode : 'Waerk'
      zibcef          as Zibcef,
      @Semantics.amount.currencyCode : 'Waerk'
      zimprac         as Zimprac,
      qproz           as Qproz,
      @Semantics.amount.currencyCode : 'Waerk'
      zimrac          as Zimrac,
      qsatz           as Qsatz,
      belnr           as Belnr,
      bldat           as Bldat,
      budat           as Budat,
      zcont           as Zcont,
      zrich           as Zrich,
      zanticipo       as Zanticipo,
      zcdaz           as Zcdaz,
      name1           as Name1,
      znzag           as Znzag,
      cbdat           as Cbdat,
      zuonr           as Zuonr,
      zwaer           as Zwaer,
      @Semantics.amount.currencyCode : 'zwaer'
      ztotfssf        as Ztotfssf,
      @Semantics.amount.currencyCode : 'zwaer'
      zimprvsf        as Zimprvsf,
      @Semantics.amount.currencyCode : 'zwaer'
      zimransf        as Zimransf,
      @Semantics.amount.currencyCode : 'zwaer'
      zimprvsfc       as Zimprvsfc,
      @Semantics.amount.currencyCode : 'zwaer'
      zimransfc       as Zimransfc,
      @Semantics.amount.currencyCode : 'zwaer'
      zimenavsc       as Zimenavsc,
      @Semantics.amount.currencyCode : 'zwaer'
      ztotfssfc       as Ztotfssfc,
      @Semantics.amount.currencyCode : 'Waerk'
      zimpfat         as Zimpfat,
      @Semantics.amount.currencyCode : 'zwaer'
      zimpfatvs       as Zimpfatvs,
      @Semantics.amount.currencyCode : 'zwaer'
      zimpfatvsc      as Zimpfatvsc,
      @Semantics.amount.currencyCode : 'Waerk'
      zimpfondo       as Zimpfondo,
      @Semantics.amount.currencyCode : 'Waerk'
      zenaaccu        as Zenaaccu,
      @Semantics.amount.currencyCode : 'Waerk'
      zfndtrat        as Zfndtrat,
      witht           as Witht,
      wt_withcd       as WtWithcd,
      @Semantics.amount.currencyCode : 'Waerk'
      zimpant         as Zimpant,
      sgtxt           as Sgtxt,
      ibelnr          as Ibelnr,
      file_name       as FileName,
      mime_type       as MimeType,
      attachment      as Attachment,
      _Positions,
      _Enasarco,
      _IVA
}
