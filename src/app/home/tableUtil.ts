
export class TableUtil {
    static exportToPdf(tableId: string,fecha:string, name: string) {
       let printContents, popupWin,fechas;
      printContents = document.getElementById(tableId).innerHTML;
      fechas = document.getElementById(fecha).innerHTML;
      console.log(printContents)
      popupWin = window.open('', '_blank', 'top=0,left=0,height=auto,width=auto');
      popupWin.document.open();
      popupWin.document.write(`
    <html>
      <head>
        </head>
  <body onload="window.print();window.close()">
  <table>
  <tr> <td width="30%"><img width="150px" src="assets/img/vivian-food.png"></td><td width="70%" style="text-align:center;font-face:arial"><h1>${name}</h1></td></tr>
  </table>
  <div style="text-align:center;font-size:11px">Desde ${fechas}</div><hr>
  <table width="100%" style="text-align:center;font-family:arial;font-size:10px">${printContents}</table></body>
    </html>`
      );
      popupWin.document.close();
    }
  }