@EndUserText.label: 'Parametri invio e-mail'
define abstract entity /EACM/A_FMAIL_PARAM
{
  @EndUserText.label: 'Data fattura'
  InvoiceDate : abap.dats;

  @EndUserText.label: 'Data pagamento'
  PaymentDate : abap.dats;

  @EndUserText.label: 'Oggetto'
  Subject : abap.char(255);

  @EndUserText.label: 'Corpo e-mail'
  @UI.multiLineText: true
  Body : abap.string(0);
}
