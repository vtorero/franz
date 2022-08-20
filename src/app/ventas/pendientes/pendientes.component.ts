import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../../api.service';
import { Global } from '../../global';
import { Boleta } from '../../modelos/Boleta/boleta';
import { Client } from '../../modelos/Boleta/client';
import { Company } from '../../modelos/Boleta/company';
import { Details } from '../../modelos/Boleta/details';
import { DetalleVenta } from '../../modelos/detalleVenta';
import { Venta } from '../../modelos/ventas';
import { AgregarventaComponent } from '../agregarventa/agregarventa.component';
import { EditarVentaComponent } from '..//editar-venta/editar-venta.component';


function sendInvoice(data,nro,url) {
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
  selector: 'app-pendientes',
  templateUrl: './pendientes.component.html',
  styleUrls: ['./pendientes.component.css']
})
export class PendientesComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  public boletacorrelativo:string;
  public Moment = new Date();
  cargando:boolean=false;
  client: any;
  letras: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '');
  company: Company = new Company('', '', {ubigueo:'',codigoPais:'',departamento:'',provincia:'',distrito:'',urbanizacion:'',direccion:''});
  cliente: Client = new Client('', '', '', { direccion: '' });
  cancela: boolean = false;
  boleta: Boleta = new Boleta('','', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0,0, 0, 0,0,0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:'',monto:0},[]);
  displayedColumns=['comprobante','cliente', 'fecha','observacion','valor_total', 'opciones'];
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


  getID(){
    this.api.getMaxId('facturas').subscribe(id=>{
      this.boletacorrelativo=id[0].ultimo.toString();
      console.log("boleee",this.boletacorrelativo);
    });
  }
  ngOnInit() {
    this.renderDataTable();
 }

  agregarVenta() {
    const dialogo1 = this.dialog.open(AgregarventaComponent, {
      data: new Venta(0,localStorage.getItem("currentId"),'', 0, 0, '','',this.Moment, this.Moment, Global.BASE_IGV, 0, 0, [], false,'',0,'',this.boleta,''),
      disableClose: true,

    });

    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
      if (art.detalleVenta.length==0 && this.cancela) {
        this.toastr.warning("Debe agregar el detalle del comprobante","Aviso");
      } else {
        this.agregar(art);
       }
    });
  }



  replaceStr(str, find, replace) {
    for (var i = 0; i < find.length; i++) {
      str = str.replace(new RegExp(find[i], 'gi'), replace[i]);
    }
    return str;
  }

  agregar(art: Venta) {
       this.cargando=true;
    if (art.comprobante != 'Pendiente') {
      let fec1;
      let fecha1;
      var boleta: Boleta = new Boleta('','', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0,0,0, 0, 0,0,0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:'',monto:0},[]);
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
          art.nro_comprobante="B001-"+id[0].ultimo.toString();
          });
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
      }
      if (art.cliente.razon_social) {
        boleta.tipoDoc = "01";
        boleta.serie = "F001";
        this.api.getMaxId('facturas').subscribe(id=>{
        boleta.correlativo=id[0].ultimo.toString();
        art.nro_comprobante="F001-"+id[0].ultimo.toString();
        });
        boleta.client.tipoDoc = "6";
        boleta.client.rznSocial = art.cliente.razon_social;
      }

      boleta.client.numDoc = art.cliente.num_documento;
      boleta.client.address.direccion = art.cliente.direccion;

      /*company*/
      boleta.company.ruc =  Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      let total = 0;
      art.detalleVenta.forEach(function (value: any) {

        let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0,0);
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
        boleta.details.push(detalleBoleta);
      });

      boleta.mtoOperGravadas = total;
      boleta.mtoOperExoneradas= 0,
      boleta.mtoIGV = total * Global.BASE_IGV;
      boleta.totalImpuestos = total * Global.BASE_IGV;
      boleta.valorVenta = total,
      boleta.mtoImpVenta = total + (total * Global.BASE_IGV),
      boleta.company = this.company;

      this.api.getNumeroALetras(total +(total * Global.BASE_IGV)).then(data => {
        boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES"+ "<hr>Observación: "+art.observacion }];

      //setTimeout(() => {
        this.api.GuardarComprobante(boleta).subscribe(
          data => {
            if (data.sunatResponse.success) {
              this.toastr.info(data.sunatResponse.cdrResponse.description,"Mensaje Sunat");

              if(art.cliente.razon_social){
                this.api.GuardarFactura(data).subscribe(dat=>{
                  boleta.correlativo=dat['max'];
                  art.nro_comprobante=dat.max.ultimo_id.toString();
              });
            }
          if(art.cliente.nombre){
              this.api.GuardarBoleta(data).subscribe(dat=>{
                boleta.correlativo=dat['max'];
                art.nro_comprobante=dat.max.ultimo_id.toString();
            });
          }

                this.api.GuardarVenta(art).subscribe(data => {
                  this.toastr.success(data['messaje']);
                },
                  error => { console.log(error) }
                );
            } else {
              this.toastr.error(art.comprobante + " no recibida");
            }

          });

        if (art.imprimir) {
          sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo,'https://facturacion.apisperu.com/api/v1/invoice/pdf');
        }
        this.cargando=false;
     // },6500);
    });
    }else{
      this.api.GuardarVenta(art).subscribe(data => {
        this.toastr.success(data['messaje']);
      },
        error => { console.log(error) }
      );
      this.cargando=false;
    }


      setTimeout(() => {
        console.log("redeeeee");
      this.renderDataTable();
      },3000);

    }


  abrirEditar(cod: Venta) {
    const dialogo2 = this.dialog2.open(EditarVentaComponent, {
      data: cod,
      disableClose: true
    });
    dialogo2.afterClosed().subscribe(art => {
      if (art != undefined){
      console.log("cargans",this.cargando);
       this.editar(art);
      }
    });
  }

  editar(art) {
    this.cargando=true;
    let fech;
    let boleta: Boleta = new Boleta('','', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0,0,0, 0,0,0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:'',monto:0},[]);
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
      boleta.tipoOperacion = "0101";
      boleta.tipoDoc = "01";
      boleta.serie = "F001";
      boleta.correlativo = art.nro_comprobante.substring(4,10);
      boleta.client.tipoDoc = "6";
      boleta.client.rznSocial = art.cliente;
    }

    boleta.client.numDoc = art.num_documento;
    boleta.client.address.direccion = art.direccion;

    /*company*/
    boleta.company.ruc = Global.RUC_EMPRESA;
    boleta.company.razonSocial = "VVIAN FOODS S.A.C";
    boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
    let total = 0;
    art.detalleVenta.forEach(function (value: any) {

      let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0,0);
      detalleBoleta.codProducto = value.codigo;
      detalleBoleta.unidad = value.unidad_medida;
      detalleBoleta.descripcion = value.nombre;
      detalleBoleta.cantidad = Number(value.cantidad);
      detalleBoleta.mtoValorUnitario = Number(value.precio);
      detalleBoleta.mtoValorVenta = Number(value.precio) * Number(value.cantidad);
      detalleBoleta.mtoBaseIgv = Number(value.precio) * Number(value.cantidad);
      detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100;
      detalleBoleta.igv = (Number(value.precio) * Number(value.cantidad)) * Global.BASE_IGV;
      detalleBoleta.totalImpuestos = (Number(value.precio) * Number(value.cantidad)) * Global.BASE_IGV;
      detalleBoleta.mtoPrecioUnitario = Number(value.precio) + (value.precio * Global.BASE_IGV);

      detalleBoleta.tipAfeIgv = 10;
      boleta.details.push(detalleBoleta);
    });

    boleta.mtoOperGravadas = Number(art.valor_neto);
    boleta.mtoIGV = Number(art.monto_igv);
    boleta.totalImpuestos = Number(art.monto_igv);
    boleta.valorVenta = Number(art.valor_neto),
    boleta.mtoImpVenta = Number(art.valor_total),
    boleta.company = this.company;
    this.api.getNumeroALetras(art.valor_total).then(data => {
      boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" + "<hr>Observación: "+art.observacion }];


  //  setTimeout(() => {
      sendInvoice(JSON.stringify(boleta), boleta.serie + art.id,'https://facturacion.apisperu.com/api/v1/invoice/pdf');
      this.cargando=false;
   // },1000);
  });
  }

  cancelar() {
    this.dialog.closeAll();
    this.cancela = false;
  }
  renderDataTable() {
    console.log("redner");
    this.api.getApi('pendientes').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
      console.log("render");
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

}