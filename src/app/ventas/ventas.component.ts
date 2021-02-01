import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Boleta } from '../modelos/Boleta/boleta';
import { Client } from '../modelos/Boleta/client';
import { Company } from '../modelos/Boleta/company';
import { Details } from '../modelos/Boleta/details';
import { DetalleVenta } from '../modelos/detalleVenta';
import { Venta } from '../modelos/ventas';
import { AgregarventaComponent } from './agregarventa/agregarventa.component';

@Component({
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.css']
})
export class VentasComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  public dataClien: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
  company: Company = new Company('', '', { direccion: '' });
  client: Client = new Client('', '', '', { direccion: '' });
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
      data: new Venta(0, localStorage.getItem("currentId"), 0, 0, 0, '', '', 0, [])
    });
    dialogo1.afterClosed().subscribe(art => {
      //console.log(art);
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }



  agregar(art: Venta) {
    let cliente=this.traerClient(art.id_cliente);
    console.log("cliiii",cliente);
    let boleta: Boleta = new Boleta('', '', '', '', '', '',this.client,this.company, 0, 0, 0, 0, 0, '', [], [{ code: '', value: '' }]);
    boleta.tipoOperacion = "0101";
    boleta.tipoDoc = "03";
    boleta.serie = "B00";
    boleta.correlativo = "000";
    boleta.fechaEmision = art.fecha;
    boleta.tipoMoneda = "PEN";
    boleta.mtoIGV = 18;
    boleta.ublVersion = "2.1";
    boleta.legends=[{code:"1000",value:"SON 100 Y 00/800 SOLES"}];
  
    /**cliente*/
    boleta.client.tipoDoc="1";
    boleta.client.numDoc="25750816";
    boleta.client.rznSocial="Victor Jimenez";
    boleta.client.address.direccion="la molina"

      /*company*/
      boleta.company.ruc = "20605174095";
      boleta.company.razonSocial = "VVIAN FOODS S.A.C";
      boleta.company.address.direccion = "AV. PARDO Y ALIAGA N° 699 INT. 802";

    art.detalleVenta.forEach(function (value: any) {
      let detalleBoleta: Details = new Details('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0);
      console.log(value.id_productob);
      detalleBoleta.codProducto = value.id_productob.codigo;
      detalleBoleta.unidad = "NIU";
      detalleBoleta.descripcion = value.id_productob.nombre;
      detalleBoleta.cantidad = value.cantidad
      detalleBoleta.mtoValorUnitario = value.precio
      detalleBoleta.mtoValorVenta = value.cantidad*value.precio
      detalleBoleta.mtoBaseIgv = value.cantidad*value.precio*0.18
      detalleBoleta.porcentajeIgv = 18
      detalleBoleta.igv = 1
      detalleBoleta.tipAfeIgv = 0
      detalleBoleta.totalImpuestos = 0
      detalleBoleta.mtoPrecioUnitario = 0
      boleta.details.push(detalleBoleta);
    });
    boleta.company=this.company;
    boleta.client=this.client;
    console.log(boleta);
    this.api.GuardarComprobante(boleta).subscribe(
      data => {
        console.log(data);
      });
  }

  traerClient(id: number) {
    let retorno:any;
    this.api.getClienteVenta(id).subscribe(data => {
      console.log("dart",data)
retorno=data
      
     });
     return retorno;
  }
  /*
      if (art) {
        this.api.GuardarVenta(art).subscribe(
          data => {
            this.toastr.success(data['messaje']);
          },
          error => { console.log(error) }
        );
        this.renderDataTable();
      }*/


  cancelar() {
    this.dialog.closeAll();
    this.cancela = true;
  }
}
