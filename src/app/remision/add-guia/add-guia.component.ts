import { Component, Inject, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Global } from 'src/app/global';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { Guia } from 'src/app/modelos/guia';
import { AddProductoComponent } from 'src/app/ventas/agregarventa/add-producto/add-producto.component';

@Component({
  selector: 'app-add-guia',
  templateUrl: './add-guia.component.html',
  styleUrls: ['./add-guia.component.css']
})
export class AddGuiaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'borrar'];
  dataTipoDocumentos = [{ id: '1', tipo: 'DNI' }, { id:'6',tipo: 'RUC' }];
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
    @Inject(MAT_DIALOG_DATA) public data: Guia,
    dateTimeAdapter: DateTimeAdapter<any>
  ) { dateTimeAdapter.setLocale('es-PE'); }

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

  change(event)
  {
   console.log(event);
  if(event.source){
    this.data.destinatario.push(event.source.value);  
}
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
    this.getclientes();
    this.getEmpresas();
  }

  cancelar() {
    this.dialog.closeAll();

  }


}
