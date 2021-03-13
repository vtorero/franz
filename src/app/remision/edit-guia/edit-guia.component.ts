import { Component, Inject, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, MatSort, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { Guia } from 'src/app/modelos/guia';

@Component({
  selector: 'app-edit-guia',
  templateUrl: './edit-guia.component.html',
  styleUrls: ['./edit-guia.component.css']
})
export class EditGuiaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'borrar'];
  dataTipoDocumentos = [{ id: '1', tipo: 'DNI' }, { id:'6',tipo: 'RUC' }];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Pendiente', tipo: 'Pendiente' }];
  dataVendedores: any;
  dataClientes: any;
  dataClient: any;
  dataDetalle: any;
  dataEmpresas: any;
  dataProductos: any;
  exampleArray: any;
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
  constructor(@Inject(MAT_DIALOG_DATA) public data: Guia,
  private api: ApiService,) { }

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


  ngOnInit() {
    this.getEmpresas();
    this.getclientes()
    this.api.getApi('guia_detalle/'+this.data.id).subscribe(x => {  
      this.dataDetalle = new MatTableDataSource();
      this.exampleArray=x;
      this.dataDetalle=this.exampleArray
      this.data.detalleVenta=this.exampleArray; 
  });
  }
}
