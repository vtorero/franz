import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Global } from '../global';
import { Boleta } from '../modelos/Boleta/boleta';
import { Client } from '../modelos/Boleta/client';
import { Company } from '../modelos/Boleta/company';
import { Details } from '../modelos/Boleta/details';
import { Nota } from '../modelos/Boleta/nota';
import { DetalleVenta } from '../modelos/detalleVenta';
import { NotaCredito } from '../modelos/notacredito';
import { Venta } from '../modelos/ventas';
import { AgregarventaComponent } from '../ventas/agregarventa/agregarventa.component';
import { AddnotaComponent } from './addnota/addnota.component';

function sendInvoice(data, nro,url) {
  fetch(url, {
    method: 'post',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + Global.TOKEN_FACTURACION
    },
    body: data
  })
    .then(response => response.blob())
    .then(blob => {
      var link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = "comprobante-" + nro + ".pdf";
      link.click();
    });
}


@Component({
  selector: 'app-notacredito',
  templateUrl: './notacredito.component.html',
  styleUrls: ['./notacredito.component.css']
})
export class NotacreditoComponent implements OnInit {

  dataSource: any;
  dataDetalle: any;
  public boletacorrelativo:string;
  public Moment = new Date();
  client: any;
  letras: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '');
  company: Company = new Company('', '', { direccion: '' });
  cliente: Client = new Client('', '', '', { direccion: '' });
  cancela: boolean = false;
  displayedColumns = ['id', 'usuario', 'vendedor', 'cliente', 'estado', 'comprobante', 'fecha', 'valor_total', 'opciones'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  filter: any;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    public dialog2: MatDialog,
    public dialogo: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }

  ngOnInit() {
  }
  agregarNota() {
    const dialogo1 = this.dialog.open(AddnotaComponent, {
      data: new Venta(0, localStorage.getItem("currentId"), 0, 0, 0, '','', this.Moment, Global.BASE_IGV, 0, 0, [], false,0)
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }



    renderDataTable() {
    this.api.getApi('notas').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }


  replaceStr(str, find, replace) {
    for (var i = 0; i < find.length; i++) {
      str = str.replace(new RegExp(find[i], 'gi'), replace[i]);
    }
    return str;
  }

  agregar(art: NotaCredito) {
    console.log(art);
    if (art.comprobante) {
      let fec1;
      let fecha1;
      var boleta: Nota = new Nota('','','','','', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0,0, '', [], [{ code: '', value: '' }]);
      fec1 = art.fecha.toDateString().split(" ", 4);
      var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];

      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      boleta.fechaEmision = fecha1;
      boleta.tipoMoneda = "PEN";
      boleta.ublVersion = "2.1";
      boleta.tipoOperacion = "0101";
      /**cliente*/
      if (art.cliente.nombre) {
        boleta.tipoDoc = "03";
        boleta.serie = "B001";
        this.api.getMaxId('boletas').subscribe(id=>{
          boleta.correlativo=id[0].ultimo.toString();
          art.nro_comprobante="B001"+id[0].ultimo.toString();
          });
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
      }
      if (art.cliente.razon_social) {
        boleta.tipoDoc = "01";
        boleta.serie = "F001";
        this.api.getMaxId('facturas').subscribe(id=>{
        boleta.correlativo=id[0].ultimo.toString();
        art.nro_comprobante="F001"+id[0].ultimo.toString();
        });
        boleta.client.tipoDoc = "6";
        boleta.client.rznSocial = art.cliente.razon_social;
      }

      boleta.client.numDoc = art.cliente.num_documento;
      boleta.client.address.direccion = art.cliente.direccion;

      /*company*/
      boleta.company.ruc = "20605174095";
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      let total = 0;
      art.detalleVenta.forEach(function (value: any) {

        let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
        detalleBoleta.codProducto = value.codProductob.codigo;
        detalleBoleta.descripcion = value.codProductob.nombre;
        detalleBoleta.mtoValorUnitario = value.mtoValorUnitario;

        detalleBoleta.unidad = value.unidadmedida;
        detalleBoleta.cantidad = value.cantidad;
        detalleBoleta.mtoValorVenta = value.cantidad * value.mtoValorUnitario;
        detalleBoleta.mtoBaseIgv = value.cantidad * value.mtoValorUnitario;
        detalleBoleta.igv = (value.cantidad * value.mtoValorUnitario) * Global.BASE_IGV;
        detalleBoleta.totalImpuestos = (value.cantidad * value.mtoValorUnitario) * Global.BASE_IGV;
        detalleBoleta.mtoPrecioUnitario = value.mtoValorUnitario + (value.mtoValorUnitario * Global.BASE_IGV);
        total = total + (value.cantidad * value.mtoValorUnitario);
        detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100
        detalleBoleta.tipAfeIgv = 10;
        console.log("total", total);
        boleta.details.push(detalleBoleta);
      });
      this.api.getNumeroALetras(total +(total * Global.BASE_IGV)).subscribe(data => {
        boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" }];
      });

      boleta.mtoOperGravadas = total;
      boleta.mtoOperExoneradas= 0,
      boleta.mtoIGV = total * Global.BASE_IGV;
      boleta.totalImpuestos = total * Global.BASE_IGV;
      boleta.valorVenta = total,
      boleta.mtoImpVenta = total + (total * Global.BASE_IGV),
      boleta.company = this.company;


      setTimeout(() => {
        
        this.api.GuardarComprobante(boleta).subscribe(
          data => {

            if(art.cliente.razon_social){
            this.api.GuardarFactura(data).subscribe(dat=>{
              console.log("faccc",dat.max.ultimo_id);
              console.log("dddd",dat['max'].ultimo_id)
              boleta.correlativo=dat['max'];
              art.nro_comprobante=dat.max.ultimo_id.toString();
          
          });
        }

        if(art.cliente.nombre){
          this.api.GuardarBoleta(data).subscribe(dat=>{
            console.log("bollll",dat.max.ultimo_id);
            boleta.correlativo=dat['max'];
            art.nro_comprobante=dat.max.ultimo_id.toString();
        
        });
      }

            if (data.sunatResponse.success) {
              this.toastr.success(data.sunatResponse.cdrResponse.description);
            } else {
              this.toastr.error(art.comprobante + " no recibida");
            }
          });
        if (art.imprimir) {
          sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo,'https://facturacion.apisperu.com/api/v1/note/send');
        }

        if (art) {
          console.log("arrrt",art);
        this.api.GuardarVenta(art).subscribe(data => {
          this.toastr.success(data['messaje']);
        },
          error => { console.log(error) }
        );
        this.renderDataTable();
        }
        
      },6000);
      

    }


    }


}
