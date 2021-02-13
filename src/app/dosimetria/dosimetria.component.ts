import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';
import { Dosimetria } from '../modelos/dosimetria';
import { AddDosimetriaComponent } from './add-dosimetria/add-dosimetria.component';
import { AddInsumoComponent } from './add-insumo/add-insumo.component';

@Component({
  selector: 'app-dosimetria',
  templateUrl: './dosimetria.component.html',
  styleUrls: ['./dosimetria.component.css']
})
export class DosimetriaComponent implements OnInit {
  dataSource: any;
  dataDetalle: any;
  dataComprobantes = [{ id: 'Factura', tipo: 'Factura' }, { id:'Boleta', tipo: 'Boleta' }];
  startDate: Date = new Date();
  
  cancela: boolean = false;
  displayedColumns = ['codigo', 'descripcion', 'inventario_inicial','fecha_registro','usuario' ,'borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api: ApiService,
    public dialog: MatDialog,
    public dialogo: MatDialog,
    private toastr: ToastrService,
    dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');
  }

  renderDataTable() {
    this.api.getApi('dosimetria').subscribe(x => {
      this.dataSource = new MatTableDataSource();
      this.dataSource.data = x;
      this.dataSource.sort = this.sort;
      this.dataSource.paginator = this.paginator;
    },
      error => {
        console.log('Error de conexion de datatable!' + error);
      });
  }

  abrirDialogo() {
    const dialogo1 = this.dialog.open(AddInsumoComponent,{
      data: new Dosimetria(0,'','','',0,'',localStorage.getItem("currentUser")),
      width:'600px'
    });
    dialogo1.afterClosed().subscribe(art => {
      this.agregar(art);
      this.renderDataTable();
    });
  }

  abrirDialog(templateRef,cod) {
    let dialogRef = this.dialogo.open(templateRef, {
   width: '500px' });
 dialogRef.afterClosed().subscribe(result => {
 if(!this.cancela){
     if(cod){
     this.api.EliminarDosimetria(cod.id).subscribe(
       data=>{
       this.toastr.success(data['messaje']);
       },
       erro=>{console.log(erro)}
         );
     this.renderDataTable();
   }
 }

});
}

    agregar(art:any) {
      console.log(art)
      if (art) {
        this.api.GuardarDosimetria(art).subscribe(
          data => {
            this.toastr.success(data['messaje']);
          },
          error => { console.log(error) }
        );
        this.renderDataTable();
      }
    }

  

  ngOnInit() {
    this,this.renderDataTable();
  }

}
