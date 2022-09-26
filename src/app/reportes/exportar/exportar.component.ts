import { Component, NgModule, OnInit } from '@angular/core';
import { OwlDateTimeModule, OwlNativeDateTimeModule, DateTimeAdapter, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { BrowserModule } from '@angular/platform-browser';
import "ng-pick-datetime/assets/style/picker.min.css";
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { ApiService } from 'src/app/api.service';
import { LoginService } from 'src/app/services/login.service';
import { Router } from '@angular/router';

function sendInvoice(data,url) {
  fetch(url, {
    method: 'post',
    headers: {
      'Content-Type': 'application/vnd.ms-excel'
    },
    body:data
  })
    .then(response => response.blob())
    .then(blob => {
      var link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = "reporte.xls";
      link.click();
    });
}

export const MY_MOMENT_FORMATS = {
  parseInput: 'l LT',
  fullPickerInput: 'l LT',
  datePickerInput: 'l',
  timePickerInput: 'LT',
  monthYearLabel: 'MM YYYY',
  dateA11yLabel: 'LL',
  monthYearA11yLabel: 'MM YYYY',
};
@Component({
  selector: 'app-exportar',
  templateUrl: './exportar.component.html',
  styleUrls: ['./exportar.component.css']
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})

export class ExportarComponent implements OnInit {
  public selectedMoment = new Date();
  public selectedMoment2 = new Date();
  dataSource: any;
  fec1= this.selectedMoment.toDateString().split(" ",4);
  fec2 = this.selectedMoment2.toDateString().split(" ",4);
  fecha1:string=this.fec1[2]+'-'+this.fec1[1]+'-'+this.fec1[3];
  fecha2:string=this.fec2[2]+'-'+this.fec2[1]+'-'+this.fec2[3];
  constructor(private api:ApiService,private _login:LoginService,private router:Router,dateTimeAdapter: DateTimeAdapter<any>) {
    dateTimeAdapter.setLocale('es-PE');

   }

  ngOnInit() {
  }
  enviaFechas(){
    var fec1 = this.selectedMoment.toDateString().split(" ",4);
    var fec2 = this.selectedMoment2.toDateString().split(" ",4);
    let ini=fec1[1]+fec1[2]+fec1[3];
    let fin=fec2[1]+fec2[2]+fec2[3];
    let fecha1=fec1[2]+'-'+fec1[1]+'-'+fec1[3];;
    let fecha2=fec2[2]+'-'+fec2[1]+'-'+fec2[3];;
    console.log(fecha1);
    console.log(fecha2);
    let fechas = {'ini':fecha1,'fin':fecha2}
        console.log("test",JSON.stringify(fechas));
    sendInvoice(JSON.stringify(fechas),'http://35.231.78.51/fapi-dev/reportes.php/exportar');
    //this.loadVentas(this.fecha1,this.fecha2,empresa);
    //this.renderDataTableConsulta(ini,fin,empresa);
    }

}
