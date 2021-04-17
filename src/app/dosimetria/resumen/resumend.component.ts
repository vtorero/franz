import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Movimiento } from 'src/app/modelos/movimiento';
import { AddDosimetriaComponent } from '../add-dosimetria/add-dosimetria.component';
import { TableUtil } from "./tableUtil";

@Component({
  selector: 'app-resumen',
  templateUrl: './resumen.component.html',
  styleUrls: ['./resumen.component.css']
})
export class ResumendComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' }];
  startDate: Date = new Date();
  
  cancela: boolean = false;
  displayedColumns = ['codigo_insumo', 'descripcion','unidad','saldo'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim(); 
    filterValue = filterValue.toLowerCase(); 
    this.dataSource.filter = filterValue;
}
  renderDataTable() {
    this.api.getApi('movresumen').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  abrirDialogo() {
    const dialogo1 = this.dialog.open(AddDosimetriaComponent,{
      data: new Movimiento('','','',0,localStorage.getItem("currentUser")),
      width:'600px'
    });
    dialogo1.afterClosed().subscribe(art => {
      this.agregar(art);
      this.renderDataTable();
    });
  }

  agregar(art:any) {
    console.log(art)
    if (art) {
      this.api.GuardarDosimetriaMov(art).subscribe(
        data => {
          this.toastr.success(data['messaje']);
        },
        error => { console.log(error) }
      );
      this.renderDataTable();
    }
  }

  ngOnInit() {
    this.renderDataTable();

  }

  exportTable(table:string,reporte:string){
    TableUtil.exportToPdf(table,reporte);
  }

}
