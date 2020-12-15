import { Component } from '@angular/core';
@Component({
  selector: 'app-header-inner',
  templateUrl: './header-inner.component.html'
})

export class HeaderInnerComponent {
usuario:string;
notificaciones:number=4;
public imagen:string

  constructor(){}


  ngOnInit() {
    let cimagen = localStorage.getItem("currentAvatar")
    let nombre = localStorage.getItem("currentNombre")
    this.imagen=cimagen;
    this.usuario=nombre;
  }

  logout(){
  localStorage.removeItem("currentEmpresa");
  localStorage.removeItem("currentUser");
  localStorage.removeItem("currentNombre");
  localStorage.removeItem("currentAvatar");
  console.log("salir");
  
  

  }

}



