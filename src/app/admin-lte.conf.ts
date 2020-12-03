export const adminLteConf = {
  skin: 'blue',
  // isSidebarLeftCollapsed: false,
  // isSidebarLeftExpandOnOver: false,
  // isSidebarLeftMouseOver: false,
  // isSidebarLeftMini: true,
  // sidebarRightSkin: 'dark',
  // isSidebarRightCollapsed: true,
  // isSidebarRightOverContent: true,
  // layout: 'normal',
  sidebarLeftMenu: [
    {label: 'OPCIONES PRINCIPALES', separator: true},
    {label: 'Dashboard', route: '/dash', iconClasses: 'fa fa-dashboard'},
    {label: 'Datos generales', route: 'general/formulario',iconClasses: 'fa fa-tasks'},  
    {label: 'Datos Bancarios', route: 'pagos/formulario',iconClasses: 'fa fa-money'},
    /*{label: 'Configuración', iconClasses: 'fa fa-th-list', children: [
      {label: 'General', route: 'general/formulario'},  
      {label: 'Datos Bancarios', route: 'pagos/formulario'},
        
      ]},
    /*{label: 'COMPONENTS', separator: true},
     pullRights: [{text: 'New', classes: 'label pull-right bg-green'}
    {label: 'Accordion', route: 'accordion', iconClasses: 'fa fa-tasks'},
    {label: 'Alert', route: 'alert', iconClasses: 'fa fa-exclamation-triangle'},
    {label: 'Boxs', iconClasses: 'fa fa-files-o', children: [
        {label: 'Default Box', route: 'boxs/box'},
        {label: 'Info Box', route: 'boxs/info-box'},
        {label: 'Small Box', route: 'boxs/small-box'}
      ]},
    {label: 'Dropdown', route: 'dropdown', iconClasses: 'fa fa-arrows-v'},
    {label: 'Form', iconClasses: 'fa fa-files-o', children: [
        {label: 'Input Text', route: 'form/input-text'}
    ]},
    {label: 'Tabs', route: 'tabs', iconClasses: 'fa fa-th'}*/  ]
};
