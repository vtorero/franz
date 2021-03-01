import { Component, Inject, NgModule, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatPaginatorModule, MatSort, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { NotaCredito } from 'src/app/modelos/notacredito';
import { AdditemComponent } from './additem/additem.component';

export const MY_MOMENT_FORMATS = {
  parseInput: 'l LT',
  fullPickerInput: 'l LT',
  datePickerInput: 'l',
  timePickerInput: 'LT',
  monthYearLabel: 'MM YYYY',
  dateA11yLabel: 'LL',
  monthYearA11yLabel: 'MM YYYY',
};
@Component({
  selector: 'app-addnota',
  templateUrl: './addnota.component.html',
  styleUrls: ['./addnota.component.css']
})

@NgModule({
  imports: [BrowserModule,OwlDateTimeModule, OwlNativeDateTimeModule,MatPaginatorModule,MatDialog],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})

export class AddnotaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal', 'borrar'];
  dataComprobantes = [{ id: '07', tipo: 'Nota de Credito' }, { id: '08', tipo: 'Nota de Debito'}];
  dataTipoDocumentos = [{ id: '01', tipo: 'Factura' }, { id:'03',tipo: 'Boleta' }];
  dataMotivos = [{ id: '01', tipo: 'Anulación de la operación' }, { id: '02', tipo: 'Anulación por error en el RUC'},{id:'07',tipo:'Devolución por ítem'}];
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
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(
    private api: ApiService,
    public dialog: MatDialog,
    @Inject(MAT_DIALOG_DATA) public data: NotaCredito,
    
  ) {  }

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
      this.dataSource.paginator = this.paginator;  
      console.log(this.data.detalleVenta)
    });
  }


  cancelar() {
    this.dialog.closeAll();
  }


}
