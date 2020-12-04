import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';

@Component({
  selector: 'app-productos',
  templateUrl: './productos.component.html',
  styleUrls: ['./productos.component.css']
})

@NgModule({
  imports: [BrowserModule,MatPaginatorModule],

})

export class ProductosComponent implements OnInit {
  dataSource:any;
  displayedColumns = ['codigo','nombre','costo','IGV','precio_sugerido'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService) {}

  renderDataTable() {  
    this.api.getProductos().subscribe(x => {  
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
    this.api.getProductos().subscribe(data=>{
      console.log(data);
    });
    

  }

}
