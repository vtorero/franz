import { Component, Inject, NgModule, OnInit } from '@angular/core';
import { MatDialog, MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Venta } from 'src/app/modelos/ventas';

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
  selector: 'app-editar-venta',
  templateUrl: './editar-venta.component.html',
  styleUrls: ['./editar-venta.component.css']
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})
export class EditarVentaComponent implements OnInit {
  displayedColumns = ['id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal'];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Pendiente', tipo: 'Pendiente' }];
  dataVendedores: any;
  dataProveedor:any;
  dataDetalle:any;
  dataClientes: any;
  dataClient: any;
  dataEmpresas: any;
  dataProductos: any;
  exampleArray:any;
  //exampleArray: any[] = [];
  dataArray;
  dataSource: any;
  selected: string;
  filter: any;
  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditarVentaComponent>,
    public dialog:MatDialog,
    @Inject(MAT_DIALOG_DATA) public data:Venta,
    dateTimeAdapter: DateTimeAdapter<any>,
    private toastr: ToastrService
  ) { 
    dateTimeAdapter.setLocale('es-PE');
  }

  getVendedores(): void {
    this.api.getApi('vendedores').subscribe(data => {
      if (data) {
        this.dataVendedores = data;
      }
    });
  }
  getclientes(): void {
    this.api.getApi('clientes').subscribe(data => {
      if (data) {
        this.dataClientes = data;
      }
    });
  }

  getEmpresas(): void {
    this.api.getApi('empresas').subscribe(data => {
      if (data) {
        this.dataEmpresas = data;
      }
    });
  }

  ngOnInit() {
     console.log(this.data.id)
    this.api.GetDetalleVenta(this.data.id).subscribe(x => {  
    this.dataDetalle = new MatTableDataSource();
    this.exampleArray=x;
    this.dataDetalle=this.exampleArray
    this.data.detalleVenta=this.exampleArray; 

    });

    this.getVendedores();
    this.getclientes();
    this.getEmpresas();
  }

  cancelar() {
    this.dialogRef.close();
  }

}
