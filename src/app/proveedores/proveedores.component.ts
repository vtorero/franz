import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from '../api.service';

@Component({
  selector: 'app-proveedores',
  templateUrl: './proveedores.component.html',
  styleUrls: ['./proveedores.component.css']
})
export class ProveedoresComponent implements OnInit {
  dataSource:any;
  cancela:boolean=false;
  displayedColumns = ['codigo','razon_social','tipo_documento','num_documento','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(private api:ApiService,public dialog:MatDialog,public dialog2:MatDialog,public dialogo:MatDialog,private toastr: ToastrService) {}
  
  renderDataTable() {  
    this.api.getProveedores().subscribe(x => {  
    this.dataSource = new MatTableDataSource();
    this.dataSource.data = x; 
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;  
  },  
  error => {  
    console.log('Error de conexion de datatable!' + error);  
  });  
  } 

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim(); 
    filterValue = filterValue.toLowerCase(); 
    this.dataSource.filter = filterValue;
}

abrirDialog(templateRef,cod) {
  let dialogRef = this.dialogo.open(templateRef, {
 width: '500px' });

dialogRef.afterClosed().subscribe(result => {
if(!this.cancela){
   if(cod){
   this.api.EliminarProducto(cod).subscribe(
     data=>{
     this.toastr.success('Aviso', data['messaje']);
     },
     erro=>{console.log(erro)}
       );
   this.renderDataTable();
 }

}

});
}

  ngOnInit() {
    this.renderDataTable() 
  }

}