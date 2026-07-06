@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'V'
@Metadata.allowExtensions: true
define root view entity /EACM/C_ZPRIM_VIEW
  provider contract transactional_query
  as projection on /EACM/I_ZPRIM_VIEW
{
  key Bukrs,
  key Gjahr,
  key Zidfs,
      Lifnr,
      Zamcf,
      Waerk,
      @Semantics.amount.currencyCode : 'Waerk'
      Ztotfs,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimprv,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimran,
      Mwskz,
      Kalsm,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimiva,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimena,
      @Semantics.amount.currencyCode : 'Waerk'
      Zibcef,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimprac,
      Qproz,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimrac,
      Qsatz,
      Belnr,
      Bldat,
      Budat,
      Zcont,
      Zrich,
      Zanticipo,
      Zcdaz,
      Name1,
      Znzag,
      Cbdat,
      Zuonr,
      Zwaer,
      @Semantics.amount.currencyCode : 'Zwaer'
      Ztotfssf,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimprvsf,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimransf,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimprvsfc,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimransfc,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimenavsc,
      @Semantics.amount.currencyCode : 'Zwaer'
      Ztotfssfc,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimpfat,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimpfatvs,
      @Semantics.amount.currencyCode : 'Zwaer'
      Zimpfatvsc,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimpfondo,
      @Semantics.amount.currencyCode : 'Waerk'
      Zenaaccu,
      @Semantics.amount.currencyCode : 'Waerk'
      Zfndtrat,
      Witht,
      WtWithcd,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimpant,
      Sgtxt,
      Ibelnr,
      FileName,
      @Semantics.mimeType: true
      MimeType,
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
//        contentDispositionPreference: #INLINE
      }
      Attachment,
      /* Associations */
      _Enasarco  : redirected to composition child /EACM/C_ZPRFAC_VIEW,
      _IVA       : redirected to composition child /EACM/C_FACIVA_VIEW,
      _Positions : redirected to composition child /EACM/C_FACSPOS_VIEW
}
