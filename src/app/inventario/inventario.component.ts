import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Inventario } from '../modelos/inventario';
import { AddInventarioComponent } from './add-inventario/add-inventario.component';

@Component({
  selector: 'app-inventario',
  templateUrl: './inventario.component.html',
  styles: []
})
export class InventarioComponent implements OnInit {
  dataSource:any;
  displayedColumns = ['producto', 'cantidad', 'fecha_produccion', 'estado','ciclo', 'operaciones'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    public dialog2: MatDialog,
    public dialogo: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) { 

    }

    applyFilter(filterValue: string) {
      filterValue = filterValue.trim();
      filterValue = filterValue.toLowerCase();
      this.dataSource.filter = filterValue;
    }

    abrirDialogo() {
      const dialogo1 = this.dialog.open(AddInventarioComponent, {
        data: new Inventario(0, 0,'','', 0, '','', 0, 0, 0, '')
      });
      dialogo1.afterClosed().subscribe(art => {
        if (art != undefined)
          console.log(art);
        //this.agregar(art);
        this.renderDataTable();
      });
    }

  ngOnInit() {
    this.renderDataTable()
  }
  renderDataTable() {
    this.api.getApi('inventarios').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

}
