@AbapCatalog.sqlViewName: '/EACM/I_BPCHACHE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cache/Staging business partner'
@Metadata.ignorePropagatedAnnotations: true
define view /EACM/I_BUSINESS_PARTNER_C
  as select from /eacm/bp_cache
{
  key business_partner                              as BusinessPartner,
      concat_with_space( first_name, last_name, 1 ) as Name,
      land1                                         as Land1,
      city                                          as City,
      post_code                                     as PostCode,
      concat_with_space( street, house_num, 1)      as Street,
      region                                        as Region,
      stceg                                         as Stceg,
      stcd1                                         as Stcd1
}
