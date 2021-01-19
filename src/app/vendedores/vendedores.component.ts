import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Vendedor } from '../modelos/vendedor';

@Component({
  selector: 'app-vendedores',
  templateUrl: './vendedores.component.html',
  styleUrls: ['./vendedores.component.css']
})
export class VendedoresComponent implements OnInit {
  dataSource: any;
  dataCategoria: any;
  data: any;
  cancela: boolean = false;
  displayedColumns = ['id', 'nombre', 'apellidos', 'dni', 'razon_social', 'ruc', 'opciones'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  datos: Vendedor = new Vendedor(0, '', '', '', '', '', '');
  constructor(private api: ApiService, public dialog: MatDialog, private toastr: ToastrService) { }
  renderDataTable() {

    this.api.getApi('vendedores').subscribe(x => {
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
  cancelar() {
    this.dialog.closeAll();
    this.cancela = true;

  }
  agregar(art:any) {
    console.log(art);
    if(art){
    this.api.GuardarVendedor(art).subscribe(
      data=>{
        console.log(data);
        this.toastr.success('Aviso', data['messaje']);
        },
      erro=>{console.log(erro)}
        );
    this.dialog.closeAll();
    this.renderDataTable();
  }
  }

  abrirDialog(templateRef, cod) {
    console.log("data", cod)
    let dialogRef = this.dialog.open(templateRef, {
      width: '500px'
    });
    dialogRef.afterClosed().subscribe(result => {
      if (!this.cancela) {
        if (cod) {
          this.api.EliminarVendedor(cod).subscribe(
            data => {
              console.log(data);
              if (data['STATUS'] == true) {
                this.toastr.success(data['messaje']);
              } else {
                this.toastr.error(data['messaje']);
              }
            },
            erro => { console.log(erro) }
          );
          this.renderDataTable();
        }

      }

    });
  }


}
