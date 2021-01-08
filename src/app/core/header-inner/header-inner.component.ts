import { Component } from '@angular/core';
import { count } from 'rxjs/operators';
import { ApiService } from 'src/app/api.service';
import { Avisos } from 'src/app/modelos/avisos';
@Component({
  selector: 'app-header-inner',
  templateUrl: './header-inner.component.html'
})

export class HeaderInnerComponent {
usuario:string;
exampleArray:Avisos[];
notificaciones:any=0;
public imagen:string

  constructor(private api:ApiService){
  }

  getAvisos(): void {
    this.api.getAvisosInventarios().subscribe(data => {
        this.exampleArray = data;
        this.notificaciones=data.length;
        });
    console.log("avisos",this.exampleArray);
  }

  ngOnInit() {
    this.getAvisos();
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



