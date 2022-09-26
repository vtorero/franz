import { Component, NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { PagoComponent } from './pago/pago.component';
import { GeneralComponent } from './general/general.component';
import {ProductosComponent} from './productos/productos.component';
import { CategoriaComponent } from './productos/categoria/categoria.component';
import {ProveedoresComponent} from './proveedores/proveedores.component';
import { ComprasComponent } from './compras/compras.component';
import { InventarioComponent } from './inventario/inventario.component';
import { AlertComponent } from 'library/angular-admin-lte/src/lib/alert/alert.component';
import { AvisosComponent } from './avisos/avisos.component';
import { AlmacenComponent } from './inventario/almacen/almacen.component';
import { SubcategoriaComponent } from './productos/subcategoria/subcategoria.component';
import { VendedoresComponent } from './vendedores/vendedores.component';
import { VentasComponent } from './ventas/ventas.component';
import { ClientesComponent } from './clientes/personas/clientes.component';
import { EmpresasComponent } from './clientes/empresas/empresas.component';
import { DosimetriaComponent } from './dosimetria/dosimetria.component';
import { MovimientoComponent } from './dosimetria/movimiento/movimiento.component';
import { ResumenComponent } from './inventario/resumen/resumen.component';
import { NotacreditoComponent } from './notacredito/notacredito.component';
import { ResumendComponent } from './dosimetria/resumen/resumend.component';
import { RemisionComponent } from './remision/remision.component';
import { AgregarventaComponent } from './ventas/agregarventa/agregarventa.component';
import { PendientesComponent } from './ventas/pendientes/pendientes.component';
import { ExportarComponent } from './reportes/exportar/exportar.component';


const routes: Routes = [
  {path:'pagos',

  children: [
    {
      path: 'formulario',
      component: PagoComponent
    }
  ]
  },
  {path:'inventario',children:[
    {path:'resumen',
    component:ResumenComponent
    }
  ]},
  {path:'dosimetria',children:[
    {path:'resumen',
    component:ResumendComponent
    }
  ]},
  {path:'notas',children:[
    {path:'credito',
    component:NotacreditoComponent
    }
  ]},
  {path:'remision',children:[
    {path:'listado',
    component:RemisionComponent
    }
  ]},
  {path:'exportar',children:[
    {path:'excel',
    component:ExportarComponent
    }
  ]},

  {path:'general',

    children: [
      {
        path:'pendientes',
        component:PendientesComponent
      },

      {
        path:'inventario',
        component:InventarioComponent
      },
      {
        path:'dosimetria',
        component:DosimetriaComponent
      },
      {
        path:'movimientos',
        component:MovimientoComponent
      },
      {
        path:'almacen',
        component:AlmacenComponent
      },
      {
        path:'alertas',
        component:AvisosComponent
      },
      {
        path:'compras',
        component:ComprasComponent
      },
      {
        path: 'formulario',
        component: GeneralComponent
      },
    {
      path: 'productos',
      component:  ProductosComponent

    },
    {
      path: 'proveedores',
      component:  ProveedoresComponent

    }, {
      path: 'clientes',
      component:  ClientesComponent

    },{
    path: 'empresas',
      component:  EmpresasComponent

    },
    {
      path: 'vendedores',
      component:  VendedoresComponent

    },
    {
      path: 'ventas',
      component:  VentasComponent

    },
    {path:'agregarventa',
    component:AgregarventaComponent}

  ]
  },
  {path:'categorias',component:CategoriaComponent},
  {path:'subcategorias',component:SubcategoriaComponent}
  ,
  {
  path: 'dash',
  data: {
      //title: 'Resultados'
  },
  children: [
    {
      path: 'reportes',
      component: HomeComponent
    }, {
      path: 'accordion',
      loadChildren: './+accordion/accordion.module#AccordionModule',
      data: {
        title: 'Accordion'
      }
    }, {
      path: 'alert',
      loadChildren: './+alert/alert.module#AlertModule',
      data: {
        title: 'Alert',
      }
    }, {
      path: 'layout',
      data: {
        title: 'Layout',
      },
      children: [
        {
          path: 'configuration',
          loadChildren: './+layout/configuration/configuration.module#ConfigurationModule',
          data: {
            title: 'Configuration'
          }
        }, {
          path: 'custom',
          loadChildren: './+layout/custom/custom.module#CustomModule',
          data: {
            title: 'Disable Layout'
            // disableLayout: true
          }
        }, {
          path: 'content',
          loadChildren: './+layout/content/content.module#ContentModule',
          data: {
            title: 'Content'
          }
        }, {
          path: 'header',
          loadChildren: './+layout/header/header.module#HeaderModule',
          data: {
            title: 'Header'
          }
        }, {
          path: 'sidebar-left',
          loadChildren: './+layout/sidebar-left/sidebar-left.module#SidebarLeftModule',
          data: {
            title: 'Sidebar Left'
          }
        }, {
          path: 'sidebar-right',
          loadChildren: './+layout/sidebar-right/sidebar-right.module#SidebarRightModule',
          data: {
            title: 'Sidebar Right'
          }
        },
      ]
    }, {
      path: 'boxs',
      data: {
        title: 'Boxs',
      },
      children: [
        {
          path: 'box',
          loadChildren: './+boxs/box-default/box-default.module#BoxDefaultModule',
          data: {
            title: 'Box'
          }
        }, {
          path: 'info-box',
          loadChildren: './+boxs/box-info/box-info.module#BoxInfoModule',
          data: {
            title: 'Info Box'
          }
        }, {
          path: 'small-box',
          loadChildren: './+boxs/box-small/box-small.module#BoxSmallModule',
          data: {
            title: 'Small Box'
          }
        }
      ]}, {
        path: 'dropdown',
        loadChildren: './+dropdown/dropdown.module#DropdownModule',
        data: {
          title: 'Dropdown',
        }
      }, {
        path: 'tabs',
        loadChildren: './+tabs/tabs.module#TabsModule',
        data: {
          title: 'Tabs',
        }
      }
    ]
  }, {
    path: 'form',
    data: {
      title: 'Form',
    },
    children: [
      {
        path: 'input-text',
        loadChildren: './+form/input-text/input-text.module#InputTextModule',
        data: {
          title: 'Input Text',
        }
      }
    ]
  }, {
    path: '',
    loadChildren: './+login/login.module#LoginModule',
    data: {
      customLayout: true
    }
  }, {
    path: 'register',
    loadChildren: './+register/register.module#RegisterModule',
    data: {
      customLayout: true
    }
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { useHash: true })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
