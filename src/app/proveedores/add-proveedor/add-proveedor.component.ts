import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { Proveedor } from 'src/app/modelos/proveedor';

@Component({
  selector: 'app-add-proveedor',
  templateUrl: './add-proveedor.component.html',
  styleUrls: ['./add-proveedor.component.css']
})
export class AddProveedorComponent implements OnInit {

  constructor(
    public dialogRef: MatDialogRef<AddProveedorComponent>,
    @ Inject(MAT_DIALOG_DATA) public data: Proveedor,
    private api:ApiService

  ) { }

  ngOnInit() {
  }

}
