import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';

@Component({
  selector: 'app-add-producto',
  templateUrl: './add-producto.component.html',
  styleUrls: ['./add-producto.component.css']
})
export class AddProductoComponent implements OnInit {
dataProducto:any;
seleccionados:string[]=[];
producto:any;
dataArray;
dataExistencias:any;
constructor(private api:ApiService,
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
    console.log(event);
    if(event.source.selected){
      this.seleccionados.push(event.source.value);
      }else{
        //console.log("deseleccionado")
      this.seleccionados.splice(event.source.index,1);
      }
      //console.log(event.source.value,event.source.selected);
      //console.log(this.seleccionados)
    }
  
  handleProducto(id){
    this.getProdExiste(id);
  }

  ngOnInit() {
    this.getProductos();
  }

}
