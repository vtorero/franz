-- phpMyAdmin SQL Dump
-- version 4.6.6deb5ubuntu0.5
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 22-01-2021 a las 15:55:12
-- Versión del servidor: 5.7.32-0ubuntu0.18.04.1
-- Versión de PHP: 7.2.24-0ubuntu0.18.04.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `frdash`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`marife`@`%` PROCEDURE `p_compra` (IN `comprobante` INT(12), IN `num_comprobante` VARCHAR(20), IN `descripcion` VARCHAR(255), IN `fecha` VARCHAR(20), IN `proveedor` INT(1))  BEGIN
 INSERT INTO compras (comprobante,num_comprobante,descripcion,fecha,id_proveedor) 
VALUES(comprobante,num_comprobante,descripcion,fecha,proveedor);
 END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_compra_detalle` (IN `p_id` INT, IN `cantidad` DECIMAL(10,2), IN `precio` DECIMAL(10,2), IN `id_compra` INT(11), IN `p_descripcion` VARCHAR(255))  BEGIN
IF(p_id=0) THEN
 INSERT INTO detalle_compras (descripcion,cantidad,precio,id_compra) 
VALUES(p_descripcion, cantidad,precio,id_compra);
ELSE
update detalle_compras set descripcion=p_descripcion,cantidad=cantidad,precio=precio where id_compra=p_id;
END IF;
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_inventario` (IN `id_producto` INT(11), IN `p_presentacion` VARCHAR(30), IN `p_unidad` VARCHAR(30), IN `p_cantidad` INT(11), IN `p_peso` DECIMAL(10,2), IN `p_fecha_produccion` VARCHAR(20), IN `p_observacion` VARCHAR(255))  BEGIN
INSERT INTO inventario (id_producto,presentacion,unidad,cantidad,peso,fecha_produccion,observacion,estado,ciclo,id_usuario) VALUES(id_producto,p_presentacion,p_unidad,p_cantidad,p_peso,p_fecha_produccion,p_observacion,1,2,1);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_inventario_upd` (IN `p_id` INT(11), IN `p_fecha_produccion` VARCHAR(20), IN `p_presentacion` VARCHAR(255), IN `p_unidad` VARCHAR(50), IN `p_cantidad` DECIMAL(10,2))  BEGIN
UPDATE inventario SET fecha_produccion=p_fecha_produccion,presentacion=p_presentacion,unidad=p_unidad,cantidad=p_cantidad where id=p_id; 
END$$

--
-- Funciones
--
CREATE DEFINER=`marife`@`%` FUNCTION `actualizarStock` (`id_articulo` INTEGER, `cantidad_articulo` INTEGER) RETURNS INT(11) BEGIN 

DECLARE stock_inicial INT;
DECLARE stock_ingreso INT;

SET stock_ingreso = cantidad_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;



RETURN stock_inicial + stock_ingreso;  

end$$

CREATE DEFINER=`marife`@`%` FUNCTION `obtenerStock` (`id_articulo` INTEGER) RETURNS INT(11) BEGIN 

DECLARE stock_inicial INT;


SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;



RETURN stock_inicial;  

end$$

CREATE DEFINER=`marife`@`%` FUNCTION `restarStock` (`id_articulo` INTEGER, `id_producto` INT, `cantidad_del_producto` INTEGER) RETURNS INT(11) BEGIN 

DECLARE stock_inicial INT;
DECLARE cantidad_articulo_en_producto INT;



SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos WHERE detalle_productos.id_producto = id_producto AND  detalle_productos.id_articulo = id_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;



RETURN stock_inicial - cantidad_articulo_en_producto * cantidad_del_producto;  

end$$

CREATE DEFINER=`marife`@`%` FUNCTION `restarStockSinProducto` (`id_articulo` INT, `cantidad` INT) RETURNS INT(11) BEGIN 

DECLARE stock_inicial INT;




SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;



RETURN stock_inicial - cantidad;  

end$$

CREATE DEFINER=`marife`@`%` FUNCTION `sumarStock` (`id_articulo` INTEGER, `cantidad` INTEGER) RETURNS INT(11) BEGIN 

DECLARE stock_inicial INT;



SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;



RETURN stock_inicial + cantidad;  

end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `abonos`
--

CREATE TABLE `abonos` (
  `id` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `tipo_pago` varchar(30) NOT NULL,
  `valor_abono` decimal(10,2) NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ajuste_inventario`
--

CREATE TABLE `ajuste_inventario` (
  `id` int(11) NOT NULL,
  `id_articulo` int(11) DEFAULT NULL,
  `id_usuario` varchar(20) DEFAULT NULL,
  `descripcion` varchar(100) NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `articulos`
--

CREATE TABLE `articulos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `medida` varchar(15) NOT NULL,
  `stock` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `dosimetria` (
  `id` int(11) NOT NULL,
  `codigo` varchar(45),
  `descripcion` varchar(200),
  `inventario_inicial` decimal(10,2),
  `fecha_registro` datetime  DEFAULT CURRENT_TIMESTAMP,
  `id_usuario` varchar(40)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `dosimetria`
  ADD PRIMARY KEY (`id`);
--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `nombre`) VALUES
(1, 'Charcuteria'),
(3, 'Galletas'),
(4, 'Quesos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `num_documento` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `apellido`, `direccion`, `telefono`, `num_documento`) VALUES
(1, 'Victor', 'Jimenez Torero', 'La molina', '992997872', '25750816');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` int(11) NOT NULL,
  `comprobante` varchar(20) NOT NULL,
  `num_comprobante` int(11) NOT NULL,
  `descripcion` varchar(25) NOT NULL,
  `fecha` date NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `id_usuario` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`id`, `comprobante`, `num_comprobante`, `descripcion`, `fecha`, `id_proveedor`, `id_usuario`) VALUES
(1, 'Factura', 989876543, '490 k Cerdo', '2020-12-15', 5, '1'),
(2, 'Boleta', 12, 'descrip', '2020-12-20', 1, NULL),
(38, 'Boleta', 1212121212, '1212121212wewew', '2020-11-23', 6, NULL),
(45, 'Boleta', 77747, '44444444', '2020-11-23', 5, NULL),
(47, 'Factura', 77747, '44444444', '2020-11-23', 5, NULL),
(50, 'Boleta', 12345678, 'desc', '2020-11-23', 1, NULL),
(51, 'Factura', 12345678, 'test', '2020-11-23', 1, NULL),
(52, 'Boleta', 211212, 'tesrt5', '2020-11-23', 1, NULL),
(54, 'Boleta', 121212121, 'wer45rwwww', '2020-12-25', 1, NULL),
(55, 'Factura', 12345611, 'Descripcion ', '2020-12-31', 8, NULL),
(56, 'Boleta', 123456211, 'Descripcion ', '2020-12-16', 5, NULL),
(57, 'Boleta', 1234567890, 'Descripcion ', '2020-12-31', 5, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compras`
--

CREATE TABLE `detalle_compras` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `id_articulo` int(11) DEFAULT NULL,
  `id_compra` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalle_compras`
--

INSERT INTO `detalle_compras` (`id`, `descripcion`, `cantidad`, `precio`, `id_articulo`, `id_compra`) VALUES
(25, 'sssss', 11, '11.00', NULL, 55),
(26, 'Descripcion ', 23, '45.00', NULL, 55),
(29, 'sssss', 23, '45.00', NULL, 50),
(31, 'producto1', 12, '23.00', NULL, 2),
(32, 'sssss', 16, '17.00', NULL, 2),
(33, 'sssss', 4, '10.00', NULL, 2),
(34, 'Descripcion ', 34, '67.00', NULL, 56),
(39, 'Descripcion ', 12, '12.00', NULL, 57),
(40, 'producto 1', 12, '12.00', NULL, 1),
(41, 'producto up', 13, '14.00', NULL, 1),
(42, 'producto 3', 1, '23.00', NULL, 1),
(43, 'producto new', 1, '1.00', NULL, 1),
(44, 'producto 4', 123, '123.00', NULL, 38),
(45, 'FutbolEnAmerica', 0, '0.00', NULL, 45),
(46, 'FutbolEnAmerica', 23, '34.00', NULL, 47),
(47, 'victor', 22, '48.00', NULL, 47),
(48, 'prodicto34', 11, '12.00', NULL, 51),
(49, 'cccddd', 11, '22.00', NULL, 52),
(51, 'dfgdfgdfgqwe222rty', 11, '45.00', NULL, 54);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_productos`
--

CREATE TABLE `detalle_productos` (
  `id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_articulo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_ventas`
--

CREATE TABLE `detalle_ventas` (
  `id` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `descuento` int(2) DEFAULT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `presentacion` varchar(50) NOT NULL,
  `unidad` varchar(30) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `peso` decimal(10,2) NOT NULL,
  `observacion` text NOT NULL,
  `fecha_produccion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` varchar(20) NOT NULL,
  `ciclo` int(2) NOT NULL,
  `id_usuario` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`id`, `id_producto`, `presentacion`, `unidad`, `cantidad`, `peso`, `observacion`, `fecha_produccion`, `estado`, `ciclo`, `id_usuario`) VALUES
(1, 2, 'Bolsa', 'Kilo', '33.00', '0.00', '', '2021-01-01 00:00:00', '1', 1, 1),
(2, 4, 'Caja', 'Docena', '1.00', '0.00', 'prueba', '2021-01-09 00:00:00', '1', 2, 1),
(3, 4, 'Bolsa', 'Unidad', '11.00', '0.00', 'obse', '2021-01-09 00:00:00', '1', 2, 1),
(4, 3, 'Bolsa', 'Sellado', '12.00', '0.00', 'zzzzzz', '2020-12-29 00:00:00', '1', 2, 1),
(5, 2, 'Bolsa', 'Docena', '100.00', '0.00', 'zzzzz', '2020-12-25 00:00:00', '1', 2, 1),
(6, 5, 'bolsa', 'cellado', '22.00', '0.00', 'sss', '2020-12-21 00:00:00', '1', 2, 1),
(7, 3, 'Sellado', 'unidad', '20.00', '0.00', 'prueba', '2021-01-09 00:00:00', '1', 2, 1),
(8, 3, 'bolsa', '', '6.00', '6.60', '6 bolsas', '2021-01-14 00:00:00', '1', 2, 1),
(9, 2, 'bolsa', '', '4.00', '12.00', 'ssss', '2021-01-15 00:00:00', '1', 2, 1),
(10, 77, 'bolsa', '', '11.00', '5.00', '', '2021-01-21 00:00:00', '1', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(11) NOT NULL,
  `dbase` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `user` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `query` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `col_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `col_type` varchar(64) COLLATE utf8_bin NOT NULL,
  `col_length` text COLLATE utf8_bin,
  `col_collation` varchar(64) COLLATE utf8_bin NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) COLLATE utf8_bin DEFAULT '',
  `col_default` text COLLATE utf8_bin
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `column_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `transformation` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `transformation_options` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `input_transformation` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `settings_data` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `export_type` varchar(10) COLLATE utf8_bin NOT NULL,
  `template_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `template_data` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `tables` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `db` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `table` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sqlquery` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `item_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `item_type` varchar(64) COLLATE utf8_bin NOT NULL,
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `tables` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Volcado de datos para la tabla `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('marife', '[{\"db\":\"frdash\",\"table\":\"inventario\"},{\"db\":\"frdash\",\"table\":\"productos\"},{\"db\":\"frdash\",\"table\":\"clientes\"},{\"db\":\"frdash\",\"table\":\"ventas_cliente\"},{\"db\":\"frdash\",\"table\":\"ventas\"},{\"db\":\"frdash\",\"table\":\"detalle_compras\"},{\"db\":\"frdash\",\"table\":\"proveedores\"},{\"db\":\"frdash\",\"table\":\"detalle_ventas\"},{\"db\":\"dashboard2\",\"table\":\"usuario\"},{\"db\":\"frdash\",\"table\":\"usuarios\"}]');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `master_table` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `master_field` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `foreign_db` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `foreign_table` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `foreign_field` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `search_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `search_data` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT '0',
  `x` float UNSIGNED NOT NULL DEFAULT '0',
  `y` float UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `display_field` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `prefs` text COLLATE utf8_bin NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

--
-- Volcado de datos para la tabla `pma__table_uiprefs`
--

INSERT INTO `pma__table_uiprefs` (`username`, `db_name`, `table_name`, `prefs`, `last_update`) VALUES
('marife', 'frdash', 'compras', '{\"sorted_col\":\"`compras`.`id_proveedor`  DESC\"}', '2021-01-13 04:49:29'),
('marife', 'frdash', 'detalle_compras', '{\"sorted_col\":\"`detalle_compras`.`id_compra`  DESC\"}', '2021-01-13 04:48:34'),
('marife', 'frdash', 'productos', '{\"sorted_col\":\"`productos`.`id`  ASC\"}', '2021-01-16 05:33:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `table_name` varchar(64) COLLATE utf8_bin NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text COLLATE utf8_bin NOT NULL,
  `schema_sql` text COLLATE utf8_bin,
  `data_sql` longtext COLLATE utf8_bin,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') COLLATE utf8_bin DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `config_data` text COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Volcado de datos para la tabla `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('marife', '2020-12-26 15:58:51', '{\"lang\":\"es\",\"collation_connection\":\"utf8mb4_unicode_ci\"}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) COLLATE utf8_bin NOT NULL,
  `tab` varchar(64) COLLATE utf8_bin NOT NULL,
  `allowed` enum('Y','N') COLLATE utf8_bin NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) COLLATE utf8_bin NOT NULL,
  `usergroup` varchar(64) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `codigo` varchar(15) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `costo` decimal(10,2) NOT NULL,
  `IGV` decimal(10,2) NOT NULL DEFAULT '0.00',
  `precio_sugerido` decimal(10,2) NOT NULL DEFAULT '0.00',
  `id_categoria` int(11) NOT NULL,
  `id_subcategoria` int(11) NOT NULL,
  `usuario` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo`, `nombre`, `costo`, `IGV`, `precio_sugerido`, `id_categoria`, `id_subcategoria`, `usuario`) VALUES
(2, '55500000002', 'CHORIZO OXFORD BOLSA 5 KG (FRESCO)', '107.50', '19.35', '181.21', 1, 1, 'admin'),
(3, '97506200400', 'CHORIZO OXFORD 400GRS', '10.80', '1.62', '15.17', 1, 1, 'admin'),
(4, '97506200600', 'CHORIZO OXFORD 600GRS', '13.50', '2.43', '22.76', 1, 0, 'admin'),
(5, '55500000001', 'CHORIZO OXFORD COCKTAIL BOLSA 1KG (FRESCO)', '22.00', '3.96', '37.09', 1, 0, 'admin'),
(6, '97506200250', 'CHORIZO OXFORD COCKTAIL 250GRS', '6.20', '1.12', '10.45', 1, 0, 'admin'),
(7, '82030201000', 'CHORIZO FINAS HIERBAS BOLSA 1KG (FRESCO)', '23.50', '4.23', '39.61', 1, 0, 'admin'),
(8, '97505200250', 'CHORIZO FINAS HIERBAS COCKTAIL 250GRS', '6.50', '1.17', '10.96', 1, 0, 'admin'),
(9, '97505200400', 'CHORIZO FINAS HIERBAS 400GRS', '10.00', '1.80', '16.86', 1, 0, 'admin'),
(10, '97505200600', 'CHORIZO FINAS HIERBAS 600GRS', '15.00', '2.70', '25.29', 1, 0, 'admin'),
(11, '97519200400', 'CHORIZO SWEET SPICY 400GRS', '13.00', '2.34', '21.91', 1, 0, 'admin'),
(12, '97519200600', 'CHORIZO SWEET SPICY 600GRS', '19.00', '3.42', '32.03', 1, 0, 'admin'),
(13, '88006200240', 'FRANKFURTER 240GRS', '6.20', '1.12', '10.45', 1, 0, 'admin'),
(14, '88006200250', 'FRANKFURTER COCKTAIL 250GRS', '6.55', '1.18', '11.04', 1, 0, 'admin'),
(15, '88006200450', 'FRANKFURTER MUNICIPAL 450GRS', '11.60', '2.09', '19.55', 1, 0, 'admin'),
(16, '88006201000', 'FRANKFURTER BOLSA DE 1KG', '23.00', '4.14', '38.77', 1, 0, 'admin'),
(17, '88006201001', 'FRANKFURTER GASTRONOMICO PAQUETE DE 1KG', '16.50', '2.97', '27.81', 1, 0, 'admin'),
(18, '88006202000', 'FRANKFURTER GASTRONOMICO PAQUETE DE 2KG', '32.00', '5.76', '53.94', 1, 0, 'admin'),
(19, '88007200250', 'VIENESA 250GRS', '4.50', '0.81', '7.59', 1, 0, 'admin'),
(20, '88007201000', 'VIENESA BOLSA DE 1KG', '14.00', '2.52', '23.60', 1, 0, 'admin'),
(21, '88007201001', 'VIENESA GASTRONOMICO PAQUETE DE 1KG', '14.00', '2.52', '23.60', 1, 0, 'admin'),
(22, '88007202000', 'VIENESA GASTRONOMICO PAQUETE DE 2KG', '27.00', '4.86', '45.51', 1, 0, 'admin'),
(23, '86005200320', 'BRATWURST X320GRS', '7.00', '1.26', '11.80', 1, 0, 'admin'),
(24, '95011200240', 'MORCILLA 240 GRS', '4.50', '0.81', '7.59', 1, 0, 'admin'),
(25, '95011200250', 'MORCILLA COCKTAIL 250GRS', '5.00', '0.90', '8.43', 1, 0, 'admin'),
(26, '66660000001', 'TOCINO AHUMADO \"REDONDO\" PZ X KILO', '31.00', '5.58', '52.26', 1, 0, 'admin'),
(27, '66660000200', 'TOCINO AHUMADO \"REDONDO\" X200GRS', '7.50', '1.35', '12.64', 1, 0, 'admin'),
(28, '66660000500', 'TOCINO AHUMADO \"REDONDO\" X500GRS', '15.50', '2.79', '26.13', 1, 0, 'admin'),
(29, '77700000001', 'TOCINO AHUMADO NATURAL PZ X KILO', '31.00', '5.58', '52.26', 1, 0, 'admin'),
(30, '77700000200', 'TOCINO AHUMADO NATURAL 200GRS', '8.00', '1.44', '13.49', 1, 0, 'admin'),
(31, '77700000500', 'TOCINO AHUMADO NATURAL 500GRS', '17.40', '3.13', '29.33', 1, 0, 'admin'),
(32, '97510200250', 'CHISTORRA HUACHANA 250GRS', '9.00', '1.62', '15.17', 1, 0, 'admin'),
(33, '97510200350', 'LONGANIZA HUACHANA PZ', '6.30', '1.13', '10.62', 1, 0, 'admin'),
(34, '64015203000', 'JAMON PIZZERO MOLDE X KILO', '18.00', '3.24', '30.34', 1, 0, 'admin'),
(35, '64015200250', 'JAMON PIZZERO X 250GRS', '5.75', '1.04', '9.69', 1, 0, 'admin'),
(36, '64015200500', 'JAMON PIZZERO X500G', '9.50', '1.71', '16.01', 1, 0, 'admin'),
(37, '64016205000', 'JAMON INGLES MOLDE X KILO', '30.15', '5.43', '50.82', 1, 0, 'admin'),
(38, '64016200250', 'JAMON INGLES X250GRS', '9.00', '1.62', '15.17', 1, 0, 'admin'),
(39, '64016200500', 'JAMON INGLES X500GRS', '18.00', '3.24', '30.34', 1, 0, 'admin'),
(40, '64021203000', 'JAMON DEL PAIS MOLDE X KILO', '33.50', '6.03', '56.47', 1, 0, 'admin'),
(41, '64021200250', 'JAMON DEL PAIS 250G', '9.50', '1.71', '16.01', 1, 0, 'admin'),
(42, '64021200500', 'JAMON DEL PAIS 500G', '18.00', '3.24', '30.34', 1, 0, 'admin'),
(43, '88800000002', 'LOMO AHUMADO ARTESANAL PZ X KILO', '32.00', '5.76', '53.94', 1, 0, 'admin'),
(44, '88800000250', 'LOMO AHUMADO  ARTESANAL LONJEADO 250GRS', '9.50', '1.71', '16.01', 1, 0, 'admin'),
(45, '99900000001', 'JAMON FRANZ ARTESANAL LA NONNA MOLDE X KILO', '30.00', '5.40', '50.57', 1, 0, 'admin'),
(46, '99900000250', 'JAMON FRANZ ARTESANAL LA NONNA X 250GRS', '9.00', '1.62', '15.17', 1, 0, 'admin'),
(47, '99900000500', 'JAMON FRANZ ARTESANAL LA NONNA X 500GRS', '18.00', '3.24', '30.34', 1, 0, 'admin'),
(48, '10100000001', 'SOLOMILLO PZS (0.250-0.400GRS)  KG', '38.00', '6.84', '64.06', 1, 0, 'admin'),
(49, '11110000001', 'JAMON \"EL TATA\" X KILO', '34.00', '6.12', '57.31', 1, 0, 'admin'),
(50, '11110000250', 'JAMON \"EL TATA\"X250GRS', '10.00', '1.80', '16.86', 1, 0, 'admin'),
(51, '11110000500', 'JAMON \"EL TATA\"X500GRS', '20.00', '3.60', '33.71', 1, 0, 'admin'),
(52, '11120000001', 'JAMON TATA A LAS FINAS HIERBAS X KILO', '38.00', '6.84', '64.06', 1, 0, 'admin'),
(53, '11120000250', 'JAMON TATA A LAS FINAS HIERBAS 250GR', '11.00', '1.98', '18.54', 1, 0, 'admin'),
(54, '11120000500', 'JAMON TATA A LAS FINAS HIERBAS 500GR', '21.00', '3.78', '35.40', 1, 0, 'admin'),
(55, '12120001000', 'QUESO EDAM ARGENTINO MOLDE  X KILO', '34.75', '6.25', '58.57', 1, 0, 'admin'),
(56, '12120000300', 'QUESO EDAM ARGENTINO X 300GRS', '10.38', '1.87', '17.50', 1, 0, 'admin'),
(57, '12130001000', 'QUESO EDAM HOLANDES MOLDE X KILO', '35.59', '6.41', '60.00', 1, 0, 'admin'),
(58, '12130000300', 'QUESO EDAM HOLANDES X 300GRS', '10.59', '1.91', '17.86', 1, 0, 'admin'),
(59, '14140001000', 'QUESO MOZZARELLA MOLDE  X KILO', '33.73', '6.07', '56.86', 1, 0, 'admin'),
(60, '14140000500', 'QUESO MOZZARELLA X 500G', '17.80', '3.20', '30.00', 1, 0, 'admin'),
(61, '19190001620', 'SANDWICH MIXTO', '4.45', '0.80', '7.50', 1, 0, 'admin'),
(62, '19190001630', 'SANDWICH FRANKFURTER', '5.04', '0.91', '8.50', 1, 0, 'admin'),
(63, '19190001640', 'SANDWICH FRANZ', '8.30', '1.49', '14.00', 1, 0, 'admin'),
(64, '19190001660', 'SANDWICH LA NONNA', '8.30', '1.49', '14.00', 1, 0, 'admin'),
(65, '19190001680', 'SANDWICH ESPECIAL', '7.71', '1.39', '13.00', 1, 0, 'admin'),
(66, '18180001615', 'PAN BAGUETTE', '2.97', '0.53', '5.00', 1, 0, 'admin'),
(67, '18180001610', 'PASTEL DE ACELGA', '6.23', '1.12', '10.50', 1, 0, 'admin'),
(68, '18180001515', 'EMPANADA DE CARNE', '5.64', '1.01', '9.50', 1, 0, 'admin'),
(69, '18180001414', 'FUGAZZA GRANDE', '11.86', '2.14', '20.00', 1, 0, 'admin'),
(70, '18180001516', 'TORTILLA DE PAPA CON CHISTORRA', '8.90', '1.60', '15.00', 1, 0, 'admin'),
(71, '18180001001', 'FUGAZZA PORCION', '2.97', '0.53', '5.00', 1, 0, 'admin'),
(72, '17170001111', 'TAPAS VARIAS', '2.97', '0.53', '5.00', 1, 0, 'admin'),
(73, '13130000678', 'SALCHICHA SICILIANA 1KG', '29.66', '5.34', '50.00', 1, 0, 'admin'),
(74, '13130000688', 'SALCHICHA SICILIANA CON PEPERONI CHINO 1KG', '29.66', '5.34', '50.00', 1, 0, 'admin'),
(75, '19150000478', 'PANETON FRANZ', '16.61', '2.99', '28.00', 1, 0, 'admin'),
(76, '19160000137', 'TABLETA DE CHOCOLATE', '11.27', '2.03', '19.00', 1, 0, 'admin'),
(77, '19170000546', 'GALLETA DE COCO', '8.01', '1.44', '13.50', 3, 0, 'admin');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id` int(11) NOT NULL,
  `razon_social` varchar(50) DEFAULT NULL,
  `direccion` varchar(200) NOT NULL,
  `num_documento` varchar(15) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `departamento` varchar(50) NOT NULL,
  `provincia` varchar(50) NOT NULL,
  `distrito` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id`, `razon_social`, `direccion`, `num_documento`, `telefono`, `departamento`, `provincia`, `distrito`) VALUES
(1, 'San Fernando', '', '123456', '009988282', '', '', ''),
(5, 'KV CONSULTING S.A.C.', 'AV. MARISCAL OSCAR R. BENAVIDES NRO. 380 INT. 602 (FRENTE AL PARQUE KENEDY)', '20521048825', NULL, 'LIMA', 'LIMA', 'MIRAFLORES'),
(6, 'AUROCO PUBLICIDAD S A', 'JR. TRINIDAD MORAN NRO. 362 (ALT. EDIFICIO EL DORADO)', '20111409391', NULL, 'LIMA', 'LIMA', 'LINCE'),
(8, 'COMPAÃ‘IA PERUANA DE RADIODIFUSION S.A.', 'JR. MONTERO ROSAS NRO. 1099 URB.  SANTA BEATRIZ', '20100049008', NULL, 'LIMA', 'LIMA', 'LIMA'),
(10, 'LA MILLA VERDE S.A.C.', 'CAL.MAXIMILIANO CARRANZA NRO. 577 COO.  ZONA D  (PISO 3)', '20562863495', NULL, 'LIMA', 'LIMA', 'SAN JUAN DE MIRAFLORES'),
(11, 'VIVIAN FOODS S.A.C.', 'AV. PARDO Y ALIAGA NRO. 699 INT. 802', '20605174095', NULL, 'LIMA', 'LIMA', 'SAN ISIDRO'),
(14, 'D\'TODO MARKET S.A.C.', 'AV. ANGAMOS OESTE NRO. 863 DPTO. 2 URB.  CHACARILLA SANTA CRUZ EL ROSARIO  (MIRAFLORES)', '20606147806', NULL, 'LIMA', 'LIMA', 'MIRAFLORES');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sub_categorias`
--

CREATE TABLE `sub_categorias` (
  `id` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sub_categorias`
--

INSERT INTO `sub_categorias` (`id`, `id_categoria`, `nombre`) VALUES
(1, 1, 'Chorizos'),
(2, 1, 'Salchichas'),
(3, 1, 'Especiales'),
(4, 1, 'Jamones'),
(5, 3, 'Galletas General');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` varchar(20) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `contrasena` varchar(32) NOT NULL,
  `rol` varchar(20) DEFAULT NULL,
  `avatar` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `contrasena`, `rol`, `avatar`) VALUES
('1', 'admin', '123', 'ADMINISTRADOR', 'logo-franz.png'),
('2', 'noemi', '123', 'ADMINISTRADOR', 'logo-franz.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `id` int(11) NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `apellidos` varchar(120) NOT NULL,
  `dni` varchar(8) DEFAULT NULL,
  `razon_social` varchar(100) DEFAULT NULL,
  `ruc` varchar(11) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`id`, `nombre`, `apellidos`, `dni`, `razon_social`, `ruc`, `fecha`) VALUES
(1, 'Victor', 'Jimenez', '25750816', 'adops', '12345678901', '2021-01-17 00:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id` int(11) NOT NULL,
  `id_usuario` varchar(10) DEFAULT NULL,
  `id_vendedor` int(11) NOT NULL,
  `valor_total` decimal(10,2) DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `comprobante` varchar(15) NOT NULL,
  `fecha` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id`, `id_usuario`, `id_vendedor`, `valor_total`, `estado`, `comprobante`, `fecha`) VALUES
(1, '1', 1, '100.00', '1', 'Factura', '2021-01-19 00:00:00');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_articulos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_articulos` (
`id` int(11)
,`nombre` varchar(100)
,`medida` varchar(15)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_buscar_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_buscar_ventas` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_categorias`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_categorias` (
`id` int(11)
,`nombre` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_clientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_clientes` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detalle_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detalle_productos` (
`id` int(11)
,`codigo` varchar(15)
,`nombre` varchar(100)
,`nombre_articulo` varchar(100)
,`cantidad` varchar(29)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detalle_ventas_categoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detalle_ventas_categoria` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_factura`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_factura` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_factura_abonos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_factura_abonos` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_factura_sin_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_factura_sin_cliente` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_mostrar_compras`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_mostrar_compras` (
`id_compra` int(11)
,`id_articulo` int(11)
,`cantidad` int(11)
,`nombre` varchar(100)
,`precio_unidad` decimal(10,2)
,`precio_total` decimal(20,2)
,`num_comprobante` int(11)
,`razon_social` varchar(50)
,`comprobante` varchar(20)
,`estado` varchar(25)
,`fecha` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_reporte_ventas_detalle`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_reporte_ventas_detalle` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_saldo_sin_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_saldo_sin_cliente` (
`id_venta` int(11)
,`valor_total` decimal(10,2)
,`abono` decimal(32,2)
,`saldo` decimal(33,2)
,`estado` varchar(30)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_saldo_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_saldo_ventas` (
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuarios` (
`id` varchar(20)
,`nombre` varchar(50)
,`contrasena` varchar(32)
,`rol` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_articulos`
--
DROP TABLE IF EXISTS `vista_articulos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_articulos`  AS  select `articulos`.`id` AS `id`,`articulos`.`nombre` AS `nombre`,`articulos`.`medida` AS `medida`,`articulos`.`stock` AS `stock` from `articulos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_buscar_ventas`
--
DROP TABLE IF EXISTS `vista_buscar_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_buscar_ventas`  AS  select `ventas`.`id` AS `id`,`clientes`.`id` AS `id_cliente`,`clientes`.`nombre` AS `nombre_cliente`,`detalle_ventas`.`cantidad` AS `cantidad`,`productos`.`nombre` AS `nombre_producto`,`productos`.`precio` AS `precio_producto`,`detalle_ventas`.`descuento` AS `descuento`,if((`detalle_ventas`.`descuento` = 0),(`productos`.`precio` * `detalle_ventas`.`cantidad`),((`productos`.`precio` * `detalle_ventas`.`cantidad`) - ((`detalle_ventas`.`precio` * `detalle_ventas`.`descuento`) / 100))) AS `precio_descuento`,(`productos`.`precio` * `detalle_ventas`.`cantidad`) AS `precio_sin_descuento`,`ventas`.`estado` AS `estado`,`abonos`.`valor_abono` AS `valor_abono` from (((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `ventas_cliente`) join `clientes`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`ventas_cliente`.`id_cliente` = `clientes`.`id`) and (`ventas_cliente`.`id_venta` = `ventas`.`id`) and (`abonos`.`id_venta` = `ventas`.`id`)) group by `productos`.`id`,`clientes`.`id`,`ventas`.`id`,`detalle_ventas`.`descuento` order by `ventas`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_categorias`
--
DROP TABLE IF EXISTS `vista_categorias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_categorias`  AS  select `categorias`.`id` AS `id`,`categorias`.`nombre` AS `nombre` from `categorias` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_clientes`
--
DROP TABLE IF EXISTS `vista_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_clientes`  AS  select `clientes`.`id` AS `id`,`clientes`.`nombre` AS `nombre`,`clientes`.`direccion` AS `direccion`,`clientes`.`telefono` AS `telefono`,`clientes`.`ruc` AS `ruc` from `clientes` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detalle_productos`
--
DROP TABLE IF EXISTS `vista_detalle_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_detalle_productos`  AS  select `detalle_productos`.`id` AS `id`,`productos`.`codigo` AS `codigo`,`productos`.`nombre` AS `nombre`,`articulos`.`nombre` AS `nombre_articulo`,concat(`detalle_productos`.`cantidad`,' - ',`articulos`.`medida`) AS `cantidad` from ((`productos` join `articulos`) join `detalle_productos`) where ((`productos`.`id` = `detalle_productos`.`id_producto`) and (`articulos`.`id` = `detalle_productos`.`id_articulo`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detalle_ventas_categoria`
--
DROP TABLE IF EXISTS `vista_detalle_ventas_categoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_detalle_ventas_categoria`  AS  select `ventas`.`id` AS `id`,sum(`detalle_ventas`.`cantidad`) AS `cantidad`,`productos`.`nombre` AS `nombre_producto`,`productos`.`precio` AS `precio_producto`,`detalle_ventas`.`descuento` AS `descu`,if((`detalle_ventas`.`descuento` = 0),(`productos`.`precio` * sum(`detalle_ventas`.`cantidad`)),((`productos`.`precio` * sum(`detalle_ventas`.`cantidad`)) - ((`detalle_ventas`.`precio` * `detalle_ventas`.`descuento`) / 100))) AS `precio_descuento`,(`productos`.`precio` * sum(`detalle_ventas`.`cantidad`)) AS `precio_sin_descuento`,`ventas`.`estado` AS `estado`,`abonos`.`valor_abono` AS `valor_abono`,`abonos`.`tipo_pago` AS `tipo_pago`,`categorias`.`nombre` AS `categorias`,`abonos`.`fecha` AS `fecha` from ((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `categorias`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`abonos`.`id_venta` = `ventas`.`id`) and (`categorias`.`id` = `productos`.`id_categoria`)) group by `productos`.`id`,`ventas`.`id`,`detalle_ventas`.`descuento`,`abonos`.`fecha`,`abonos`.`valor_abono` order by `ventas`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_factura`
--
DROP TABLE IF EXISTS `vista_factura`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_factura`  AS  select `ventas`.`id` AS `id`,`clientes`.`id` AS `id_cliente`,`clientes`.`nombre` AS `nombre_cliente`,`detalle_ventas`.`cantidad` AS `cantidad`,`productos`.`nombre` AS `nombre_producto`,`productos`.`precio` AS `precio_producto`,`detalle_ventas`.`descuento` AS `descu`,if((`detalle_ventas`.`descuento` = 0),(`productos`.`precio` * `detalle_ventas`.`cantidad`),((`productos`.`precio` * `detalle_ventas`.`cantidad`) - ((`detalle_ventas`.`precio` * `detalle_ventas`.`descuento`) / 100))) AS `precio_descuento`,(`productos`.`precio` * `detalle_ventas`.`cantidad`) AS `precio_sin_descuento`,`ventas`.`estado` AS `estado`,`clientes`.`direccion` AS `direccion`,`clientes`.`telefono` AS `telefono`,`abonos`.`valor_abono` AS `valor_abono`,`ventas`.`fecha` AS `fecha`,`usuarios`.`nombre` AS `nombre_usuario` from ((((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `ventas_cliente`) join `clientes`) join `usuarios`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`ventas_cliente`.`id_cliente` = `clientes`.`id`) and (`ventas_cliente`.`id_venta` = `ventas`.`id`) and (`abonos`.`id_venta` = `ventas`.`id`) and (`usuarios`.`id` = `ventas`.`id_usuario`)) group by `productos`.`id`,`clientes`.`id`,`ventas`.`id`,`detalle_ventas`.`descuento` order by `ventas`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_factura_abonos`
--
DROP TABLE IF EXISTS `vista_factura_abonos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_factura_abonos`  AS  select `abonos`.`id` AS `id_abono`,`ventas`.`id` AS `id_venta`,`clientes`.`id` AS `id_cliente`,`clientes`.`nombre` AS `nombre_cliente`,`ventas`.`estado` AS `estado`,`clientes`.`direccion` AS `direccion`,`clientes`.`telefono` AS `telefono`,`abonos`.`valor_abono` AS `valor_abono`,`abonos`.`fecha` AS `fecha`,`usuarios`.`nombre` AS `nombre_usuario` from ((((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `ventas_cliente`) join `clientes`) join `usuarios`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`ventas_cliente`.`id_cliente` = `clientes`.`id`) and (`ventas_cliente`.`id_venta` = `ventas`.`id`) and (`abonos`.`id_venta` = `ventas`.`id`) and (`usuarios`.`id` = `ventas`.`id_usuario`)) group by `abonos`.`id` order by `id_venta` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_factura_sin_cliente`
--
DROP TABLE IF EXISTS `vista_factura_sin_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_factura_sin_cliente`  AS  select `ventas`.`id` AS `id`,`detalle_ventas`.`cantidad` AS `cantidad`,`productos`.`nombre` AS `nombre_producto`,`productos`.`precio` AS `precio_producto`,`detalle_ventas`.`descuento` AS `descu`,if((`detalle_ventas`.`descuento` = 0),(`productos`.`precio` * `detalle_ventas`.`cantidad`),((`productos`.`precio` * `detalle_ventas`.`cantidad`) - ((`detalle_ventas`.`precio` * `detalle_ventas`.`descuento`) / 100))) AS `precio_descuento`,(`productos`.`precio` * `detalle_ventas`.`cantidad`) AS `precio_sin_descuento`,`ventas`.`estado` AS `estado`,`abonos`.`valor_abono` AS `valor_abono`,`ventas`.`fecha` AS `fecha`,`usuarios`.`nombre` AS `nombre_usuario` from ((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `usuarios`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`abonos`.`id_venta` = `ventas`.`id`) and (`usuarios`.`id` = `ventas`.`id_usuario`)) group by `productos`.`id`,`ventas`.`id`,`detalle_ventas`.`descuento` order by `ventas`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_mostrar_compras`
--
DROP TABLE IF EXISTS `vista_mostrar_compras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_mostrar_compras`  AS  select `compras`.`id` AS `id_compra`,`detalle_compras`.`id_articulo` AS `id_articulo`,`detalle_compras`.`cantidad` AS `cantidad`,`articulos`.`nombre` AS `nombre`,`detalle_compras`.`precio` AS `precio_unidad`,(`detalle_compras`.`precio` * `detalle_compras`.`cantidad`) AS `precio_total`,`compras`.`num_comprobante` AS `num_comprobante`,`proveedores`.`razon_social` AS `razon_social`,`compras`.`comprobante` AS `comprobante`,`compras`.`descripcion` AS `estado`,`compras`.`fecha` AS `fecha` from (((`compras` join `detalle_compras`) join `proveedores`) join `articulos`) where ((`compras`.`id` = `detalle_compras`.`id_compra`) and (`detalle_compras`.`id_articulo` = `articulos`.`id`) and (`compras`.`id_proveedor` = `proveedores`.`id`)) order by `compras`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos`
--
DROP TABLE IF EXISTS `vista_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_productos`  AS  select `productos`.`codigo` AS `codigo`,`productos`.`nombre` AS `nombre`,`productos`.`precio` AS `precio`,`categorias`.`nombre` AS `nombre_categoria` from (`productos` join `categorias`) where (`productos`.`id_categoria` = `categorias`.`id`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores`
--
DROP TABLE IF EXISTS `vista_proveedores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_proveedores`  AS  select `proveedores`.`id` AS `id`,`proveedores`.`razon_social` AS `razon_social`,`proveedores`.`tipo_documento` AS `tipo_documento`,`proveedores`.`num_documento` AS `num_documento`,`proveedores`.`telefono` AS `telefono` from `proveedores` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_reporte_ventas_detalle`
--
DROP TABLE IF EXISTS `vista_reporte_ventas_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_reporte_ventas_detalle`  AS  select `ventas`.`id` AS `id`,`detalle_ventas`.`cantidad` AS `cantidad`,`productos`.`nombre` AS `nombre_producto`,`productos`.`precio` AS `precio_producto`,`detalle_ventas`.`descuento` AS `descu`,if((`detalle_ventas`.`descuento` = 0),(`productos`.`precio` * `detalle_ventas`.`cantidad`),((`productos`.`precio` * `detalle_ventas`.`cantidad`) - ((`detalle_ventas`.`precio` * `detalle_ventas`.`descuento`) / 100))) AS `precio_descuento`,(`productos`.`precio` * `detalle_ventas`.`cantidad`) AS `precio_sin_descuento`,`ventas`.`estado` AS `estado`,`abonos`.`valor_abono` AS `valor_abono`,`abonos`.`tipo_pago` AS `tipo_pago`,`categorias`.`nombre` AS `categoria`,`abonos`.`fecha` AS `fecha` from ((((`ventas` join `detalle_ventas`) join `productos`) join `abonos`) join `categorias`) where ((`ventas`.`id` = `detalle_ventas`.`id_venta`) and (`productos`.`id` = `detalle_ventas`.`id_producto`) and (`productos`.`id_categoria` = `categorias`.`id`) and (`abonos`.`id_venta` = `ventas`.`id`)) group by `productos`.`id`,`ventas`.`id`,`detalle_ventas`.`descuento`,`abonos`.`fecha`,`abonos`.`valor_abono` order by `ventas`.`id` desc ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_saldo_sin_cliente`
--
DROP TABLE IF EXISTS `vista_saldo_sin_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_saldo_sin_cliente`  AS  select `abonos`.`id_venta` AS `id_venta`,`ventas`.`valor_total` AS `valor_total`,sum(`abonos`.`valor_abono`) AS `abono`,if((sum(`abonos`.`valor_abono`) = 0),`ventas`.`valor_total`,(`ventas`.`valor_total` - sum(`abonos`.`valor_abono`))) AS `saldo`,`ventas`.`estado` AS `estado` from (`ventas` join `abonos`) where ((`ventas`.`id` = `abonos`.`id_venta`) and (`ventas`.`id` = `ventas`.`id`)) group by `ventas`.`id` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_saldo_ventas`
--
DROP TABLE IF EXISTS `vista_saldo_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_saldo_ventas`  AS  select `abonos`.`id_venta` AS `id_venta`,`clientes`.`id` AS `id_cliente`,`clientes`.`nombre` AS `nombre`,`ventas`.`valor_total` AS `valor_total`,sum(`abonos`.`valor_abono`) AS `abono`,if((sum(`abonos`.`valor_abono`) = 0),`ventas`.`valor_total`,(`ventas`.`valor_total` - sum(`abonos`.`valor_abono`))) AS `saldo`,`ventas`.`estado` AS `estado` from (((`ventas` join `clientes`) join `ventas_cliente`) join `abonos`) where ((`ventas_cliente`.`id_venta` = `ventas`.`id`) and (`ventas_cliente`.`id_cliente` = `clientes`.`id`) and (`ventas`.`id` = `abonos`.`id_venta`) and (`ventas`.`id` = `ventas`.`id`)) group by `ventas`.`id` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuarios`
--
DROP TABLE IF EXISTS `vista_usuarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`marife`@`%` SQL SECURITY DEFINER VIEW `vista_usuarios`  AS  select `usuarios`.`id` AS `id`,`usuarios`.`nombre` AS `nombre`,`usuarios`.`contrasena` AS `contrasena`,`usuarios`.`rol` AS `rol` from `usuarios` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `abonos`
--
ALTER TABLE `abonos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `ajuste_inventario`
--
ALTER TABLE `ajuste_inventario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_articulo` (`id_articulo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `articulos`
--
ALTER TABLE `articulos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_proveedor` (`id_proveedor`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_articulo` (`id_articulo`),
  ADD KEY `id_compra` (`id_compra`);

--
-- Indices de la tabla `detalle_productos`
--
ALTER TABLE `detalle_productos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_articulo` (`id_articulo`);

--
-- Indices de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indices de la tabla `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indices de la tabla `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indices de la tabla `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indices de la tabla `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indices de la tabla `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indices de la tabla `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indices de la tabla `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indices de la tabla `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indices de la tabla `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indices de la tabla `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indices de la tabla `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indices de la tabla `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indices de la tabla `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indices de la tabla `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indices de la tabla `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indices de la tabla `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indices de la tabla `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `num_documento` (`num_documento`);

--
-- Indices de la tabla `sub_categorias`
--
ALTER TABLE `sub_categorias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `abonos`
--
ALTER TABLE `abonos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `ajuste_inventario`
--
ALTER TABLE `ajuste_inventario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `articulos`
--
ALTER TABLE `articulos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;
--
-- AUTO_INCREMENT de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT de la tabla `detalle_productos`
--
ALTER TABLE `detalle_productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT de la tabla `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;
--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `sub_categorias`
--
ALTER TABLE `sub_categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `abonos`
--
ALTER TABLE `abonos`
  ADD CONSTRAINT `abonos_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`);

--
-- Filtros para la tabla `ajuste_inventario`
--
ALTER TABLE `ajuste_inventario`
  ADD CONSTRAINT `ajuste_inventario_ibfk_1` FOREIGN KEY (`id_articulo`) REFERENCES `articulos` (`id`),
  ADD CONSTRAINT `ajuste_inventario_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id`),
  ADD CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD CONSTRAINT `detalle_compras_ibfk_1` FOREIGN KEY (`id_articulo`) REFERENCES `articulos` (`id`),
  ADD CONSTRAINT `detalle_compras_ibfk_2` FOREIGN KEY (`id_compra`) REFERENCES `compras` (`id`);

--
-- Filtros para la tabla `detalle_productos`
--
ALTER TABLE `detalle_productos`
  ADD CONSTRAINT `detalle_productos_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `detalle_productos_ibfk_2` FOREIGN KEY (`id_articulo`) REFERENCES `articulos` (`id`);

--
-- Filtros para la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD CONSTRAINT `detalle_ventas_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `detalle_ventas_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id`);

--
-- Filtros para la tabla `sub_categorias`
--
ALTER TABLE `sub_categorias`
  ADD CONSTRAINT `sub_categorias_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
