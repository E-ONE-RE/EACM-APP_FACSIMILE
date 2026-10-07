@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Testata invio e-mail facsimili'
@Metadata.allowExtensions: true
define root view entity /EACM/C_FMAIL_RUN
  provider contract transactional_query
  as projection on /EACM/I_FMAIL_RUN
{
  key RunUuid,
      CreatedAt,
      CreatedBy,
      Status, //S inviato, E errore
      StatusText,
      StatusCriticality,
      Gjahr,
      Zamcf,
      _Logs : redirected to composition child /EACM/C_FMAIL_LOG
}
