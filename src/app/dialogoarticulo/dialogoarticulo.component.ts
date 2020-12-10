import { Component, OnInit, Inject } from '@angular/core';
import {MatDialog, MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';
import { Observable } from 'rxjs';
import { ApiService } from '../api.service';
import { Categoria } from '../modelos/categoria';
import {Producto} from '../modelos/producto';
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

    getTypeT(): void {
      this.api.getCategoriaSelect().subscribe(data => {
        if(data) {
          this.dataSource = data;
          this.isLoaded = true;
          console.log(this.dataSource);
        }
      } );
    }

  ngOnInit() {
    this.getTypeT();
  
}

  cancelar() {
    this.dialogRef.close();
  }

}
