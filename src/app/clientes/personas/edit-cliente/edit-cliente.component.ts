import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { Clientes } from 'src/app/modelos/clientes';

@Component({
  selector: 'app-edit-cliente',
  templateUrl: './edit-cliente.component.html',
  styleUrls: ['./edit-cliente.component.css']
})
export class EditClienteComponent implements OnInit {

  constructor(@ Inject(MAT_DIALOG_DATA) public data: Clientes,
  public dialog: MatDialogRef<EditClienteComponent>
  ) { }

  ngOnInit() {
  }

  cancelar() {
    this.dialog.close();
  }

}
