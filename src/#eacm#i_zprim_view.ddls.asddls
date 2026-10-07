@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_ZPRIM_VIEW
  as select from /eacm/zprim as zprim

    inner join   /eacm/zpraa as zpraa on zprim.zcdaz = zpraa.zcdaz
  //    left outer join /eacm/bp_cache as bp on zprim.lifnr = bp.business_partner
  composition [0..*] of /EACM/I_FACSPOS_VIEW as _Positions
  composition [0..*] of /EACM/I_ZPRFAC_VIEW  as _Enasarco
  composition [0..*] of /EACM/I_FACIVA_VIEW  as _IVA

  association [0..*] to /EACM/I_FMAIL_LOG    as _MailLogs on  $projection.Bukrs = _MailLogs.Bukrs
                                                          and $projection.Gjahr = _MailLogs.Gjahr
                                                          and $projection.Zidfs = _MailLogs.Zidfs

{
  key zprim.bukrs                                       as Bukrs,
  key zprim.gjahr                                       as Gjahr,
  key zprim.zidfs                                       as Zidfs,
      zprim.lifnr                                       as Lifnr,
      zprim.zamcf                                       as Zamcf,
      zprim.waerk                                       as Waerk,
      @Semantics.amount.currencyCode : 'Waerk'
      //      ztotfs     as Ztotfs,
      cast(zprim.ztotfs - zprim.zimrac as /eacm/ztotfs) as Ztotfs,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimprv                                      as Zimprv,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimran                                      as Zimran,
      zprim.mwskz                                       as Mwskz,
      zprim.kalsm                                       as Kalsm,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimiva                                      as Zimiva,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimena                                      as Zimena,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zibcef                                      as Zibcef,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimprac                                     as Zimprac,
      zprim.qproz                                       as Qproz,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimrac                                      as Zimrac,
      zprim.qsatz                                       as Qsatz,
      zprim.belnr                                       as Belnr,
      zprim.bldat                                       as Bldat,
      zprim.budat                                       as Budat,
      zprim.zcont                                       as Zcont,
      zprim.zrich                                       as Zrich,
      zprim.zanticipo                                   as Zanticipo,
      zprim.zcdaz                                       as Zcdaz,
      zprim.name1                                       as Name1,
      zprim.znzag                                       as Znzag,
      zprim.cbdat                                       as Cbdat,
      zprim.zuonr                                       as Zuonr,
      zprim.zwaer                                       as Zwaer,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.ztotfssf                                    as Ztotfssf,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimprvsf                                    as Zimprvsf,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimransf                                    as Zimransf,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimprvsfc                                   as Zimprvsfc,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimransfc                                   as Zimransfc,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimenavsc                                   as Zimenavsc,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.ztotfssfc                                   as Ztotfssfc,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimpfat                                     as Zimpfat,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimpfatvs                                   as Zimpfatvs,
      @Semantics.amount.currencyCode : 'zwaer'
      zprim.zimpfatvsc                                  as Zimpfatvsc,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimpfondo                                   as Zimpfondo,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zenaaccu                                    as Zenaaccu,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zfndtrat                                    as Zfndtrat,
      zprim.witht                                       as Witht,
      zprim.wt_withcd                                   as WtWithcd,
      @Semantics.amount.currencyCode : 'Waerk'
      zprim.zimpant                                     as Zimpant,
      zprim.sgtxt                                       as Sgtxt,
      zprim.ibelnr                                      as Ibelnr,
      zprim.file_name                                   as FileName,
      zprim.mime_type                                   as MimeType,
      zprim.attachment                                  as Attachment,
      zprim.file_name_d                                 as FileNameD,
      zprim.attachment_d                                as AttachmentD,
      zpraa.mailaddress                                 as Mailaddress,
      _Positions,
      _Enasarco,
      _IVA,
      _MailLogs
}
