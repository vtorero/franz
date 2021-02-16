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
import { DetalleVenta } from '../modelos/detalleVenta';
import { Venta } from '../modelos/ventas';
import { AgregarventaComponent } from './agregarventa/agregarventa.component';
import { EditarVentaComponent } from './editar-venta/editar-venta.component';


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
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.css']
})
export class VentasComponent implements OnInit {
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


  /*getID(){
    this.api.getMaxId('facturas').subscribe(id=>{
      this.boletacorrelativo=id[0].ultimo.toString();
      console.log("boleee",this.boletacorrelativo)
    });
  }*/

  renderDataTable() {
    this.api.getApi('ventas').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }
  ngOnInit() {
    this.renderDataTable();
 }

  agregarVenta() {
    const dialogo1 = this.dialog.open(AgregarventaComponent, {
      data: new Venta(0, localStorage.getItem("currentId"), 0, 0, 0, '','', this.Moment, Global.BASE_IGV, 0, 0, [], false,0)
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }

  replaceStr(str, find, replace) {
    for (var i = 0; i < find.length; i++) {
      str = str.replace(new RegExp(find[i], 'gi'), replace[i]);
    }
    return str;
  }

  agregar(art: Venta) {
    
    if (art.comprobante != 'Pendiente') {
      let fec1;
      let fecha1;
      var boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0,0, '', [], [{ code: '', value: '' }]);
 
      boleta.fechaEmision = art.fecha;
      fec1 = art.fecha.toDateString().split(" ", 4);
      var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];

      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      boleta.fechaEmision = fecha1;
      boleta.tipoMoneda = "PEN";
      boleta.ublVersion = "2.1";

      /**cliente*/
      if (art.cliente.nombre) {
        boleta.tipoOperacion = "0101";
        boleta.tipoDoc = "03";
        boleta.serie = "B001";
        boleta.correlativo = this.boletacorrelativo;
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
      }
      if (art.cliente.razon_social) {
        boleta.tipoOperacion = "0101";
        boleta.tipoDoc = "01";
        boleta.serie = "F001";
        this.api.getMaxId('facturas').subscribe(id=>{
        boleta.correlativo=id[0].ultimo.toString();
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
        art.nro_comprobante=boleta.serie + boleta.correlativo;
        this.api.GuardarComprobante(boleta).subscribe(
          data => {
            this.api.GuardarFactura(data).subscribe(dat=>{console.log(dat)});
            console.log("factura",data);
            if (data.sunatResponse.success) {
              this.toastr.success(data.sunatResponse.cdrResponse.description);
            } else {
              this.toastr.error(art.comprobante + " no recibida");
            }
          });
        if (art.imprimir) {
          sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo,'https://facturacion.apisperu.com/api/v1/invoice/pdf');
        }
        
      },6000);
      

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
  }

  abrirEditar(cod: Venta) {
    const dialogo2 = this.dialog2.open(EditarVentaComponent, {
      data: cod
    });
    dialogo2.afterClosed().subscribe(art => {
      if (art != undefined)
        this.editar(art);
      //this.renderDataTable();
    });
  }

  editar(art) {
    console.log(art);
    let fech;
    let boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0, 0, 0,0, '', [], [{ code: '', value: '' }]);
    fech=art.fecha+"T00:00:00-05:00"
    boleta.fechaEmision = fech  ;
    boleta.tipoMoneda = "PEN";
    boleta.ublVersion = "2.1";

    /**cliente*/
    if (art.comprobante=='Boleta') {
      boleta.tipoOperacion = "0101";
      boleta.tipoDoc = "03";
      boleta.serie = "B001";
      boleta.correlativo = art.nro_comprobante.substring(4,10);
      boleta.client.tipoDoc = "1";
      boleta.client.rznSocial = art.cliente;
    }
    if (art.comprobante=='Factura') {
      boleta.tipoOperacion = "1001";
      boleta.tipoDoc = "01";
      boleta.serie = "F001";
      boleta.correlativo = art.nro_comprobante.substring(4,10);
      boleta.client.tipoDoc = "6";
      boleta.client.rznSocial = art.cliente;
    }

    boleta.client.numDoc = art.num_documento;
    boleta.client.address.direccion = art.direccion;

    /*company*/
    boleta.company.ruc = "20605174095";
    boleta.company.razonSocial = "VVIAN FOODS S.A.C";
    boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
    let total = 0;
    art.detalleVenta.forEach(function (value: any) {
      
      let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
      detalleBoleta.codProducto = value.codigo;
      detalleBoleta.descripcion = value.nombre;
      detalleBoleta.mtoValorUnitario = Number(value.precio);
      detalleBoleta.unidad = value.unidad_medida;
     
      detalleBoleta.cantidad = Number(value.cantidad);
      detalleBoleta.mtoValorVenta = Number(value.precio) * Number(value.cantidad);
      detalleBoleta.mtoBaseIgv = Number(value.precio);
      detalleBoleta.igv = Number(value.precio) * Global.BASE_IGV;
      detalleBoleta.totalImpuestos = Number(value.precio) * Global.BASE_IGV;
      detalleBoleta.mtoPrecioUnitario = Number(value.precio) + (value.precio * Global.BASE_IGV);
      detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100
      detalleBoleta.tipAfeIgv = 10;
      boleta.details.push(detalleBoleta);
    });

    boleta.mtoOperGravadas = Number(art.valor_neto);
    boleta.mtoIGV = Number(art.monto_igv);
    boleta.totalImpuestos = Number(art.monto_igv);
    boleta.valorVenta = Number(art.valor_total),
      boleta.mtoImpVenta = Number(art.valor_total),
      boleta.company = this.company;
    this.api.getNumeroALetras(art.valor_total).subscribe(data => {
      boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" }];
    });

    setTimeout(() => {
      console.log("boletaaaa",boleta);
      sendInvoice(JSON.stringify(boleta), boleta.serie + art.id,'https://facturacion.apisperu.com/api/v1/invoice/pdf');
    },2000);

  }

  cancelar() {
    this.dialog.closeAll();
    this.cancela = true;
  }
}
