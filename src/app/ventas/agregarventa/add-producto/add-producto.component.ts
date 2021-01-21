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
  ngOnInit() {
    this.getProductos();
  }

}
