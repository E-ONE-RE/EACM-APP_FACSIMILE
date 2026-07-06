@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view issued facsimile'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_ZPRIM
  as select from    /eacm/zprim        as hdr
    inner join      /eacm/t001         as t001   on t001.bukrs = hdr.bukrs
    left outer join /EACM/I_FACPOS_SUM as sumpos on  sumpos.Bukrs = hdr.bukrs
                                                 and sumpos.Gjahr = hdr.gjahr
                                                 and sumpos.Zidfs = hdr.zidfs
  composition [0..*] of /EACM/I_FACPOS             as _FacPos
  composition [0..*] of /EACM/I_FACIVA             as _FacIva

  association [0..1] to /EACM/I_BUSINESS_PARTNER_C as _Supplier on $projection.Lifnr = _Supplier.BusinessPartner
{
  key hdr.bukrs                                                         as Bukrs,
  key hdr.gjahr                                                         as Gjahr,
  key hdr.zidfs                                                         as Zidfs,

      _FacPos,
      _FacIva,
      _Supplier,

      hdr.lifnr                                                         as Lifnr,
      hdr.zamcf                                                         as Zamcf,

      cast(
        concat(
          substring( cast( hdr.zamcf as abap.char(6) ), 5, 2 ),
          concat(
            '/',
            substring( cast( hdr.zamcf as abap.char(6) ), 1, 4 )
          )
        ) as abap.char(7)
      )                                                                 as ZamcfFmt,

      hdr.waerk                                                         as Waerk,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.ztotfs                                                        as Ztotfs,

      cast(
        case
          when hdr.ztotfs > 0 then 'FATTURA'
          else 'NOTA DEBITO'
        end
        as abap.char(15)
      )                                                                 as TipoDoc,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimprv                                                        as Zimprv,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimran                                                        as Zimran,

      hdr.mwskz                                                         as Mwskz,
      hdr.kalsm                                                         as Kalsm,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimiva                                                        as Zimiva,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimena                                                        as Zimena,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zibcef                                                        as Zibcef,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimprac                                                       as Zimprac,

      hdr.qproz                                                         as Qproz,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimrac                                                        as Zimrac,


      hdr.qsatz                                                         as Qsatz,
      hdr.belnr                                                         as Belnr,
      hdr.bldat                                                         as Bldat,

      case
        when hdr.bldat = '00000000' then ''
        else cast(
          concat(
            concat(
              substring( cast( hdr.bldat as abap.char(8) ), 7, 2 ),
              '/'
            ),
            concat(
              substring( cast( hdr.bldat as abap.char(8) ), 5, 2 ),
              concat(
                '/',
                substring( cast( hdr.bldat as abap.char(8) ), 1, 4 )
              )
            )
          ) as abap.char(10)
        )
      end                                                               as BldatFmt,

      hdr.budat                                                         as Budat,
      hdr.zcont                                                         as Zcont,
      hdr.zrich                                                         as Zrich,
      hdr.zanticipo                                                     as Zanticipo,
      hdr.zcdaz                                                         as Zcdaz,
      hdr.name1                                                         as Name1,
      hdr.znzag                                                         as Znzag,
      hdr.cbdat                                                         as Cbdat,
      hdr.zuonr                                                         as Zuonr,
      hdr.zwaer                                                         as Zwaer,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.ztotfssf                                                      as Ztotfssf,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.zimprvsf                                                      as Zimprvsf,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.zimransf                                                      as Zimransf,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.zimprvsfc                                                     as Zimprvsfc,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.zimransfc                                                     as Zimransfc,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.zimenavsc                                                     as Zimenavsc,

      @Semantics.amount.currencyCode: 'Zwaer'
      hdr.ztotfssfc                                                     as Ztotfssfc,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimpfat                                                       as Zimpfat,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimpfatvs                                                     as Zimpfatvs,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimpfatvsc                                                    as Zimpfatvsc,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimpfondo                                                     as Zimpfondo,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zenaaccu                                                      as Zenaaccu,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zfndtrat                                                      as Zfndtrat,

      hdr.witht                                                         as Witht,
      hdr.wt_withcd                                                     as WtWithcd,

      @Semantics.amount.currencyCode: 'Waerk'
      hdr.zimpant                                                       as Zimpant,

      hdr.sgtxt                                                         as Sgtxt,
      hdr.ibelnr                                                        as Ibelnr,

      hdr.file_name                                                     as FileName,

      @Semantics.mimeType: true
      hdr.mime_type                                                     as MimeType,

      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
      }
      hdr.attachment                                                    as Attachment,

      @Semantics.amount.currencyCode: 'Waerk'
      sumpos.ZiprvTot                                                   as ZiprvTot,

      @Semantics.amount.currencyCode: 'Waerk'
      cast( get_numeric_value( hdr.zimena ) * -1 as abap.dec( 15, 2 ) ) as ZimenaNeg,

      @Semantics.amount.currencyCode: 'Waerk'
      cast(
        get_numeric_value( sumpos.ZiprvTot ) - get_numeric_value( hdr.zimena )
        as abap.dec( 15, 2 )
      )                                                                 as TotDopoEnasarco,

      @Semantics.amount.currencyCode: 'Waerk'
      cast( get_numeric_value( hdr.zimrac ) * -1 as abap.dec( 15, 2 ) ) as ZimracNeg,

      @Semantics.amount.currencyCode: 'Waerk'
      cast(
        ( get_numeric_value( sumpos.ZiprvTot ) - get_numeric_value( hdr.zimena ) )
        - get_numeric_value( hdr.zimrac )
        as abap.dec( 15, 2 )
      )                                                                 as TotDopoRitenuta,


      @Semantics.amount.currencyCode: 'Waerk'
      cast(
        get_numeric_value( hdr.ztotfs ) - get_numeric_value( hdr.zimrac )
        as abap.dec(15,2)
      )                                                                 as TotaleDocumentoFinale,

      hdr.zpage                                                         as Zpage,
      t001.butxt                                                        as Butxt,
      t001.city                                                         as City,
      t001.post_code                                                    as Post_code,
      concat_with_space(t001.street , t001.house_num, 1 )               as Street,
      t001.land1                                                        as Country,
      t001.region                                                       as Region,
      t001.stceg                                                        as Stceg,
      t001.stcd1                                                        as Stcd1

}
