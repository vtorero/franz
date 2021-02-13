import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import {ApiService} from '../api.service';
import { BrowserModule } from '@angular/platform-browser';
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTable, MatTableDataSource } from '@angular/material/table';
import { DialogoarticuloComponent } from './AddProducto/AddProducto.component';
import { EditarProductoComponent } from './editar-producto/editar-producto.component';
import { MatSort } from '@angular/material/sort';
import { Producto } from '../modelos/producto';
import { MatDialog } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { LoginService } from '../services/login.service';
import { Router } from '@angular/router';


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
  cancela:boolean=false;
  usuario:string;
  displayedColumns = ['codigo','nombre','peso','nombrecategoria','costo','usuario','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private _login:LoginService,private router:Router,private api:ApiService,public dialog:MatDialog,public dialog2:MatDialog,public dialogo:MatDialog,private toastr: ToastrService) {}

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
    if(this._login.getCurrentUser==false){
      this.router.navigate(['']);
      }else{
        this.usuario= localStorage.getItem("currentNombre");
      } 

  }

  @ViewChild(MatTable) tabla1: MatTable<Producto>;

  abrirDialogo() {
    const dialogo1 = this.dialog.open(DialogoarticuloComponent, {
      data: new Producto(0,'', '',0, '',0,0,0,0,0,this.usuario)
    });

     dialogo1.afterClosed().subscribe(art => {
       if (art!= undefined)
        this.agregar(art);
      });
  }

  abrirDialogoEdit(cod) {
    console.log("edit",cod);
    cod.usuario=this.usuario;
    const dialogo2 = this.dialog2.open(EditarProductoComponent, {
      data: cod
    });

     dialogo2.afterClosed().subscribe(art => {
      if(!this.cancela){
       if (art!= undefined)
        this.editar(cod);
        this.renderDataTable();
      }
      });
  
  }

  cancelar(){
    this.dialog.closeAll();
    this.dialog2.closeAll();
    this.cancela=true;

  }

  abrirDialog(templateRef,cod) {
         let dialogRef = this.dialogo.open(templateRef, {
        width: '500px' });
    
      dialogRef.afterClosed().subscribe(result => {
      if(!this.cancela){
          if(cod){
          this.api.EliminarProducto(cod).subscribe(
            data=>{
            this.toastr.success('Aviso', data['messaje']);
            },
            erro=>{console.log(erro)}
              );
          this.renderDataTable();
        }

      }
    
});
}
  agregar(art: Producto) {
    if(art){
    this.api.GuardarProducto(art).subscribe(
      data=>{
        this.toastr.success('Aviso', data['messaje']);
        },
      erro=>{console.log(erro)}
        );
      this.renderDataTable();
  }
}

editar(art: Producto) {
  if(art){
  this.api.EditarProducto(art).subscribe(
    data=>{
      this.toastr.success('Aviso', data['messaje']);
      },
    erro=>{console.log(erro)}
      );
    this.renderDataTable();
}
}

}
