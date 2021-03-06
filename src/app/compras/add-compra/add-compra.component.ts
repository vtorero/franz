
import { Component, Inject, NgModule, OnInit} from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { OwlDateTimeModule, OwlNativeDateTimeModule, DateTimeAdapter, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { Compra } from 'src/app/modelos/compra';
import "ng-pick-datetime/assets/style/picker.min.css";
import { BrowserModule } from '@angular/platform-browser';
import { ApiService } from 'src/app/api.service';
import { ToastrService } from 'ngx-toastr';
import { AddDetalleComponent } from './addDetalle.component';
import { DetalleCompra } from 'src/app/modelos/detalleCompra';



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
  exampleArray:any[] = [];
  dataProveedor:any;
  dataArray;
  dataSource:any;
  cancela:boolean=false;
  public selectedMoment = new Date();
  displayedColumns=['nombre','cantidad','precio','borrar'];
   dataComprobantes=[ {id:'Factura',tipo:'Factura'}, {id:'Boleta',tipo:'Boleta'}];
   constructor(
    private toastr: ToastrService,
    public dialogo:MatDialog,
    public dialogRef: MatDialogRef<AddCompraComponent>,
    public dialog:MatDialog,
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

deleteTicket(rowid: number){
  if (rowid > -1) {
    this.data.detalleCompra.splice(rowid, 1);
    this.dataSource = new MatTableDataSource(this.data.detalleCompra);
}
}

abrirDialog() {
  const dialogo1 = this.dialog.open(AddDetalleComponent, {
    data: new DetalleCompra(0,'',0,0) 
  });
  dialogo1.afterClosed().subscribe(art => {
    if (art!= undefined)
    this.exampleArray.push(art)
    this.dataSource = new MatTableDataSource();
    this.dataSource.data = this.exampleArray; 
    this.data.detalleCompra=this.exampleArray;
   });
}



cancelar(){
  this.dialogRef.close();
  //this.dialogo.closeAll();
  this.cancela=true;
}

  close() {
     this.dialog.closeAll();

}
  

}
