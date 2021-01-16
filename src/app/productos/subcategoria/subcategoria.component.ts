import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog, MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Subcategoria } from 'src/app/modelos/subcategoria';

@Component({
  selector: 'app-subcategoria',
  templateUrl: './subcategoria.component.html',
  styleUrls: ['./subcategoria.component.css']
})
export class SubcategoriaComponent implements OnInit {
  dataSource:any;
  dataCategoria:any;
  data:any;
  cancela:boolean=false;
  displayedColumns = ['codigo','id_categoria','categoria','nombre','borrar'];
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  datos: Subcategoria = new Subcategoria(0,0,'','');
  constructor(private api:ApiService,public dialog: MatDialog,private toastr: ToastrService) { }
  renderDataTable() {  
   
    this.api.getApi('subcategorias').subscribe(x => {  
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
    this.getCate();
  }

  getCate(): void {
    this.api.getApi('categorias').subscribe(data => {
      if(data) {
        this.dataCategoria = data;
      }
    } );
  }

  addSubCategoria(cate:any){
    console.log(cate);
    this.agregar(cate);
      this.renderDataTable();
  }

  agregar(art: Subcategoria) {
    console.log(art);
    if(art){
    this.api.GuardarSubCategoria(art).subscribe(
      data=>{
        console.log(data);
        this.toastr.success('Aviso', data['messaje']);
        },
      erro=>{console.log(erro)}
        );
    this.dialog.closeAll();
    this.renderDataTable();
  }
  }
  cancelar(){
    this.dialog.closeAll();
    this.cancela=true;
  
  }
  abrirDialog(templateRef,cod) {
    console.log("dataaa",cod)
    let dialogRef = this.dialog.open(templateRef, {
        width: '600px' });
  
    dialogRef.afterClosed().subscribe(result => {
      if(!this.cancela){
        if(cod){
          this.api.EliminarCategoria(cod).subscribe(
            data=>{
              console.log(data);
              if(data['STATUS']==true){
            this.toastr.success(data['messaje']);
              }else{
              this.toastr.error(data['messaje']);
              }
            },
            erro=>{console.log(erro)}
              );
          this.renderDataTable();
        }
  
      }
    
  });
  }


}
