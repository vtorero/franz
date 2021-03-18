import { Component, Inject, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { NotaCredito } from 'src/app/modelos/notacredito';

@Component({
  selector: 'app-vernota',
  templateUrl: './vernota.component.html',
  styleUrls: ['./vernota.component.css']
})
export class VernotaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal'];
  dataComprobantes = [{ id: '07', tipo: 'Nota de Credito' }, { id: '08', tipo: 'Nota de Debito'}];
  dataTipoDocumentos = [{ id: '01', tipo: 'Factura' }, { id:'03',tipo: 'Boleta' }];
  dataMotivos = [{ id: '01', tipo: 'Anulación de la operación' }, { id: '02', tipo: 'Anulación por error en el RUC'},{id:'07',tipo:'Devolución por ítem'}];
  dataVendedores: any;
  dataClientes: any;
  dataDetalle:any;
  dataClient: any;
  exampleArray:any;
  dataEmpresas: any;
  dataProductos: any;
  //exampleArray: any[] = [];
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
    @Inject(MAT_DIALOG_DATA) public data: NotaCredito
  ) { }


  ngOnInit() {
    this.api.GetDetalleNota(this.data.id).subscribe(x => {  
     
      this.exampleArray=x;
      this.dataDetalle=this.exampleArray

      this.dataDetalle = new MatTableDataSource();
      this.dataDetalle.data = this.exampleArray;
      this.data.detalleVenta = this.exampleArray;
      this.dataDetalle.paginator = this.paginator;  
      this.data.detalleVenta=this.exampleArray; 
      this.dataDetalle.paginator = this.paginator;  

  
      });

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



  cancelar() {
    this.dialog.closeAll();
  }
}
