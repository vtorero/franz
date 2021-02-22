export const adminLteConf = {
  skin: 'blue',
  // isSidebarLeftCollapsed: false,
  // isSidebarLeftExpandOnOver: false,
  // isSidebarLeftMouseOver: false,
  // isSidebarLeftMini: true,
   sidebarRightSkin: 'dark',
  // isSidebarRightCollapsed: true,
  // isSidebarRightOverContent: true,
  // layout: 'normal',
  sidebarLeftMenu: [
    {label: 'MENU', separator: true},
    {label: 'Inventarios',iconClasses: 'fa fa-edit',children:[
      {label:'Almacen',iconClasses: 'fa fa-table',route: 'general/almacen'},  
      {label:'Vencimiento',iconClasses: 'fa fa-table',route: 'general/inventario'},
      {label:'Resumenes',iconClasses: 'fa fa-table',route: 'inventario/resumen'}
    ]},
    {label:'Dosimetria',iconClasses: 'fa fa-table',children:[
      {label:'Insumos',iconClasses: 'fa fa-table',route: 'general/dosimetria'},
      {label:'Movimientos',iconClasses: 'fa fa-table',route: 'general/movimientos'}
    ]},  
    {label: 'Productos',iconClasses: 'fa fa-tasks',children:[
    {label: 'Listado', route: 'general/productos'},  
    {label: 'Categorias', route: 'categorias'},
    {label: 'Subcategorias', route: 'subcategorias'},
      
    ]}, 
    {label: 'Compras',iconClasses:'fa fa-tasks',children:[
      {label: 'Listado de compras', route: 'general/compras'},  
      {label: 'Proveedores', route: 'general/proveedores'},  

    ]},
    {label: 'Vendedores',iconClasses: 'fa fa-tasks',children:[
      {label: 'Mantenimiento', route: 'general/vendedores'}
    ]},  
    {label: 'Clientes',iconClasses: 'fa fa-files-o',children:[
      {label: 'Personas (DNI)', route: 'general/clientes'},
      {label: 'Empresas (RUC)', route: 'general/empresas'}
    ]},
    {label: 'Ventas',iconClasses: 'fa fa-files-o',children:[
      {label: 'Listado', route: 'general/ventas'}
    ]},
    {label: 'Reportes',iconClasses: 'fa fa-files-o',children:[
      {label: 'Productos', route: 'dash/reportes'}
    ]},
     /*
    {label: 'Dashboard', route: '/dash', iconClasses: 'fa fa-dashboard'},
   {label: 'Datos Bancarios', route: 'pagos/formulario',iconClasses: 'fa fa-money'},
    {label: 'Configuración', iconClasses: 'fa fa-th-list', children: [
      {label: 'General', route: 'general/formulario'},  
      {label: 'Datos Bancarios', route: 'pagos/formulario'},
        
      ]}*/
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
