import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Boleta } from '../modelos/Boleta/boleta';
import { Client } from '../modelos/Boleta/client';
import { Company } from '../modelos/Boleta/company';
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
  dataClien:any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' },{ id:'Sin Comprobante', tipo: 'Pendiente' }];
  startDate: Date = new Date();
  detalleVenta: DetalleVenta = new DetalleVenta('','','',0,0,0,0,0,0,0,0,0);
  boleta:Boleta = new Boleta('','','','','','',{rznSocial:'',numDoc:'',tipoDoc:'',address:{direccion:''}},[],0,0,0,0,0,'',[],{code:'',value:''});
  company:Company = new Company('','',{direccion:''});
  client:Client = new Client('','','',{direccion:''});
  cancela: boolean = false;
  displayedColumns = ['id', 'usuario','vendedor','cliente','estado','comprobante','fecha','valor_total','opciones'];
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

  agregarVenta(){
    const dialogo1 = this.dialog.open(AgregarventaComponent, {
      data: new Venta(0,localStorage.getItem("currentId"),0,0,0,'','',0,[])
    });
    dialogo1.afterClosed().subscribe(art => {
      //console.log(art);
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }

  agregar(art:Venta) {
    this.traerClient(art.id_cliente);
    this.company.ruc="20605174095";
    this.company.razonSocial="VVIAN FOODS S.A.C";
    this.company.address.direccion="AV. PARDO Y ALIAGA N° 699 INT. 802";
     this.boleta.tipoOperacion="0101";
     
     this.boleta.tipoDoc="03";
     this.boleta.fechaEmision=art.fecha;
     this.boleta.tipoMoneda="PEN";
     this.boleta.mtoIGV=18;
     this.boleta.details=art.detalleVenta;
     this.boleta.company.push(this.company);
     this.boleta.client=this.client;
    console.log(this.boleta);
    this.api.GuardarComprobante(this.boleta).subscribe(
      data => {
        console.log(data);
      });
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
  

traerClient(id:number){
  this.api.getApi('cliente/'+id).subscribe(data=>{
    this.dataClien=data;
    this.client.numDoc=this.dataClien[0].num_documento;
    this.client.tipoDoc="1";
    this.client.address.direccion=this.dataClien[0].direccion;
    this.client.rznSocial=this.dataClien[0].nombre;
  });
}    

cancelar(){
   this.dialog.closeAll();
  this.cancela=true;
}


}
