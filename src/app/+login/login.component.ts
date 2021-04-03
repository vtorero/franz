import { Component, OnInit, NgModule } from '@angular/core';
import {Router} from '@angular/router';
import {LoginService} from '../services/login.service';
import {Usuario} from '../modelos/usuario';
import { FormsModule,ReactiveFormsModule} from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';

@NgModule({
  imports:      [BrowserModule,FormsModule,ReactiveFormsModule],
})

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
public usuario :Usuario;
public error_user:boolean;
dato:any;

constructor(private router:Router,private login:LoginService) {
  this.usuario= new Usuario("","");
  this.error_user=false;
 }

 loginUser(){
    event.preventDefault();
    
    if(this.usuario.usuario){
          this.login.loginUser(this.usuario.usuario,this.usuario.password).subscribe(data=>{
            if(data['rows']==1) {
              console.log(data['data'][0]);
              localStorage.removeItem("currentId");
              localStorage.removeItem("currentUser");
              localStorage.removeItem("currentNombre");
              localStorage.removeItem("currentAvatar");
              localStorage.removeItem("currentEmpresa"); 
              sessionStorage.removeItem("hashsession"); 
              localStorage.setItem("currentId",data['data'][0]['id']);
              localStorage.setItem("currentUser",data['data'][0]['nombre']);
              localStorage.setItem("currentNombre",data['data'][0]['nombre']);
              localStorage.setItem("currentAvatar",data['data'][0]['avatar']);
              localStorage.setItem("currentEmpresa",data['data'][0]['nombre']);
              sessionStorage.setItem("hashsession",data['data'][0]['hash']);
              this.router.navigate(['dash/reportes']);

            }else{
              this.error_user = true;
              //console.log(this.error_user)
            }
            
          });
    }
//this.router.navigate(['dash']);
  }

  ngOnInit() {

}
}
