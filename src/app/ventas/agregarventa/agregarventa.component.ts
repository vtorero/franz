import { Component, Inject, NgModule, OnInit } from '@angular/core';
import { MatDialog, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { Venta } from 'src/app/modelos/ventas';
import { AddProductoComponent } from './add-producto/add-producto.component';
import { BrowserModule } from '@angular/platform-browser';

@Component({
  selector: 'app-agregarventa',
  templateUrl: './agregarventa.component.html',
  styleUrls: ['./agregarventa.component.css']
})

@NgModule({
  imports: [OwlDateTimeModule, OwlNativeDateTimeModule, BrowserModule, MatPaginatorModule],
  providers: [{ provide: OWL_DATE_TIME_FORMATS, useValue: { useUtc: true } },]
})
export class AgregarventaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio', 'borrar'];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  dataVendedores: any;
  dataClientes: any;
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
    @Inject(MAT_DIALOG_DATA) public data: Venta,
    dateTimeAdapter: DateTimeAdapter<any>
  ) { dateTimeAdapter.setLocale('es-PE'); }

  getVendedores(): void {
    this.api.getApi('vendedores').subscribe(data => {
      if (data) {
        this.dataVendedores = data;
      }
    });
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

  radioChange(selected) {
    this.filter = selected.value;
    console.log(this.filter);

  }

  onKeyVendedor(value) {
    this.dataArray = [];
    this.selectSearch(value);
  }
  selectSearch(value: string) {
    this.api.getSelectApi('vendedor', value).subscribe(data => {
      if (data) {
        this.dataVendedores = data;
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

  clienteNuevo(value) {
    console.log("check", value.target.checked);

  }

  abrirDialog() {
    const dialogo1 = this.dialog.open(AddProductoComponent, {
      data: new DetalleVenta(0, 0, 0, '', 0, 0, 0)
    });
    dialogo1.afterClosed().subscribe(art => {
      console.log("art", art)
      if (art != undefined)
        this.exampleArray.push(art)
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = this.exampleArray;
      this.data.detalleVenta = this.exampleArray;
    });
  }
  ngOnInit() {
    this.getVendedores();
    this.getclientes();
    this.getEmpresas();
  }
  deleteTicket(rowid: number) {
    if (rowid > -1) {
      this.data.detalleVenta.splice(rowid, 1);
      this.dataSource = new MatTableDataSource(this.data.detalleVenta);
    }
  }

  cancelar() {
    this.dialog.closeAll();
  }


}
