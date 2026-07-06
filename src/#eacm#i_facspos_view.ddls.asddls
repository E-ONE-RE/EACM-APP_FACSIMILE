@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visualizzazione Facsimili'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_FACSPOS_VIEW
  as select from    /eacm/facspos      as facpos
    inner join      /EACM/I_ZPRIM_VIEW as zprim on  facpos.bukrs = zprim.Bukrs
                                                and facpos.gjahr = zprim.Gjahr
                                                and facpos.zidfs = zprim.Zidfs
    left outer join /eacm/zpr08        as zpr   on facpos.zclpr = zpr.zclpr

  association to parent /EACM/I_ZPRIM_VIEW as _Root on  $projection.Bukrs = _Root.Bukrs
                                                    and $projection.Gjahr = _Root.Gjahr
                                                    and $projection.Zidfs = _Root.Zidfs
{
  key facpos.bukrs   as Bukrs,
  key facpos.gjahr   as Gjahr,
  key facpos.zidfs   as Zidfs,
  key facpos.zclpr   as Zclpr,
  key facpos.zcspv   as Zcspv,
  key facpos.mwskz   as Mwskz,
  key facpos.kalsm   as Kalsm,
      @Semantics.amount.currencyCode : 'Waerk'
      facpos.ziprv   as Ziprv,
      facpos.msatz   as Msatz,
      @Semantics.amount.currencyCode : 'Zwaer'
      facpos.ziprvvs as Ziprvvs,
      zprim.Waerk    as Waerk,
      zprim.Zwaer    as Zwaer,
      zpr.zdesc      as Zdesc,
      _Root
}
