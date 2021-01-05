import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { Inventario } from 'src/app/modelos/inventario';

@Component({
  selector: 'app-edit-inventario',
  templateUrl: './edit-inventario.component.html',
  styleUrls: ['./edit-inventario.component.css']
})
export class EditInventarioComponent implements OnInit {

  constructor(
    @Inject(MAT_DIALOG_DATA) public data:Inventario,
    dateTimeAdapter: DateTimeAdapter<any>
  ) {  dateTimeAdapter.setLocale('es-PE');}

  ngOnInit() {
  }



}
