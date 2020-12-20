import { Component, Inject, Input, NgModule } from '@angular/core';
import {  MatPaginatorModule, MAT_DIALOG_DATA } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { OwlDateTimeModule, OwlNativeDateTimeModule, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { MY_MOMENT_FORMATS } from 'src/app/home/home.component';
import { Compra } from 'src/app/modelos/compra';
import { DetalleCompra } from 'src/app/modelos/detalleCompra';




@Component({
  selector: 'hello',
  template: `<div>
  <h1 mat-dialog-title>Agregar Producto</h1>
  <div mat-dialog-content>
      <div style="display: flex;flex-direction: column; margin:1rem auto; width: 400px; padding: 1rem;">
          <mat-form-field>
              <input matInput [(ngModel)]="data.nombre" type="text" placeholder="Ingrese nombre"required>
          </mat-form-field>
          <mat-form-field>
              <input matInput [(ngModel)]="data.cantidad" type="text" placeholder="Ingrese cantidad" required>
          </mat-form-field>
          <mat-form-field>
            <input matInput [(ngModel)]="data.precio" type="number" placeholder=" S/.Precio" required>
            </mat-form-field>
           </div>
  </div>
  <div mat-dialog-actions>
    <button  mat-button [mat-dialog-close]="true">Cancelar</button>
      <button mat-button [mat-dialog-close]="data" cdkFocusInitial>Confirmar</button>
  </div>
  </div>`
})

@NgModule({
    imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
    providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
  })
export class HelloComponent  {
    constructor(  @Inject(MAT_DIALOG_DATA) public data: DetalleCompra){}

}
