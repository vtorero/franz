import { Component, AfterViewInit } from '@angular/core';

import * as Prism from 'prismjs';

@Component({
  selector: 'app-sidebar-left',
  templateUrl: './sidebar-left.component.html'
})
export class SidebarLeftComponent implements AfterViewInit {
  imagen:string
  empresa:string
  /**
   * @method ngAfterViewInit
   */
  ngAfterViewInit() {
    Prism.highlightAll();
    this.imagen=localStorage.getItem("currentAvatar")
    this.empresa=localStorage.getItem("currentEmpresa")
  }
}
