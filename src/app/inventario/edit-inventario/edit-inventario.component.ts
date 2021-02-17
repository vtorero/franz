import { Component, Inject, NgModule } from '@angular/core';
import { MatDialogRef, MatPaginatorModule, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';


export const MY_MOMENT_FORMATS = {
  parseInput: 'l LT',
  fullPickerInput: 'l LT',
  datePickerInput: 'l',
  timePickerInput: 'LT',
  monthYearLabel: 'MM YYYY',
  dateA11yLabel: 'LL',
  monthYearA11yLabel: 'MM YYYY',
};

@Component({
  selector: 'app-edit-inventario',
  templateUrl: './edit-inventario.component.html',
  styleUrls: ['./edit-inventario.component.css']
})


@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS}]
})
export class EditInventarioComponent {
  dataProducto:any;
  dataArray:any;
  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditInventarioComponent>,
    @Inject(MAT_DIALOG_DATA) public data:Inventario,
    dateTimeAdapter: DateTimeAdapter<any>
    )
    {  dateTimeAdapter.setLocale('es-PE')}

  ngOnInit() {
    this.getProductos();
  }

  onKey(value) { 
    this.dataArray= []; 
    this.selectSearch(value);       
}
selectSearch(value:string){
  this.api.getProductosSelect(value).subscribe(data => {
    if(data) {
      this.dataProducto = data;
    }
  } );
  
}

  getProductos(): void {
    this.api.getProductosSelect().subscribe(data => {
      if(data) {
        this.dataProducto = data;
      }
    } );
  }

  cancelar() {
    this.dialogRef.close();
  }

}
