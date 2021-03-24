
export class TableUtil {
    static exportToPdf(tableId: string, name: string) {
       let printContents, popupWin;
      printContents = document.getElementById(tableId).innerHTML;
      console.log(printContents)
      popupWin = window.open('', '_blank', 'top=0,left=0,height=auto,width=auto');
      popupWin.document.open();
      popupWin.document.write(`
    <html>
      <head>
        </head>
  <body onload="window.print();window.close()">
  <table>
  <tr> <td width="30%"><img width="150px" src="http://localhost:4200/assets/img/vivian-food.png"></td><td width="70%" style="text-align:center;font-face:arial"><h1>${name}</h1></td></tr>
  <tr><td colspan="2"width="100%" style="text-align:center"><h3>Desde 2021-03-12 al 2021-03-22</h3></td></tr>
  </table>
  <table width="100%" style="text-align:center;font-family:arial;font-size:10px">${printContents}</table></body>
    </html>`
      );
      popupWin.document.close();
    }
  }