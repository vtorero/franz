import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { Dosimetria } from 'src/app/modelos/dosimetria';

@Component({
  selector: 'app-add-insumo',
  templateUrl: './add-insumo.component.html',
  styleUrls: ['./add-insumo.component.css']
})
export class AddInsumoComponent implements OnInit {
  dataOperacion = [{ id: 'entrada', tipo: 'Entrada' }, { id:'salida', tipo: 'Salida' }];
  dataUnidades = [{ id: 'NIU', tipo: 'Unidades' }, { id: 'KGM', tipo: 'Kilogramo' }];
  constructor(
    @Inject(MAT_DIALOG_DATA) public data: Dosimetria)
  { }

  ngOnInit() {

  }

}
