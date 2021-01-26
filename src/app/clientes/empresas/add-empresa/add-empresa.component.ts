import { Component, Inject, NgModule, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Proveedor } from 'src/app/modelos/proveedor';
import { BrowserModule } from '@angular/platform-browser';

@Component({
  selector: 'app-add-empresa',
  templateUrl: './add-empresa.component.html',
  styleUrls: ['./add-empresa.component.css']
})

@NgModule({
  imports: [BrowserModule],  
})
export class AddEmpresaComponent implements OnInit {

  constructor(
    private toastr: ToastrService,
    public dialogRef: MatDialogRef<AddEmpresaComponent>,
    @ Inject(MAT_DIALOG_DATA) public data: Proveedor,
    private api:ApiService

  ) { }

    onLoadDatos(event:any){
    if(event.target.value!=""){
    this.api.getProveedor(event.target.value).subscribe(data => {
      if(data) {
        console.log(data);
        this.data.razon_social=data['razonSocial']
        this.data.direccion=data['direccion']
        this.data.estado=data['estado']
        this.data.departamento=data['departamento']
        this.data.provincia=data['provincia']
        this.data.distrito=data['distrito']
      } 
    },
    error=>{
      console.log(error)
      this.toastr.error("Numero de RUC incorrecto");
    } );
  }else{
    this.toastr.warning("Debe indicar el Numero de RUC");
  }
 }

  ngOnInit() {
  }
  cancelar() {
    this.dialogRef.close();
  }

}
