import { Component, ElementRef, NgModule, ViewChild} from '@angular/core';
import { Chart } from 'chart.js';  
import {ApiService} from '../api.service';
import * as Prism from 'prismjs';
import {LoginService} from '../services/login.service';
import {Router} from '@angular/router';
import {Datos} from '../modelos/datos';
import { OwlDateTimeModule, OwlNativeDateTimeModule, DateTimeAdapter, OWL_DATE_TIME_FORMATS } from 'ng-pick-datetime';
import { BrowserModule } from '@angular/platform-browser';
import "ng-pick-datetime/assets/style/picker.min.css";
import {MatPaginatorModule, PageEvent, MatPaginator} from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { TableUtil } from "./tableUtil";



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
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
 
})

@NgModule({
  imports: [OwlDateTimeModule,OwlNativeDateTimeModule,BrowserModule,MatPaginatorModule],
  providers:[{provide: OWL_DATE_TIME_FORMATS, useValue: MY_MOMENT_FORMATS},]
})

export class HomeComponent{

public selectedMoment = new Date();
public selectedMoment2 = new Date();
datos:Datos;
pie = [];  
piechar =[];
barchar =[];
labels=[];
line=[];
values=[];
labeldias=[];
dias_value_desk=[]
dias_value_movil=[];
dias_value_tablet=[];
creat_dias=[];
creat_total=[];
ingreso_cpm:number;
ingreso_total:number;

neto_boleta:number;
igv_boleta:number;
total_boleta:number;

neto_factura:number;
igv_factura:number;
total_factura:number;

neto_nota:number;
igv_nota:number;
total_nota:number;

datatable=[];
startDate:Date = new Date();
cargando:boolean=false;
pageEvent: PageEvent;
inicio:string;
final:string;
data:string= localStorage.getItem("data");
  window: any;
  columnad_exchange_estimated_revenue: number;
  columnad_exchange_impressions: number;
  dimensionad_exchange_creative_sizes: string;
  dimensiondate: string;
  dimensionad_exchange_device_category:string;
  displayedColumns = ['fecha','nro_comprobante','num_documento','cliente','valor_neto','monto_igv','valor_total'];
  displayedColumnsnotas = ['fecha','nro_nota','num_documento','cliente','valor_neto','monto_igv','valor_total','numDocfectado'];
  dataSource: any;
  dataSourceFac: any;
  dataSourceNot: any;
  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;
  
  fec1= this.selectedMoment.toDateString().split(" ",4); 
  fec2 = this.selectedMoment2.toDateString().split(" ",4); 
  fecha1:string=this.fec1[2]+'-'+this.fec1[1]+'-'+this.fec1[3];
  fecha2:string=this.fec2[2]+'-'+this.fec2[1]+'-'+this.fec2[3];

 
  
  constructor(private api:ApiService,private _login:LoginService,private router:Router,dateTimeAdapter: DateTimeAdapter<any>){
    dateTimeAdapter.setLocale('es-PE');
  }

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim(); 
    filterValue = filterValue.toLowerCase(); 
    this.dataSource.filter = filterValue;
}

renderDataTable() {  
  let emp=sessionStorage.getItem("hashsession");
  this.api.getTablaInicial(emp).subscribe(x => {  
  this.dataSource = new MatTableDataSource();
  this.dataSource.data = x; 
  this.dataSource.sort = this.sort;
  this.dataSource.paginator = this.paginator;  
},  
error => {  
  console.log('Error de conexion de datatable!' + error);  
});  
} 

renderDataTableConsulta(inicio:string,final:string,emp:string) { 
  this.dataSource=[];
  this.api.getTablaConsultar(inicio,final,emp).subscribe( x => {  
  this.dataSource = new MatTableDataSource();  
  this.dataSource.data = x; 
  this.dataSource.sort = this.sort;
  this.dataSource.paginator = this.paginator;
  
},  
error => {  
  console.log('Error de conexion de datatable!!' + error);  
});  
} 
  
  ngOnInit() {
   // this.renderDataTable();
    if(this._login.getCurrentUser==false){
      this.router.navigate(['']);
      }

    this.cargando=true;
       let hash= sessionStorage.getItem("hashsession");
    this.api.getDatos(hash)
        .subscribe(res => {
          console.log(res);
         
      this.ingreso_cpm= res['ingreso'].map(res => res.ingreso_cpm);
      this.inicio=res['inicio'];
      this.final=res['final'];
      this.ingreso_total= res['ingreso'].map(res => res.ingreso_total);
      
      
      let alldates = res['data'].map(res => res.total)
      let  alllabels = res['data'].map(res => res.dimensionad_exchange_device_category)
      let dias_val = res['diario_desktop'].map(res=>res.dimensiondate)
      let dias_valdesc =res['diario_desktop'].map(res=>res.total)
      let dias_valmovil =res['diario_movil'].map(res=>res.total)
      let dias_valtablet =res['diario_tablet'].map(res=>res.total)
      let creative_sizes = res['creatives'].map(res=>res.dimensionad_exchange_creative_sizes);
      let creative_total = res['creatives'].map(res=>res.total);
  
      alllabels.forEach((res)=>{this.labels.push(res)});
      alldates.forEach((res) =>{this.values.push(res)});

      dias_val.forEach((res)=>{this.labeldias.push(res)})
      dias_valdesc.forEach((res)=>{this.dias_value_desk.push(res)})
      dias_valmovil.forEach((res)=>{this.dias_value_movil.push(res)})
      dias_valtablet.forEach((res)=>{this.dias_value_tablet.push(res)})

      creative_sizes.forEach((res)=>{this.creat_dias.push(res)})
      creative_total.forEach((res)=>{this.creat_total.push(res)})
      

      this.api.getPie(this.creat_dias,this.creat_total,'canvas4','Ingresos por tamaño de creatividad');
      this.api.getPie(this.labels,this.values,'canvas','Ingresos por dispositivo');

 
  
       this.barchar = new Chart('canvas2', {
        type: 'line',
        data: {
          labels: this.labeldias,
          datasets: [
            {
              //label: "Desktop",
              fill: true,
              backgroundColor: "#2196f3ff",
              borderColor: "#2196f3ff",
              borderCapStyle: 'butt',
              borderDash: [],
              borderDashOffset: 0.0,
              borderJoinStyle: 'miter',
              pointBorderColor: "rgba(6, 58, 228)",
              pointBackgroundColor: "#000",
              pointBorderWidth: 0,
              pointHoverRadius: 1,
              pointHoverBackgroundColor: "rgba(6, 58, 228)",
              pointHoverBorderColor: "#2196f3ff",
              pointHoverBorderWidth: 2,
              pointRadius: 4,
              pointHitRadius: 10,
              // notice the gap in the data and the spanGaps: true
              data: this.dias_value_desk,
              spanGaps: true,
            }
           /* {
              label: "Mobile",
              fill: true,
              lineTension: 0,
              backgroundColor: "RGBA(61,0,255,0.3)",
              //borderColor: "blue", // The main line color
              borderCapStyle: 'butt',
              borderDash: [], // try [5, 15] for instance
              borderDashOffset: 0.0,
              borderJoinStyle: 'miter',
              pointBorderColor: "blue",
              pointBackgroundColor: "white",
              pointBorderWidth: 1,
              pointHoverRadius: 8,
              pointHoverBackgroundColor: "blue",
              pointHoverBorderColor: "blue",
              pointHoverBorderWidth: 2,
              pointRadius: 4,
              pointHitRadius: 10,
              // notice the gap in the data and the spanGaps: false
              data:this.dias_value_movil,
              spanGaps: false,
            },
            {
              label: "Tablet",
              fill: true,
              lineTension: 0,
              backgroundColor: "RGBA(246,91,246,0.3)",
              //borderColor: "#F65BF6", // The main line color
              borderCapStyle: 'butt',
              borderDash: [], // try [5, 15] for instance
              borderDashOffset: 0.0,
              borderJoinStyle: 'miter',
              pointBorderColor: "#F65BF6",
              pointBackgroundColor: "F65BF6",
              pointBorderWidth: 1,
              pointHoverRadius: 8,
              pointHoverBackgroundColor: "#F65BF6",
              pointHoverBorderColor: "#F65BF6",
              pointHoverBorderWidth: 2,
              pointRadius: 4,
              pointHitRadius: 10,
              // notice the gap in the data and the spanGaps: false
              data: this.dias_value_tablet,
              spanGaps: false,
            }*/
          ],
       
        },
        options: {
          legend: {
            display: false,
            },
          responsive: true,
          title:{
              display:false,
              text:'Ingresos por día',
              fontSize:15
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
            xAxes:[{ gridLines: {
                  display:false
              }}],
            yAxes: [
              {
              gridLines: {
                  display:false
              } , 
                scaleLabel: {
                     display: true,
                     labelString: 'Ingresos (S/.)',
                     fontSize: 14 
                  }
            }],
                        
        }  
      },
      
          plugins: {
            datalabels: {
              anchor: 'end',
              align: 'top',
              formatter: Math.round,
              font: {
                weight: 'bold'
              }
            }
          }
      })

      

    })
  
    this.cargando=false;
  }

  ngAfterViewInit() {
    Prism.highlightAll();
  }



enviaFechas(){
this.labels=[];
this.values=[];
var empresa = sessionStorage.getItem("CurrentUser");
var fec1 = this.selectedMoment.toDateString().split(" ",4); 
var fec2 = this.selectedMoment2.toDateString().split(" ",4); 
let ini=fec1[1]+fec1[2]+fec1[3];
let fin=fec2[1]+fec2[2]+fec2[3];

this.fecha1=fec1[2]+'-'+fec1[1]+'-'+fec1[3];;
this.fecha2=fec2[2]+'-'+fec2[1]+'-'+fec2[3];;

console.log(this.fecha1,this.fecha2);
this.loadVentas(this.fecha1,this.fecha2,empresa);
//this.renderDataTableConsulta(ini,fin,empresa);
}

  /*carga datos click*/ 

loadVentas(inicio:string,final:string,empresa:string){

  this.labels=[];
  this.values=[];
  this.labeldias=[];
  this.dias_value_desk=[];
  this.creat_dias=[];
  this.creat_total=[];
  this.resetChart();
  this.cargando=true;
this.resetChart();
this.api.getVentaBoletas(inicio,final,empresa)
.subscribe(x => {
  this.inicio=x['inicio'];
  this.final=x['final'];
  this.ingreso_total=x['totales'].map(res=>res.valor_total);

  let dias = x['totaldias'].map(res=>res.fecha);
  let dias_valdesck =x['totaldias'].map(res=>res.valor_total);
 
  dias.forEach((res)=>{this.labeldias.push(res)})
  dias_valdesck.forEach((res)=>{this.dias_value_desk.push(res)})

  this.neto_boleta=x['totalboleta'].map(res=>res.valor_neto);
  this.igv_boleta=x['totalboleta'].map(res=>res.monto_igv);
  this.total_boleta=x['totalboleta'].map(res=>res.valor_total);

  this.neto_factura=x['totalfactura'].map(res=>res.valor_neto);
  this.igv_factura=x['totalfactura'].map(res=>res.monto_igv);
  this.total_factura=x['totalfactura'].map(res=>res.valor_total);

  this.neto_nota=x['totalnotas'].map(res=>res.valor_neto);
  this.igv_nota=x['totalnotas'].map(res=>res.monto_igv);
  this.total_nota=x['totalnotas'].map(res=>res.valor_total);


  this.dataSource = new MatTableDataSource();  
  this.dataSource.data = x['boletas'];
  this.dataSource.sort = this.sort;
  this.dataSource.paginator = this.paginator;
  
  this.dataSourceFac = new MatTableDataSource();  
  this.dataSourceFac.data = x['facturas'];
  this.dataSourceFac.sort = this.sort;
  this.dataSourceFac.paginator = this.paginator;


  this.dataSourceNot = new MatTableDataSource();  
  this.dataSourceNot.data = x['notas'];
  this.dataSourceNot.sort = this.sort;
  this.dataSourceNot.paginator = this.paginator;


  this.barchar = new Chart('canvas2', {
    type: 'line',
    data: {
      labels: this.labeldias,
      datasets: [
        {
          //label: "Desktop",
          fill: true,
          lineTension: 0.3,
          backgroundColor: "#2196f3ff",
          borderColor: "#2196f3ff",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(6, 58, 228)",
          pointBackgroundColor: "#000",
          pointBorderWidth: 0,
          pointHoverRadius: 1,
          pointHoverBackgroundColor: "rgba(6, 58, 228)",
          pointHoverBorderColor: "#2196f3ff",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          //spanGaps: true,
          data: this.dias_value_desk,
          //spanGaps: true,
        }
       /* {
          label: "Mobile",
          fill: true,
          lineTension: 0,
          backgroundColor: "RGBA(61,0,255,0.3)",
          //borderColor: "blue", // The main line color
          borderCapStyle: 'butt',
          borderDash: [], // try [5, 15] for instance
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "blue",
          pointBackgroundColor: "white",
          pointBorderWidth: 1,
          pointHoverRadius: 8,
          pointHoverBackgroundColor: "blue",
          pointHoverBorderColor: "blue",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          // notice the gap in the data and the spanGaps: false
          data:this.dias_value_movil,
          spanGaps: false,
        },
        {
          label: "Tablet",
          fill: true,
          lineTension: 0,
          backgroundColor: "RGBA(246,91,246,0.3)",
          //borderColor: "#F65BF6", // The main line color
          borderCapStyle: 'butt',
          borderDash: [], // try [5, 15] for instance
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "#F65BF6",
          pointBackgroundColor: "F65BF6",
          pointBorderWidth: 1,
          pointHoverRadius: 8,
          pointHoverBackgroundColor: "#F65BF6",
          pointHoverBorderColor: "#F65BF6",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          // notice the gap in the data and the spanGaps: false
          data: this.dias_value_tablet,
          spanGaps: false,
        }*/
      ],
   
    },
    options: {
      legend: {
        display: false,
        },
      responsive: true,
      title:{
          display:false,
          text:'Ingresos por día',
          fontSize:15
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
        xAxes:[{ gridLines: {
              display:false
          }}],
        yAxes: [
          {
          gridLines: {
              display:false
          } , 
            scaleLabel: {
                 display: true,
                 labelString: 'Ingresos (Soles)',
                 fontSize: 14 
              }
        }],
                    
    }  
  },
  
      plugins: {
        datalabels: {
          anchor: 'end',
          align: 'top',
          formatter: Math.round,
          font: {
            weight: 'bold'
          }
        }
      }
  })


});


  
}  

exportTable(table:string,fechas:string,reporte:string){
  TableUtil.exportToPdf(table,fechas,reporte);
}


loadDatos(inicio:string,final:string,empresa:string){

      this.labels=[];
      this.values=[];
      this.labeldias=[];
      this.dias_value_desk=[];
      this.dias_value_movil=[];
      this.dias_value_tablet=[];
      this.creat_dias=[];
      this.creat_total=[];
      this.resetChart();
      this.cargando=true;

      this.api.getReportes(inicio,final,empresa)
      .subscribe(res => {
          this.inicio=res['inicio'];
        this.final=res['final'];
        this.ingreso_total= res['ingreso'].map(res => res.ingreso_total);
        let alldates = res['data'].map(res => res.total)
        let  alllabels = res['data'].map(res => res.dimensionad_exchange_device_category)

        let dias = res['diario_desktop'].map(res=>res.dimensiondate)
        let dias_valdesck =res['diario_desktop'].map(res=>res.total)
        
        let creative_sizes = res['creatives'].map(res=>res.dimensionad_exchange_creative_sizes);
        let creative_total = res['creatives'].map(res=>res.total);
    
        creative_sizes.forEach((res)=>{this.creat_dias.push(res)})
        creative_total.forEach((res)=>{this.creat_total.push(res)})

        alllabels.forEach((res)=>{this.labels.push(res)});
        alldates.forEach((res) =>{this.values.push(res)});
  
        dias.forEach((res)=>{this.labeldias.push(res)})
        dias_valdesck.forEach((res)=>{this.dias_value_desk.push(res)})
        
  
  if(this.window != undefined)
  this.window.destroy();
  this.window = new Chart(this.piechar, {});

  this.api.getPie(this.creat_dias,this.creat_total,'canvas4','Ingreso por tamaño de creatividad');
  this.api.getPie(this.labels,this.values,'canvas','Ingresos por dispositivo');
  

  this.barchar = new Chart('canvas2', {
    type: 'line',
    data: {
      labels: this.labeldias,
      datasets: [
        {
          //label: "Desktop",
          fill: true,
          lineTension: 0.3,
          backgroundColor: "#2196f3ff",
          borderColor: "#2196f3ff",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(6, 58, 228)",
          pointBackgroundColor: "#000",
          pointBorderWidth: 0,
          pointHoverRadius: 1,
          pointHoverBackgroundColor: "rgba(6, 58, 228)",
          pointHoverBorderColor: "#2196f3ff",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          //spanGaps: true,
          data: this.dias_value_desk,
          //spanGaps: true,
        }
       /* {
          label: "Mobile",
          fill: true,
          lineTension: 0,
          backgroundColor: "RGBA(61,0,255,0.3)",
          //borderColor: "blue", // The main line color
          borderCapStyle: 'butt',
          borderDash: [], // try [5, 15] for instance
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "blue",
          pointBackgroundColor: "white",
          pointBorderWidth: 1,
          pointHoverRadius: 8,
          pointHoverBackgroundColor: "blue",
          pointHoverBorderColor: "blue",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          // notice the gap in the data and the spanGaps: false
          data:this.dias_value_movil,
          spanGaps: false,
        },
        {
          label: "Tablet",
          fill: true,
          lineTension: 0,
          backgroundColor: "RGBA(246,91,246,0.3)",
          //borderColor: "#F65BF6", // The main line color
          borderCapStyle: 'butt',
          borderDash: [], // try [5, 15] for instance
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "#F65BF6",
          pointBackgroundColor: "F65BF6",
          pointBorderWidth: 1,
          pointHoverRadius: 8,
          pointHoverBackgroundColor: "#F65BF6",
          pointHoverBorderColor: "#F65BF6",
          pointHoverBorderWidth: 2,
          pointRadius: 4,
          pointHitRadius: 10,
          // notice the gap in the data and the spanGaps: false
          data: this.dias_value_tablet,
          spanGaps: false,
        }*/
      ],
   
    },
    options: {
      legend: {
        display: false,
        },
      responsive: true,
      title:{
          display:false,
          text:'Ingresos por día',
          fontSize:15
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
        xAxes:[{ gridLines: {
              display:false
          }}],
        yAxes: [
          {
          gridLines: {
              display:false
          } , 
            scaleLabel: {
                 display: true,
                 labelString: 'Ingresos (USD)',
                 fontSize: 14 
              }
        }],
                    
    }  
  },
  
      plugins: {
        datalabels: {
          anchor: 'end',
          align: 'top',
          formatter: Math.round,
          font: {
            weight: 'bold'
          }
        }
      }
  })
this.cargando=false;
})

}

resetChart(){
//var pieChartContent = document.getElementById('pieChartContent');
//pieChartContent.innerHTML = '&nbsp;';
//pieChartContent.innerHTML='<canvas id="canvas"><canvas>';
var barChartContent = document.getElementById('barChartContent2');
barChartContent.innerHTML = '&nbsp;';
barChartContent.innerHTML='<canvas id="canvas2"><canvas>';
//var barChartContent4 = document.getElementById('barChartContent4');
//barChartContent4.innerHTML = '&nbsp;';
//barChartContent4.innerHTML='<canvas id="canvas4"><canvas>';
}
}