import { Component, Inject, NgModule, OnInit ,Output, EventEmitter} from '@angular/core';
import { MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Compra } from 'src/app/modelos/compra';

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
  selector: 'app-edit-compra',
  templateUrl: './edit-compra.component.html',
  styles: []
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})
export class EditCompraComponent implements OnInit {
  dataProveedor:any;
  displayedColumns=['nombre','cantidad','precio','borrar'];
  dataComprobantes=[ {id:"1",tipo:'Factura'}, {id:"2",tipo:'Boleta'}];
  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditCompraComponent>,
    @Inject(MAT_DIALOG_DATA) public data:Compra,
    dateTimeAdapter: DateTimeAdapter<any>
      ) {
        dateTimeAdapter.setLocale('es-PE');
       }
       getProveedores(): void {
        this.api.getProveedorSelect().subscribe(data => {
          if(data) {
            this.dataProveedor = data;
          }
        } );
            }


      deleteTicket(rowid: number){

        console.log(rowid)
        if (rowid > -1) {
          console.log(this.data);
         //this.data.detalle.splice(rowid,1);
          //this.data.detalleCompra= new MatTableDataSource(this.data.detalleCompra);
      }
      }
  ngOnInit() {
    this.getProveedores();
  }
  cancelar() {
    this.dialogRef.close();
  }

}
