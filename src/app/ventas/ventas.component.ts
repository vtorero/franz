import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { DetalleVenta } from '../modelos/detalleVenta';
import { Venta } from '../modelos/ventas';
import { AgregarventaComponent } from './agregarventa/agregarventa.component';

@Component({
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.css']
})
export class VentasComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' },{ id:'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta(0,0,0,'',0,0);
  cancela: boolean = false;
  displayedColumns = ['id', 'id_usuario','vendedor', 'estado','comprobante','fecha','valor_total','opciones'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    public dialog2: MatDialog,
    public dialogo: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }
  renderDataTable() {
    this.api.getApi('ventas').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }
  ngOnInit() {
    this.renderDataTable();
  }

  agregarVenta(){
    const dialogo1 = this.dialog.open(AgregarventaComponent, {
      data: new Venta(0,'',0,0,0,'',this.startDate,0,[])
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        //this.agregar(art);
      this.renderDataTable();
    });
  }

}
