import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../../api.service';
import { Clientes } from '../../modelos/clientes';

@Component({
  selector: 'app-clientes',
  templateUrl: './clientes.component.html',
  styleUrls: ['./clientes.component.css']
})
export class ClientesComponent implements OnInit {
  dataSource:any;
  //data:any;
  cancela:boolean=false;
  displayedColumns = ['num_documento','nombre','apellido','direccion','telefono','opciones'];
  data: Clientes = new Clientes(0,'','','','','');
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(
    private api: ApiService, public dialog: MatDialog, public dialog2: MatDialog, public dialogo: MatDialog, private toastr: ToastrService
    ) { }

    applyFilter(filterValue: string) {
      filterValue = filterValue.trim(); 
      filterValue = filterValue.toLowerCase(); 
      this.dataSource.filter = filterValue;
  }
  
  renderDataTable() {
    this.api.getApi('clientes').subscribe(x => {
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

  cancelar(){
    this.cancela=true;
    this.dialog.closeAll();
    
  }

 addCliente(cli:Clientes) {
    console.log(cli);
    if(cli){
    this.api.GuardarCliente(cli).subscribe(
      data=>{
        console.log(data);
        this.toastr.success(data['messaje']);
        cli.num_documento=''
        cli.nombre=''
        cli.apellido=''
        cli.direccion=''
        cli.telefono=''
        },
      erro=>{console.log(erro)}
      );
    this.dialog.closeAll();
    this.renderDataTable();
  }
  
  }

eliminarCliente(cod){
  console.log(cod)
  if (cod) {
    this.api.EliminarCliente(cod.num_documento).subscribe(
      data => {
        this.toastr.success( data['messaje']);
      },
      error => { 
        console.log(error)
        this.toastr.error("Error al eliminar el cliente");
       }
    );
    
  }

}


  abrirDialog(templateRef,cod:Clientes) {
     let dialogRef = this.dialog.open(templateRef, {
        width: '600px'});
      dialogRef.afterClosed().subscribe(result => {
        if (!this.cancela) {
          this.renderDataTable();
  
        }
    });
  }

  onLoadDatos(event:any){
    console.log(this.cancela)
    if(event.target.value && !this.cancela){
    this.api.getCliente(event.target.value).subscribe(data => {
      if(data) {
        console.log(data);
        this.data.nombre=data['nombres'];
        this.data.apellido= data['apellidoPaterno']+' '+ data['apellidoMaterno'];
        this.data.direccion= '';
        this.data.telefono= '';
      } 
    },
    error=>{
      console.log(error)
      this.toastr.error("Numero de DNI incorrecto");
    } );
  }else{
    this.toastr.warning("Debe indicar el Numero de DNI");
  }
 }

}
