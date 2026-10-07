@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Testata invio e-mail facsimili'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_FMAIL_RUN
  as select from /eacm/fmail_run as FMailRun
  composition [0..*] of /EACM/I_FMAIL_LOG as _Logs
{
  key FMailRun.run_uuid   as RunUuid,
      FMailRun.created_at as CreatedAt,
      FMailRun.created_by as CreatedBy,
      FMailRun.status     as Status,

      cast(
        case FMailRun.status
          when 'Q' then 'In attesa'
          when 'P' then 'In elaborazione'
          when 'S' then 'Inviato'
          when 'W' then 'Inviato con avvisi'
          when 'E' then 'Errore'
          else 'Stato sconosciuto'
        end as abap.char(30)
      )                   as StatusText,

      cast(
        case FMailRun.status
          when 'Q' then 0  // Neutro
          when 'P' then 5  // Informazione
          when 'S' then 3  // Positivo
          when 'W' then 2  // Avviso
          when 'E' then 1  // Errore
          else 0
        end as abap.int1
      )                   as StatusCriticality,
      gjahr               as Gjahr,
      zamcf               as Zamcf,
      _Logs
}
