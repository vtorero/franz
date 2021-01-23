import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';

@Component({
  selector: 'app-clientes',
  templateUrl: './clientes.component.html',
  styleUrls: ['./clientes.component.css']
})
export class ClientesComponent implements OnInit {
  dataSource:any;
  datos:any;
  cancela:boolean;
  displayedColumns = ['num_documento','nombre','apellido','direccion','telefono','opciones'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(
    private api: ApiService, public dialog: MatDialog, public dialog2: MatDialog, public dialogo: MatDialog, private toastr: ToastrService
    ) { }

    applyFilter(filterValue: string) {
      filterValue = filterValue.trim(); 
      filterValue = filterValue.toLowerCase(); 
      this.dataSource.filter = filterValue;
  }
  
  renderDataTable() {
    this.api.getApi('clientes').subscribe(x => {
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

  abrirDialog(templateRef,cod) {
    console.log("dataaa",cod)
    let dialogRef = this.dialog.open(templateRef, {
        width: '600px' });
  
    dialogRef.afterClosed().subscribe(result => {
      if(!this.cancela){
        if(cod){
          this.api.EliminarCategoria(cod).subscribe(
            data=>{
              console.log(data);
              if(data['STATUS']==true){
            this.toastr.success(data['messaje']);
              }else{
              this.toastr.error(data['messaje']);
              }
            },
            erro=>{console.log(erro)}
              );
          this.renderDataTable();
        }
  
      }
    
  });
  }

}
