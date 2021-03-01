import { Component, Inject, NgModule } from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Inventario } from 'src/app/modelos/inventario';


export const MY_FORMATS = {
  parse: {
    dateInput: 'LL',
  },
  display: {
    dateInput: 'DD/MM/YYYY',
    monthYearLabel: 'YYYY',
    dateA11yLabel: 'LL',
    monthYearA11yLabel: 'YYYY',
  },
};

@NgModule({
  imports: [BrowserModule,OwlDateTimeModule, OwlNativeDateTimeModule,MatDialog],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_FORMATS},]
})

@Component({
  selector: 'app-edit-inventario',
  templateUrl: './edit-inventario.component.html',
  styleUrls: ['./edit-inventario.component.css']
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
