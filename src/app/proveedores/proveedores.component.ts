import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Proveedor } from '../modelos/proveedor';
import { AddProveedorComponent } from './add-proveedor/add-proveedor.component';

@Component({
  selector: 'app-proveedores',
  templateUrl: './proveedores.component.html',
  styleUrls: ['./proveedores.component.css']
})
export class ProveedoresComponent implements OnInit {
  dataSource: any;
  cancela: boolean = false;
  displayedColumns = ['num_documento', 'razon_social', 'departamento','provincia','distrito', 'borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService, public dialog: MatDialog, public dialog2: MatDialog, public dialogo: MatDialog, private toastr: ToastrService) { }

  renderDataTable() {
    this.api.getProveedores().subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim();
    filterValue = filterValue.toLowerCase();
    this.dataSource.filter = filterValue;
  }

  cancelar() {
    this.dialog.closeAll();
    this.dialog2.closeAll();
    this.cancela = true;

  }

  abrirDialog(templateRef, cod) {
    let dialogRef = this.dialogo.open(templateRef, {
      width: '550px'
    });

    dialogRef.afterClosed().subscribe(result => {
      if (!this.cancela) {
        if (cod) {
          this.api.EliminarProveedor(cod).subscribe(
            data => {
              this.toastr.success( data['messaje']);
            },
            error => { 
              console.log(error)
              this.toastr.error("Error al eliminar el proveedor");
             }
          );
          this.renderDataTable();
        }

      }

    },
    error=>{
      this.toastr.error( error['messaje']);

    });
  }


  
  abrirDialogo() {
    const dialogo1 = this.dialog.open(AddProveedorComponent, {
      data: new Proveedor('', '','', '','','','','')
    });
     dialogo1.afterClosed().subscribe(art => {
       if (art!= undefined)
     console.log("·");
       this.agregar(art);
      }
      );
  }

  agregar(art: Proveedor) {
    if(art){
    this.api.GuardarProveedor(art).subscribe(
      data=>{
        this.toastr.success('Aviso', data['messaje']);
        },
      erro=>{console.log(erro)}
        );
      this.renderDataTable();
  }
}

  ngOnInit() {
    this.renderDataTable()
  }

}