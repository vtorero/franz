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
  styleUrls: ['./categoria.component.css']
})
@NgModule({
  imports: [BrowserModule,MatPaginatorModule,MatDialog,
  ]
})

export class CategoriaComponent implements OnInit {
  dataSource:any;
  data:any;
  cancela:boolean=false;
  displayedColumns = ['codigo','nombre','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  datos: Categoria = new Categoria('');
  constructor(private api:ApiService,public dialog: MatDialog,private toastr: ToastrService) {}
  
  renderDataTable() {  
   
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
      console.log(data);
      this.toastr.success('Aviso', data['messaje']);
      },
    erro=>{console.log(erro)}
      );
  this.dialog.closeAll();
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

  ngOnInit() {
    this.renderDataTable();  
  }

}
