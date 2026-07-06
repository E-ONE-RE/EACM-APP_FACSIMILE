@ObjectModel.query.implementedBy: 'ABAP:/EACM/CL_PRIM_I_RUN'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS_C Generazione facsimile - ZPRIM'
@Metadata.allowExtensions: true
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]
define root view entity /EACM/PRIM_C_RUN
  provider contract transactional_query
  as projection on /EACM/PRIM_I_RUN
{
  key RunUuid,
      RunStatus,
      CreatedBy,
      Vkorg,
      Vtweg,
      Zclpr,
      Bukrs,
      Gjahr,
      Zidfs,
      Lifnr,
      Zcdaz,
      Zamcf,
      Bldat,
      Waerk,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimprv,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimena,
      @Semantics.amount.currencyCode : 'Waerk'
      Zibcef,
      @Semantics.amount.currencyCode : 'Waerk'
      Zimprac,
      Qproz,
      Zimrac,
      @Semantics.amount.currencyCode : 'Waerk'
      Qsatz,
      Zimiva,
      @Semantics.amount.currencyCode : 'Waerk'
      Ztotfs,
      TipoDoc,
      Zpage,
      @Semantics.mimeType: true
      MimeType,
      FileName,
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
      }
      Attachment,
      Butxt,
      City,
      Post_code,
      Street,
      Country,
      Region,
      Stceg,
      Stcd1,
      /* Associations */
      @ObjectModel.filter.enabled: false
      _Enasarco  : redirected to composition child /EACM/PRFAC_C_RUN,
      @ObjectModel.filter.enabled: false
      _IVA       : redirected to composition child /EACM/FACIVA_C_RUN,
      @ObjectModel.filter.enabled: false
      _Positions : redirected to composition child /EACM/FACPOS_C_RUN,
      @ObjectModel.filter.enabled: false
      @ObjectModel.sort.enabled: false
      _Supplier
}
