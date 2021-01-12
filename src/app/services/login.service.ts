import { Injectable } from '@angular/core';
import { HttpClient,HttpHeaders } from '@angular/common/http';
import {map} from 'rxjs/operators';
import { Global } from '../global';
import { isNullOrUndefined } from 'util';

@Injectable({
  providedIn: 'root'
})
export class LoginService {
 loggedStatus = false;
  constructor(private http: HttpClient) { }
  headers: HttpHeaders = new HttpHeaders({ "Content-type":"application/json" });
  
  loginUser(usuario: string, password: string) {
      const url = Global.BASE_API_URL + 'api.php/login';
      return this.http.post(url,{
          usuario: usuario,
          password: password
      }, { headers: this.headers }).pipe(map(data => data));
  }

  get getCurrentUser(){
    let user = localStorage.getItem("currentUser");
    if(!user){
      return false;
       }else{
         return true;
       }
  }
}
