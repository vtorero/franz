drop database if exists frdash;
create database if not exists barcode;

CREATE DATABASE frdash;
/**
	Se modifica la tabla ventas, agregando los campos
    tipo_descuento,
    descuento.
*/

USE frdash;

CREATE TABLE clientes
(
id VARCHAR(15) PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
direccion VARCHAR(100),
telefono VARCHAR(10),
ruc VARCHAR(10)
)engine = InnoDB;

CREATE TABLE articulos
(
id INTEGER (11) PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(100) UNIQUE NOT NULL,
medida VARCHAR(15) NOT NULL,
stock INTEGER DEFAULT 0
)engine = InnoDB;


CREATE TABLE usuarios
(
id VARCHAR(20) PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
contrasena VARCHAR(32) NOT NULL,
rol VARCHAR(20)
)engine = InnoDB;

CREATE TABLE ventas
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
id_usuario VARCHAR(10),
valor_total DECIMAL(10,2),
estado VARCHAR(30),
fecha DATE NOT NULL,
FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
)engine = InnoDB;


CREATE TABLE categorias
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(50) UNIQUE NOT NULL
)engine = InnoDB;

CREATE TABLE productos
(
id INTEGER (11) PRIMARY KEY AUTO_INCREMENT,
codigo VARCHAR(15) UNIQUE NOT NULL,
nombre VARCHAR(100) UNIQUE NOT NULL,
precio DECIMAL(10,2) NOT NULL,
id_categoria INTEGER(11) NOT NULL,
FOREIGN KEY (id_categoria) REFERENCES categorias(id)
);

/**Tabla para llevar el control de los abonos en cada venta *2020-18-04* **/
CREATE TABLE abonos
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
id_venta INTEGER(11) NOT NULL,
tipo_pago VARCHAR(30) NOT NULL,
valor_abono DECIMAL(10,2) NOT NULL,
fecha DATE NOT NULL,
FOREIGN KEY (id_venta) REFERENCES ventas(id)
) engine = InnoDB;
/** **/
/**Tabla para relacionar los clientes con las ventas *2020-18-04* **/
CREATE TABLE ventas_cliente
(
	id_venta INTEGER(11) NOT NULL,
    id_cliente VARCHAR(15) NOT NULL,
    FOREIGN KEY(id_venta) 	REFERENCES ventas(id),
    FOREIGN KEY(id_cliente) REFERENCES clientes(id)
)engine = InnoDB;
/****************/

CREATE TABLE detalle_ventas
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
precio DECIMAL(10,2) NOT NULL,
descuento INTEGER (2),
id_producto INTEGER(11) NOT NULL,
cantidad INTEGER NOT NULL,
id_venta INTEGER(11) NOT NULL,
FOREIGN KEY (id_producto) REFERENCES productos(id),
FOREIGN KEY (id_venta) REFERENCES ventas(id)
)engine = InnoDB;

CREATE TABLE detalle_productos
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
cantidad INTEGER(11) NOT NULL,
id_producto INTEGER(11),
id_articulo INTEGER(11),
FOREIGN KEY (id_producto) REFERENCES productos(id),
FOREIGN KEY (id_articulo) REFERENCES articulos(id)
)engine = InnoDB;

CREATE TABLE proveedores 
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
razon_social VARCHAR(50) NULL,
tipo_documento VARCHAR(15) NULL,
num_documento VARCHAR(15) UNIQUE NULL,
telefono VARCHAR(10) NULL
)engine = InnoDB;

CREATE TABLE compras
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
comprobante VARCHAR(15) NOT NULL,
num_comprobante INTEGER(11) NOT NULL,
descripcion VARCHAR(25) NOT NULL,
fecha DATE NOT NULL,
id_proveedor INTEGER(11),
id_usuario VARCHAR(10),
FOREIGN KEY (id_proveedor) REFERENCES proveedores(id),
FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
)engine = InnoDB;

CREATE TABLE detalle_compras
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
/*stock INTEGER(11) NOT NULL*/
cantidad INTEGER(11) NOT NULL,
/**medida VARCHAR(10) NOT NULL,*/
precio DECIMAL(10,2) NOT NULL,
id_articulo INTEGER(11),
id_compra INTEGER(11),
FOREIGN KEY (id_articulo) REFERENCES articulos(id),
FOREIGN KEY (id_compra)	REFERENCES compras(id)
)engine = InnoDB;


CREATE VIEW vista_productos 
AS SELECT 
productos.codigo,
productos.nombre,
productos.precio,
categorias.nombre AS nombre_categoria
FROM productos,categorias where productos.id_categoria = categorias.id;

CREATE VIEW vista_detalle_productos 
AS SELECT 
detalle_productos.id,
productos.codigo, 
productos.nombre, 
articulos.nombre AS nombre_articulo, 
CONCAT(detalle_productos.cantidad,' - ',articulos.medida) AS cantidad
FROM productos, articulos, detalle_productos
WHERE (productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo) ;

CREATE VIEW vista_clientes AS
SELECT * FROM clientes;

CREATE VIEW vista_usuarios AS
SELECT * FROM usuarios;	

CREATE VIEW vista_proveedores AS
SELECT * FROM proveedores;

CREATE VIEW vista_categorias AS
SELECT * FROM categorias;

CREATE VIEW vista_articulos AS
SELECT * FROM articulos;

/**********************************************************/
SET GLOBAL log_bin_trust_function_creators = 1;
/**********************************************************/
delimiter $ 
CREATE FUNCTION actualizarStock(id_articulo INTEGER, cantidad_articulo INTEGER) RETURNS INT(11)
BEGIN 

DECLARE stock_inicial INT;
DECLARE stock_ingreso INT;

SET stock_ingreso = cantidad_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial + stock_ingreso;  

end$ 
delimiter ;


/*********************************************************************/


DELIMITER $

CREATE FUNCTION obtenerStock(id_articulo INTEGER) RETURNS int(11)
BEGIN 

DECLARE stock_inicial INT;


SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;*/

RETURN stock_inicial;  

end $
DELIMITER ;

/******************************************************************************/




/*---------------------------------------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION restarStock(id_articulo INTEGER,id_producto INT,cantidad_del_producto INTEGER) RETURNS int(11)
BEGIN 

DECLARE stock_inicial INT;
DECLARE cantidad_articulo_en_producto INT;

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos WHERE detalle_productos.id_producto = id_producto AND  detalle_productos.id_articulo = id_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial - cantidad_articulo_en_producto * cantidad_del_producto;  

end $
DELIMITER ;
/*--------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------*/
INSERT INTO usuarios(id,nombre,contrasena,rol) VALUES (1234,'admin',MD5('1234'),'ADMINISTRADOR');
/*---------------------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------*/
/*Esta tabla crea el detalle del ingreso o actualiacion del inventario.*/
/*-----------------------------------------------------------------------*/
/*Esta tabla crea el detalle del ingreso o actualiacion del inventario.*/
CREATE TABLE ajuste_inventario 
(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    id_articulo INTEGER,
    id_usuario VARCHAR(20),
    descripcion VARCHAR(100) NOT NULL, 
    fecha DATE NOT NULL,
    FOREIGN KEY (id_articulo) REFERENCES articulos(id),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
);
/*------------------------------------------------------------------------*/



/*---------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION sumarStock(id_articulo INTEGER, cantidad INTEGER) RETURNS int(11)
BEGIN 

DECLARE stock_inicial INT;

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial + cantidad;  

end $
DELIMITER ;

/*---------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION restarStockSinProducto(id_articulo INT, cantidad INT) RETURNS int(11)
BEGIN 

DECLARE stock_inicial INT;
/*DECLARE cantidad_articulo_en_producto INT;

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos WHERE detalle_productos.id_producto = id_producto AND  detalle_productos.id_articulo = id_articulo;*/

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial - cantidad;  

end $
DELIMITER ;
/*------------------------------------------------------------------------------------------*/

/*************************************************************/
/*Crea la vista para mostrar las ventas asociadas al cliente*/


/**********************************************
*************************************
************************************
FUNCIONANDO SIN SUMAR PRODUCTOS EN VENTAS...
create view vista_buscar_ventas as
select  
	ventas.id,
    clientes.id as id_cliente,
	clientes.nombre as nombre_cliente,
	detalle_ventas.cantidad as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descuento, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *sum(detalle_ventas.cantidad) ,productos.precio * sum(detalle_ventas.cantidad) - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *sum(detalle_ventas.cantidad) as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono 
from 
	ventas, detalle_ventas, productos, abonos, ventas_cliente, clientes
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and ventas_cliente.id_cliente = clientes.id
	and ventas_cliente.id_venta  = ventas.id
	and abonos.id_venta = ventas.id 
	group by productos.id, clientes.id,ventas.id,detalle_ventas.descuento order by id desc;
/*************************************************************
*************************************************************/

/************************************************************/





/**************************************
****************************************/
create view vista_buscar_ventas as
select  
	ventas.id,
    clientes.id as id_cliente,
	clientes.nombre as nombre_cliente,
	detalle_ventas.cantidad as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descuento, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio * detalle_ventas.cantidad ,productos.precio * detalle_ventas.cantidad - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio * detalle_ventas.cantidad as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono 
from 
	ventas, detalle_ventas, productos, abonos, ventas_cliente, clientes
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and ventas_cliente.id_cliente = clientes.id
	and ventas_cliente.id_venta  = ventas.id
	and abonos.id_venta = ventas.id 
	group by productos.id, clientes.id,ventas.id,detalle_ventas.descuento order by id desc;



/**********************************************************/
create view vista_saldo_ventas as
select
	abonos.id_venta ,
    clientes.id as id_cliente,
    clientes.nombre,
    ventas.valor_total,
    sum(abonos.valor_abono) as abono,
    if(sum(abonos.valor_abono) = 0,ventas.valor_total ,ventas.valor_total - sum(abonos.valor_abono)) as saldo,
    /*ventas.valor_total - sum(abonos.valor_abono) as saldo,*/
    ventas.estado
from ventas, clientes, ventas_cliente, abonos
where 
	ventas_cliente.id_venta = ventas.id
	and ventas_cliente.id_cliente = clientes.id
	and ventas.id = abonos.id_venta
	and ventas.id = ventas.id  group by ventas.id;  
    /**********************************************************************/
   
   
create view vista_saldo_sin_cliente as   
select
	abonos.id_venta ,
    ventas.valor_total,
    sum(abonos.valor_abono) as abono,
    if(sum(abonos.valor_abono) = 0,ventas.valor_total ,ventas.valor_total - sum(abonos.valor_abono)) as saldo,
    ventas.estado
from ventas,abonos
where 
	ventas.id = abonos.id_venta
	and ventas.id = ventas.id 
    group by ventas.id;      
    
    
    
    
    
	
/*Versión 1 funciona, pero cuando el abono es cero, retorna saldo cero,
lo cual es incorrecto
select
	abonos.id_venta ,
    clientes.id as id_cliente,
    clientes.nombre,
    ventas.valor_total,
    sum(abonos.valor_abono) as abono,
    if(abonos.valor_abono = 0,0,ventas.valor_total - sum(abonos.valor_abono)) as saldo,
    ventas.estado
from ventas, clientes, ventas_cliente, abonos
where 
	ventas_cliente.id_venta = ventas.id
	and ventas_cliente.id_cliente = clientes.id
	and ventas.id = abonos.id_venta
	and ventas.id = ventas.id  group by ventas.id; 
    */

/******************************************************
********************************************************
*/






/*******************************************
********************************************
FUNCIONANDO SIN LA OPCION DE BUSCAR TICKET**
********************************************
create view vista_factura as
select  
	ventas.id,
    clientes.id as id_cliente,
	clientes.nombre as nombre_cliente,
	sum(detalle_ventas.cantidad) as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *sum(detalle_ventas.cantidad) ,productos.precio * sum(detalle_ventas.cantidad) - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *sum(detalle_ventas.cantidad) as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono 
from 
	ventas, detalle_ventas, productos, abonos, ventas_cliente, clientes
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and ventas_cliente.id_cliente = clientes.id
	and ventas_cliente.id_venta  = ventas.id
	and abonos.id_venta = ventas.id 
	group by productos.id, clientes.id,ventas.id,detalle_ventas.descuento order by id desc;
    *************************************************************************************
    *****************************************************
    ********************************
    *****************/
    
    
    
/*******************************************
********************************************
FUNCIONANDO CON BUSCAR TICKET - PROBANDO**
********************************************/

   create view vista_factura as
	select  
	ventas.id,
    clientes.id as id_cliente,
	clientes.nombre as nombre_cliente,
	detalle_ventas.cantidad as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *detalle_ventas.cantidad ,productos.precio * detalle_ventas.cantidad - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio * detalle_ventas.cantidad as precio_sin_descuento,	
	ventas.estado,
	clientes.direccion,
    clientes.telefono,
	abonos.valor_abono,
    ventas.fecha,
    usuarios.nombre as nombre_usuario
from 
	ventas, detalle_ventas, productos, abonos, ventas_cliente, clientes, usuarios
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and ventas_cliente.id_cliente = clientes.id
	and ventas_cliente.id_venta  = ventas.id
	and abonos.id_venta = ventas.id 
    and usuarios.id = ventas.id_usuario
	group by productos.id, clientes.id,ventas.id,detalle_ventas.descuento order by id desc; 
    
/***********************************************************/   

create view vista_factura_abonos as
select  
	abonos.id as id_abono,
	ventas.id as id_venta,
    clientes.id as id_cliente,
	clientes.nombre as nombre_cliente,
	ventas.estado,
	clientes.direccion,
    clientes.telefono,
	abonos.valor_abono,
	abonos.fecha,
    usuarios.nombre as nombre_usuario
from 
	ventas, detalle_ventas, productos, abonos, ventas_cliente, clientes, usuarios
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and ventas_cliente.id_cliente = clientes.id
	and ventas_cliente.id_venta  = ventas.id
	and abonos.id_venta = ventas.id 
    and usuarios.id = ventas.id_usuario
	group by abonos.id order by id_venta desc;  
/************************************************************
*************************************************************
*************************************************************
*************************************************************/





/******************************************
*******************************************
FUNCIONANDO SIN SUMAR PRODUCTOS EN VENAS
create view vista_factura_sin_cliente as 
select  
	ventas.id,
	sum(detalle_ventas.cantidad) as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *sum(detalle_ventas.cantidad) ,productos.precio * sum(detalle_ventas.cantidad) - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *sum(detalle_ventas.cantidad) as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono 
from 
	ventas, detalle_ventas, productos, abonos
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and abonos.id_venta = ventas.id 
	group by productos.id, ventas.id,detalle_ventas.descuento order by id desc;
/***********************************************************************************/
/*************************************************************************************
*************************************************************************************/

create view vista_factura_sin_cliente as 
select  
	ventas.id,
	detalle_ventas.cantidad as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
	(
	  detalle_ventas.descuento = 0,productos.precio *detalle_ventas.cantidad ,productos.precio * detalle_ventas.cantidad - (detalle_ventas.precio * detalle_ventas.descuento/100)
	) as precio_descuento,
	productos.precio *detalle_ventas.cantidad as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono,
    ventas.fecha,
    usuarios.nombre as nombre_usuario
from 
	ventas, detalle_ventas, productos, abonos, usuarios
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and abonos.id_venta = ventas.id 
    and usuarios.id = ventas.id_usuario
	group by productos.id, ventas.id,detalle_ventas.descuento order by id desc;




/*********************************************
**********************************************
FUNCIONANDO ANTES DE SUMAR PRODUCTOS**********
create view vista_reporte_ventas_detalle as
select  
	ventas.id,
	sum(detalle_ventas.cantidad) as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *sum(detalle_ventas.cantidad) ,productos.precio * sum(detalle_ventas.cantidad) - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *sum(detalle_ventas.cantidad) as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono,
	abonos.tipo_pago,
	abonos.fecha
from 
	ventas, detalle_ventas, productos, abonos
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and abonos.id_venta = ventas.id 
	group by productos.id, ventas.id,detalle_ventas.descuento,fecha,abonos.valor_abono order by id desc;
    *******************************************************************************************/
    
create view vista_reporte_ventas_detalle as   
select  
	ventas.id,
	detalle_ventas.cantidad as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *detalle_ventas.cantidad ,productos.precio * detalle_ventas.cantidad - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *detalle_ventas.cantidad as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono,
	abonos.tipo_pago,
	categorias.nombre as categoria, 
	abonos.fecha
from 
	ventas, detalle_ventas, productos, abonos, categorias
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and productos.id_categoria = categorias.id 
	and abonos.id_venta = ventas.id 
	group by productos.id, ventas.id,detalle_ventas.descuento,fecha,abonos.valor_abono order by id desc;   
/***************************************************************************************
***************************************************************************
***************************************************************************/


    
    

/**************************************************************************************
*******************************EN PRUEBA***********************************************/
CREATE VIEW vista_detalle_ventas_categoria as
select  
	ventas.id,
	sum(detalle_ventas.cantidad) as cantidad,
	productos.nombre as nombre_producto,	
	productos.precio  as precio_producto,
	detalle_ventas.descuento as descu, 
	if
		(
			detalle_ventas.descuento = 0,productos.precio *sum(detalle_ventas.cantidad) ,productos.precio * sum(detalle_ventas.cantidad) - (detalle_ventas.precio * detalle_ventas.descuento/100)
		) as precio_descuento,
	productos.precio *sum(detalle_ventas.cantidad) as precio_sin_descuento,	
	ventas.estado,
	abonos.valor_abono,
	abonos.tipo_pago,
	categorias.nombre as categorias,
	abonos.fecha
from 
	ventas, detalle_ventas, productos, abonos,categorias 
where 
	ventas.id =  detalle_ventas.id_venta
	and productos.id = detalle_ventas.id_producto
	and abonos.id_venta = ventas.id 
	and categorias.id = productos.id_categoria 
	group by productos.id, ventas.id,detalle_ventas.descuento,fecha,abonos.valor_abono order by id desc;
    
    

/*************************************
************************************
************************************/
create view vista_mostrar_compras as   
select 
	compras.id as id_compra,
	detalle_compras.id_articulo,
	detalle_compras.cantidad,
	articulos.nombre,
	detalle_compras.precio as precio_unidad,
	detalle_compras.precio * detalle_compras.cantidad as precio_total,
	compras.num_comprobante,
	proveedores.razon_social,
	compras.comprobante, 
	compras.descripcion as estado,
	compras.fecha 
from 
	compras, detalle_compras, proveedores, articulos
where 
	compras.id = detalle_compras.id_compra
	and detalle_compras.id_articulo = articulos.id
	and compras.id_proveedor = proveedores.id order by id_compra desc; 	    
    

/***********************************************************************************/
SET SQL_SAFE_UPDATES=0;
/***********************************************************************************/

