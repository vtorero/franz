import { Component, Inject, OnInit } from '@angular/core';
import { MatDialog, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Nota } from 'src/app/modelos/Boleta/nota';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { NotaCredito } from 'src/app/modelos/notacredito';
import { Venta } from 'src/app/modelos/ventas';
import { AdditemComponent } from './additem/additem.component';

@Component({
  selector: 'app-addnota',
  templateUrl: './addnota.component.html',
  styleUrls: ['./addnota.component.css']
})
export class AddnotaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal', 'borrar'];
  dataComprobantes = [{ id: 'debito', tipo: 'Nota de Debito' }, { id: 'Credito', tipo: 'Nota de Credito'}];
  dataTipoDocumentos = [{ id: '07', tipo: 'Factura' }, { id: '08', tipo: 'Boleta' }];
  dataVendedores: any;
  dataClientes: any;
  dataClient: any;
  dataEmpresas: any;
  dataProductos: any;
  exampleArray: any[] = [];
  dataProveedor: any;
  dataArray;
  dataSource: any;
  selected: string;
  filter: any;
  constructor(
    private api: ApiService,
    public dialog: MatDialog,
    @Inject(MAT_DIALOG_DATA) public data: NotaCredito,
    dateTimeAdapter: DateTimeAdapter<any>
  ) { dateTimeAdapter.setLocale('es-PE'); }

  radioChange(selected) {
    this.filter = selected.value;
    console.log(this.filter);

  }

  ngOnInit() {
    this.getEmpresas();
    this.getclientes();
  }

  getclientes(): void {
    this.api.getApi('clientes').subscribe(data => {
      if (data) {
        this.dataClientes = data;
      }
    });
  }

  getEmpresas(): void {
    this.api.getApi('empresas').subscribe(data => {
      if (data) {
        this.dataEmpresas = data;
      }
    });
  }

  onKeyCliente(value) {
    this.dataArray = [];
    this.SearchCliente(value);
  }
  SearchCliente(value: string) {
    let criterio;
    if (value) {
      criterio = "/" + value
    } else {
      criterio ='';
    }
    console.log(value)
    this.api.getSelectApi('clientes', criterio).subscribe(data => {
      if (data) {
        this.dataClientes = data;
      }
    });
  }
  onKeyRuc(value) {
    this.dataArray = [];
    this.SearchRuc(value);
  }
  SearchRuc(value: string) {
    let criterio;
    if (value) {
      criterio = "/" + value
    } else {
      criterio ='';
    }
    console.log(value)
    this.api.getSelectApi('empresas', criterio).subscribe(data => {
      if (data) {
        this.dataEmpresas = data;
      }
    });
  }

  abrirDialog() {
    const dialogo1 = this.dialog.open(AdditemComponent, {
    data: new DetalleVenta('','','',0,0,0,0,0,0,0,0,0,0,0,'')
    });
    dialogo1.afterClosed().subscribe(art => {
      console.log(art);
      if (art)
        this.exampleArray.push(art)
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = this.exampleArray;
      this.data.detalleVenta = this.exampleArray;
      console.log(this.data.detalleVenta)
    });
  }

}
