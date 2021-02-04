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

@Component({
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.css']
})
export class VentasComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  client: any
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id: 'Boleta', tipo: 'Boleta' }, { id: 'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
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
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }


  agregar(art: Venta) {
    console.log("venta",art);
    let boleta: Boleta = new Boleta('', '', '', '', '', '', this.cliente, this.company, 0, 0, 0, 0, 0, '', [], [{ code: '', value: '' }]);
    boleta.tipoOperacion = "0101";
    boleta.correlativo = "000";
    boleta.fechaEmision = art.fecha;
    boleta.tipoMoneda = "PEN";
    boleta.ublVersion = "2.1";
    boleta.legends = [{ code: "1000", value: "SON 100 Y 00/800 SOLES" }];

    /**cliente*/
    if (art.cliente.nombre) {
      boleta.tipoDoc = "03";
      boleta.serie = "B00";
      boleta.client.tipoDoc = "1";
      boleta.client.rznSocial = art.cliente.nombre + ' ' + art.cliente.apellido;
    }
    if (art.cliente.razon_social) {
      boleta.tipoDoc = "01";
      boleta.serie = "F00";
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
      detalleBoleta.unidad = "NIU";
      detalleBoleta.descripcion = value.codProductob.nombre;
      detalleBoleta.cantidad = value.cantidad;
      detalleBoleta.mtoValorUnitario = value.mtoValorUnitario;
      detalleBoleta.mtoValorVenta = value.cantidad * value.mtoValorUnitario;
      detalleBoleta.mtoBaseIgv = value.cantidad * value.mtoValorUnitario;
      detalleBoleta.porcentajeIgv = Global.BASE_IGV * 100
      detalleBoleta.igv = 18;
      detalleBoleta.tipAfeIgv = 10;
      detalleBoleta.totalImpuestos = (value.cantidad * value.mtoValorUnitario) * Global.BASE_IGV;
      detalleBoleta.mtoPrecioUnitario = value.mtoValorUnitario * Global.BASE_IGV;
      total = total + value.cantidad * value.mtoValorUnitario;
      console.log("total",total);
      boleta.details.push(detalleBoleta);
    });
    boleta.mtoOperGravadas = total;
    boleta.mtoIGV = total * Global.BASE_IGV;
    boleta.totalImpuestos = 18,
      boleta.valorVenta = total,
      boleta.mtoImpVenta = total + (total * Global.BASE_IGV),
      boleta.company = this.company;
    console.log(boleta);
    this.api.GuardarComprobante(boleta).subscribe(
      data => {
        console.log(data);
      });
  
  
      if (art) {
        this.api.GuardarVenta(art).subscribe(
          data => {
            this.toastr.success(data['messaje']);
          },
          error => { console.log(error) }
        );
        this.renderDataTable();
      }
    }


  cancelar() {
    this.dialog.closeAll();
    this.cancela = true;
  }
}
