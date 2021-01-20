import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { Venta } from 'src/app/modelos/ventas';

@Component({
  selector: 'app-agregarventa',
  templateUrl: './agregarventa.component.html',
  styleUrls: ['./agregarventa.component.css']
})
export class AgregarventaComponent implements OnInit {
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' },{ id:'Sin Comprobante', tipo: 'Pendiente' }];
  dataVendedores:any;
  constructor(
    private api:ApiService,
    @Inject(MAT_DIALOG_DATA) public data: Venta,

  ) { }

  getVendedores(): void {
    this.api.getApi('vendedores').subscribe(data => {
      if(data) {
        this.dataVendedores = data;
      }
    } );
  }

  ngOnInit() {
    this.getVendedores();
  }

}
