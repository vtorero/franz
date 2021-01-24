import { Component, OnInit, Inject } from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';
import { ApiService } from '../../api.service';
import {Producto} from '../../modelos/producto';
@Component({
  selector: 'app-dialogoarticulo',
  templateUrl: './dialogoarticulo.component.html'
})
export class DialogoarticuloComponent implements OnInit {
  dataSource;
  dataSubcategoria;
  isLoaded;
  usuario;
  constructor(
    public dialogRef: MatDialogRef<DialogoarticuloComponent>,
    @Inject(MAT_DIALOG_DATA) public data: Producto,
    private api:ApiService) {}

    getCate(): void {
      this.api.getCategoriaSelect().subscribe(data => {
        if(data) {
          this.dataSource = data;
          this.isLoaded = true;
        }
      } );
    }

    getSubCate(id): void {
      this.api.getApi('subcategoria/'+id).subscribe(data => {
        if(data) {
          this.dataSubcategoria=data;
        }
      } );
    }

  ngOnInit() {
    this.getCate();
  
}

handleCagetoria(data){
  this.getSubCate(data);
  console.log(this.dataSubcategoria)
}

  cancelar() {
    this.dialogRef.close();
  }

}
