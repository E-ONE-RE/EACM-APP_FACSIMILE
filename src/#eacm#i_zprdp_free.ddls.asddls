@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dettaglio ZPRDP - generazione facsimile'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_zprdp_free
  as select from    /eacm/zprdp     as dp

    inner join      /eacm/prdo      as do    on  dp.vkorg = do.vkorg
                                             and dp.vtweg = do.vtweg
                                             and dp.zclpr = do.zclpr
                                             and dp.vbeln = do.vbeln
                                             and dp.posnr = do.posnr
                                             and dp.zcdaz = do.zcdaz
                                             and dp.zidag = do.zidag

    inner join      /eacm/zpr08     as cl    on  cl.bukrs = dp.bukrs
                                             and cl.zclpr = dp.zclpr

  //    inner join      /eacm/zpr48     as zpr48 on do.vbtyp = zpr48.vbtyp

  //    inner join      /eacm/t001      as t001  on t001.bukrs = dp.bukrs

    left outer join /eacm/facdp_run as run   on  dp.vkorg = run.vkorg
                                             and dp.vtweg = run.vtweg
                                             and dp.zclpr = run.zclpr
                                             and dp.vbeln = run.vbeln
                                             and dp.posnr = run.posnr
                                             and dp.zcdaz = run.zcdaz
                                             and dp.zidag = run.zidag

    inner join      /eacm/zpraa     as zpraa on dp.zcdaz = zpraa.zcdaz
    inner join      /eacm/zpr02     as zpr02 on zpr02.ztpag = zpraa.ztpag
    inner join      /eacm/zpr01     as zpr01 on zpr01.bukrs = dp.bukrs
{
  key dp.vkorg as Vkorg,
  key dp.vtweg as Vtweg,
  key dp.zclpr as Zclpr,
  key dp.vbeln as Vbeln,
  key dp.posnr as Posnr,
  key dp.zcdaz as Zcdaz,
  key dp.zidag as Zidag,
  key dp.zidrg as Zidrg,
      dp.bukrs as Bukrs,
      dp.kunrg as Kunrg,
      do.zdest as Zdest,
      dp.zamco as Zamco,
      dp.waerk as Waerk, //valuta del documento
      dp.fkdat as Fkdat,
      run.dtchange as Dtchange, // solo per alimentazione in /EACM/CL_FACSIMILE=>get_lock_dp
      zpraa.ztpag,
      zpraa.lifnr,
      case when cl.zcaan = 'X'
      then 'X'
      else ''
      end      as Anticipo
}

where
       dp.zidfs    =  '0000'
  and  dp.zbloc    =  ''
  and  dp.zstre    <> 'D'
  and  dp.ztpcd    =  '' //blocco provvisioni - S sospese da /EACM/ONOFFPRV
  and(
       cl.zcapr    =  'X'
    or cl.zcaan    =  'X'
  )
  and(
       zpr02.zfsan =  'X'
    or zpr02.zfspr =  'X'
  )
  and  zpr01.zfman =  'A' //generazione automatica
  and  run.vbeln   is null
