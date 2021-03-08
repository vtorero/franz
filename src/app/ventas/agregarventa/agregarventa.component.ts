import { Component, Inject, NgModule, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatPaginatorModule, MatSort, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { BrowserModule } from '@angular/platform-browser';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { Venta } from 'src/app/modelos/ventas';
import { AddProductoComponent } from './add-producto/add-producto.component';
import { Global } from 'src/app/global';
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
  selector: 'app-agregarventa',
  templateUrl: './agregarventa.component.html',
  styleUrls: ['./agregarventa.component.css']
})


@NgModule({
  imports: [BrowserModule,OwlDateTimeModule, OwlNativeDateTimeModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})
export class AgregarventaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal', 'borrar'];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Pendiente', tipo: 'Pendiente' }];
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
  valor_neto:number=0;
  monto_igv:number=0;
  valor_total:number=0;
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
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

  change(event)
    {
     console.log(event);
    if(event.source){
      this.data.cliente.push(event.source.value);  
  }
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
    this.data.id_vendedor=0;
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
      data: new DetalleVenta('','','',0,0,0,0,0,0,0,0,0,0,0,''),
      disableClose:true
    });
    dialogo1.afterClosed().subscribe(art => {
    console.log("art",art)
    console.log(art.cantidad*art.mtoValorUnitario)
    this.valor_neto=this.valor_neto+(art.cantidad*art.mtoValorUnitario);  
    this.monto_igv=this.monto_igv+(art.cantidad*art.mtoValorUnitario) * Global.BASE_IGV;  
    this.valor_total=this.valor_neto+this.monto_igv;
      if (art)
       this.exampleArray.push(art)
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = this.exampleArray;
      this.data.detalleVenta = this.exampleArray;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    });
  }

  ngOnInit() {
    this.valor_neto=0;
    this.monto_igv=0;
    this.valor_total=0;
    this.getVendedores();
    this.getclientes();
    this.getEmpresas();
  }
  deleteTicket(rowid,obj) {
    console.log(obj)
    if (rowid > -1) {
      this.valor_neto=this.valor_neto-(obj.cantidad*obj.mtoValorUnitario);  
      this.monto_igv=this.monto_igv-(obj.cantidad*obj.mtoValorUnitario) * Global.BASE_IGV;  
      this.valor_total=this.valor_neto+this.monto_igv;

      this.data.detalleVenta.splice(rowid, 1);
      this.dataSource = new MatTableDataSource(this.data.detalleVenta);
    }
  }


  cancelar() {
    this.dialog.closeAll();

  }


}
