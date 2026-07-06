@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BLDAT default in generazione facsimile'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACRUN_Bldat   as select from I_CalendarDate
{
  key CalendarDate,
//  FirstDayOfMonthDate,
//  LastDayOfMonthDate,
  dats_add_days( FirstDayOfMonthDate, -1, 'FAIL') as LastDayOfPrevMonth,
  substring( dats_add_days( FirstDayOfMonthDate, -1, 'FAIL'), 1, 6 ) as CompetencePrevMonth
}
where CalendarDate = $session.system_date
