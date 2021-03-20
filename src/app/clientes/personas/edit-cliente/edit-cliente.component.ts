import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Clientes } from 'src/app/modelos/clientes';

@Component({
  selector: 'app-edit-cliente',
  templateUrl: './edit-cliente.component.html',
  styleUrls: ['./edit-cliente.component.css']
})
export class EditClienteComponent implements OnInit {

  constructor(@ Inject(MAT_DIALOG_DATA) public data: Clientes,
  private api: ApiService,
  private toastr: ToastrService,
  public dialog: MatDialogRef<EditClienteComponent>
  ) { }

  ngOnInit() {
  }

  onLoadDatos(event:any){
    if(event.target.value!=""){
    this.api.getCliente(event.target.value).subscribe(data => {
      if(data) {
        console.log(data);
        this.data.nombre=data['razonSocial']
        this.data.direccion=data['direccion']
        this.data.apellido=data['departamento']
        
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

  cancelar() {
    this.dialog.close();
  }

}
