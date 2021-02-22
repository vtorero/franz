import { Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ApiService } from 'src/app/api.service';

@Component({
  selector: 'app-resumen',
  templateUrl: './resumen.component.html',
  styleUrls: ['./resumen.component.css']
})
export class ResumenComponent implements OnInit {
  dataSource:any;
  dataSourceB:any;
  dataSourceC:any;
  dataSourceD:any;
  datatotal:any;
  datatotalB:any;
  datatotalC:any;
  datatotalD:any;
  displayedColumns = ['id','codigo','producto','granel','merma','cantidad','peso'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(
    private api: ApiService
  ) { }
  applyFilter(filterValue: string) {
    filterValue = filterValue.trim();
    filterValue = filterValue.toLowerCase();
    this.dataSource.filter = filterValue;
  }

  applyFilterB(filterValue: string) {
    filterValue = filterValue.trim();
    filterValue = filterValue.toLowerCase();
    this.dataSource.filter = filterValue;
  }


  
  ngOnInit() {
    this.renderDataTable();
    this.renderDataTable2();
    this.renderDataTable3();
    this.renderDataTable4();
  }
  renderDataTable() {
    this.api.getInventarios('inventario/1').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x['data'];
      this.datatotal = x['total'];
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
      console.log("total",this.datatotal)
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }
  renderDataTable2() {
    this.api.getInventarios('inventario/2').subscribe(x => {
      this.dataSourceB = new MatTableDataSource();
      this.dataSourceB.data = x['data'];
      this.datatotalB = x['total'];
      this.dataSourceB.sort = this.sort;
      this.dataSourceB.paginator = this.paginator;
      console.log("totalB",this.datatotalB)
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  renderDataTable3() {
    this.api.getInventarios('inventario/3').subscribe(x => {
      this.dataSourceC = new MatTableDataSource();
      this.dataSourceC.data = x['data'];
      this.datatotalC = x['total'];
      this.dataSourceC.sort = this.sort;
      this.dataSourceC.paginator = this.paginator;
      console.log("totalC",this.datatotalB)
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }


  renderDataTable4() {
    this.api.getInventarios('inventario/4').subscribe(x => {
      this.dataSourceD = new MatTableDataSource();
      this.dataSourceD.data = x['data'];
      this.datatotalD = x['total'];
      this.dataSourceD.sort = this.sort;
      this.dataSourceD.paginator = this.paginator;
      console.log("totalC",this.datatotalB)
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }



}
