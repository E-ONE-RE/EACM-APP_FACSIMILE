@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BLDAT default in generazione facsimile'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACRUN_DATE_VH
  as select from I_CalendarDate
{
  key CalendarDate,
      //  FirstDayOfMonthDate,
      //  LastDayOfMonthDate,
      substring( CalendarDate, 1, 6 ) as Competence,
      @EndUserText: {
              label: 'Today',
              quickInfo: 'Today'
          }
      cast(
        case when CalendarDate = $session.system_date
        then 'X'
        else '' end as abap_boolean ) as Today

}
where
  CalendarDate between dats_add_days( $session.system_date, - 365, 'FAIL' ) and dats_add_days( $session.system_date, 365, 'FAIL' )
