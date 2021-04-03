import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Global } from '../global';
import { Client } from '../modelos/Boleta/client';
import { Company } from '../modelos/Boleta/company';
import { Destinatario } from '../modelos/destinatario';
import { DetalleVenta } from '../modelos/detalleVenta';
import { Envio } from '../modelos/envio';
import { Guia } from '../modelos/guia';
import { Guiadetalle } from '../modelos/guiadetalle';
import { Remision } from '../modelos/remision';
import { Transportista } from '../modelos/transportista';
import { AddGuiaComponent } from './add-guia/add-guia.component';
import { EditGuiaComponent } from './edit-guia/edit-guia.component';


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
  company: Company = new Company('', '', {ubigueo:'',codigoPais:'',departamento:'',provincia:'',distrito:'',urbanizacion:'',direccion:''});
  cliente: Client = new Client('', '', '', { direccion: '' });
  destinatario: Destinatario= new Destinatario(0,'','','',{direccion:''});
  transportista= new Transportista('','','','','','');
  envio : Envio= new Envio('','','','','','',0,'',0,{ubigueo:'',direccion:''},{ubigueo:'',direccion:''},this.transportista);
  cancela: boolean = false;
  displayedColumns = ['numero', 'doc', 'destinatario', 'fechaemision', 'observacion', 'nombre_transportista','nro_placa' ,'opciones'];
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

  agregarGuia() {
    const dialogo1 = this.dialog.open(AddGuiaComponent, {
      data: new Guia(0,localStorage.getItem("currentUser"),'',[],"","","","","",0,"","",this.Moment,0,0,0,[],false,"","150108","AV.LAS GAVIOTAS 925","",""),
      disableClose: true,
      panelClass: 'my-dialog'
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        if (art.detalleVenta.length == 0) {
          this.toastr.warning("Debe agregar el detalle de la guía", "Aviso");
        } else {
          this.agregar(art);
        }
    });
  }

  abrirEditar(cod: Guia) {
    console.log(cod);
    const dialogo2 = this.dialog2.open(EditGuiaComponent, {
      data: cod,
      disableClose: true
    });
    dialogo2.afterClosed().subscribe(art => {
      if (art != undefined){
       this.editar(art);
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
    this.cargando = true;
      let fec1;
      let fecha1;
     //var boleta:any;
      var boleta: Remision = new Remision('','','',this.destinatario,this.Moment,this.company,this.envio,[],"",localStorage.getItem("currentUser"));
      fec1 = art.fechaemision.toDateString().split(" ", 4);
      var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];

      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      /*Instancia Guia*/

      /*cabecera*/
      boleta.tipoDoc = "09";
      boleta.serie = "T001";
      this.api.getMaxId('guias').subscribe(id => {
      boleta.correlativo = id[0].ultimo.toString();
      });
      boleta.fechaemision = fecha1;
      boleta.company.ruc = Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      
      /*Destinatario*/
      boleta.destinatario.id=art.destinatario.id;
      boleta.destinatario.tipoDoc=art.tipo_destinatario;
      if(art.tipo_destinatario=='1'){
      boleta.destinatario.numDoc=art.destinatario.num_documento;
      boleta.destinatario.rznSocial=art.destinatario.nombre +' '+ art.destinatario.apellido;
      }

      if(art.tipo_destinatario=='6'){
        boleta.destinatario.numDoc=art.destinatario.num_documento;
        boleta.destinatario.rznSocial=art.destinatario.razon_social;
        }

      boleta.destinatario.address.direccion=art.llegada;
      boleta.observacion=art.observacion;

      boleta.envio.modTraslado="01";
      boleta.envio.codTraslado= "01"
      boleta.envio.desTraslado="VENTA"
      boleta.envio.fecTraslado= fecha1;
      boleta.envio.codPuerto= "123";
      boleta.envio.pesoTotal= art.peso_bruto;
      boleta.envio.undPesoTotal='KGM';
      boleta.envio.numBultos= art.nro_bultos;
      boleta.envio.transportista.tipoDoc="6"
      boleta.envio.transportista.numDoc= "";
      boleta.envio.transportista.rznSocial=art.nombre_transportista; 
      boleta.envio.transportista.placa= art.nro_placa;
      boleta.envio.transportista.choferTipoDoc= "1";
      boleta.envio.transportista.choferDoc=art.nro_transportista
      boleta.envio.llegada.ubigueo= art.ubigeo_llegada;
      boleta.envio.llegada.direccion= art.llegada;
      boleta.envio.partida.ubigueo="150108"
      boleta.envio.partida.direccion= "AV.LAS GAVIOTAS 925";
        
      
      art.detalleVenta.forEach(function (value: any) {
      let detalleBoleta: Guiadetalle = new Guiadetalle('','', '', '',0);
        detalleBoleta.id = value.codProductob.id;  
        detalleBoleta.codigo = value.codProductob.codigo;
        detalleBoleta.descripcion = value.codProductob.nombre;
        detalleBoleta.unidad = value.unidadmedida;
        detalleBoleta.cantidad = value.cantidad;
        boleta.details.push(detalleBoleta);
      });

      this.api.GuardarGuia(boleta).subscribe(data => {
        this.toastr.success(data['messaje']);
      },
        error => { console.log(error)});
      
    if (art.imprimir) {
        sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo, 'https://facturacion.apisperu.com/api/v1/despatch/pdf');
      }

    setTimeout(() => {
      this.cargando=false;
      this.renderDataTable();
      
    }, 3000);

  }


  editar(art: Guia) {
    console.log(art);
    this.cargando = true;
      let fec1;
      let fecha1;
     //var boleta:any;
      var boleta: Remision = new Remision('','','',this.destinatario,this.Moment,this.company,this.envio,[],"",localStorage.getItem("currentUser"));
      /* var find = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var replace = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
      fecha1 = fec1[3] + '-' + this.replaceStr(fec1[1], find, replace) + '-' + fec1[2] + "T00:00:00-05:00";
      /*Instancia Guia*/
      fec1=boleta.fechaemision+"T00:00:00-05:00"
      /*cabecera*/
      boleta.tipoDoc = "09";
      boleta.serie = "T001";
      boleta.correlativo = art.id;
      boleta.fechaemision = fec1;
      boleta.company.ruc = Global.RUC_EMPRESA;
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";
      
      /*Destinatario*/
      boleta.destinatario.id=art.destinatario.id;
      boleta.destinatario.tipoDoc=art.tipo_destinatario;
      if(art.tipo_destinatario=='1'){
      boleta.destinatario.numDoc=art.num_documento;
      boleta.destinatario.rznSocial=art.destinatario;
      }

      if(art.tipo_destinatario=='6'){
        boleta.destinatario.numDoc=art.num_documento;
        boleta.destinatario.rznSocial=art.destinatario;
        }

      boleta.destinatario.address.direccion=art.llegada;
      boleta.observacion=art.observacion;

      boleta.envio.modTraslado="01";
      boleta.envio.codTraslado= "01"
      boleta.envio.desTraslado="VENTA"
      boleta.envio.fecTraslado= fecha1;
      boleta.envio.codPuerto= "123";
      boleta.envio.pesoTotal= art.peso_bruto;
      boleta.envio.undPesoTotal='KGM';
      boleta.envio.numBultos= art.nro_bultos;
      boleta.envio.transportista.tipoDoc="6"
      boleta.envio.transportista.numDoc= "";
      boleta.envio.transportista.rznSocial=art.nombre_transportista; 
      boleta.envio.transportista.placa= art.nro_placa;
      boleta.envio.transportista.choferTipoDoc= "1";
      boleta.envio.transportista.choferDoc=art.nro_transportista
      boleta.envio.llegada.ubigueo= art.ubigeo_llegada;
      boleta.envio.llegada.direccion= art.llegada;
      boleta.envio.partida.ubigueo="150108"
      boleta.envio.partida.direccion= "AV.LAS GAVIOTAS 925";
        
      
      art.detalleVenta.forEach(function (value: any) {
      let detalleBoleta: Guiadetalle = new Guiadetalle('','', '', '',0);
        detalleBoleta.id = value.id;  
        detalleBoleta.codigo = value.codigo;
        detalleBoleta.descripcion = value.nombre;
        detalleBoleta.unidad = value.unidad;
        detalleBoleta.cantidad = value.cantidad;
        boleta.details.push(detalleBoleta);
      });

        sendInvoice(JSON.stringify(boleta), boleta.serie + boleta.correlativo, 'https://facturacion.apisperu.com/api/v1/despatch/pdf');
    
    this.cargando=false;
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
