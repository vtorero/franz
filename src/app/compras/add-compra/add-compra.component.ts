
import { Component, Inject, NgModule, OnInit} from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MAT_DIALOG_DATA } from '@angular/material';
import { OwlDateTimeModule, OwlNativeDateTimeModule, DateTimeAdapter, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { Compra } from 'src/app/modelos/compra';
import "ng-pick-datetime/assets/style/picker.min.css";
import { BrowserModule } from '@angular/platform-browser';
import { ApiService } from 'src/app/api.service';
import { ToastrService } from 'ngx-toastr';



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
  selector: 'app-add-compra',
  templateUrl: './add-compra.component.html',
  styleUrls: ['./add-compra.component.css']
})


@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})


export class AddCompraComponent implements OnInit {
  dataProveedor:any;
  dataArray;
  cancela:boolean=false;
  displayedColumns=['item','descripcion','cantidad','total','borrar'];
  dataDetalle=[{item:1,descripcion:'cerdo',cantidad:89,total:102.1}];
  dataComprobantes=[ {id:1,tipo:'Factura'}, {id:2,tipo:'Boleta'}];
  public selectedMoment = new Date();
  constructor(
    private toastr: ToastrService,
    public dialogo:MatDialog,
    public dialogRef: MatDialogRef<AddCompraComponent>,
    @Inject(MAT_DIALOG_DATA) public data: Compra,
  dateTimeAdapter: DateTimeAdapter<any>,private api:ApiService) {
    dateTimeAdapter.setLocale('es-PE');
   }
   getProveedores(): void {
    this.api.getProveedorSelect().subscribe(data => {
      if(data) {
        this.dataProveedor = data;
      }
    } );
  }

  ngOnInit() {
    this.getProveedores();
  }

  onKey(value) { 
    this.dataArray= []; 
    this.selectSearch(value);       
}
selectSearch(value:string){
  this.api.getProveedorSelect(value).subscribe(data => {
    if(data) {
      this.dataProveedor = data;
    }
  } );
  
}

abrirDialog(templateRef2) {
  let dialogRef = this.dialogo.open(templateRef2, {
 width: '500px' });
}

cancelar(){
  this.dialogRef.close();
  this.dialogo.closeAll();
  this.cancela=true;
}
cancel(c){
  close;
  this.cancela=true
  
}
  

}
