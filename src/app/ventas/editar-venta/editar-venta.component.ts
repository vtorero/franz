import { Component, Inject, NgModule, OnInit } from '@angular/core';
import { MatDatepickerModule, MatDialog, MatDialogRef, MatPaginatorModule, MatTableDataSource, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Venta } from 'src/app/modelos/ventas';
import { Global } from '../../global';

export const MY_MOMENT_FORMATS = {
  parseInput: 'l LT',
  fullPickerInput: 'l LT',
  datePickerInput: 'l',
  timePickerInput: 'LT',
  monthYearLabel: 'MM YYYY',
  dateA11yLabel: 'LL',
  monthYearA11yLabel: 'MM YYYY',
};

function getCDR(nro,url) {
  console.log("nro",nro.substring(5,10))
  var serie = nro.substring(0,4)
  var letra = nro.substring(0,1);
  var tipo = (letra=="F"?"01":"03");
  console.log(serie)
  fetch(url, {
    method: 'post',
    headers: {
      'Content-Type': 'application/x-zip-compressed'
    },
    body: JSON.stringify({"rucSol":"20605174095","userSol":"PUREADYS","passSol":"bleusiger","ruc":"20605174095","tipo":tipo,"serie":serie,"numero":nro.substring(5,10)})
  })
    .then(response => response.blob())
    .then(blob => {
      var link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = "20605174095-"+tipo+"-"+serie +"-"+nro.substring(5,10) +".zip";
      link.click();
    });
  }

@Component({
  selector: 'app-editar-venta',
  templateUrl: './editar-venta.component.html',
  styleUrls: ['./editar-venta.component.css']
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: {useUtc: true}}]
})


export class EditarVentaComponent implements OnInit {
  displayedColumns = ['id','id_producto', 'nombre', 'cantidad', 'peso', 'precio','subtotal'];
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' },{ id: 'Factura Gratuita', tipo: 'Factura Gratuita' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Pendiente', tipo: 'Pendiente' }];
  dataFormapago = [{ id: 'Contado' }, { id: 'Credito' }];
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

  verCDR(codigo){
    getCDR(codigo,Global.DOWNLOAD_CDR);
    console.log(codigo);
 }
  cancelar() {
    this.dialogRef.close();
  }

}
