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
import { AddnotaComponent } from './addnota/addnota.component';
import { VernotaComponent } from './vernota/vernota.component';

function sendInvoice(data, nro, url) {
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
      link.download = "nota-" + nro + ".pdf";
      link.click();
    });
}


@Component({
  selector: 'app-notacredito',
  templateUrl: './notacredito.component.html',
  styleUrls: ['./notacredito.component.css']
})
export class NotacreditoComponent implements OnInit {
  cargando: boolean = false;
  dataSource: any;
  dataDetalle: any;
  public boletacorrelativo: string;
  public Moment = new Date();
  client: any;
  letras: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '');
   
  company: Company = new Company('', '', { direccion: '' });
  cliente: Client = new Client('', '', '', { direccion: '' });
  boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0,0, '', [], [{ code: '', value: '' }]);
  cancela: boolean = false;
  displayedColumns = ['nro_nota', 'cliente', 'tipDocAfectado', 'NombreDoc', 'numDocfectado', 'fecha', 'valor_total', 'opciones'];
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

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim();
    filterValue = filterValue.toLowerCase();
    this.dataSource.filter = filterValue;
  }


  ngOnInit() {
    this.renderDataTable();
  }

  abrirEditar(cod: NotaCredito) {
    console.log(cod);
    const dialogo2 = this.dialog2.open(VernotaComponent, {
      data: cod,
      disableClose: true
    });
    dialogo2.afterClosed().subscribe(art => {
      if (art && !this.cancela) {
        console.log(art)
        this.editar(art);
        this.renderDataTable();
      }
      this.cancela = false
    });
  }

  agregarNota() {
    const dialogo1 = this.dialog.open(AddnotaComponent, {
      data: new Venta(0, localStorage.getItem("currentId"), 0, 0, 0, '', '', this.Moment, Global.BASE_IGV, 0, 0, [], false, '', 0, '',this.boleta),
      disableClose: true
    });
    dialogo1.afterClosed().subscribe(art => {
      console.log("notaaaa", art.detalleVenta.length);
      if (art != undefined) {
        if (art.detalleVenta.length == 0) {
          this.toastr.error("Debe indicar los Items de la nota");
        } else {
          this.agregar(art);
          this.renderDataTable();
        }
      }
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
    console.log("nota", art);
    if (art) {
      let fec1;
      let fecha1;
      var boleta: Nota = new Nota('', '', '', '', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0, 0, '', [], [{ code: '', value: '' }]);
      fec1 = art.fecha.toDateString().split(" ", 4);
      var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];

      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      boleta.fechaEmision = fecha1;
      boleta.tipoMoneda = "PEN";
      boleta.ublVersion = "2.1";
      boleta.tipDocAfectado = art.tipDocAfectado;
      boleta.tipoDoc = art.tipoDoc;
      boleta.codMotivo = art.codMotivo;
      boleta.desMotivo = art.desMotivo;
      boleta.numDocfectado = art.numDocfectado;
      /**cliente*/
      if (art.cliente.nombre) {
        boleta.serie = "BB01";
        this.api.getMaxId('notascredito').subscribe(id => {
          boleta.correlativo = id[0].ultimo.toString();
          art.nro_comprobante = "BB01" + id[0].ultimo.toString();
          art.comprobante = 'Boleta';
          art.nro_nota = boleta.serie + '-' + boleta.correlativo;
        });
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
      }
      if (art.cliente.razon_social) {
        boleta.serie = "FF01";
        this.api.getMaxId('notascredito').subscribe(id => {
          boleta.correlativo = id[0].ultimo.toString();
          art.nro_comprobante = "FF01" + id[0].ultimo.toString();
          art.comprobante = 'Factura';
          art.nro_nota = boleta.serie + '-' + boleta.correlativo;
        });
        boleta.client.tipoDoc = "6";
        boleta.client.rznSocial = art.cliente.razon_social;
      }

      boleta.client.numDoc = art.cliente.num_documento;
      boleta.client.address.direccion = art.cliente.direccion;

      /*company*/
      boleta.company.ruc = Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      let total = 0;
      art.detalleVenta.forEach(function (value: any) {

        let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
        detalleBoleta.codProducto = value.codProducto.codigo;
        detalleBoleta.descripcion = value.codProducto.nombre;
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
        boleta.details.push(detalleBoleta);
      });
      this.api.getNumeroALetras(total + (total * Global.BASE_IGV)).then(data => {
        boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" }]



        boleta.mtoOperGravadas = total;
        boleta.mtoOperExoneradas = 0,
          boleta.mtoIGV = total * Global.BASE_IGV;
        boleta.totalImpuestos = total * Global.BASE_IGV;
        //boleta.valorVenta = total,
        boleta.mtoImpVenta = total + (total * Global.BASE_IGV),
          boleta.company = this.company;

        this.api.sendNotaSunat(boleta).subscribe(data => {
          if (art) {
            this.api.GuardarNota(data).subscribe(dat => {
              boleta.correlativo = dat['max'];
              art.nro_comprobante = dat.max.ultimo_id.toString();
            });
          }
          if (data.sunatResponse.success) {
            this.toastr.info(data.sunatResponse.cdrResponse.description, "Mensaje Sunat");
          } else {
            this.toastr.error(art.comprobante + " no recibida");
          }
        });

        if (art.imprimir) {
          sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo, 'https://facturacion.apisperu.com/api/v1/note/pdf');
        }


        if (art) {
          this.api.GuardarNotaCredito(art).subscribe(data => {
            this.toastr.success(data['messaje']);
          },
            error => { console.log(error) }
          );

        }
        //      }, 6000);
      });
  
    }

    setTimeout(() => {
      this.cargando = false;
      this.renderDataTable();
    }, 3000);
  }



  editar(art: NotaCredito) {
    this.cargando = true;
    if (art) {
      let fech;
      var boleta: Nota = new Nota('', '', '', '', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0, 0, '', [], [{ code: '', value: '' }]);
      fech = art.fecha + "T00:00:00-05:00";
      boleta.fechaEmision = fech;
      boleta.tipoMoneda = "PEN";
      boleta.ublVersion = "2.1";
      boleta.tipDocAfectado = art.tipDocAfectado;
      boleta.tipoDoc = art.tipoDoc;
      boleta.codMotivo = art.codMotivo;
      boleta.desMotivo = art.desMotivo;
      boleta.numDocfectado = art.numDocfectado;
      /**cliente*/
      if (art.tipDocAfectado == 'Boleta') {
        boleta.serie = "BB01";
        boleta.correlativo = art.nro_nota.substring(5, 10);
        art.comprobante = 'Boleta';
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente;
      }

      if (art.tipDocAfectado == 'Factura') {
        boleta.serie = "FF01";
        boleta.correlativo = art.nro_nota.substring(5, 10);
        boleta.client.tipoDoc = "6";
        boleta.client.rznSocial = art.cliente.razon_social;
      }

      boleta.client.numDoc = art.num_documento;
      boleta.client.address.direccion = art.direccion;

      /*company*/
      boleta.company.ruc = Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      let total = 0;
      art.detalleVenta.forEach(function (value: any) {

        let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
        detalleBoleta.codProducto = value.codigo;
        detalleBoleta.descripcion = value.nombre;
        detalleBoleta.mtoValorUnitario = value.precio;

        detalleBoleta.unidad = value.unidadmedida;
        detalleBoleta.cantidad = value.cantidad;
        detalleBoleta.mtoValorVenta = value.cantidad * value.precio;
        detalleBoleta.mtoBaseIgv = value.cantidad * value.precio;
        detalleBoleta.igv = (value.cantidad * value.precio) * Global.BASE_IGV;
        detalleBoleta.totalImpuestos = (value.cantidad * value.precio) * Global.BASE_IGV;
        detalleBoleta.mtoPrecioUnitario = value.precio + detalleBoleta.totalImpuestos;
        total = total + (value.cantidad * value.precio);
        detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100
        detalleBoleta.tipAfeIgv = 10;
        boleta.details.push(detalleBoleta);
      });
      this.api.getNumeroALetras(art.valor_total).then(data => {
        boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" }];
        boleta.mtoOperGravadas = total;
        boleta.mtoOperExoneradas = 0,
          boleta.mtoIGV = total * Global.BASE_IGV;
        boleta.totalImpuestos = total * Global.BASE_IGV;
        boleta.mtoImpVenta = total + (total * Global.BASE_IGV),
          boleta.company = this.company;

        console.log("boleta", boleta);
        sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo, 'https://facturacion.apisperu.com/api/v1/note/pdf');
        this.cargando = false;
      });

    }
  }


}