import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';
import { AddInventarioComponent } from '../add-inventario/add-inventario.component';
import { EditInventarioComponent } from '../edit-inventario/edit-inventario.component';

@Component({
  selector: 'app-almacen',
  templateUrl: './almacen.component.html',
  styleUrls: ['./almacen.component.css']
})
export class AlmacenComponent implements OnInit {
dataSource:any;
cancela: boolean = false;
displayedColumns = ['id_producto','codigo', 'nombre', 'cantidad','fecha_produccion','fecha_vencimiento','operaciones'];
@ViewChild(MatSort) sort: MatSort;
@ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    public dialogo: MatDialog,
    private toastr: ToastrService,
    public dialog2: MatDialog,
    dateTimeAdapter: DateTimeAdapter<any>) { }

    applyFilter(filterValue: string) {
      filterValue = filterValue.trim(); 
      filterValue = filterValue.toLowerCase(); 
      this.dataSource.filter = filterValue;
  }

  renderDataTable() {
    this.api.getApi('almacen').subscribe(x => {
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
    const dialogo1 = this.dialog.open(AddInventarioComponent, {
      data: new Inventario(0,0,0,0,0,0,0,0,0,'','','','','')
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        console.log(art);
      this.agregar(art);
      this.renderDataTable();
    });
  }
  ngOnInit() {
    this.renderDataTable()
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
  abrirDialog(templateRef,cod) {
    let dialogRef = this.dialogo.open(templateRef, {
   width: '500px' });

 dialogRef.afterClosed().subscribe(result => {
 if(!this.cancela){
     if(cod){
     this.api.EliminarAlmacen(cod).subscribe(
       data=>{
       this.toastr.success(data['messaje']);
       },
       erro=>{console.log(erro)}
         );
     this.renderDataTable();
   }

 }

});
}

}
