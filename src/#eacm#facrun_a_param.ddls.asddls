@EndUserText.label: 'Gen. facsimili - parametri di selezione'
define root abstract entity /EACM/FACRUN_A_PARAM
  //  with parameters parameter_name : parameter_type
{
  @Consumption.filter: {
        mandatory: true,
      selectionType: #SINGLE
  }
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: '/EACM/I_FACRUN_DATE_VH',
        element: 'Competence'
      },
      useForValidation: true
    }
  ]
  Zamcf : /eacm/zamcf;
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: '/EACM/I_FACRUN_DATE_VH',
        element: 'CalendarDate'
      },
      useForValidation: true
    }
  ]
  Bldat : bldat;
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: '/EACM/C_T001',
        element: 'Bukrs'
      },
      useForValidation: true
    }
  ]
  Bukrs : bukrs;
  @Consumption.valueHelpDefinition: [{ entity:
  {name : '/EACM/C_TVKO' , element: 'Vkorg' },
  distinctValues: true
  }]
  Vkorg : vkorg;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/C_TVTW', element: 'Vtweg' },
    useForValidation: true }]
  Vtweg : vtweg;
  @Consumption.valueHelpDefinition: [{ entity: {name: '/EACM/C_Zpr08', element: 'Zclpr' }, useForValidation: true }]
  Zclpr : /eacm/zclpr;
  @Consumption.valueHelpDefinition: [{ entity: {name: '/EACM/C_ZPRAA', element: 'Zcdaz' }, useForValidation: true }]
  Zcdaz : /eacm/zcdaz;
  //  Waerk : /eacm/prim_i_run-Waerk;

}
