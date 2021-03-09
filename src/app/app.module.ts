import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import {HttpClientModule} from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import {MatInputModule} from '@angular/material/input';
import {MatButtonModule} from '@angular/material/button';
import {MatCardModule} from '@angular/material/card';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatCheckboxModule} from '@angular/material/checkbox';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatRadioModule} from '@angular/material/radio';
import {MatSelectModule} from '@angular/material/select';
import { adminLteConf } from './admin-lte.conf';
import { AppRoutingModule } from './app-routing.module';
import { CoreModule } from './core/core.module';
import { LayoutModule, AlertModule } from 'angular-admin-lte';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { LoadingPageModule, MaterialBarModule } from 'angular-loading-page';
import { BoxModule, BoxInfoModule as MkBoxInfoModule } from 'angular-admin-lte';
import { MatNativeDateModule } from '@angular/material/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { OwlDateTimeModule, OwlNativeDateTimeModule } from 'ng-pick-datetime';
import {MatPaginatorModule, MatPaginatorIntl} from '@angular/material/paginator';
import {MatTableModule} from '@angular/material/table';
import { MatSortModule } from '@angular/material/sort';
import { PagoComponent } from './pago/pago.component';
import { GeneralComponent } from './general/general.component';
import { PaginatorEspañol } from './modelos/paginator-espanol';
import { AlertModule as MkAlertModule } from 'angular-admin-lte';
import { ProductosComponent } from './productos/productos.component';
import { DialogoarticuloComponent } from './productos/AddProducto/AddProducto.component';
import { MatDialogModule } from '@angular/material/dialog';
import { CategoriaComponent } from './productos/categoria/categoria.component';
import { ToastrModule } from 'ngx-toastr';
import { CommonModule, DatePipe } from '@angular/common';
import { EditarProductoComponent } from './productos/editar-producto/editar-producto.component';
import { ProveedoresComponent } from './proveedores/proveedores.component';
import { AddProveedorComponent } from './proveedores/add-proveedor/add-proveedor.component';
import { ComprasComponent } from './compras/compras.component';
import { AddCompraComponent } from './compras/add-compra/add-compra.component';
import { AddDetalleComponent } from './compras/add-compra/addDetalle.component';
import { EditCompraComponent } from './compras/edit-compra/edit-compra.component';
import { InventarioComponent } from './inventario/inventario.component';
import { AddInventarioComponent } from './inventario/add-inventario/add-inventario.component';
import { EditInventarioComponent } from './inventario/edit-inventario/edit-inventario.component';
import { AvisosComponent } from './avisos/avisos.component';
import { AlmacenComponent } from './inventario/almacen/almacen.component';
import { SubcategoriaComponent } from './productos/subcategoria/subcategoria.component';
import { VendedoresComponent } from './vendedores/vendedores.component';
import { VentasComponent } from './ventas/ventas.component';
import { AgregarventaComponent } from './ventas/agregarventa/agregarventa.component';
import { AddProductoComponent } from './ventas/agregarventa/add-producto/add-producto.component';
import { ClientesComponent } from './clientes/personas/clientes.component';
import { EmpresasComponent } from './clientes/empresas/empresas.component';
import { AddEmpresaComponent } from './clientes/empresas/add-empresa/add-empresa.component';
import { EditClienteComponent } from './clientes/personas/edit-cliente/edit-cliente.component';
import { EditarVentaComponent } from './ventas/editar-venta/editar-venta.component';
import { EditEmpresaComponent } from './clientes/empresas/edit-empresa/edit-empresa.component';
import { DosimetriaComponent } from './dosimetria/dosimetria.component';
import { AddDosimetriaComponent } from './dosimetria/add-dosimetria/add-dosimetria.component';
import { MovimientoComponent } from './dosimetria/movimiento/movimiento.component';
import { AddInsumoComponent } from './dosimetria/add-insumo/add-insumo.component';
import { ResumenComponent } from './inventario/resumen/resumen.component';
import { NotacreditoComponent } from './notacredito/notacredito.component';
import { AddnotaComponent } from './notacredito/addnota/addnota.component';
import { AdditemComponent } from './notacredito/addnota/additem/additem.component';
import { ResumendComponent } from './dosimetria/resumen/resumend.component';
import { VernotaComponent } from './notacredito/vernota/vernota.component';
import { RemisionComponent } from './remision/remision.component';




@NgModule({
  imports: [
    BrowserModule,OwlDateTimeModule, OwlNativeDateTimeModule,
    AppRoutingModule,
    CoreModule,
    LayoutModule.forRoot(adminLteConf),
    LoadingPageModule, MaterialBarModule,HttpClientModule,
    BoxModule,
    MkBoxInfoModule,
    FormsModule,MatPaginatorModule,MatTableModule,
    MatDatepickerModule,BrowserAnimationsModule,
    MatInputModule,MatButtonModule,MatCardModule,MatFormFieldModule,MatCheckboxModule,MatRadioModule,MatSelectModule,MatNativeDateModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatInputModule,
    MatInputModule,
    MatButtonModule,
    MatDialogModule,
    MatDatepickerModule,
    MkAlertModule,AlertModule,
    CommonModule,
    BrowserAnimationsModule, // required animations module
    ToastrModule.forRoot()
 
  ],
  providers:[{ provide: MatPaginatorIntl, useClass: PaginatorEspañol}]
  ,
  entryComponents: 
  [DialogoarticuloComponent,
    ProductosComponent,
    EditarProductoComponent,
    AddProveedorComponent,
    AddCompraComponent,
    EditCompraComponent,
    AddDetalleComponent,
    EditInventarioComponent,
    AddInventarioComponent,
    AgregarventaComponent,
    AddProductoComponent,
    AddEmpresaComponent,
    ClientesComponent,
    EditClienteComponent,
    EditarVentaComponent,
  EditEmpresaComponent,
  AddDosimetriaComponent,
  AddInsumoComponent,
  AddnotaComponent,
  AdditemComponent,
VernotaComponent],
  declarations: [
    AppComponent,
    PagoComponent,
    HomeComponent,
    GeneralComponent,
    ProductosComponent,
    CategoriaComponent,
    DialogoarticuloComponent,
    CategoriaComponent,
    EditarProductoComponent,
    ProveedoresComponent,
    AddProveedorComponent,
    ComprasComponent,
    AddCompraComponent,
    AddDetalleComponent,
    EditCompraComponent,
    InventarioComponent,
    AddInventarioComponent,
    EditInventarioComponent,
    AvisosComponent,
    AlmacenComponent,
    SubcategoriaComponent,
    VendedoresComponent,
    VentasComponent,
    AgregarventaComponent,
    AddProductoComponent,
    ClientesComponent,
    EmpresasComponent,
    AddEmpresaComponent,
    EditClienteComponent,
    EditarVentaComponent,
    EditEmpresaComponent,
    DosimetriaComponent,
    AddDosimetriaComponent,
    MovimientoComponent,
    AddInsumoComponent,
    ResumenComponent,
    ResumendComponent,
    NotacreditoComponent,
    AddnotaComponent,
    AdditemComponent,
    VernotaComponent,
    RemisionComponent
    ],
  bootstrap: [AppComponent]
})
export class AppModule {}
