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
  isLoaded;
  constructor(
    public dialogRef: MatDialogRef<DialogoarticuloComponent>,
    @ Inject(MAT_DIALOG_DATA) public data: Producto,private api:ApiService) {}

    getCate(): void {
      this.api.getCategoriaSelect().subscribe(data => {
        if(data) {
          this.dataSource = data;
          this.isLoaded = true;
          console.log(this.dataSource);
        }
      } );
    }

  ngOnInit() {
    this.getCate();
  
}

  cancelar() {
    this.dialogRef.close();
  }

}
