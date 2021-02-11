import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../../api.service';
import { Proveedor } from '../../modelos/proveedor';
import { AddEmpresaComponent } from './add-empresa/add-empresa.component';
import { EditEmpresaComponent } from './edit-empresa/edit-empresa.component';

@Component({
  selector: 'app-empresas',
  templateUrl: './empresas.component.html',
  styleUrls: ['./empresas.component.css']
})
export class EmpresasComponent implements OnInit {
  dataSource: any;
  cancela: boolean = false;
  displayedColumns = ['num_documento', 'razon_social', 'departamento','provincia','distrito', 'borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService, public dialog: MatDialog, public dialog2: MatDialog, public dialogo: MatDialog, private toastr: ToastrService) { }

  renderDataTable() {
    this.api.getApi('empresas').subscribe(x => {
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
          this.api.EliminarEmpresa(cod).subscribe(
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
    const dialogo1 = this.dialog.open(AddEmpresaComponent, {
      data: new Proveedor('', '','', '','','','','','')
    });
     dialogo1.afterClosed().subscribe(art => {
       if (art!= undefined)
       this.agregar(art);
      }
      );
  }

  agregar(art: Proveedor) {
    if(art){
    this.api.GuardarEmpresa(art).subscribe(
      data=>{
        this.toastr.success(data['messaje']);
        },
      erro=>{console.log(erro['messaje'])}
        );
      this.renderDataTable();
  }
}

abrirEditar(cod: Proveedor) {
  console.log("compra",cod)
  const dialogo2 = this.dialog2.open(EditEmpresaComponent, {
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
    this.api.EditarEmpresa(art).subscribe(
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

}