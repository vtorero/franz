import { Component, Inject, NgModule, OnInit} from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Compra } from 'src/app/modelos/compra';
import { DetalleCompra } from 'src/app/modelos/detalleCompra';
import { AddDetalleComponent } from '../add-compra/addDetalle.component';

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
  styleUrls: ['./edit-compra.component.css'],
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})
export class EditCompraComponent implements OnInit {
  startDate:Date = new Date();
  public selectedMoment = new Date();
  exampleArray:any;
  dataProveedor:any;
  dataDetalle:any;
  displayedColumns=['nombre','cantidad','precio','borrar'];
  dataComprobantes=[ {id:'Factura',tipo:'Factura'}, {id:'Boleta',tipo:'Boleta'}];
  fec1= this.selectedMoment.toDateString().split(" ",4); 
   fecha1:string=this.fec1[2]+'-'+this.fec1[1]+'-'+this.fec1[3];

  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditCompraComponent>,
    public dialog:MatDialog,
    @Inject(MAT_DIALOG_DATA) public data:Compra,
    dateTimeAdapter: DateTimeAdapter<any>,
    private toastr: ToastrService
      ) {
     
        dateTimeAdapter.setLocale('es-PE');
      }
      date : any;
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
        const dialogo1 = this.dialog.open(AddDetalleComponent, {
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

  enviaData(a){
    console.log("ve2r",a);
    var fec1 = a.fecha.toDateString().split(" ",4); 
    console.log(fec1);
    this.editar(a);

  }

  
editar(art:any) {
  if(art){
  this.api.EditarCompra(art).subscribe(
    data=>{
      this.toastr.success( data['messaje']);
      },
    erro=>{console.log(erro)}
      );
}
}

  cancelar() {
    this.dialogRef.close();
  }

}
