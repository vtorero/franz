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
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.css']
})
export class VentasComponent implements OnInit {
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
  boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0,0,0, 0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:''});
  cancela: boolean = false;
  displayedColumns=['nro_comprobante','comprobante','cliente', 'fecha','estado','observacion','valor_total', 'opciones'];
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
      data: new Venta(0, localStorage.getItem("currentId"),'',0, 0, '','', this.Moment, Global.BASE_IGV, 0, 0, [], false,'',0,'',this.boleta),
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
      var boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0, 0,0, 0,0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:''});
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
        boleta.client.tipoDoc = "1";
        boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
        art.tipoDoc="1";
        this.api.getMaxId('boletas').subscribe(id=>{
        boleta.correlativo=id[0].ultimo.toString();
           });
      }
      if (art.cliente.razon_social) {
        boleta.tipoDoc = "01";
        boleta.serie = "F001";
        boleta.client.tipoDoc = "6";
        boleta.client.rznSocial = art.cliente.razon_social;
        art.tipoDoc="2";
        this.api.getMaxId('facturas').subscribe(id=>{
          boleta.correlativo=id[0].ultimo.toString();
             });
      }
      
      boleta.client.numDoc = art.cliente.num_documento;
      boleta.client.address.direccion = art.cliente.direccion;

      /*company*/
      boleta.company.ruc =  Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.ubigueo="150131";
      boleta.company.address.codigoPais="PE";
      boleta.company.address.departamento="LIMA";
      boleta.company.address.provincia="LIMA";
      boleta.company.address.distrito="SAN ISIDRO";
      boleta.company.address.urbanizacion="-";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      let total = 0;
      art.detalleVenta.forEach(function (value: any) {

        let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
        detalleBoleta.codProducto = value.codProductob.codigo;
        detalleBoleta.descripcion = value.codProductob.nombre;
        detalleBoleta.mtoValorUnitario = value.mtoValorUnitario;

        detalleBoleta.unidad = value.unidadmedida;
        detalleBoleta.cantidad = value.cantidad;
        detalleBoleta.mtoValorVenta = parseFloat((value.cantidad * value.mtoValorUnitario).toFixed(2));
        detalleBoleta.mtoBaseIgv = parseFloat((value.cantidad * value.mtoValorUnitario).toFixed(2));
        detalleBoleta.igv = parseFloat(((value.cantidad * value.mtoValorUnitario) * Global.BASE_IGV).toFixed(2));
        detalleBoleta.totalImpuestos = parseFloat(((value.cantidad * value.mtoValorUnitario) * Global.BASE_IGV).toFixed(2));
        detalleBoleta.mtoPrecioUnitario = value.mtoValorUnitario + (value.mtoValorUnitario * Global.BASE_IGV);
        total = total + (value.cantidad * value.mtoValorUnitario);
        detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100
        detalleBoleta.tipAfeIgv = 10;
        boleta.details.push(detalleBoleta);
      });

      boleta.mtoOperGravadas = parseFloat(total.toFixed(2));
      boleta.mtoOperExoneradas= 0,
      boleta.mtoIGV = parseFloat((total * Global.BASE_IGV).toFixed(2));
      boleta.totalImpuestos = parseFloat((total * Global.BASE_IGV).toFixed(2));
      boleta.valorVenta = parseFloat(total.toFixed(2));
      boleta.mtoImpVenta = parseFloat((total + (total * Global.BASE_IGV)).toFixed(2));
      boleta.subTotal = parseFloat((total + (total * Global.BASE_IGV)).toFixed(2));
      boleta.company = this.company;
      boleta.formaPago.moneda="PEN";
      boleta.formaPago.tipo="Contado";

      this.api.getNumeroALetras(total +(total * Global.BASE_IGV)).then(letra => {
        boleta.legends = [{ code: "1000", value: "SON " + letra + " SOLES"+ " -------------- Observación: "+art.observacion }];

      //setTimeout(() => {
        /*
        this.api.GuardarComprobante(boleta).subscribe(
          fact => {
            if (fact.sunatResponse.success) {
              this.toastr.info(fact.sunatResponse.cdrResponse.description,"Mensaje Sunat");
              
              if(art.cliente.razon_social){
                this.api.GuardarFactura(fact).subscribe(dat=>{
                  boleta.correlativo=dat['max'];
                  art.nro_comprobante=dat.max.ultimo_id.toString();
              });
            }
            if(art.cliente.nombre){
              this.api.GuardarBoleta(fact).subscribe(dat=>{
                boleta.correlativo=dat['max'];
                art.nro_comprobante=dat.max.ultimo_id.toString(); 
            });
          }

            }
            else {
             
              this.toastr.error("Factura/Boleta no recibida");
            }
            });
            */
            art.boleta=boleta;
            this.api.GuardarVenta(art).subscribe(data => {
              this.toastr.info(data['sunat'],"Mensaje Sunat");
                  this.toastr.success(data['messaje']);
                },
                  error => { console.log(error) }
            );
         
        
        if (art.imprimir) {

          


          sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo,'https://facturacion.apisperu.com/api/v1/invoice/pdf');
        }
        this.cargando=false;
    
    });
    }else{
      this.api.GuardarVenta(art).subscribe(data => {
        this.toastr.success(data['messaje']);
      },
        error => { console.log(error) }
      );
    }


      setTimeout(() => {
      this.renderDataTable();
      this.cargando=false;
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
    let boleta: Boleta = new Boleta('', '', '', '', this.Moment, '', this.cliente, this.company, 0, 0,0, 0, 0, 0,0, '', [], [{ code: '', value: '' }],{moneda:'',tipo:''});
    fech=art.fecha+"T00:00:00-05:00"
    boleta.fechaEmision = fech  ;
    boleta.tipoMoneda = "PEN";
    boleta.ublVersion = "2.1";

    /**cliente*/
    if (art.comprobante=='Boleta') {
      boleta.tipoOperacion = "0101";
      boleta.tipoDoc = "03";
      boleta.serie = "B001";
      boleta.correlativo = art.nro_comprobante.substring(5,10);
      boleta.client.tipoDoc = "1";
      boleta.client.rznSocial = art.cliente;
    }
    if (art.comprobante=='Factura') {
      boleta.tipoOperacion = "0101";
      boleta.tipoDoc = "01";
      boleta.serie = "F001";
      boleta.correlativo = art.nro_comprobante.substring(5,10);
      boleta.client.tipoDoc = "6";
      boleta.client.rznSocial = art.cliente;
    }

    boleta.client.numDoc = art.num_documento;
    boleta.client.address.direccion = art.direccion;

    /*company*/
    boleta.company.ruc = Global.RUC_EMPRESA;
    boleta.company.razonSocial = "VVIAN FOODS S.A.C";
    boleta.company.address.ubigueo="150131";
    boleta.company.address.codigoPais="PE";
    boleta.company.address.departamento="LIMA";
    boleta.company.address.provincia="LIMA";
    boleta.company.address.distrito="SAN ISIDRO";
    boleta.company.address.urbanizacion="-";
    boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
    let total = 0;
    art.detalleVenta.forEach(function (value: any) {
      
      let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
      detalleBoleta.codProducto = value.codigo;
      detalleBoleta.unidad = value.unidad_medida;
      detalleBoleta.descripcion = value.nombre;
      detalleBoleta.cantidad = Number(value.cantidad);
      detalleBoleta.mtoValorUnitario = parseFloat(Number(value.precio).toFixed(2));
      detalleBoleta.mtoValorVenta = parseFloat((Number(value.precio) * Number(value.cantidad)).toFixed(2));
      detalleBoleta.mtoBaseIgv = parseFloat((Number(value.precio) * Number(value.cantidad)).toFixed(2));
      detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100;
      detalleBoleta.igv = parseFloat(((Number(value.precio) * Number(value.cantidad)) * Global.BASE_IGV).toFixed(2));
      detalleBoleta.totalImpuestos = parseFloat(((Number(value.precio) * Number(value.cantidad)) * Global.BASE_IGV).toFixed(2));
      detalleBoleta.mtoPrecioUnitario = parseFloat((Number(value.precio) + (value.precio * Global.BASE_IGV)).toFixed(2));
      
      detalleBoleta.tipAfeIgv = 10;
      boleta.details.push(detalleBoleta);
    });

    boleta.mtoOperGravadas = parseFloat(Number(art.valor_neto).toFixed(2));
    boleta.mtoIGV = parseFloat(Number(art.monto_igv).toFixed(2));
    boleta.totalImpuestos = parseFloat(Number(art.monto_igv).toFixed(2));
    boleta.valorVenta = parseFloat(Number(art.valor_neto).toFixed(2));
    boleta.mtoImpVenta = parseFloat(Number(art.valor_total).toFixed(2));
    boleta.subTotal = parseFloat(Number(art.valor_total).toFixed(2)),
    boleta.company = this.company;
    boleta.formaPago.moneda="PEN";
      boleta.formaPago.tipo="Contado";

    this.api.getNumeroALetras(art.valor_total).then(data => {
      boleta.legends = [{ code: "1000", value: "SON " + data + " SOLES" + " | Observación: "+art.observacion }];
   

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
    this.api.getApi('ventas').subscribe(x => {
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
