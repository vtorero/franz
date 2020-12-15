import { Component, OnInit, Inject } from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';
import { ApiService } from '../../api.service';
import {Producto} from '../../modelos/producto';

@Component({
  selector: 'app-editar-producto',
  templateUrl: './editar-producto.component.html',
  styleUrls: ['./editar-producto.component.css']
})
export class EditarProductoComponent implements OnInit {
  dataSource;
  isLoaded;
  constructor( public dialogRef2: MatDialogRef<EditarProductoComponent>,
    @ Inject(MAT_DIALOG_DATA) public data: Producto,
    private api:ApiService) { }
    getCate(): void {
      this.api.getCategoriaSelect().subscribe(data => {
        if(data) {
          this.dataSource = data;
          this.isLoaded = true;
        }
      } );
    }
  ngOnInit() {
    this.getCate()
  }

  cancelar() {
    this.dialogRef2.close();
  }

}
