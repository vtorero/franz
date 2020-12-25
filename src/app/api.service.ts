import { Injectable } from '@angular/core';
import {HttpClient, HttpHeaders} from '@angular/common/http';
import 'rxjs/add/operator/map';
import {Observable} from 'rxjs/Observable';
import { Chart } from 'chart.js';  
import 'rxjs/add/operator/map';
import { Global } from './global';
import { map } from 'rxjs/operators';
import { Impresiones } from './modelos/impresiones';
import { Datosgeneral } from './modelos/datosgeneral';
import { Databanco } from './modelos/databanco';
import { Producto } from './modelos/producto';
import { Categoria } from './modelos/categoria';
import { Proveedor } from './modelos/proveedor';
import { Compra } from './modelos/compra';


@Injectable({
  providedIn: 'root'
})
export class ApiService {
  public url:string;
  constructor(public _http: HttpClient,) {
    this.url="http://slim.com/api.php/productos";
    
   }
   headers: HttpHeaders = new HttpHeaders({ "Content-type":"application/json" });

/*   getProductos(): Observable<any>{
    return this._http.get(this.url);
}*/

getApi(ruta:string){
  return this._http.get(Global.BASE_API_URL+'api.php/'+ruta,
  { headers: this.headers }
 ).pipe(map(result => result));
}

getProductos() {
  return this._http.get(Global.BASE_API_URL+'api.php/productos',
   { headers: this.headers }
  ).pipe(map(result => result));
}

public GuardarProducto(datos:Producto):Observable<any> {
  let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
  let json = JSON.stringify(datos);
   return this._http.post(Global.BASE_API_URL+'api.php/producto',
    {json:json},{ headers: headers });
  }

  public EliminarProducto(datos:Producto):Observable<any> {
    let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
    let json = JSON.stringify(datos);
     return this._http.post(Global.BASE_API_URL+'api.php/productodel',
      {json:json},{ headers: headers });
    }

    public EditarProducto(datos:Producto):Observable<any> {
      let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
      let json = JSON.stringify(datos);
       return this._http.post(Global.BASE_API_URL+'api.php/productoedit',
        {json:json},{ headers: headers });
      }
    
  
    getCategorias() {
      return this._http.get(Global.BASE_API_URL+'api.php/categorias',
       { headers: this.headers }
      ).pipe(map(result => result));
    }

    getCategoriaSelect():Observable<Categoria[]>{
      return this._http.get<Categoria[]>(Global.BASE_API_URL+'api.php/categorias', { headers: this.headers });
    }

    getProveedorSelect(value=''):Observable<Proveedor[]>{
      if(value==''){
      return this._http.get<Proveedor[]>(Global.BASE_API_URL+'api.php/proveedores', { headers: this.headers });
    }else{
      return this._http.get<Proveedor[]>(Global.BASE_API_URL+'api.php/proveedores/'+value, { headers: this.headers });
    }
    }

    public GuardarCategoria(datos:Categoria):Observable<any> {
      let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
      let json = JSON.stringify(datos);
       return this._http.post(Global.BASE_API_URL+'api.php/categoria',
        {json:json},{ headers: headers });
      }

      public EliminarCategoria(datos:Categoria):Observable<any> {
        let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
        let json = JSON.stringify(datos);
         return this._http.post(Global.BASE_API_URL+'api.php/categoriadel',
          {json:json},{ headers: headers });
        }
      

/*PROVEEDORES*/

getProveedores() {
  return this._http.get(Global.BASE_API_URL+'api.php/proveedores',
   { headers: this.headers }
  ).pipe(map(result => result));
}

public GuardarProveedor(datos:Proveedor):Observable<any> {
  let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
  let json = JSON.stringify(datos);
   return this._http.post(Global.BASE_API_URL+'api.php/proveedor',
    {json:json},{ headers: headers });
  }
  
  /**Compras  api*/

  GuardarCompra(datos:Compra):Observable<any> {
    let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
    let json = JSON.stringify(datos);
     return this._http.post(Global.BASE_API_URL+'api.php/compra',
      {json:json},{ headers: headers });
    }

EditarCompra(datos:Compra):Observable<any> {
      let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
      let json = JSON.stringify(datos);
       return this._http.post(Global.BASE_API_URL+'api.php/compraedit',
        {json:json},{ headers: headers });
}

    GetDetalleCompra(id:any){
      return this._http.get(Global.BASE_API_URL+'api.php/compra/'+id,
      { headers: this.headers }
      ).pipe(map(result => result));
    }

getReportes(inicio: string, final: string,empresa:string) {
  const url = Global.BASE_API_URL + 'api.php/reporte';
  return this._http.post(url,{
      ini: inicio,
      fin: final,
      emp:empresa
  }, { headers: this.headers }).pipe(map(data => data));
}

getProveedor(ruc:string) {
  return this._http.get(Global.BASE_API_SUNAT+'ruc/'+ruc+'?token='+Global.TOKEN_API_PERU,
  { headers: this.headers }
  ).pipe(map(result => result));
}


getDatos(empresa:string) {
  return this._http.post(Global.BASE_API_URL+'api.php/inicio',
  {
    emp:empresa
  },{ headers: this.headers }
  ).pipe(map(result => result));
}

public GuardarDataBanco(datos:Databanco):Observable<any> {
  let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
  let json = JSON.stringify(datos);
   return this._http.post(Global.BASE_API_URL+'api.php/banco',
    {json:json},{ headers: headers });
  }

public GuardarDatosGeneral(datos:Datosgeneral):Observable<any> {
let headers = new HttpHeaders().set('Content-Type','application/x-www-form-urlencoded');
let json = JSON.stringify(datos);
 return this._http.post(Global.BASE_API_URL+'api.php/general',
  {json:json},{ headers: headers });
}

getDatosBanco(empresa:string) {
  return this._http.post(Global.BASE_API_URL+'api.php/bancosget',
  {
    empresa:empresa
  },{ headers: this.headers }
  ).pipe(map(result => result));
}

getDatosGeneral(empresa:string) {
  return this._http.post(Global.BASE_API_URL+'api.php/generalget',
  {
    empresa:empresa
  },{ headers: this.headers }
  ).pipe(map(result => result));
}


public getTablaInicial(empresa:string):Observable<Impresiones[]> {
  return this._http.post<Impresiones[]>(Global.BASE_API_URL+'api.php/tabla',{
    emp:empresa
},{ headers: this.headers }).pipe(map(result => result));
}


public getTablaConsultar(ini:string,fin:string,empresa:string):Observable<Impresiones[]> {
  return this._http.post<Impresiones[]>(Global.BASE_API_URL+'api.php/tablaconsulta',{
    ini:ini,
    fin:fin,
    emp:empresa
},{ headers: this.headers }).pipe(map(result => result));
}


getPie(labels:any,datos:any,canvas:string,titulo:string){

  return new Chart(canvas, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [
        {
          fill: true,
          lineTension: 0,
          //backgroundColor: "RGBA(0,233,168,0.3)",
          //borderColor: "#3cb371",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "3cb371",
          pointBackgroundColor: "3cb371",
          pointBorderWidth: 0,
          pointHoverRadius: 8,
          pointHoverBackgroundColor: "#3cb371",
          pointHoverBorderColor: "3cb371",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          data: datos,
          //borderColor: '#3cba9f',
          //fill: true,
          backgroundColor: [  
            "#0f498aff",  
            "#999999ff",  
            "#2196f3ff",  
            "#ccccccff",  
            "#bbdefbff",  
            "#f990a7",  
            "#aad2ed",  
            "#FF00FF",  
            "Blue",  
            "Red",  
            "Blue"  
          ]
        }
      
      ],

    },
    options: {
      legend: {
        display: true,
        position:'right',
        labels: {
          fontColor: 'rgb(0,0,0)',
          boxWidth: 10,
          padding: 20,
          fontSize:10
      }

        },
      responsive: true,
      title:{
          display:true,
          text:titulo,
          fontSize:14
      },
      tooltips: {
          mode: 'index',
          intersect: true
      },
      hover: {
          mode: 'nearest',
          intersect: true
      },
        
        scales: {
          xAxes: [],
          yAxes: []
        }          
    }  
  }
  )

}
  
}
