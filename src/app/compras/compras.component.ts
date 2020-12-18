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
  dataComprobantes=[ {id:1,tipo:'Factura'}, {id:2,tipo:'Boleta'}];
  startDate:Date = new Date()
  cancela:boolean=false;
  displayedColumns = ['comprobante','num_comprobante','descripcion','fecha','razon_social','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService,
    public dialog:MatDialog,
    public dialogo:MatDialog,
    private toastr: ToastrService) {
 

   }
   

  ngOnInit() {
    this.renderDataTable()
  }

  abrirDialogo() {
    
    const dialogo1 = this.dialog.open(AddCompraComponent, {
      data: new Compra('', '', '',this.startDate,'','','')
    });
     dialogo1.afterClosed().subscribe(art => {
       if (art!= undefined)
       console.log(art);
   //  this.agregar(art);
      });
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

}
