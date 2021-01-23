import { Component, Inject, NgModule, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';
import { BrowserModule } from '@angular/platform-browser';
import { ThrowStmt } from '@angular/compiler';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-add-producto',
  templateUrl: './add-producto.component.html',
  styleUrls: ['./add-producto.component.css']
})


@NgModule({
  imports: [BrowserModule]
})

export class AddProductoComponent implements OnInit {
dataProducto:any;
seleccionados:string[]=[];
producto:any;
dataArray;
stock;
dataExistencias:any;
constructor(private api:ApiService,
  private toastr: ToastrService,
    @Inject(MAT_DIALOG_DATA) public data: DetalleVenta
    ) { }
  getProductos(): void {
    this.api.getApi('productos').subscribe(data => {
      if(data) {
        this.dataProducto = data;
      }
    } );
  }

  getProdExiste(id): void {
    this.api.getApi('inventarios/'+id).subscribe(data => {
      if(data) {
       this.dataExistencias=data;
      }
    });
  }
  onKey(value) { 
  this.dataArray= []; 
  this.selectSearch(value);       
}
selectSearch(value:string){
  this.api.getProductosSelect(value).subscribe(data => {
    if(data) {
      this.dataProducto = data;
    }
  } );
  
}
  change(event)
  {
    console.log(event.source.value);
    this.data.precio=event.source.value.precio;
    
    if(event.source.selected){
      this.seleccionados.push(event.source.value);
      }else{
          this.seleccionados.splice(event.source.index,1);
      }
      //console.log(event.source.value,event.source.selected);
      //console.log(this.seleccionados)
    }

    verifica(cantidad){
      this.stock=this.seleccionados;
      console.log(this.stock[0].cantidad)
      console.log(cantidad);
      if(cantidad>this.stock[0].cantidad){
        this.toastr.error("Inventario insuficiente");
      }
    }
  
  handleProducto(id){
    this.getProdExiste(id);
  }

  ngOnInit() {
    this.getProductos();
  }


}
