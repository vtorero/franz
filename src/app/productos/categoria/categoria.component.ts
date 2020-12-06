import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTable, MatTableDataSource } from '@angular/material/table';
import { DialogoarticuloComponent } from '../../dialogoarticulo/dialogoarticulo.component';
import { MatSort } from '@angular/material/sort';
import { Categoria } from '../../modelos/categoria';
import { MatDialog } from '@angular/material';

@Component({
  selector: 'app-categoria',
  templateUrl: './categoria.component.html',
  styles: []
})
@NgModule({
  imports: [BrowserModule,MatPaginatorModule,MatDialog],

})

export class CategoriaComponent implements OnInit {
  dataSource:any;
  cancela:boolean=false;
  displayedColumns = ['codigo','nombre','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService,public dialog: MatDialog) {}


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


  ngOnInit() {
    this.renderDataTable();  

  }

}
