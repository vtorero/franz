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
  totalgranel:any=0;
  totalmerma:any=0;
  totalcantidad:any=0;
  totalpeso:any=0;

  dataSourceB:any;
  totalgranelB:any=0;
  totalmermaB:any=0;
  totalcantidadB:any=0;
  totalpesoB:any=0;

  dataSourceC:any;
  totalgranelC:any=0;
  totalmermaC:any=0;
  totalcantidadC:any=0;
  totalpesoC:any=0;

  dataSourceD:any;
  totalgranelD:any=0;
  totalmermaD:any=0;
  totalcantidadD:any=0;
  totalpesoD:any=0;

  dataSourceE:any;
  totalgranelE:any=0;
  totalmermaE:any=0;
  totalcantidadE:any=0;
  totalpesoE:any=0;
  
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
    this.renderDataTable6();
  }
  renderDataTable() {
    this.api.getInventarios('inventario/1').subscribe(x => {
      if(x){
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x['data'];
      this.totalgranel = x['total'][0].granel;
      this.totalmerma = x['total'][0].merma;
      this.totalcantidad = x['total'][0].cantidad;
      this.totalpeso = x['total'][0].peso;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
      console.log("total",this.totalpeso)
    }
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }
  renderDataTable2() {
    this.api.getInventarios('inventario/2').subscribe(x => {
      this.dataSourceB = new MatTableDataSource();
      this.dataSourceB.data = x['data'];
      this.totalgranelB = x['total'][0].granel;
      this.totalmermaB = x['total'][0].merma;
      this.totalcantidadB = x['total'][0].cantidad;
      this.totalpesoB = x['total'][0].peso;

      this.dataSourceB.sort = this.sort;
      this.dataSourceB.paginator = this.paginator;
    
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  renderDataTable3() {
    this.api.getInventarios('inventario/3').subscribe(x => {
      this.dataSourceC = new MatTableDataSource();
      this.dataSourceC.data = x['data'];
      this.totalgranelC = x['total'][0].granel;
      this.totalmermaC = x['total'][0].merma;
      this.totalcantidadC = x['total'][0].cantidad;
      this.totalpesoC = x['total'][0].peso;
      this.dataSourceC.sort = this.sort;
      this.dataSourceC.paginator = this.paginator;
      
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }


  renderDataTable4() {
    this.api.getInventarios('inventario/4').subscribe(x => {
      this.dataSourceD = new MatTableDataSource();
      this.dataSourceD.data = x['data'];
      this.totalgranelD = x['total'][0].granel;
      this.totalmermaD = x['total'][0].merma;
      this.totalcantidadD = x['total'][0].cantidad;
      this.totalpesoD = x['total'][0].peso;
      this.dataSourceD.sort = this.sort;
      this.dataSourceD.paginator = this.paginator;
      
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }


  renderDataTable6() {
    this.api.getInventarios('inventario/6').subscribe(x => {
      this.dataSourceE = new MatTableDataSource();
      this.dataSourceE.data = x['data'];
      this.totalgranelE = x['total'][0].granel;
      this.totalmermaE = x['total'][0].merma;
      this.totalcantidadE = x['total'][0].cantidad;
      this.totalpesoE = x['total'][0].peso;
      this.dataSourceE.sort = this.sort;
      this.dataSourceE.paginator = this.paginator;
      
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }



}
