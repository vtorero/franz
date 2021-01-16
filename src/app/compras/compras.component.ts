import { Component, NgModule, OnInit, ViewChild } from '@angular/core';
import { ApiService } from '../api.service';
import { BrowserModule } from '@angular/platform-browser';
import { MatPaginatorModule, PageEvent, MatPaginator } from '@angular/material/paginator';
import { MatTable, MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { Compra } from '../modelos/compra';
import { MatDialog, MAT_DATE_LOCALE } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { AddCompraComponent } from './add-compra/add-compra.component';
import { DetalleCompra } from '../modelos/detalleCompra';
import { EditCompraComponent } from './edit-compra/edit-compra.component';
import { DateTimeAdapter, OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
export const MY_CUSTOM_FORMATS = {
  fullPickerInput: 'YYYY-MM-DD',
  parseInput: 'YYYY-MM-DD',
  datePickerInput: 'YYYY-MM-DD',
  timePickerInput: 'LT',
  monthYearLabel: 'MMM YYYY',
  dateA11yLabel: 'LL',
  monthYearA11yLabel: 'MMMM YYYY'
};

@Component({
  selector: 'app-compras',
  templateUrl: './compras.component.html',
  styleUrls: ['./compras.component.css'],
  providers: [
    { provide: OWL_DATE_TIME_FORMATS, useValue: 'es-PE' },
  ],
})

@NgModule({
  imports: [OwlDateTimeModule, OwlNativeDateTimeModule, BrowserModule, MatPaginatorModule],
  providers: [{ provide: OWL_DATE_TIME_FORMATS, useValue: MY_CUSTOM_FORMATS },]

})



export class ComprasComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' }];
  startDate: Date = new Date();
  detallecompra: DetalleCompra = new DetalleCompra(0, '', 0, 0);
  cancela: boolean = false;
  displayedColumns = ['comprobante', 'num_comprobante', 'fecha', 'razon_social','total', 'borrar'];
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
  ngOnInit() {
    this.renderDataTable()
  }

  abrirDialogo() {
    const dialogo1 = this.dialog.open(AddCompraComponent, {
      data: new Compra(0, '', '', '', '', '', '', '', [],0)
    });
    dialogo1.afterClosed().subscribe(art => {
      if (art != undefined)
        this.agregar(art);
      this.renderDataTable();
    });
  }

  agregar(art:Compra) {
    if (art) {
      this.api.GuardarCompra(art).subscribe(
        data => {
          this.toastr.success(data['messaje']);
        },
        error => { console.log(error) }
      );
      this.renderDataTable();
    }
  }


  renderDataTable() {
    this.api.getApi('compras').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  abrirEditar(cod: Compra) {
    const dialogo2 = this.dialog2.open(EditCompraComponent, {
      data: cod
    });
    dialogo2.afterClosed().subscribe(art => {
      console.log(art);
      if (art != undefined)
        this.editar(art);
      this.renderDataTable();
    });
  }

  editar(art: any) {
    if (art) {
      this.api.EditarCompra(art).subscribe(
        data => {
          this.toastr.success(data['messaje']);
        },
        erro => { console.log(erro) }
      );
    }
  }

}
