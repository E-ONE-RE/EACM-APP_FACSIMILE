@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log invio e-mail facsimili'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity /EACM/C_FMAIL_LOG
  as projection on /EACM/I_FMAIL_LOG
{
  key RunUuid,
  key LogUuid,
      Bukrs,
      Gjahr,
      Zidfs,
      Mailaddress,
      FileName,
      FileNameD,
      Status, //stato: Q accodato, P in elaborazione, S inviato, E errore
      StatusText,
      StatusCriticality,
      ProcessedAt,
      ErrorText,
      /* Associations */
      _Run : redirected to parent /EACM/C_FMAIL_RUN
}
