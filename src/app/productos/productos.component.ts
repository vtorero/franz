import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTable, MatTableDataSource } from '@angular/material/table';
import { DialogoarticuloComponent } from '../dialogoarticulo/dialogoarticulo.component';
import { MatSort } from '@angular/material/sort';
import { Producto } from '../modelos/producto';
import { MatDialog } from '@angular/material';

@Component({
  selector: 'app-productos',
  templateUrl: './productos.component.html',
  styleUrls: ['./productos.component.css']
})

@NgModule({
  imports: [BrowserModule,MatPaginatorModule,MatDialog],

})

export class ProductosComponent implements OnInit {
  dataSource:any;
  displayedColumns = ['codigo','nombre','costo','IGV','precio_sugerido','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService,public dialog: MatDialog) {}

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

  columnas: string[] = ['codigo', 'nombre', 'costo','IGV','precio'];

  datos: Producto[] = [new Producto('1','papas',0,0,0),];

  ds = new MatTableDataSource<Producto>(this.datos);

  @ViewChild(MatTable) tabla1: MatTable<Producto>;

  

  abrirDialogo() {
    const dialogo1 = this.dialog.open(DialogoarticuloComponent, {
      data: new Producto('', '', 0,0,0)
    });

    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        this.agregar(art);
    });
  }

  borrarFila(cod: number) {
    if (confirm("Realmente quiere borrarlo?")) {
      this.datos.splice(cod, 1);
      
    }
  }

  agregar(art: Producto) {
    this.datos.push(new Producto(art.codigo, art.nombre, art.costo,art.igv,art.precio));
    console.log(art);
    this.renderDataTable();
  }

}
