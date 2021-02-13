import { Component, Inject, OnInit } from '@angular/core';
import { MatDialog, MAT_DIALOG_DATA } from '@angular/material';
import { ApiService } from 'src/app/api.service';
import { Movimiento } from 'src/app/modelos/movimiento';

@Component({
  selector: 'app-add-dosimetria',
  templateUrl: './add-dosimetria.component.html',
  styleUrls: ['./add-dosimetria.component.css']
})
export class AddDosimetriaComponent implements OnInit {
dataInsumos;
dataArray;
unidad:string='';
dataOperacion = [{ id:'entrada',tipo: 'Entrada' },{ id:'salida', tipo:'Salida'}];
dataUnidades = [{ id: 'unidad', tipo: 'Unidades' }, { id: 'kilogramo', tipo: 'Kilogramo' }];
  constructor(private api: ApiService,
    @Inject(MAT_DIALOG_DATA) public data: Movimiento,
    public dialog: MatDialog,
    
    ) { }

  getInsumos(): void {
    this.api.getApi('dosimetria').subscribe(data => {
      if (data) {
        this.dataInsumos = data;
      }
    });
  }

  onKeyVendedor(value) {
    this.dataArray = [];
    this.selectSearch(value);
  }
  selectSearch(value: string) {
    this.api.getSelectApi('dosimetria/', value).subscribe(data => {
      if (data) {
        this.dataInsumos = data;
      }
    });

  }

  selectInsumo(ev,value){
    if (ev.source.selected) {
    this.data.unidad=value.unidad;
    }
  }

  ngOnInit() {
    this.getInsumos();
  }

  cancelar() {
    this.dialog.closeAll();
  }


}
