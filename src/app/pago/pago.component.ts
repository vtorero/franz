import { Component, OnInit } from '@angular/core';
import   {Databanco} from '../modelos/databanco';
import {ApiService} from '../api.service';
import { LoginService } from '../services/login.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-pago',
  templateUrl: './pago.component.html',
  styleUrls: ['./pago.component.css']
})
export class PagoComponent implements OnInit {
  public dataBanco:Databanco;
  public mensaje:string='';
  public show:boolean=false;
  constructor(private api:ApiService,private _login:LoginService,private router:Router) {
    this.dataBanco = new Databanco("","","","","","","","","","","","","","","","");
   }

  ngOnInit() {
    if(this._login.getCurrentUser==false){
      this.router.navigate(['']);
      }

     this.getDatos();

  }

  getDatos(){
    let emp = localStorage.getItem("currentEmpresa");
    this.api.getDatosBanco(emp).subscribe(res=>{
      console.log(res['data']);
      this.dataBanco.entidad=res['data'].map(res => res.entidad);
      this.dataBanco.beneficiario=res['data'].map(res => res.beneficiario);
      this.dataBanco.persona=res['data'].map(res => res.persona);
      this.dataBanco.dom_entidad=res['data'].map(res => res.dom_entidad);
      this.dataBanco.ciudad=res['data'].map(res => res.ciudad);
      this.dataBanco.sucursal=res['data'].map(res => res.sucursal);
      this.dataBanco.tipocuenta=res['data'].map(res => res.tipocuenta);
      this.dataBanco.numerocta=res['data'].map(res => res.numerocta);
      this.dataBanco.aba=res['data'].map(res => res.aba);
      this.dataBanco.swift=res['data'].map(res => res.swift);
      this.dataBanco.contactobco=res['data'].map(res => res.contactobco);
      this.dataBanco.tlfcontacto=res['data'].map(res => res.tlfcontacto);
      this.dataBanco.bancointer=res['data'].map(res => res.bancointer);
      this.dataBanco.abainter=res['data'].map(res => res.abainter);
      
    },err=>{console.log(err)})
  }



  onSubmit(){
  console.log(this.dataBanco)
    this.dataBanco.empresa=localStorage.getItem("currentEmpresa");
    this.api.GuardarDataBanco(this.dataBanco).subscribe(
      data=>{
        this.show=true;
        this.mensaje=data['messaje'];
        console.log(this.show)
        },
      erro=>{console.log(erro)}
  
      );
      
  }

}
