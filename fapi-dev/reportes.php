<?php
header('Access-Control-Allow-Origin:*');
header("Access-Control-Allow-Headers: X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Allow: GET, POST, OPTIONS, PUT, DELETE");
$method = $_SERVER['REQUEST_METHOD'];
if($method == "OPTIONS") {
    die();
}
require_once 'vendor/autoload.php';
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

$app = new Slim\Slim();
$db = new mysqli("localhost","marife","libido16","franzdev");
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

//mysqli_set_charset($db, 'utf8');
if (mysqli_connect_errno()) {
    printf("Conexiónes fallida: %s\n", mysqli_connect_error());
    exit();
}


$app->get("/inventario/:id",function($id) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
  $resultado = $db->query("SELECT p.id,p.codigo,s.nombre categoria,p.nombre producto,sum(i.granel) granel,sum(i.merma) merma,sum(i.cantidad) cantidad,sum(i.peso/1000) peso FROM frdash.inventario i, productos p,categorias c,sub_categorias s WHERE p.id_subcategoria={$id} and p.id_categoria=c.id and p.id_subcategoria=s.id and p.id_categoria=c.id and i.id_producto=p.id group by 1,2,3,4");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            $prods[]=$fila;
      }

    $totales = $db->query("SELECT p.id_subcategoria,sum(i.granel) granel,sum(i.merma) merma,sum(i.cantidad) cantidad,sum(i.peso/1000)peso FROM frdash.inventario i, productos p where p.id_subcategoria={$id} and i.id_producto=p.id group by 1;");  
    $tot=array();
        while ($fila = $totales->fetch_array()) {
            $tot[]=$fila;
      }

   

      $respuesta=json_encode(array("status"=>200,"data"=>$prods,"total"=>$tot));
    echo  $respuesta;
    
});

$app->post("/reporte",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $json = $app->request->getBody();
    $dat = json_decode($json, true);
    $arraymeses=array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
    $arraynros=array('01','02','03','04','05','06','07','08','09','10','11','12');
    $mes1=substr($dat['ini'], 3,3);
    $mes2=substr($dat['fin'], 3,3);
    $dia1=substr($dat['ini'], 0,2);
    $dia2=substr($dat['fin'], 0,2);
    $ano1=substr($dat['ini'], 7,4);
    $ano2=substr($dat['fin'], 7,4);
    $fmes1=str_replace($arraymeses,$arraynros,$mes1);
    $fmes2=str_replace($arraymeses,$arraynros,$mes2);
    $ini=$ano1.'-'.$fmes1.'-'.$dia1;
    $fin=$ano2.'-'.$fmes2.'-'.$dia2;
    $inicio=$dia1.'/'.$fmes1;
    $final=$dia2.'/'.$fmes2;


    $ingreso=$db->query("SELECT v.id, v.tipoDoc,v.id_usuario,case  v.estado when '1' then 'Enviada' when '3' then 'Anulada' end as estado,u.nombre usuario,ve.id id_vendedor,concat(ve.nombre,' ',ve.apellidos) vendedor,c.id id_cliente,c.num_documento,c.direccion,concat(c.nombre,' ',c.apellido) cliente,igv,monto_igv,valor_neto,valor_total,  comprobante,nro_comprobante, DATE_FORMAT(v.fecha, '%Y-%m-%d') fecha,observacion FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Boleta') and fecha  between '".$ini."' and '".$fin."' order by v.id desc");
       $infoboleta=array();
    while ($row = $ingreso->fetch_array()) {
            $infoboleta[]=$row;
        }

        $factura=$db->query("SELECT v.id, v.tipoDoc,v.id_usuario,case  v.estado when '1' then 'Enviada' when '3' then 'Anulada' end as estado,u.nombre usuario,ve.id id_vendedor,concat(ve.nombre,' ',ve.apellidos) vendedor,c.id id_cliente,c.num_documento,c.direccion,concat(c.nombre,' ',c.apellido) cliente,igv,monto_igv,valor_neto,valor_total,  comprobante,nro_comprobante, DATE_FORMAT(v.fecha, '%Y-%m-%d') fecha,observacion FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Factura') and fecha  between '".$ini."' and '".$fin."' order by v.id desc");
        $infofactura=array();
    while ($row = $factura->fetch_array()) {
            $infofactura[]=$row;
        }

        $totales=$db->query("SELECT sum(valor_neto) valor_neto,sum(monto_igv) monto_igv,sum(valor_total) valor_total  FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Boleta','Factura') and fecha  between '".$ini."' and '".$fin."'");
        $infototal=array();
        while ($row = $totales->fetch_array()) {
                $infototal[]=$row;
            }

            $totalboleta=$db->query("SELECT sum(valor_neto) valor_neto,sum(monto_igv) monto_igv,sum(valor_total) valor_total  FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Boleta') and fecha  between '".$ini."' and '".$fin."'");
        $totalbo=array();
        while ($row = $totalboleta->fetch_array()) {
                $totalbo[]=$row;
            }

            $totalfactura=$db->query("SELECT sum(valor_neto) valor_neto,sum(monto_igv) monto_igv,sum(valor_total) valor_total  FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Factura') and fecha  between '".$ini."' and '".$fin."'");
            $totalfac=array();
            while ($row = $totalfactura->fetch_array()) {
                    $totalfac[]=$row;
                }

                

                $totalxdia=$db->query("SELECT DATE_FORMAT(v.fecha, '%d-%m-%y') fecha,sum(valor_neto) valor_neto,sum(monto_igv) monto_igv,sum(valor_total) valor_total  FROM ventas v,usuarios u,clientes c,vendedor ve where v.estado=1 and v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id and v.comprobante in('Boleta','Factura') and fecha  between '".$ini."' and '".$fin."' group by 1");
                $totaldias=array();
                while ($row = $totalxdia->fetch_array()) {
                        $totaldias[]=$row;
                    }       


        $data = array("status"=>200,
        "boletas"=>$infoboleta,
        "facturas"=>$infofactura,
        "totales"=>$infototal,
        "totalboleta"=>$totalbo,
        "totalfactura"=>$totalfac,
        "totaldias"=>$totaldias,
        "inicio"=>$ini,"final"=>$fin);

        echo json_encode($data);

       

     });


$app->run();