import { Component, OnInit } from '@angular/core';
import   {Datosgeneral} from '../modelos/datosgeneral';
import {ApiService} from '../api.service';
import { LoginService } from '../services/login.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-general',
  templateUrl: './general.component.html',
  styleUrls: ['./general.component.css']
})
export class GeneralComponent implements OnInit {
public datosGeneral:Datosgeneral;
public mensaje:string='';
public show:boolean=false;
  constructor(private api:ApiService,private _login:LoginService,private router:Router) { 
    this.datosGeneral = new Datosgeneral("","","","","","","","","","","","","","","","");
  }

  getDatos(){
    let emp = localStorage.getItem("currentEmpresa");
    let hash = sessionStorage.getItem("hash");
    this.api.getDatosGeneral(emp).subscribe(res=>{
      console.log(res['data']);
      this.datosGeneral.correo=res['data'].map(res => res.correo);
      this.datosGeneral.nombres=res['data'].map(res => res.nombres);
      this.datosGeneral.telefono=res['data'].map(res => res.telefono);
      this.datosGeneral.sociedad=res['data'].map(res => res.sociedad);
      this.datosGeneral.paginas=res['data'].map(res => res.paginas);
      this.datosGeneral.rut=res['data'].map(res => res.rut);
      this.datosGeneral.domicilio=res['data'].map(res => res.domicilio);
      this.datosGeneral.calle=res['data'].map(res => res.calle);
      this.datosGeneral.numero=res['data'].map(res => res.numero);
      this.datosGeneral.ciudad=res['data'].map(res => res.ciudad);
      this.datosGeneral.pais=res['data'].map(res => res.pais);
      this.datosGeneral.confinanzas=res['data'].map(res => res.confinanzas);
      this.datosGeneral.tlffinanzas=res['data'].map(res => res.tlffinanzas);
      this.datosGeneral.correofinan=res['data'].map(res => res.correofinan);
      this.datosGeneral.medios=res['data'].map(res => res.medios);
    },err=>{console.log(err)})
  }

  ngOnInit() {
    if(this._login.getCurrentUser==false){
      this.router.navigate(['']);
      }

     this.getDatos();

  }
  onSubmit(){

    console.log(this.datosGeneral)
    this.datosGeneral.empresa=localStorage.getItem("currentEmpresa")
    this.api.GuardarDatosGeneral(this.datosGeneral).subscribe(
      data=>{
        this.show=true;
        this.mensaje=data['messaje'];
        console.log(this.show)
        },
      erro=>{console.log(erro)}
  
      );
      
  }

}
