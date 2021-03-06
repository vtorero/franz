import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';


@Component({
  selector: 'app-add-inventario',
  templateUrl: './add-inventario.component.html',
  styleUrls: ['./add-inventario.component.css']
})
export class AddInventarioComponent implements OnInit {
  dataProducto: any;
  dataArray;
  dataPeso: any;
  constructor(private api: ApiService,
    @Inject(MAT_DIALOG_DATA) public data: Inventario,
    public dialogRef: MatDialogRef<AddInventarioComponent>,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }

  ngOnInit() {
    this.getProductos();
  }


  onCantidad(value,da) {
    console.log(da.id_producto);
    this.getProdPeso(da.id_producto)
      this.data.peso = value * this.dataPeso[0].peso;
  }

  getProdPeso(id) {
    this.api.getApi('producto/' + id).subscribe(data => {
      if (data) {
        this.dataPeso = data;
      }
    });
  }

  onKey(value) {
    this.dataArray = [];
    this.selectSearch(value);
  }
  selectSearch(value: string) {
    this.api.getProductosSelect(value).subscribe(data => {
      if (data) {
        this.dataProducto = data;
      }
    });

  }

  cancelar() {
    this.dialogRef.close();
  }

  getProductos(): void {
    this.api.getProductosSelect().subscribe(data => {
      if (data) {
        this.dataProducto = data;
      }
    });
  }

}
