import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';

@Component({
  selector: 'app-add-inventario',
  templateUrl: './add-inventario.component.html',
  styleUrls: ['./add-inventario.component.css']
})
export class AddInventarioComponent implements OnInit {
dataProducto:any;
dataArray;
  constructor(private api: ApiService,
    @Inject(MAT_DIALOG_DATA) public data: Inventario) { }


  

  ngOnInit() {
    this.getProductos();
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


  getProductos(): void {
    this.api.getProductosSelect().subscribe(data => {
      if(data) {
        this.dataProducto = data;
      }
    } );
  }

}
