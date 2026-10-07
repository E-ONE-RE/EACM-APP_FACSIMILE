@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log invio e-mail facsimili'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FMAIL_LOG
  as select from /eacm/fmail_log as FMailLog

  association to parent /EACM/I_FMAIL_RUN as _Run on $projection.RunUuid = _Run.RunUuid
{
  key FMailLog.run_uuid     as RunUuid,
  key FMailLog.log_uuid     as LogUuid,

      FMailLog.bukrs        as Bukrs,
      FMailLog.gjahr        as Gjahr,
      FMailLog.zidfs        as Zidfs,
      FMailLog.mailaddress  as Mailaddress,
      FMailLog.file_name    as FileName,
      FMailLog.file_name_d  as FileNameD,
      FMailLog.status       as Status,

      cast(
        case FMailLog.status
          when 'Q' then 'In attesa'
          when 'P' then 'In elaborazione'
          when 'S' then 'Inviato'
          when 'W' then 'Inviato con avvisi'
          when 'E' then 'Errore'
          else 'Stato sconosciuto'
        end as abap.char(30)
      )                     as StatusText,

      cast(
        case FMailLog.status
          when 'Q' then 0
          when 'P' then 5
          when 'S' then 3
          when 'W' then 2
          when 'E' then 1
          else 0
        end as abap.int1
      )                     as StatusCriticality,

      FMailLog.processed_at as ProcessedAt,
      FMailLog.error_text   as ErrorText,
      _Run
}
