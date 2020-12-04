import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import {HttpClientModule} from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import {MatInputModule} from '@angular/material/input';
import {MatButtonModule} from '@angular/material/button';
import {MatCardModule} from '@angular/material/card';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatCheckboxModule} from '@angular/material/checkbox';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatRadioModule} from '@angular/material/radio';
import {MatSelectModule} from '@angular/material/select';
import { adminLteConf } from './admin-lte.conf';
import { AppRoutingModule } from './app-routing.module';
import { CoreModule } from './core/core.module';
import { LayoutModule, AlertModule } from 'angular-admin-lte';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { LoadingPageModule, MaterialBarModule } from 'angular-loading-page';
import { BoxModule, BoxInfoModule as MkBoxInfoModule } from 'angular-admin-lte';
import { MatNativeDateModule } from '@angular/material/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { OwlDateTimeModule, OwlNativeDateTimeModule } from 'ng-pick-datetime';
import {MatPaginatorModule, MatPaginatorIntl} from '@angular/material/paginator';
import {MatTableModule} from '@angular/material/table';
import { MatSortModule } from '@angular/material/sort';
import { PagoComponent } from './pago/pago.component';
import { GeneralComponent } from './general/general.component';
import { PaginatorEspañol } from './modelos/paginator-espanol';
import { AlertModule as MkAlertModule } from 'angular-admin-lte';
import { AlertComponent } from 'library/angular-admin-lte/src/lib/alert/alert.component';
import { ProductosComponent } from './productos/productos.component';




@NgModule({
  imports: [
    BrowserModule,OwlDateTimeModule, OwlNativeDateTimeModule,
    AppRoutingModule,
    CoreModule,
    LayoutModule.forRoot(adminLteConf),
    LoadingPageModule, MaterialBarModule,HttpClientModule,
    BoxModule,
    MkBoxInfoModule,
    FormsModule,MatPaginatorModule,MatTableModule,
    MatDatepickerModule,BrowserAnimationsModule,
    MatInputModule,MatButtonModule,MatCardModule,MatFormFieldModule,MatCheckboxModule,MatRadioModule,MatSelectModule,MatNativeDateModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatInputModule,
    MkAlertModule,AlertModule
 
  ],
  providers:[{ provide: MatPaginatorIntl, useClass: PaginatorEspañol}]
  ,

  declarations: [
    AppComponent,
    PagoComponent,
    HomeComponent,
    GeneralComponent,
    ProductosComponent,
    
    
      ],
  bootstrap: [AppComponent]
})
export class AppModule {}
