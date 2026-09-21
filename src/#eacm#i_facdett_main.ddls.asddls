@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Facsimile di dettaglio - MAIN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]
define root view entity /EACM/I_FACDETT_MAIN
  as select from    /eacm/zprim    as im

    left outer join /eacm/bp_cache as bp on bp.business_partner = im.lifnr

  composition [0..*] of /EACM/I_FACDETT_CLI as _Clienti

{
  key im.bukrs,
      //  key im.gjahr,
  key im.zidfs,
  key im.zamcf,
      im.zcdaz,
      bp.first_name,
      bp.last_name,
      bp.street,
      bp.house_num,
      bp.post_code,
      bp.city,
      bp.region,
      im.waerk,

      _Clienti
}
