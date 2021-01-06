import { Component, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';

@Component({
  selector: 'app-edit-inventario',
  templateUrl: './edit-inventario.component.html',
  styleUrls: ['./edit-inventario.component.css']
})
export class EditInventarioComponent {
  dataProducto:any;
  dataArray:any;
  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditInventarioComponent>,
    @Inject(MAT_DIALOG_DATA) public data:Inventario,
    dateTimeAdapter: DateTimeAdapter<any>
  ) {  dateTimeAdapter.setLocale('es-PE');}

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

  cancelar() {
    this.dialogRef.close();
  }

}
