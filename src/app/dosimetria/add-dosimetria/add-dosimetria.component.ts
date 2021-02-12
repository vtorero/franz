import { Component, OnInit } from '@angular/core';
import { ApiService } from 'src/app/api.service';

@Component({
  selector: 'app-add-dosimetria',
  templateUrl: './add-dosimetria.component.html',
  styleUrls: ['./add-dosimetria.component.css']
})
export class AddDosimetriaComponent implements OnInit {
dataInsumos;
dataArray;
dataOperacion = [{ id: 'entrada', tipo: 'Entrada' }, { id:'salida', tipo: 'Salida' }];
dataUnidades = [{ id: 'NIU', tipo: 'Unidades' }, { id: 'KGM', tipo: 'Kilogramo' }];
  constructor(private api: ApiService,) { }

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

  ngOnInit() {
    this.getInsumos();
  }

}
