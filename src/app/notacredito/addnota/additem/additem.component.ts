import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { DetalleVenta } from 'src/app/modelos/detalleVenta';

@Component({
  selector: 'app-additem',
  templateUrl: './additem.component.html',
  styleUrls: ['./additem.component.css']
})
export class AdditemComponent implements OnInit {
  dataProducto:any;
  seleccionados:string[]=[];
  producto:any;
  dataArray;
  stock;
  stockPeso;
  dataExistencias:any;
  dataUnidades = [{ id: 'NIU', tipo: 'Unidades' }, { id: 'KGM', tipo: 'Kilogramo' }];
  constructor(private api:ApiService,
    private toastr: ToastrService,
      @Inject(MAT_DIALOG_DATA) public data: DetalleVenta
      ) { 
  
      }
    getProductos(): void {
      this.api.getApi('productos').subscribe(data => {
        if(data) {
          this.dataProducto = data;
        }
      } );
    }

    changeprod(event,pro)
    {
      console.log(pro);
      this.data.mtoPrecioUnitario=pro.precio;
      if(event.source.selected){
        this.seleccionados.push(event.source.value);
        }else{
            this.seleccionados.splice(event.source.index,1);
        }
        //console.log(event.source.value,event.source.selected);
        //console.log(this.seleccionados)
    }

    
    getProdExiste(id): void {
      this.api.getApi('inventarios/'+id).subscribe(data => {
        if(data) {
         this.dataExistencias=data;
        }
      });
    }

  ngOnInit() {
   this.getProductos();
  }
  
  onKey(value) { 
    this.dataArray= []; 
    this.selectSearch(value);       
  }
  selectSearch(value:string){
    this.api.getProductosSelect(value).subscribe(data => {
      if(data) {
        this.dataProducto = data;
      }
    } );
    
  }

}
