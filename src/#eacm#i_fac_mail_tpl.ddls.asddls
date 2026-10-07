@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dati template e-mail facsimile'
@ObjectModel.supportedCapabilities: [ #OUTPUT_EMAIL_DATA_PROVIDER ]
@Metadata.ignorePropagatedAnnotations: true

define view entity /EACM/I_FAC_MAIL_TPL
  as select from /eacm/zprim as Facsimile
{
  @EndUserText.label: 'Società'
  key Facsimile.bukrs as Bukrs,

  @EndUserText.label: 'Esercizio'
  key Facsimile.gjahr as Gjahr,

  @EndUserText.label: 'Identificativo facsimile'
  key Facsimile.zidfs as Zidfs,

  @EndUserText.label: 'Codice agente'
      Facsimile.zcdaz as AgentCode,

  @EndUserText.label: 'Nome agente'
      Facsimile.name1 as AgentName,

  @EndUserText.label: 'Periodo provvigionale'
      Facsimile.zamcf as CommissionPeriod,

//  @EndUserText.label: 'Numero documento contabile'
//      Facsimile.belnr as AccountingDocument,

  @EndUserText.label: 'Data documento'
      Facsimile.bldat as DocumentDate,

//  @EndUserText.label: 'Data registrazione'
//      Facsimile.budat as PostingDate,

  @EndUserText.label: 'Data elaborazione'
      $session.system_date as SendDate,

  @EndUserText.label: 'Fornitore'
      Facsimile.lifnr as Supplier,

//  @EndUserText.label: 'Riferimento'
//      Facsimile.zuonr as AssignmentReference,

  @EndUserText.label: 'Valuta'
      Facsimile.waerk as Currency,

  @EndUserText.label: 'Totale facsimile'
  @Semantics.amount.currencyCode: 'Currency'
      cast(
        Facsimile.ztotfs - Facsimile.zimrac
        as /eacm/ztotfs
      ) as TotalAmount,

  @EndUserText.label: 'Nome file facsimile'
      Facsimile.file_name as FacsimileFileName,

  @EndUserText.label: 'Nome file dettaglio'
      Facsimile.file_name_d as DetailFileName
}
