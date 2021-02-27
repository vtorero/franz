import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Inventario } from '../modelos/inventario';
import { AddInventarioComponent } from './add-inventario/add-inventario.component';
import { EditInventarioComponent } from './edit-inventario/edit-inventario.component';

@Component({
  selector: 'app-inventario',
  templateUrl: './inventario.component.html',
  styleUrls: ['./inventario.component.css']
})
export class InventarioComponent implements OnInit {
  dataSource:any;
  cancela:boolean;
  displayedColumns = ['id','codigo','producto','presentacion','cantidad', 'peso', 'fecha_produccion','fecha_vencimiento','dias'];
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
        data: new Inventario(0,0,0,0,0,0,0,0,0,'','','','','','')
      });
      dialogo1.afterClosed().subscribe(art => {
        if (art != undefined)
          console.log(art);
        this.agregar(art);
        this.renderDataTable();
      });
    }

    agregar(art:Inventario) {
      if (art) {
        this.api.GuardarInventario(art).subscribe(
          data => {
            this.toastr.success(data['messaje']);
          },
          error => { console.log(error) }
        );
        this.renderDataTable();
      }
    }
    abrirEditar(cod:Inventario) {
      console.log(cod);
         const dialogo2 = this.dialog2.open(EditInventarioComponent, {
        data: cod
      });
      dialogo2.afterClosed().subscribe(art => {
        console.log(art);
        if (art != undefined)
          this.editar(art);
        this.renderDataTable();
      });
    }

    editar(art: any) {
      if (art) {
        this.api.EditarInventario(art).subscribe(
          data => {
            this.toastr.success(data['messaje']);
          },
          erro => { console.log(erro) }
        );
      }
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



  cancelar(){
  
    this.dialog.closeAll();
    
  }

}
