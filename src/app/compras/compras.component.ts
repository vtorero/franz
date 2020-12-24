import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTable, MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { Compra } from '../modelos/compra';
import { MatDialog } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { AddCompraComponent } from './add-compra/add-compra.component';
import { DetalleCompra } from '../modelos/detalleCompra';
import { EditCompraComponent } from './edit-compra/edit-compra.component';

@Component({
  selector: 'app-compras',
  templateUrl: './compras.component.html',
  styles: []
})

@NgModule({
  imports: [BrowserModule,MatPaginatorModule,MatDialog],

})
export class ComprasComponent implements OnInit {
  dataSource:any;
  dataDetalle:any;
  datosprueba:string="prueba";
  dataComprobantes=[ {id:1,tipo:'Factura'}, {id:2,tipo:'Boleta'}];
  startDate:Date = new Date()
  detallecompra:DetalleCompra=new DetalleCompra(0,'',0,0)
  cancela:boolean=false;
  displayedColumns = ['comprobante','num_comprobante','descripcion','fecha','razon_social','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService,
    public dialog:MatDialog,
    public dialog2:MatDialog,
    public dialogo:MatDialog,
    private toastr: ToastrService) {
 

   }
   

  ngOnInit() {
    this.renderDataTable()
  }

  abrirDialogo() {
    
    const dialogo1 = this.dialog.open(AddCompraComponent, {
      data: new Compra(0,'', '', '',this.startDate,'','','',[])
    });
     dialogo1.afterClosed().subscribe(art => {
       if (art!= undefined)
       console.log(art);
     this.agregar(art);
     this.toastr.success( 'Compra registrada');
     this.renderDataTable();
      });
  }

  agregar(art:Compra) {
    if(art){
    this.api.GuardarCompra(art).subscribe(
      data=>{
        this.toastr.success( data['messaje']);
        },
      erro=>{console.log(erro)}
        );
      this.renderDataTable();
  }
}


  renderDataTable() {  
    this.api.getApi('compras').subscribe(x => {  
    this.dataSource = new MatTableDataSource();
    this.dataSource.data = x; 
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;  
  },  
  error => {  
    console.log('Error de conexion de datatable!' + error);  
  });  
  } 

  abrirEditar(cod) {
    console.log("codmanda",cod);
     const dialogo2 = this.dialog2.open(EditCompraComponent,{
      data:cod
    });
    dialogo2.afterClosed().subscribe(art => {
      if (art!= undefined)
      console.log(art);
    this.editar(art);
    //this.toastr.success( 'Compra actualizada');
    this.renderDataTable();
     });  
}

editar(art:Compra) {
  if(art){
  this.api.EditarCompra(art).subscribe(
    data=>{
      this.toastr.success( data['messaje']);
      },
    erro=>{console.log(erro)}
      );
    this.renderDataTable();
}
}


}
