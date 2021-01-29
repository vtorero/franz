import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Boleta } from '../modelos/boleta';
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
  detalleVenta: DetalleVenta = new DetalleVenta(0,0,0,'',0,0,0);
  boleta:Boleta = new Boleta('','','','','','',[],[],0,0,0,0,0,'',[],[]);
  cancela: boolean = false;
  displayedColumns = ['id', 'usuario','vendedor','cliente','estado','comprobante','fecha','valor_total','opciones'];
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

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim(); 
    filterValue = filterValue.toLowerCase(); 
    this.dataSource.filter = filterValue;
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
      data: new Venta(0,localStorage.getItem("currentId"),0,0,0,'','',0,[])
    });
    dialogo1.afterClosed().subscribe(art => {
      console.log(art);
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }

  agregar(art:Venta) {
    console.log(art);
    if(art.comprobante=='Boleta'){
      

    }

    if (art) {
      this.api.GuardarVenta(art).subscribe(
        data => {
          this.toastr.success(data['messaje']);
        },
        error => { console.log(error) }
      );
      this.renderDataTable();
    }
  }


cancelar(){
   this.dialog.closeAll();
  this.cancela=true;
}


}
