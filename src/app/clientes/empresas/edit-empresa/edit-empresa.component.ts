import { Component, Inject, OnInit } from '@angular/core';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { DateTimeAdapter } from 'ng-pick-datetime';
import { ToastrService } from 'ngx-toastr';
import { ApiService } from 'src/app/api.service';
import { Proveedor } from 'src/app/modelos/proveedor';

@Component({
  selector: 'app-edit-empresa',
  templateUrl: './edit-empresa.component.html',
  styleUrls: ['./edit-empresa.component.css']
})
export class EditEmpresaComponent implements OnInit {

  constructor(
    private api:ApiService,
    public dialogRef: MatDialogRef<EditEmpresaComponent>,
    public dialog:MatDialog,
    @Inject(MAT_DIALOG_DATA) public data:Proveedor,
    dateTimeAdapter: DateTimeAdapter<any>,
    private toastr: ToastrService
  ) { }

  ngOnInit() {
  }

  cancelar() {
    this.dialogRef.close();
  }

}
