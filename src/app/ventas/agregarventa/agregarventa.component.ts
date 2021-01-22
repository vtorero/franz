import { Component, Inject, OnInit } from '@angular/core';
import { MatDialog, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { Venta } from 'src/app/modelos/ventas';
import { AddProductoComponent } from './add-producto/add-producto.component';

@Component({
  selector: 'app-agregarventa',
  templateUrl: './agregarventa.component.html',
  styleUrls: ['./agregarventa.component.css']
})
export class AgregarventaComponent implements OnInit {
  displayedColumns=['id_producto','nombre','cantidad','peso','precio','borrar'];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' },{ id:'Sin Comprobante', tipo: 'Pendiente' }];
  dataVendedores:any;
  dataClientes:any;
  dataProductos:any;
  exampleArray:any[] = [];
  dataProveedor:any;
  dataArray;
  dataSource:any;
  constructor(
    private api:ApiService,
    public dialog:MatDialog,
    @Inject(MAT_DIALOG_DATA) public data: Venta,

  ) { }

  getVendedores(): void {
    this.api.getApi('vendedores').subscribe(data => {
      if(data) {
        this.dataVendedores = data;
      }
    } );
  }
  getclientes(): void {
    this.api.getApi('clientes').subscribe(data => {
      if(data) {
        this.dataClientes = data;
      }
    } );
  }
  abrirDialog() {
    const dialogo1 = this.dialog.open(AddProductoComponent, {
      data: new DetalleVenta(0,0,0,'',0,0,0)
    });
    dialogo1.afterClosed().subscribe(art => {
      console.log("art",art)
      if (art!= undefined)
      this.exampleArray.push(art)
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = this.exampleArray; 
      this.data.detalleVenta=this.exampleArray;
     });
  }
  ngOnInit() {
    this.getVendedores();
    this.getclientes();
  }
  deleteTicket(rowid: number){
    if (rowid > -1) {
      this.data.detalleVenta.splice(rowid, 1);
      this.dataSource = new MatTableDataSource(this.data.detalleVenta);
  }
  }

}
