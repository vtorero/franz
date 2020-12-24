import { Component, Inject, NgModule, OnInit ,Output, EventEmitter} from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ApiService } from 'src/app/api.service';
import { Compra } from 'src/app/modelos/compra';
import { DetalleCompra } from 'src/app/modelos/detalleCompra';
import { HelloComponent } from '../add-compra/hello.component';

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
  exampleArray:any;
  dataProveedor:any;
  dataDetalle:any;
  displayedColumns=['nombre','cantidad','precio','borrar'];
  dataComprobantes=[ {id:"1",tipo:'Factura'}, {id:"2",tipo:'Boleta'}];
  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditCompraComponent>,
    public dialog:MatDialog,
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
       
            if (rowid > -1) {
              console.log(this.exampleArray)
              this.exampleArray.splice(rowid, 1);
              this.dataDetalle = new MatTableDataSource(this.data.detalleCompra);
        }
      }

      abrirDialog() {
        const dialogo1 = this.dialog.open(HelloComponent, {
          data: new DetalleCompra(0,'',0,0) 
        });
        dialogo1.afterClosed().subscribe(art => {
          if (art!= undefined)
          this.exampleArray.push(art)
          this.dataDetalle = new MatTableDataSource();
          this.dataDetalle.data = this.exampleArray; 
          this.data.detalleCompra=this.exampleArray;
         });
      }
      
  ngOnInit() {
    console.log(this.data.id)
    this.api.GetDetalleCompra(this.data.id).subscribe(x => {  
      this.dataDetalle = new MatTableDataSource();
      this.exampleArray=x;
      this.dataDetalle=this.exampleArray
      this.data.detalleCompra=this.exampleArray; 

      });
    this.getProveedores();
  }
  cancelar() {
    this.dialogRef.close();
  }

}
