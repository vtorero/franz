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
$app = new Slim\Slim();
$db = new mysqli("localhost","marife","libido16","franzdev");
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

//mysqli_set_charset($db, 'utf8');
if (mysqli_connect_errno()) {
    printf("Conexiónes fallida: %s\n", mysqli_connect_error());
    exit();
}
$data=array();

/*Productos*/
$app->get("/productos",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT p.id,codigo,p.nombre,c.nombre nombrecategoria,costo,IGV,precio_sugerido,c.id id_categoria,id_subcategoria,usuario FROM  productos p, categorias c WHERE p.id_categoria=c.id");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
    });

$app->get("/categorias",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
        $resultado = $db->query("SELECT id, nombre  FROM  categorias order by id");  
        $prods=array();
            while ($fila = $resultado->fetch_array()) {
                
                $prods[]=$fila;
            }
            $respuesta=json_encode($prods);
            echo  $respuesta;
            
        });

        $app->get("/subcategorias",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
            $resultado = $db->query("SELECT s.id,c.id id_categoria,c.nombre categoria,s.nombre FROM sub_categorias s,categorias c WHERE s.id_categoria=c.id order by s.id");  
            $prods=array();
                while ($fila = $resultado->fetch_array()) {
                    
                    $prods[]=$fila;
                }
                $respuesta=json_encode($prods);
                echo  $respuesta;
                
            });


    $app->post("/categoria",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
        
            $nombre=(is_array($data->nombre))? array_shift($data->nombre): $data->nombre;
           
            $query ="INSERT INTO categorias (nombre) VALUES ('"."{$nombre}"."')";
            $proceso=$db->query($query);
            if($proceso){
           $result = array("STATUS"=>true,"messaje"=>"Categoria creada correctamente");
            }else{
            $result = array("STATUS"=>false,"messaje"=>"Ocurrio un error en la creación");
            }
            echo  json_encode($result);
        });

        $app->post("/subcategoria",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
               $json = $app->request->getBody();
               $j = json_decode($json,true);
               $data = json_decode($j['json']);
            
               $query ="INSERT INTO sub_categorias (id_categoria,nombre) VALUES ({$data->id_categoria},'{$data->nombre}')";
                $proceso=$db->query($query);
                if($proceso){
               $result = array("STATUS"=>true,"messaje"=>"Subcategoria creada correctamente");
                }else{
                $result = array("STATUS"=>false,"messaje"=>"Ocurrio un error en la creación");
                }
                echo  json_encode($result);
        });

        $app->get("/subcategoria/:criterio",function($criterio) use($db,$app){
            header("Content-type: application/json; charset=utf-8");
            $resultado = $db->query("SELECT s.id,c.id id_categoria,c.nombre categoria,s.nombre FROM sub_categorias s,categorias c WHERE s.id_categoria=c.id and c.id={$criterio} order by s.id");  
            $prods=array();
                while ($fila = $resultado->fetch_array()) {
                    
                    $prods[]=$fila;
                }
                $respuesta=json_encode($prods);
                echo  $respuesta;
                
        });


        $app->post("/categoriadel",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
               $json = $app->request->getBody();
               $j = json_decode($json,true);
               $data = json_decode($j['json']);
               $codigo=(is_array($data->id))? array_shift($data->id): $data->id;
               $query ="DELETE FROM categorias WHERE id="."'{$codigo}'";
               $operacion=$db->query($query);
               if($operacion){        
               $result = array("STATUS"=>true,"messaje"=>"Categoria eliminada correctamente");
            }else{
                $result = array("STATUS"=>false,"messaje"=>'Ocurrio un error');
            }
                echo  json_encode($result);
            });        

    $app->post("/productodel",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
           $codigo=(is_array($data->codigo))? array_shift($data->codigo): $data->codigo;
           $query ="DELETE FROM productos WHERE codigo="."'{$codigo}'";
           $db->query($query);
                   
           $result = array("STATUS"=>true,"messaje"=>"Producto eliminado correctamente","string"=>$query);
            echo  json_encode($result);
        });


/*productos*/

    $app->get("/productos/:criterio",function($criterio) use($db,$app){
            header("Content-type: application/json; charset=utf-8");
            try{
            $resultado = $db->query("SELECT `id`, `codigo`, `nombre` FROM `productos` where nombre like '%".$criterio."%'");  
            $prods=array();
            while ($fila = $resultado->fetch_array()) {
                
                $prods[]=$fila;
            }
            $respuesta=json_encode($prods);
        }catch (PDOException $e){
            $respuesta=json_encode(array("status"=>$e->message));
        }
                     echo  $respuesta;
                
        });

    $app->post("/producto",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
    
           $codigo=(is_array($data->codigo))? array_shift($data->codigo): $data->codigo;
            $nombre=(is_array($data->nombre))? array_shift($data->nombre): $data->nombre;
            $costo=(is_array($data->costo))? array_shift($data->costo): $data->costo;
            $precio=(is_array($data->precio_sugerido))? array_shift($data->precio_sugerido): $data->precio_sugerido;
            $categoria=(is_array($data->id_categoria))? array_shift($data->id_categoria): $data->id_categoria;
            $sub_categoria=(is_array($data->id_subcategoria))? array_shift($data->id_subcategoria): $data->id_subcategoria;
            $usuario=(is_array($data->usuario))? array_shift($data->usuario): $data->usuario;
    
        
           $query ="INSERT INTO productos (codigo,nombre,costo,precio_sugerido,id_categoria,id_subcategoria,usuario) VALUES ("
          ."'{$codigo}',"
          ."'{$nombre}',"
          ."{$costo},"
          ."{$precio},"
          ."{$categoria},"
          ."{$sub_categoria},"
          ."'{$usuario}'".")";
       
          $insert=$db->query($query);
                   
           $result = array("STATUS"=>true,"messaje"=>"Producto creado correctamente");
            echo  json_encode($result);
        });

        $app->post("/productoedit",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
            $json = $app->request->getBody();
            $j = json_decode($json,true);
            $data = json_decode($j['json']);
             
            $codigo=(is_array($data->codigo))? array_shift($data->codigo): $data->codigo;
            $nombre=(is_array($data->nombre))? array_shift($data->nombre): $data->nombre;
            $costo=(is_array($data->costo))? array_shift($data->costo): $data->costo;
            $precio=(is_array($data->precio_sugerido))? array_shift($data->precio_sugerido): $data->precio_sugerido;
            $categoria=(is_array($data->id_categoria))? array_shift($data->id_categoria): $data->id_categoria;
            $sub_categoria=(is_array($data->id_subcategoria))? array_shift($data->id_subcategoria): $data->id_subcategoria;
            $usuario=(is_array($data->usuario))? array_shift($data->usuario): $data->usuario;

            $sql = "UPDATE productos SET nombre='".$nombre."',costo=".$costo.", precio_sugerido=".$precio.",id_categoria=".$categoria.",id_subcategoria=".$sub_categoria.",usuario='".$usuario."' WHERE id={$data->id}";
            try { 
            $db->query($sql);
             $result = array("STATUS"=>true,"messaje"=>"Producto actualizado correctamente","string"=>$sql);
             echo  json_encode($result);
            }
             catch(PDOException $e) {
        echo '{"error":{"text":'. $e->getMessage() .'}}';
        }
                               
        
         });
 
/*Proveedores*/
$app->get("/proveedores",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
            $resultado = $db->query("SELECT `id`, `razon_social`,`num_documento`, `direccion`,`departamento`,`provincia`,`distrito` FROM `proveedores` order by id desc");  
            $prods=array();
                while ($fila = $resultado->fetch_array()) {
                    
                    $prods[]=$fila;
                }
                $respuesta=json_encode($prods);
                echo  $respuesta;
                
});

$app->get("/empresas",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT `id`, `razon_social`,`num_documento`, `direccion`,`departamento`,`provincia`,`distrito` FROM `empresas` order by id desc");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
});


     
$app->post("/proveedor",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);

        $ruc=(is_array($data->num_documento))? array_shift($data->num_documento): $data->num_documento;
        $razon_social=(is_array($data->razon_social)) ? array_shift(str_replace("'","\'",$data->razon_social)):str_replace("'","\'",$data->razon_social);
        $direccion=(is_array($data->direccion))? array_shift($data->direccion): $data->direccion;
        $departamento=(is_array($data->departamento))? array_shift($data->departamento): $data->departamento;
        $provincia=(is_array($data->provincia))? array_shift($data->provincia): $data->provincia;
        $distrito=(is_array($data->distrito))? array_shift($data->distrito): $data->distrito;
        $num_documento=(is_array($data->num_documento))? array_shift($data->num_documento): $data->num_documento;


        $query ="INSERT INTO proveedores (razon_social, direccion, num_documento, departamento,provincia,distrito) VALUES ("
      ."'{$razon_social}',"
      ."'{$direccion}',"
      ."'{$ruc}',"
      ."'{$departamento}',"
      ."'{$provincia}',"
      ."'{$distrito}'".")";
        $db->query($query);
        
               
       $result = array("STATUS"=>true,"messaje"=>"Proveedor registrado correctamente","string"=>$query);
        echo  json_encode($result);
    });

    $app->delete("/proveedor/:ruc",function($ruc) use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
                      $query ="DELETE FROM proveedores WHERE num_documento='{$ruc}'";
                      if($db->query($query)){
           $result = array("STATUS"=>true,"messaje"=>"Proveedor eliminado correctamente");
           }
           else{
            $result = array("STATUS"=>false,"messaje"=>"Error al eliminar el proveedor");
           }
           
            echo  json_encode($result);
        });

/**Compras */

$app->post("/compra",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);
       try { 
        $fecha=substr($data->fecha,0,10);
        $sql="call p_compra({$data->comprobante},{$data->num_comprobante},'{$data->descripcion}','{$fecha}',{$data->id_proveedor})";
        $stmt = mysqli_prepare($db,$sql);
        mysqli_stmt_execute($stmt);
        $datos=$db->query("SELECT max(id) ultimo_id FROM compras");
        $ultimo_id=array();
        while ($d = $datos->fetch_object()) {
         $ultimo_id=$d;
         }

         foreach($data->detalleCompra as $valor){
            $proc="call p_compra_detalle(0,{$valor->cantidad},{$valor->precio},{$ultimo_id->ultimo_id},'{$valor->descripcion}')";
           $stmt = mysqli_prepare($db,$proc);
            mysqli_stmt_execute($stmt);
            $proc="";
        }
        $result = array("STATUS"=>true,"messaje"=>"Compra registrada correctamente","string"=>$fecha);
        
        }
         catch(PDOException $e) {

        $result = array("STATUS"=>false,"messaje"=>$e->getMessage());
        
    }
    
             echo  json_encode($result);   
});



$app->post("/compraedit",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);

       $sql = "UPDATE compras SET comprobante='".$data->comprobante."',id_proveedor=".$data->id_proveedor.",num_comprobante='".$data->num_comprobante."', descripcion='".$data->descripcion."',fecha='".substr($data->fecha,0,10)."' WHERE id=".$data->id;
       try { 
        $db->query($sql);
        $borra="DELETE FROM detalle_compras where id_compra={$data->id}";
        $db->query($borra);
        foreach($data->detalleCompra as $valor){
          $proc="call p_compra_detalle(0,{$valor->cantidad},{$valor->precio},{$data->id},'{$valor->descripcion}')";
           $stmt = mysqli_prepare($db,$proc);
            mysqli_stmt_execute($stmt);
            $proc="";
        }

        $result = array("STATUS"=>true,"messaje"=>"Compra actualizada correctamente");
        }
         catch(PDOException $e) {
        $result = array("STATUS"=>true,"messaje"=>$e->getMessage());
         }
        echo  json_encode($result);
     
      
});

$app->get("/compra/:id",function($id) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT `id`, `descripcion`, `cantidad`, `precio`, `id_articulo`, `id_compra` FROM `detalle_compras` where id_compra={$id}");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;    
});


$app->get("/compras",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT c.`id`, comprobante,`num_comprobante`, `descripcion`,DATE_FORMAT(fecha, '%Y-%m-%d') fecha, c.`id_proveedor`,p.razon_social, `id_usuario`,(select sum(precio) from detalle_compras where id_compra=c.id) total  FROM `compras` c, proveedores p where c.id_proveedor=p.id order by c.id desc");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;    
});


/*Inventarios*/

$app->get("/almacen",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado=$db->query("SELECT id_producto,p.codigo,p.nombre, id_producto,sum(cantidad) cantidad, sum(peso) peso FROM inventario i, productos p where i.id_producto=p.id GROUP by 1,2,3,4");
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;

});

$app->get("/inventarios",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT i.id,p.codigo,`id_producto`,p.nombre, `id_producto`,`presentacion`,`cantidad`,peso, DATE_FORMAT(fecha_produccion, '%Y-%m-%d')  fecha_produccion,DATE_FORMAT(fecha_vencimiento, '%Y-%m-%d')  fecha_vencimiento,datediff(fecha_vencimiento,now()) `dias`, `estado`, `ciclo`, `id_usuario` FROM `inventario` i, productos p where i.id_producto=p.id");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
    });


    $app->get("/alertaintentario",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
        $prods=array();
        $resultado = $db->query("SELECT i.id,id_producto,fecha_produccion,p.nombre,datediff(now(),fecha_produccion) dias FROM `inventario` i ,`productos` p where i.id_producto=p.id and datediff(now(),fecha_produccion)>=7 order by fecha_produccion");  
        
        if($resultado->num_rows>0){
               while ($fila = $resultado->fetch_array()) {

                $prods[]=$fila;
            }
            $respuesta=json_encode($prods);
        }else{
            $respuesta=json_encode($prods);
        }
            echo  $respuesta;
        });


    $app->post("/inventario",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
           try { 
            $fecha=substr($data->fecha_produccion,0,10);
            $fecha2=substr($data->fecha_vencimiento,0,10);
            $sql="call p_inventario({$data->id_producto},'{$data->presentacion}',{$data->cantidad},{$data->peso},'{$fecha}','{$fecha2}','{$data->observacion}')";
            $stmt = mysqli_prepare($db,$sql);
            mysqli_stmt_execute($stmt);
            $result = array("STATUS"=>true,"messaje"=>"Inventario registrado correctamente","string"=>$fecha);
           }
            catch(PDOException $e) {
                $result = array("STATUS"=>true,"messaje"=>$e->getMessage());
                 }
            
                 $respuesta=json_encode($result);
                echo  $respuesta;

        });



        $app->put("/inventario",function() use($db,$app){
            header("Content-type: application/json; charset=utf-8");
               $json = $app->request->getBody();
               $j = json_decode($json,true);
               $data = json_decode($j['json']);
               try { 
                $fecha=substr($data->fecha_produccion,0,10);
                $sql="call p_inventario_upd({$data->id},'{$fecha}','{$data->presentacion}','{$data->unidad}',{$data->cantidad})";
                $stmt = mysqli_prepare($db,$sql);
                mysqli_stmt_execute($stmt);
                $result = array("STATUS"=>true,"messaje"=>"Inventario actualizado correctamente");
               }
                catch(PDOException $e) {
                    $result = array("STATUS"=>true,"messaje"=>$e->getMessage());
                     }
                $respuesta=json_encode($result);
                echo  $respuesta;
    
        });

/*vendedores*/


$app->post("/vendedores",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);
    
       $query ="INSERT INTO vendedor (nombre,apellidos,dni,razon_social,ruc) VALUES ('{$data->nombre}','{$data->apellidos}','{$data->dni}','{$data->razon_social}','{$data->ruc}')";
        $proceso=$db->query($query);
        if($proceso){
       $result = array("STATUS"=>true,"messaje"=>"Vendedor creado correctamente");
        }else{
        $result = array("STATUS"=>false,"messaje"=>"Ocurrio un error en la creación");
        }
        echo  json_encode($result);
});

$app->get("/vendedores",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT `id`, `nombre`, `apellidos`, `dni`, `razon_social`, `ruc`, `fecha` FROM `vendedor` order by id desc");  
    $vendedores=array();
        while ($fila = $resultado->fetch_array()) {
            
            $vendedores[]=$fila;
        }
        $respuesta=json_encode($vendedores);
        echo  $respuesta;
    });

    $app->delete("/vendedores/:id",function($id) use($db,$app){
        header("Content-type: application/json; charset=utf-8");
        $resultado = $db->query("DELETE FROM `vendedor` where  id={$id}");  
        if($resultado){
            $result = array("STATUS"=>true,"messaje"=>"Vendedor eliminado correctamente");
             }else{
             $result = array("STATUS"=>false,"messaje"=>"Ocurrio un error en la creación");
             }
             echo  json_encode($result);
        });
    
/*ventas*/

$app->get("/ventas",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT  v.id, v.id_usuario,u.nombre usuario,concat(ve.nombre,' ',ve.apellidos) vendedor,concat(c.nombre,' ',c.apellido) cliente,valor_total, estado, comprobante, v.fecha FROM ventas v,usuarios u,clientes c,vendedor ve where v.id_vendedor=ve.id and v.id_cliente=c.id and v.id_usuario=u.id order by id desc");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;    
});

$app->get("/inventarios/:id",function($id) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT i.id,p.codigo,`id_producto`,p.nombre,p.precio_sugerido precio,`presentacion`,`cantidad`,peso,DATE_FORMAT(fecha_produccion,'%Y-%m-%d')  fecha_produccion,datediff(now(),fecha_produccion) `dias`, `estado`, `ciclo`, `id_usuario` FROM `inventario` i, productos p where i.id_producto=p.id and id_producto={$id} order by fecha_produccion asc");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
    });

    $app->post("/venta",function() use($db,$app){
        header("Content-type: application/json; charset=utf-8");
           $json = $app->request->getBody();
           $j = json_decode($json,true);
           $data = json_decode($j['json']);
           $valor_total=0;
           /*total de la venta*/
           foreach($data->detalleVenta as $value){
                $valor_total+=$value->cantidad*$value->precio;
           }
           try { 
            $fecha=substr($data->fecha,0,10);
            $sql="call p_venta('{$data->id_usuario}',{$data->id_vendedor},'{$data->id_cliente}','{$data->comprobante}','{$fecha}',{$valor_total})";
           $stmt = mysqli_prepare($db,$sql);
            mysqli_stmt_execute($stmt);
            $datos=$db->query("SELECT max(id) ultimo_id FROM ventas");
            $ultimo_id=array();
            while ($d = $datos->fetch_object()) {
             $ultimo_id=$d;
             }
            foreach($data->detalleVenta as $valor){
            /*inserta detalla*/
            $proc="call p_venta_detalle({$ultimo_id->ultimo_id},{$valor->id_producto},{$valor->cantidad},{$valor->peso},{$valor->precio})";
            $stmt = mysqli_prepare($db,$proc);
            mysqli_stmt_execute($stmt);

             $proc="";
            
             /*actualiza inventario*/   
            $actualiza="call p_actualiza_inventario({$valor->id_productob->id},{$valor->cantidad},{$valor->peso})";    
            $stmtb = mysqli_prepare($db,$actualiza);
            mysqli_stmt_execute($stmtb);

            }
           
            $result = array("STATUS"=>true,"messaje"=>"Venta registrada correctamente con el nro:".$ultimo_id->ultimo_id);
            
            }
             catch(PDOException $e) {
    
            $result = array("STATUS"=>false,"messaje"=>$e->getMessage());
            
        }
        
            echo  json_encode($result);   
    });

/*clientes*/


$app->get("/clientes",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT id, nombre, apellido, direccion,telefono,num_documento FROM clientes order by id desc");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
});

$app->delete("/cliente/:dni",function($dni) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);
                  $query ="DELETE FROM clientes WHERE num_documento='{$dni}'";
                  if($db->query($query)){
       $result = array("STATUS"=>true,"messaje"=>"Cliente eliminado correctamente");
       }
       else{
        $result = array("STATUS"=>false,"messaje"=>"Error al eliminar el cliente");
       }
       
        echo  json_encode($result);
    });

$app->post("/cliente",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);
       try { 
        $query ="INSERT INTO clientes (nombre,apellido,direccion,telefono,num_documento) VALUES ('{$data->nombre}','{$data->apellido}','{$data->direccion}','{$data->telefono}','{$data->num_documento}')";
        $db->query($query);
        $result = array("STATUS"=>true,"messaje"=>"Ciente registrado correctamente");
          }
         catch(PDOException $e) {
        $result = array("STATUS"=>false,"messaje"=>$e->getMessage());
    }
        echo  json_encode($result);   
});

$app->get("/clientes/:criterio",function($criterio) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT `id`, `nombre`,`apellido` FROM `clientes` where apellido like '%".$criterio."%' or nombre like '%".$criterio."%'");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
});

$app->get("/clientes/:id",function($id) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT id, nombre,apellido,num_documento,direccion FROM `clientes` where id={$id}");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
});


$app->get("/empresas/:criterio",function($criterio) use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $resultado = $db->query("SELECT `id`, `razon_social` FROM `empresas` where razon_social like '%".$criterio."%'");  
    $prods=array();
        while ($fila = $resultado->fetch_array()) {
            
            $prods[]=$fila;
        }
        $respuesta=json_encode($prods);
        echo  $respuesta;
        
});

     
$app->post("/empresa",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);

        $ruc=(is_array($data->num_documento))? array_shift($data->num_documento): $data->num_documento;
        $razon_social=(is_array($data->razon_social)) ? array_shift(str_replace("'","\'",$data->razon_social)):str_replace("'","\'",$data->razon_social);
        $direccion=(is_array($data->direccion))? array_shift($data->direccion): $data->direccion;
        $departamento=(is_array($data->departamento))? array_shift($data->departamento): $data->departamento;
        $provincia=(is_array($data->provincia))? array_shift($data->provincia): $data->provincia;
        $distrito=(is_array($data->distrito))? array_shift($data->distrito): $data->distrito;
        $num_documento=(is_array($data->num_documento))? array_shift($data->num_documento): $data->num_documento;
        $estado=(is_array($data->estado))? array_shift($data->estado): $data->estado;

      $query ="INSERT INTO empresas (razon_social, direccion, num_documento, departamento,provincia,distrito,estado) VALUES ("
      ."'{$razon_social}',"
      ."'{$direccion}',"
      ."'{$ruc}',"
      ."'{$departamento}',"
      ."'{$provincia}',"
      ."'{$distrito}',"
      ."'{$estado}'".")";
        $estado=$db->query($query);
        $db->close();
if($estado){
        $result = array("STATUS"=>true,"messaje"=>"Empresa registrada correctamente","string"=>$estado);
    }else{
        $result = array("STATUS"=>false,"messaje"=>$estado);
    }
       echo  json_encode($result);
    });


$app->get("/numeroletras"),function() use($db,$app){
  
    $curl = curl_init();
    
    curl_setopt_array($curl, [
        CURLOPT_URL => "https://numeros-a-letras1.p.rapidapi.com/api/NAL/23",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_ENCODING => "",
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "GET",
        CURLOPT_HTTPHEADER => [
            "x-rapidapi-host: numeros-a-letras1.p.rapidapi.com",
            "x-rapidapi-key: SIGN-UP-FOR-KEY"
        ],
    ]);
    
    $response = curl_exec($curl);
    $err = curl_error($curl);
    
    curl_close($curl);
    
    if ($err) {
        echo "cURL Error #:" . $err;
    } else {
        echo $response;
    }

});   


$app->post("/bancosget",function() use($db,$app) {
header("Content-type: application/json; charset=utf-8");
    $json = $app->request->getBody();
    $data = json_decode($json, true);
      $datos=$db->query("SELECT * FROM api.dash_bancario WHERE usuario='{$data["empresa"]}'");
       $infocliente=array();
  while ($cliente = $datos->fetch_object()) {
            $infocliente[]=$cliente;
        }
        $return=array("data"=>$infocliente);

           echo  json_encode($return);
});



$app->post("/generalget",function() use($db,$app) {
header("Content-type: application/json; charset=utf-8");
    $json = $app->request->getBody();
    $data = json_decode($json, true);
      $datos=$db->query("SELECT * FROM api.dash_general WHERE empresa='{$data["empresa"]}'");
       $infocliente=array();
  while ($cliente = $datos->fetch_object()) {
            $infocliente[]=$cliente;
        }
        $return=array("data"=>$infocliente);

           echo  json_encode($return);
});


 $app->post("/banco",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);

        
        $empresa=(is_array($data->empresa))? array_shift($data->empresa): $data->empresa;
        $entidad=(is_array($data->entidad))? array_shift($data->entidad): $data->entidad;
        $beneficiario=(is_array($data->beneficiario))? array_shift($data->beneficiario): $data->beneficiario;
        $persona=(is_array($data->persona))? array_shift($data->persona): $data->persona;
        $dom_entidad=(is_array($data->dom_entidad))? array_shift($data->dom_entidad): $data->dom_entidad;
        $ciudad=(is_array($data->ciudad))? array_shift($data->ciudad): $data->ciudad;
        $sucursal=(is_array($data->sucursal))? array_shift($data->sucursal): $data->sucursal;
        $tipocuenta=(is_array($data->tipocuenta))? array_shift($data->tipocuenta): $data->tipocuenta;
        $numerocta=(is_array($data->numerocta))? array_shift($data->numerocta): $data->numerocta;
        $aba=(is_array($data->aba))? array_shift($data->aba): $data->aba;            
        $swift=(is_array($data->swift))? array_shift($data->swift): $data->swift;
        $contactobco=(is_array($data->contactobco))? array_shift($data->contactobco): $data->contactobco;
        $tlfcontacto=(is_array($data->tlfcontacto))? array_shift($data->tlfcontacto): $data->tlfcontacto;
        $bancointer=(is_array($data->bancointer))? array_shift($data->bancointer): $data->bancointer;
        $abainter=(is_array($data->abainter))? array_shift($data->abainter): $data->abainter;
        


        $contar=array();
        $cantidad=$db->query("SELECT * FROM api.dash_bancario WHERE usuario='{$empresa}'");
  while ($cliente = $cantidad->fetch_array()) {
            $contar[]=$cliente;
        }


if(count($contar)>0){ 

     $query ="UPDATE api.dash_bancario  SET "
        ."entidad ='{$entidad}',"
        ."beneficiario = '{$beneficiario}',"
        ."persona = '{$persona}',"
        ."dom_entidad = '{$dom_entidad}',"
        ."ciudad = '{$ciudad}',"
        ."sucursal = '{$sucursal}',"
        ."tipocuenta= '{$tipocuenta}',"
        ."numerocta= '{$numerocta}',"
        ."aba = '{$aba}',"
        ."swift = '{$swift}',"
        ."contactobco = '{$contactobco}',"
        ."tlfcontacto = '{$tlfcontacto}',"
        ."bancointer = '{$bancointer}',"
        ."abainter = '{$abainter}'"
        ." WHERE usuario='{$empresa}'";
          
          $update=$db->query($query);

      
    }else{
        $query ="INSERT INTO api.dash_bancario (usuario,entidad,beneficiario,persona,dom_entidad,ciudad,sucursal,tipocuenta,numerocta,aba,swift,contactobco,
        tlfcontacto,bancointer,abainter) VALUES ("
      ."'{$empresa}',"
      ."'{$entidad}',"
      ."'{$beneficiario}',"
      ."'{$persona}',"
      ."'{$dom_entidad}',"
      ."'{$ciudad}',"
      ."'{$sucursal}',"
      ."'{$tipocuenta}',"
      ."'{$numerocta}',"
      ."'{$aba}',"
      ."'{$swift}',"
      ."'{$contactobco}',"
      ."'{$tlfcontacto}',"
      ."'{$bancointer}',"
      ."'{$abainter}'"
        .")";
   
      $insert=$db->query($query);
    }
       if(count($contar)>0){
       $result = array("STATUS"=>true,"messaje"=>"Datos actualizados correctamente");
        }else{
        $result = array("STATUS"=>false,"messaje"=>"Datos creados correctamente");
        }
        echo  json_encode($result);
    });



 $app->post("/general",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
       $json = $app->request->getBody();
       $j = json_decode($json,true);
       $data = json_decode($j['json']);

        
        $nombres=(is_array($data->nombres))? array_shift($data->nombres): $data->nombres;
        $correo=(is_array($data->correo))? array_shift($data->correo): $data->correo;
        $telefono=(is_array($data->telefono))? array_shift($data->telefono): $data->telefono;
        $sociedad=(is_array($data->sociedad))? array_shift($data->sociedad): $data->sociedad;
        $paginas=(is_array($data->paginas))? array_shift($data->paginas): $data->paginas;
        $rut=(is_array($data->rut))? array_shift($data->rut): $data->rut;
        $domicilio=(is_array($data->domicilio))? array_shift($data->domicilio): $data->domicilio;
        $calle=(is_array($data->calle))? array_shift($data->calle): $data->calle;
        $numero=(is_array($data->numero))? array_shift($data->numero): $data->numero;            
        $ciudad=(is_array($data->ciudad))? array_shift($data->ciudad): $data->ciudad;
        $pais=(is_array($data->pais))? array_shift($data->pais): $data->pais;
        $confinanzas=(is_array($data->confinanzas))? array_shift($data->confinanzas): $data->confinanzas;
        $tlffinanzas=(is_array($data->tlffinanzas))? array_shift($data->tlffinanzas): $data->tlffinanzas;
        $correofinan=(is_array($data->correofinan))? array_shift($data->correofinan): $data->correofinan;
        $medios=(is_array($data->medios))? array_shift($data->medios): $data->medios;
        $empresa=$data->empresa;



        $contar=array();
        $cantidad=$db->query("SELECT * FROM api.dash_general WHERE empresa='{$empresa}'");
  while ($cliente = $cantidad->fetch_array()) {
            $contar[]=$cliente;
        }


if(count($contar)>0){ 

     $query ="UPDATE api.dash_general  SET "
        ."nombres ='{$nombres}',"
        ."correo = '{$correo}',"
        ."telefono = '{$telefono}',"
        ."sociedad = '{$sociedad}',"
        ."paginas = '{$paginas}',"
        ."rut = '{$rut}',"
        ."domicilio = '{$domicilio}',"
        ."calle = '{$calle}',"
        ."numero = '{$numero}',"
        ."ciudad = '{$ciudad}',"
        ."pais = '{$pais}',"
        ."confinanzas = '{$confinanzas}',"
        ."tlffinanzas = '{$tlffinanzas}',"
        ."correofinan = '{$correofinan}',"
        ."medios = '{$medios}'"
        ." WHERE empresa='{$empresa}'";
          
          $update=$db->query($query);

      
    }else{
        $query ="INSERT INTO api.dash_general (correo,empresa,nombres,telefono,sociedad,paginas,rut,domicilio,calle,numero,ciudad,pais,confinanzas,tlffinanzas,correofinan,medios) VALUES ("
      ."'{$correo}',"
      ."'{$empresa}',"
      ."'{$nombres}',"
      ."'{$telefono}',"
      ."'{$sociedad}',"
      ."'{$paginas}',"
      ."'{$rut}',"
      ."'{$domicilio}',"
      ."'{$calle}',"
      ."'{$numero}',"
      ."'{$ciudad}',"
      ."'{$pais}',"
      ."'{$confinanzas}',"
      ."'{$tlffinanzas}',"
      ."'{$correofinan}',"
      ."'{$medios}'"
          .")";
   
      $insert=$db->query($query);
    }
       if(count($contar)>0){
       $result = array("STATUS"=>true,"messaje"=>"Usuario actualizado correctamente");
        }else{
        $result = array("STATUS"=>false,"messaje"=>"Usuario creado correctamente");
        }
        echo  json_encode($result);
    });

/*login*/
   $app->post("/login",function() use($db,$app){
         $json = $app->request->getBody();
        $data = json_decode($json, true);

        $resultado = $db->query("SELECT * FROM usuarios where nombre='".$data['usuario']."' and contrasena='".$data['password']."'");  
        $usuario=array();
        while ($fila = $resultado->fetch_object()) {
        $usuario[]=$fila;
        }
        if(count($usuario)==1){
            $data = array("status"=>true,"rows"=>1,"data"=>$usuario);
        }else{
            $data = array("status"=>false,"rows"=>0,"data"=>null);
        }
        echo  json_encode($data);
    });

    $app->get("/vendedor/:criterio",function($criterio) use($db,$app){
        header("Content-type: application/json; charset=utf-8");
        $resultado = $db->query("SELECT id, nombre,apellidos FROM `vendedor` where nombre like '%{$criterio}%'");  
        $prods=array();
            while ($fila = $resultado->fetch_array()) {
                $prods[]=$fila;
            }
            $respuesta=json_encode($prods);
            echo  $respuesta;
        });


/*dashboard adops*/

   $app->post("/reporte",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $json = $app->request->getBody();
    $dat = json_decode($json, true);
    $hash=$dat['emp'];
    $arraymeses=array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
    $arraynros=array('01','02','03','04','05','06','07','08','09','10','11','12');
    $mes1=substr($dat['ini'], 0,3);
    $mes2=substr($dat['fin'], 0,3);
    $dia1=substr($dat['ini'], 3,2);
    $dia2=substr($dat['fin'], 3,2);
    $ano1=substr($dat['ini'], 5,4);
    $ano2=substr($dat['fin'], 5,4);
    $fmes1=str_replace($arraymeses,$arraynros,$mes1);
    $fmes2=str_replace($arraymeses,$arraynros,$mes2);
    $ini=$ano1.'-'.$fmes1.'-'.$dia1;
    $fin=$ano2.'-'.$fmes2.'-'.$dia2;
    $inicio=$dia1.'/'.$fmes1;
    $final=$dia2.'/'.$fmes2;

   $datocliente=$db->query("SELECT * FROM api.usuarios where hash='".$hash."'");
   $infocliente=array();
  while ($cliente = $datocliente->fetch_array()) {
            $infocliente[]=$cliente;
        }

        $tasa=(float) $infocliente[0]["tasa"];
        $emp=$infocliente[0]["empresa"];
        $cpm=(float) $infocliente[0]["cpm"];
        
        if($emp=='Latina.pe' and $fmes1=='08' and $fmes2=='08'){
            $tasa=1;
            $cpm=1;

        }

        $numeromes=(int)$fmes1;
        if($emp=='America Economia' and $numeromes>=10 and $ano1=='2020'){
            $tasa=0.70;
            $cpm=0.70;
        }


$ingreso=$db->query("SELECT FORMAT(sum(columnad_exchange_estimated_revenue*".$cpm.")/(sum(columnad_exchange_impressions))*1000,2) ingreso_cpm,FORMAT(ROUND(sum(columnad_exchange_estimated_revenue)*".$tasa.",2),2) ingreso_total ,FORMAT(sum(columnad_exchange_impressions),0) impresiones FROM adops.11223363888   where dimensionad_exchange_network_partner_name='".$emp."' and dimensiondate between '".$ini."' and '".$fin."'");
       $infoingreso=array();
  while ($row = $ingreso->fetch_array()) {
            $infoingreso[]=$row;
        }

   
              $resultado_desk = $db->query("SELECT concat(SUBSTRING(dimensiondate,6,2),'/',SUBSTRING(dimensiondate,9,2)) dimensiondate,FORMAT(sum(columnad_exchange_estimated_revenue)*".$tasa.",2) as total FROM adops.11223363888
    where  dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' group by 1 order by 1 asc");  
    $infodesk=array();
        while ($filadesk= $resultado_desk->fetch_array()) {
            
            $infodesk[]=$filadesk;
        }    

        

          $resultado_table = $db->query("SELECT dimensiondate,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where  dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 and dimensionad_exchange_device_category='Tablets' group by 1 order by 1 asc");  
    $infotablet=array();
        while ($filatab = $resultado_table->fetch_array()) {
            
            $infotablet[]=$filatab;
        }


          $resultado_mobil = $db->query("SELECT dimensiondate,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 and dimensionad_exchange_device_category='High-end mobile devices' group by 1 order by 1 asc");  
    $infomovil=array();
        while ($filamob = $resultado_mobil->fetch_array()) {
            
            $infomovil[]=$filamob;
        }


    $resultado = $db->query("SELECT REPLACE(dimensionad_exchange_device_category,'High-end mobile devices','Mobile') dimensionad_exchange_device_category,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where  dimensionad_exchange_network_partner_name='".$emp."'  and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 group by 1 order by 2 desc");  
    $info=array();
        while ($fila = $resultado->fetch_array()) {
            
            $info[]=$fila;
        }

     $result_creative = $db->query("SELECT dimensionad_exchange_creative_sizes,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."'  and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 group by 1 order by 2 desc limit 5");  
    $info_creative=array();
        while ($filac = $result_creative->fetch_array()) {
            
            $info_creative[]=$filac;
        }
        
        $data = array("status"=>200,"data"=>$info,"ingreso"=>$infoingreso,"creatives"=>$info_creative,"diario_desktop"=>$infodesk,"diario_tablet"=>$infotablet,"inicio"=>$inicio,"final"=>$final);
        echo json_encode($data);
        });


$app->post("/dashb",function() use($db,$app){
 $json = $app->request->getBody();
    $dat = json_decode($json, true);
    $suc=$dat["sucursal"];
    $fechainicio= $dat["inicio"];
    $fechafin=$dat["fin"];
    $sucur=array();
  
    $sucursales = $db->query("SELECT id,sucursal FROM dashboard.usuario where id<>1");
    while ($filatabla = $sucursales->fetch_array()) {
            $sucur[]=$filatabla;
        }

$sql="(SELECT pg.idOrden,UPPER(c.nombreCliente) nombreCliente,o.fechaCreado,o.idUsuario, u.sucursal,pg.pago1 AS pago, IF(tipoPago1=0,'EFECTIVO','TARJETA') modoPago,IF(o.Estado=0,'ENTREGA','RECOJO') Movimiento FROM  (SELECT * FROM dashboard.Pago WHERE fechaPago BETWEEN '".$fechainicio." 00:00:00' AND '".$fechafin. " 23:59:59'  AND pago1>0) pg INNER JOIN dashboard.Orden o ON o.idOrden=pg.idOrden AND o.tipoPago IN(1) AND o.estado=0 INNER JOIN dashboard.usuario u ON o.idUsuario=u.id INNER JOIN dashboard.Cliente c ON o.idCliente=c.idCliente AND u.id IN(" .$suc. ") ORDER BY modoPago) UNION ALL  (SELECT pg.idOrden,UPPER(c.nombreCliente) nombreCliente,pg.fechaActualizado AS fechaCreado,o.idUsuario, u.sucursal,pg.pago1 AS pago,IF(pg.tipoPago2=0,'EFECTIVO','TARJETA') modoPago, IF(o.Estado=0,'ENTREGA','RECOJO') Movimiento FROM (SELECT * FROM dashboard.Pago WHERE fechaPago BETWEEN '".$fechainicio." 00:00:00' AND '".$fechafin." 23:59:59' ) pg INNER JOIN dashboard.Orden o ON o.idOrden=pg.idOrden AND o.tipoPago IN(2) AND o.estado IN(0,1) INNER JOIN dashboard.usuario u ON o.idUsuario=u.id  INNER JOIN dashboard.Cliente c ON o.idCliente=c.idCliente AND  u.id IN(" .$suc. ") ORDER BY modoPago) UNION ALL  (SELECT pg.idOrden,UPPER(c.nombreCliente) nombreCliente,pg.fechaActualizado AS fechaCreado,o.idUsuario, u.sucursal, pg.pago2 AS pago ,IF(pg.tipoPago2=0,'EFECTIVO','TARJETA') modoPago, IF(o.Estado=0,'ENTREGA','RECOJO') Movimiento FROM (SELECT * FROM dashboard.Pago WHERE fechaActualizado BETWEEN '".$fechainicio." 00:00:00' AND '".$fechafin." 23:59:59') pg INNER JOIN dashboard.Orden o ON o.idOrden=pg.idOrden AND o.tipoPago IN(2) AND o.estado IN(1) INNER JOIN dashboard.usuario u ON o.idUsuario=u.id  INNER JOIN dashboard.Cliente c ON o.idCliente=c.idCliente AND u.id IN(". $suc.")  ORDER BY modoPago) ORDER BY modopago,idOrden";
 $result = $db->query($sql);

   $datos=array();
    while ($filas = $result->fetch_array()){
            $datos[]=$filas;
        }
         $data = array("status"=>200,"sucursal"=>$sucur,"sql"=>$sql,"data"=>$datos);

          echo  json_encode($data);



}) ;


$app->post("/inicio",function() use($db,$app){
    header("Content-type: application/json; charset=utf-8");
    $json = $app->request->getBody();
    $dat = json_decode($json, true);
    $date = new DateTime();
    $date2 = new DateTime();
    $date->modify('last day of this month');
    $date2->modify('first day of this month');
    $date->format('Y-m-d');
    $ini=substr( $date->format('Y-m-d'),0,7).'-01';
    $fin = substr($date->format('Y-m-d'),0,10);
    $inicio=$date2->format('d/m');
    $final=date("d/m",strtotime("- 1 days"));
    $hash=$dat['emp'];

    
    $datocliente=$db->query("SELECT * FROM api.usuarios where hash='".$hash."'");
       $infocliente=array();
      while ($cliente = $datocliente->fetch_array()) {
            $infocliente[]=$cliente;
        }

        $tasa=(float) $infocliente[0]["tasa"];
        $emp=$infocliente[0]["empresa"];
        $cpm=(float) $infocliente[0]["cpm"];

  $resultado_diario = $db->query("SELECT dimensiondate ,dimensionad_exchange_creative_sizes ,dimensionad_exchange_device_category  ,columnad_exchange_impressions ,columnad_exchange_estimated_revenue*".$tasa." columnad_exchange_estimated_revenue FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00  order by 1 desc");  
    $infotabla=array();
        while ($filatabla = $resultado_diario->fetch_array()) {
            
            $infotabla[]=$filatabla;
        }



  $resultado_diario = $db->query("SELECT dimensiondate,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 group by 1 order by 1 asc");  
    $infodia=array();
        while ($filadia = $resultado_diario->fetch_array()) {
            
            $infodia[]=$filadia;
        }


              $resultado_desk = $db->query("SELECT concat(SUBSTRING(dimensiondate,6,2),'/',SUBSTRING(dimensiondate,9,2)) dimensiondate,FORMAT(sum(columnad_exchange_estimated_revenue)*".$tasa.",2) as total FROM adops.11223363888
    where  dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' group by 1 order by 1 asc");  
    $infodesk=array();
        while ($filadesk= $resultado_desk->fetch_array()) {
            
            $infodesk[]=$filadesk;
        }    

        

          $resultado_table = $db->query("SELECT dimensiondate,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 and dimensionad_exchange_device_category='Tablets' group by 1 order by 1 asc");  
    $infotablet=array();
        while ($filatab = $resultado_table->fetch_array()) {
            
            $infotablet[]=$filatab;
        }


          $resultado_mobil = $db->query("SELECT dimensiondate,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."' and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 and dimensionad_exchange_device_category='High-end mobile devices' group by 1 order by 1 asc");  
    $infomovil=array();
        while ($filamob = $resultado_mobil->fetch_array()) {
            
            $infomovil[]=$filamob;
        }



    $resultado = $db->query("SELECT REPLACE(dimensionad_exchange_device_category,'High-end mobile devices','Mobile') dimensionad_exchange_device_category,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where dimensionad_exchange_network_partner_name='".$emp."'  and 
    dimensiondate between '".$ini."' and '".$fin."' group by 1 order by 2 desc");  
    $info=array();
        while ($fila = $resultado->fetch_array()) {
            
            $info[]=$fila;
        }

    $result_creative = $db->query("SELECT dimensionad_exchange_creative_sizes,round(sum(columnad_exchange_estimated_revenue),2)*".$tasa." as total FROM adops.11223363888
    where  dimensionad_exchange_network_partner_name='".$emp."'  and 
    dimensiondate between '".$ini."' and '".$fin."' and round(columnad_exchange_estimated_revenue,2)>0.00 group by 1 order by 2 desc limit 5");  
    $info_creative=array();
        while ($filac = $result_creative->fetch_array()) {
            
            $info_creative[]=$filac;
        }

        
       $ingreso=$db->query("SELECT FORMAT(sum(columnad_exchange_estimated_revenue*".$cpm.")/(sum(columnad_exchange_impressions))*1000,2) ingreso_cpm,FORMAT(ROUND(sum(columnad_exchange_estimated_revenue)*".$tasa.",2),2) ingreso_total,FORMAT(sum(columnad_exchange_impressions),0) impresiones  FROM adops.11223363888   where  dimensionad_exchange_network_partner_name='".$emp."' and dimensiondate between '".$ini."' and '".$fin."'");
       $infoingreso=array();
  while ($row = $ingreso->fetch_array()) {
            $infoingreso[]=$row;
        }
        
        $data = array("status"=>200,"data"=>$info,"ingreso"=>$infoingreso,"diario"=>$infodia,"diario_desktop"=>$infodesk,"diario_tablet"=>$infotablet,"diario_movil"=>$infomovil,"creatives"=>$info_creative,"inicio"=>$inicio,"final"=>$final);
        echo  json_encode($data);




    });


/*final adops dashobard*/

    $app->post("/skoda",function() use($db,$app){
        $query ="INSERT INTO skoda (source,origen,nombres,apellidos,rut,telefono,correo,marca,modelo,concesionario,dispositivo)  VALUES ("
        ."'{$app->request->post("source")}',"
        ."'{$app->request->post("origen")}',"
         ."'{$app->request->post("nombres")}',"
         ."'{$app->request->post("apellidos")}',"
         ."'{$app->request->post("rut")}',"
         ."'{$app->request->post("telefono")}',"
         ."'{$app->request->post("correo")}',"
         ."'{$app->request->post("marca")}',"
         ."'{$app->request->post("modelo")}',"
         ."'{$app->request->post("concesionario")}',"
         ."'{$app->request->post("dispositivo")}'"
         .")";

         $insert= $db->query($query);
          if($insert){
          $result = array("STATUS"=>true,"messaje"=>"Skoda registrado correctamente");
           }else{
           $result = array("STATUS"=>false,"messaje"=>"Skoda no creado");
           }
            echo json_encode($result);
           }); 


function traer_datos($ini,$fin,$emp,$tasa){
$db=new mysqli("localhost","marife","libido16","adops");
    
    $sql="SELECT ROUND(sum(columnad_exchange_ad_ecpm)*".$tasa.",2) ingreso_cpm,ROUND(sum(columnad_exchange_estimated_revenue)*".$tasa.",2) ingreso_total  FROM adops.11223363888   where dimensionad_exchange_network_partner_name='".$emp."' and dimensiondate between ".$ini." and ".$fin;

 $ingreso=$db->query($sql);
    
     $data=array();
       while ($row = $ingreso->fetch_array()) {
         $data[]=$row;
     }
        return $data;
}

function ordena_fecha($inicio,$fin){
    $arraymeses=array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
    $arraynros=array('01','02','03','04','05','06','07','08','09','10','11','12');
    $mes1=substr($inicio, 0,3);
    $mes2=substr($fin, 0,3);
    $dia1=substr($inicio, 3,2);
    $dia2=substr($fin, 3,2);
    $ano1=substr($inicio, 5,4);
    $ano2=substr($fin, 5,4);
    $fmes1=str_replace($arraymeses,$arraynros,$mes1);
    $fmes2=str_replace($arraymeses,$arraynros,$mes2);
    $ini=$ano1.'-'.$fmes1.'-'.$dia1;
    $fin=$ano2.'-'.$fmes2.'-'.$dia2;
    return array("inicio"=>$ini,"final"=>$fin);

}

$app->run();