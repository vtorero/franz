import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Movimiento } from 'src/app/modelos/movimiento';
import { AddDosimetriaComponent } from '../add-dosimetria/add-dosimetria.component';

@Component({
  selector: 'app-movimiento',
  templateUrl: './movimiento.component.html',
  styleUrls: ['./movimiento.component.css']
})
export class MovimientoComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' }];
  startDate: Date = new Date();
  
  cancela: boolean = false;
  displayedColumns = ['codigo', 'descripcion', 'movimiento','unidad','cantidad','fecha_registro','usuario' ,'borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }

  renderDataTable() {
    this.api.getApi('movimientos').subscribe(x => {
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
      console.log(art);
      //  this.agregar(art);
      this.renderDataTable();
    });
  }

  ngOnInit() {
    this,this.renderDataTable();
  }

}