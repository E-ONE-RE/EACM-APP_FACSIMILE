@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Facsimile di dettaglio - totale cliente'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACDETT_LIST
  as select from /EACM/I_FACDET_IMPDIV as dp

    inner join   /EACM/I_SDTYPESIGN    as sign on dp.vbtyp = sign.vbtyp

  association to parent /EACM/I_FACDETT_CLI as _Clienti on  $projection.bukrs = _Clienti.bukrs
                                                        and $projection.zidfs = _Clienti.zidfs
                                                        and $projection.zamcf = _Clienti.zamcf
                                                        and $projection.kunrg = _Clienti.kunrg

{
  key dp.vkorg,
  key dp.vtweg,
  key dp.zclpr,
  key dp.vbeln,
  key dp.posnr,
  key dp.zcdaz,
  key dp.zidag,
  key dp.zidrg,
      dp.bukrs,
      dp.gjahr,
      dp.zidfs,
      dp.zamcf,
      dp.kunrg,

      case when dp.zclpr = 'SB'
      then
        case dp.vbtyp
        when 'O' then 'NC'
        when 'N' then 'NC'
        when 'M' then
            case when dp.ziprv = 0
            then 'IP'
            else 'FT'
            end
        else '**'
        end
      else ''
      end                                               as Type,
      dp.bldat,
      dp.Waerkf,
      @Semantics.amount.currencyCode: 'Waerkf'
      // Importo documento
      case when dp.AnticipoManuale = 'X'
      then curr_to_decfloat_amount( dp.zimanf ) * sign.segno
      else curr_to_decfloat_amount( dp.zlordf ) * sign.segno
      end                                               as Importo,
      dp.ztprv,
      @Semantics.amount.currencyCode: 'Waerkf'
      curr_to_decfloat_amount( dp.zimppf ) * sign.segno as zimppf, //Imponibile
      //Importo rata
      @Semantics.amount.currencyCode: 'Waerkf'
      case
        when dp.zimcof = 0
          then curr_to_decfloat_amount( dp.zimppf ) * sign.segno
        else
          curr_to_decfloat_amount( dp.ziprvf )
            * get_numeric_value( dp.zimppf )
            / get_numeric_value( dp.zimcof )
            * sign.segno
      end                                               as Rata,
      //Importo provvigione
      @Semantics.amount.currencyCode: 'Waerkf'
      curr_to_decfloat_amount( dp.ziprvf ) * sign.segno as ziprvf,
      _Clienti

}
where
      dp.zidfs <> '0000'

//  and dp.zidfs =  '0674'
//  and dp.zamcf =  '202602'
