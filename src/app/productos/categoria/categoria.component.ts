import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { Categoria } from '../../modelos/categoria';
import { MatDialog } from '@angular/material';
import { ToastrService } from 'ngx-toastr';


@Component({
  selector: 'app-categoria',
  templateUrl: './categoria.component.html',
  styleUrls: []
})
@NgModule({
  imports: [BrowserModule,MatPaginatorModule,MatDialog,
  ]
})

export class CategoriaComponent implements OnInit {
  dataSource:any;
  cancela:boolean=false;
  displayedColumns = ['codigo','nombre','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  datos: Categoria = new Categoria('');
  constructor(private api:ApiService,public dialog: MatDialog,private toastr: ToastrService) {}
  
  renderDataTable() {  
    this.toastr.error('Hello world!', 'Toastr fun!');
    this.api.getCategorias().subscribe(x => {  
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

addCategoria(cate:any){
this.agregar(cate);
  this.renderDataTable();
}

agregar(art: Categoria) {
  console.log(art);
  if(art){
  this.api.GuardarCategoria(art).subscribe(
    data=>{
      //this.show=true;
      //this.mensaje=data['messaje'];
      //console.log(this.show)
      },
    erro=>{console.log(erro)}
      );
  this.renderDataTable();
}
}
cancelar(){
  this.dialog.closeAll();
  this.cancela=true;

}
abrirDialog(templateRef,cod) {
  let dialogRef = this.dialog.open(templateRef, {
      width: '600px' });

  dialogRef.afterClosed().subscribe(result => {
    if(!this.cancela){
      if(cod){
        this.api.EliminarCategoria(cod).subscribe(
          data=>{
          },
          erro=>{console.log(erro)}
            );
        this.renderDataTable();
      }

    }
  
});
}

  ngOnInit() {
    this.renderDataTable();  
  }

}
