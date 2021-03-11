import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Global } from '../global';
import { Client } from '../modelos/Boleta/client';
import { Company } from '../modelos/Boleta/company';
import { Details } from '../modelos/Boleta/details';
import { Destinatario } from '../modelos/destinatario';
import { DetalleVenta } from '../modelos/detalleVenta';
import { Envio } from '../modelos/envio';
import { Guia } from '../modelos/guia';
import { Remision } from '../modelos/remision';
import { Transportista } from '../modelos/transportista';
import { AddGuiaComponent } from './add-guia/add-guia.component';


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
      link.download = "comprobante-" + nro + ".pdf";
      link.click();
    });
}

@Component({
  selector: 'app-remision',
  templateUrl: './remision.component.html',
  styleUrls: ['./remision.component.css']
})
export class RemisionComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  public boletacorrelativo: string;
  public Moment = new Date();
  cargando: boolean = false;
  client: any;
  letras: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '');
  company: Company = new Company('', '', { direccion: '' });
  cliente: Client = new Client('', '', '', { direccion: '' });
  destinatario: Destinatario= new Destinatario('','','',{direccion:''});
  transportista= new Transportista('','','','','','');
  envio : Envio= new Envio('','','','','','',0,'',0,'','','','',this.transportista);
  cancela: boolean = false;
  displayedColumns = ['nro_comprobante', 'comprobante', 'cliente', 'fecha', 'observacion', 'valor_total', 'opciones'];
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


  getID() {
    this.api.getMaxId('facturas').subscribe(id => {
      this.boletacorrelativo = id[0].ultimo.toString();
      console.log("boleee", this.boletacorrelativo);
    });
  }
  ngOnInit() {
    this.renderDataTable();
  }

  agregarVenta() {
    const dialogo1 = this.dialog.open(AddGuiaComponent, {
      data: new Guia(localStorage.getItem("currentUser"),0,"","","","","",0,"","","",0,0,0,[],false,"","150108","AV.LAS GAVIOTAS 925","",""),
      disableClose: true,
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        if (art.detalleVenta.length == 0 && this.cancela) {
          this.toastr.warning("Debe agregar el detalle de la guía", "Aviso");
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

  agregar(art: Guia) {
    console.log("Guia",art);
    this.cargando = true;
      let fec1;
      let fecha1;
     //var boleta:any;
      var boleta: Remision = new Remision('','','',this.destinatario,'','','','','',this.company,0,0,this.envio,[],"");
      fec1 = art.fecha.toDateString().split(" ", 4);
      var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      /*Instancia Guia*/

      /*cabecera*/
      boleta.tipoDoc = "09";
      boleta.serie = "T001";
      /*this.api.getMaxId('guiaremision').subscribe(id => {
      boleta.correlativo = id[0].ultimo.toString();
      art.nro_guia = "T001-" + id[0].ultimo.toString()});*/
      boleta.correlativo="1";
      boleta.fechaEmision = fecha1;
      boleta.company.ruc = Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      
      /*Destinatario*/
      boleta.destinatario.tipoDoc='1'
      boleta.destinatario.numDoc= art.nro_documento;
      boleta.destinatario.rznSocial=art.name_destinatario;
      boleta.destinatario.address.direccion=art.llegada;
      boleta.observacion="NOTA OBSERVACIONES";


      
      boleta.envio.modTraslado="01";
      boleta.envio.codTraslado= "01"
      boleta.envio.desTraslado="VENTA"
      boleta.envio.fecTraslado= fecha1;
      boleta.envio.codPuerto= "123";
      boleta.envio.pesoTotal= 12.6;
      boleta.envio.undPesoTotal='KGM';
      boleta.envio.numBultos= 3;
      
      boleta.envio.ubigueo_llegada= "201121";
      boleta.envio.direccion_llegada= "AV LIMA";
      boleta.envio.ubigueo_partida="150203";
      boleta.envio.direccion_llegada= "AV ITALIA";
        
      
      boleta.envio.transportista.tipoDoc="6"
      boleta.envio.transportista.numDoc= "20521048825"
      boleta.envio.transportista.rznSocial= "TRANSPORTES"
      boleta.envio.transportista.placa= "ABI-453";
      boleta.envio.transportista.choferTipoDoc= "1";
      boleta.envio.transportista.choferDoc="40003344";
      
      art.detalleVenta.forEach(function (value: any) {
      let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
        detalleBoleta.codProducto = value.codProductob.codigo;
        detalleBoleta.descripcion = value.codProductob.nombre;
        detalleBoleta.mtoValorUnitario = value.mtoValorUnitario;
         detalleBoleta.unidad = value.unidadmedida;
        detalleBoleta.cantidad = value.cantidad;
        boleta.details.push(detalleBoleta);
      });

     /*
      this.api.GuardarVenta(art).subscribe(data => {
        this.toastr.success(data['messaje']);
      },
        error => { console.log(error) }
      );*/
      console.log("Guiaaaa",boleta);
    if (art.imprimir) {
        sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo, 'https://facturacion.apisperu.com/api/v1/despatch/pdf');
      }

    setTimeout(() => {
      this.renderDataTable();
    }, 3000);

  }

  cancelar() {
    this.dialog.closeAll();
    this.cancela = false;
  }
  renderDataTable() {
    console.log("redner");
    this.api.getApi('guias').subscribe(x => {
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
