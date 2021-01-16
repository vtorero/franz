import { Component } from '@angular/core';

@Component({
  selector: 'app-sidebar-left-inner',
  templateUrl: './sidebar-left-inner.component.html'
})
export class SidebarLeftInnerComponent {
  imagen:string
  empresa:string

  ngAfterViewInit() {
    this.imagen=localStorage.getItem("currentAvatar")
    this.empresa=localStorage.getItem("currentNombre")
  }
}
