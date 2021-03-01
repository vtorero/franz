-- phpMyAdmin SQL Dump
-- version 4.6.6deb5ubuntu0.5
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 01-03-2021 a las 00:52:21
-- Versión del servidor: 5.7.33-0ubuntu0.18.04.1
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
CREATE DEFINER=`marife`@`%` PROCEDURE `p_actualiza_inventario` (IN `p_id` INT(11), IN `p_id_producto` INT(11), IN `p_cantidad` DECIMAL(10,2), IN `p_peso` DECIMAL(10,2), IN `p_medida` VARCHAR(5))  BEGIN
UPDATE inventario SET cantidad=cantidad-p_cantidad where id=p_id;
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_boleta` (IN `p_hash` VARCHAR(200), IN `p_code` INT(11), IN `p_descripcion` VARCHAR(300), IN `p_nro` VARCHAR(30), IN `p_cdrZip` TEXT, IN `p_success` VARCHAR(20), IN `p_xml` TEXT)  BEGIN
INSERT INTO boletas(hash,code,message,numero,zip,success,xml) values(p_hash,p_code,p_descripcion,p_nro,p_cdrZip,p_success,p_xml);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_compra` (IN `comprobante` VARCHAR(20), IN `num_comprobante` VARCHAR(20), IN `descripcion` VARCHAR(255), IN `fecha` VARCHAR(20), IN `proveedor` INT(1))  BEGIN
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

CREATE DEFINER=`marife`@`%` PROCEDURE `p_dosimetria` (IN `p_codigo` VARCHAR(50), IN `p_descripcion` VARCHAR(200), IN `p_unidad` VARCHAR(30), IN `p_cantidad` DECIMAL(10,2), IN `p_usuario` VARCHAR(30))  BEGIN
INSERT INTO dosimetria (codigo,descripcion,unidad,inventario_inicial,usuario) VALUES(p_codigo,p_descripcion,p_unidad,p_cantidad,p_usuario);
INSERT INTO dosimetria_movimientos(codigo_insumo,movimiento,unidad,cantidad_movimiento,cantidad,usuario) 
values(p_codigo,'ingreso',unidad,0,0,p_usuario) ;
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_factura` (IN `p_hash` VARCHAR(200), IN `p_code` INT(11), IN `p_descripcion` VARCHAR(300), IN `p_nro` VARCHAR(30), IN `p_cdrZip` TEXT, IN `p_success` VARCHAR(20), IN `p_xml` TEXT)  BEGIN
INSERT INTO facturas(hash,code,message,numero,zip,success,xml) values(p_hash,p_code,p_descripcion,p_nro,p_cdrZip,p_success,p_xml);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_inventario` (IN `p_id_producto` INT, IN `p_presentacion` VARCHAR(20), IN `p_unidad` VARCHAR(5), IN `p_granel` DECIMAL(10,2), IN `p_cantidad` INT, IN `p_peso` DECIMAL(10,2), IN `p_merma` DECIMAL(10,2), IN `p_fecha_produccion` VARCHAR(20), IN `p_fecha_vencimiento` VARCHAR(20), IN `p_observacion` TEXT)  BEGIN
SELECT @peso :=peso FROM productos where id=p_id_producto;
INSERT INTO inventario (id_producto,presentacion,unidad,granel,cantidad,peso,merma,fecha_produccion,fecha_vencimiento,observacion,estado,ciclo,id_usuario) VALUES(p_id_producto,p_presentacion,p_unidad,p_granel,p_cantidad,(p_cantidad*@peso),p_merma,p_fecha_produccion,p_fecha_vencimiento,p_observacion,1,2,1);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_inventario_upd` (IN `p_id` INT(11), IN `p_fecha_produccion` VARCHAR(20), IN `p_fecha_vencimiento` VARCHAR(20), IN `p_presentacion` VARCHAR(255), IN `p_cantidad` DECIMAL(10,2))  BEGIN
UPDATE inventario SET fecha_produccion=p_fecha_produccion,fecha_vencimiento=p_fecha_vencimiento,presentacion=p_presentacion,cantidad=p_cantidad where id=p_id; 
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_movimiento` (IN `p_codigo` VARCHAR(40), IN `p_operacion` VARCHAR(20), IN `p_unidad` VARCHAR(50), IN `p_cantidad` DECIMAL(10,2), IN `p_usuario` VARCHAR(20))  BEGIN
SELECT @utimo_cantidad:=cantidad FROM dosimetria_movimientos where codigo_insumo=p_codigo order by id desc limit 1;
IF(p_operacion='entrada') THEN
INSERT INTO dosimetria_movimientos(codigo_insumo,movimiento,unidad,cantidad_movimiento,cantidad,usuario) values(p_codigo,p_operacion,p_unidad,p_cantidad,@utimo_cantidad+p_cantidad,p_usuario);
END IF;
IF(p_operacion='salida') THEN
INSERT INTO dosimetria_movimientos(codigo_insumo,movimiento,unidad,cantidad_movimiento,cantidad,usuario) values(p_codigo,p_operacion,p_unidad,-p_cantidad,@utimo_cantidad-p_cantidad,p_usuario);
END IF;
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_nota` (IN `p_usuario` VARCHAR(255), IN `p_cliente` INT(11), IN `p_tipo_doc` VARCHAR(5), IN `p_comprobante` VARCHAR(255), IN `p_nro_comprobante` VARCHAR(255), IN `p_fecha` VARCHAR(20), IN `p_total` DECIMAL(10,2), IN `p_monto_igv` DECIMAL(10,2))  BEGIN
 INSERT INTO notas(id_usuario,id_cliente,fecha,tipoDoc,comprobante,nro_comprobante,igv,monto_igv,valor_neto,valor_total,estado)  
 VALUES(p_usuario,p_cliente,p_fecha,p_tipo_doc,p_comprobante,p_nro_comprobante,p_monto_igv,p_total*p_monto_igv,p_total,(p_total+(p_total*p_monto_igv)),1);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_notacredito` (IN `p_hash` VARCHAR(200), IN `p_code` INT(11), IN `p_descripcion` VARCHAR(300), IN `p_nro` VARCHAR(30), IN `p_cdrZip` TEXT, IN `p_success` VARCHAR(20), IN `p_xml` TEXT)  BEGIN
INSERT INTO notascredito(hash,code,message,numero,zip,success,xml) values(p_hash,p_code,p_descripcion,p_nro,p_cdrZip,p_success,p_xml);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_nota_detalle` (IN `p_id_venta` INT, IN `p_id_producto` VARCHAR(25), IN `p_unidad` VARCHAR(5), IN `p_cantidad` DECIMAL(10,2), IN `p_peso` DECIMAL(10,2), IN `p_precio` DECIMAL(10,2))  BEGIN
INSERT INTO nota_detalle (id_venta,id_producto,unidad_medida,cantidad,peso,precio,subtotal) 
VALUES(p_id_venta,p_id_producto,p_unidad,p_cantidad,p_peso,p_precio,p_cantidad*p_precio);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_venta` (IN `p_usuario` VARCHAR(255), IN `p_vendedor` INT(11), IN `p_cliente` INT(11), IN `p_comprobante` VARCHAR(255), IN `p_nro_comprobante` VARCHAR(255), IN `p_fecha` VARCHAR(20), IN `p_total` DECIMAL(10,2), IN `p_monto_igv` DECIMAL(10,2))  BEGIN
 INSERT INTO ventas (id_usuario,id_vendedor,id_cliente,fecha,comprobante,nro_comprobante,igv,monto_igv,valor_neto,valor_total,estado)  
 VALUES(p_usuario,p_vendedor,p_cliente,p_fecha,p_comprobante,p_nro_comprobante,p_monto_igv,p_total*p_monto_igv,p_total,(p_total+(p_total*p_monto_igv)),1);
END$$

CREATE DEFINER=`marife`@`%` PROCEDURE `p_venta_detalle` (IN `p_id_venta` INT, IN `p_id_producto` INT, IN `p_unidad` VARCHAR(5), IN `p_cantidad` DECIMAL(10,2), IN `p_peso` DECIMAL(10,2), IN `p_precio` DECIMAL(10,2))  BEGIN
INSERT INTO venta_detalle (id_venta,id_producto,unidad_medida,cantidad,peso,precio,subtotal) 
VALUES(p_id_venta,p_id_producto,p_unidad,p_cantidad,p_peso,p_precio,p_cantidad*p_precio);
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
-- Estructura de tabla para la tabla `boletas`
--

CREATE TABLE `boletas` (
  `id` int(11) NOT NULL,
  `xml` text NOT NULL,
  `hash` varchar(200) NOT NULL,
  `success` varchar(50) NOT NULL,
  `code` varchar(20) NOT NULL,
  `zip` text NOT NULL,
  `numero` varchar(40) NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `boletas`
--

INSERT INTO `boletas` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(1, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<Invoice xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:Invoice-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>RwR2nXczE/hSSHk/qa8pb9UxJJA=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>w+GvHMp4/qpH7FSzrztLbbW7KPejCY3F0g8YQkl7HfOsmeBY8oTPjeWim3CBq3c5SQz9TpzXfCU0WgcuR+QkJqBz4Bhu2uZRQYfF+EfhAOBioI08rx/BVo2OFo+bnNoo5YDciNDjBIKQzXlsNy3ueR7briVp3ppVxOAtyWMEnJjbYom4c+RJqJJgkqoKBS6IKRX4dRLBn+ufPf4FoRPqPvlswIYjH8lPWoxkQY2E0f2b/BzoB/WBd2yKsRay+/xzdDyV4K+o5GnhDgprK94L3LpQLGVfv4ofblLxZUaDci6UoMcT3s591Iyn0/cAHz/Gq8UwFO3vsoKSHeldPxuGAA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGLDCCBBSgAwIBAgIIXn/yNYNbKk8wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAxNzMxNTJaFw00MjA4MTAxNzMxNTJaMHIxCzAJBgNVBAYTAlBFMUIwQAYDVQQKDDlFbnRpZGFkIGRlIENlcnRpZmljYWNpw7NuIE5hY2lvbmFsIHBhcmEgZWwgRXN0YWRvIFBlcnVhbm8xHzAdBgNVBAMMFkVDRVJORVAgUEVSVSBDQSBST09UIDMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC2vL2la6NIgUWwoyA7CdnqjuiVlYrp5/MX01RCXrn5tDvuobS/Afb2unu0oVRsw6jYcpDP0bNnaPuBhlaOFKhjbOVJvA3US+b+9Ek2cKekCzJyQLNWb6R/m2ggTGGGGITOGayNklsrMOvNPP8F/T48bxOnUDupGVMpuKLMzz9xASBF0DhofKOxC/eEuU/irr6dnmbFDtFFdrJr/4cGlnYiYerwPw4Knu4br6uJ6KfKXE1P5r7eoli4n3JxBhUi0NK/mMc8CypJkZXC+LZ2bv7nNGgZpVk0v4yen/uX5VkuIevMYPyNi2EengxwIJOSexZPBMITH37RqiGQ2NDsN1EopFqXpddwyMIJMClr4ZsVnQZhddOKLxZmPt1P/GPy8VM763LkKWnHueq842GQ2CWrUa0U8R8Y4iJRUn/qOlyJYdveDNfLufgF/5YML5UrcXjq+j6r54je02nY6dgZ3oI8CP9HaNRvsrFbRt9bnRlwVlXQr8/iFoyAyBnClhs0KpxGAy0v4pBB6OtL0yTp7NeBY1FMY8tFAQNP5HkZ3v684j2kJ/T3wPwfCQuQuLY1bztbp/bfxjZGkkrznqSLbOO/+tJUBeAeditx8H3d61RpAo1QNpXHLKIXJz6k5/bpYT4nQuUDkHZ0vv68j9SVEyd77lfMt0qWHV/yp3uEYZ0OAQIDAQABo4HFMIHCMBIGA1UdEwEB/wQIMAYBAf8CAQIwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwSQYIKwYBBQUHAQEEPTA7MDkGCCsGAQUFBzAChi1odHRwOi8vd3d3LnJlbmllYy5nb2IucGUvY3J0L3NoYTIvZWNlcm5lcC5jcnQwEQYDVR0gBAowCDAGBgRVHSAAMB0GA1UdDgQWBBQf6SkgYdIxQrXd/VIivt0Oz/JHhzAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAEQP8rU4dSIY9ZQts3a6/vFvb1hNvETmvxhx/DhI7GkWAuiXANVBL/x1jeDJnKmXaOThQWAzBCVbuyrD1LB+ptvOGB6Lti6MG1heGvOmFMgzprqH9J4AF8w2IfyfbgzCaTTOrGp88lS959h3mqOLmfcq3xR+MFAN7JGvWPcsbaLj8sFqYI1t1JN/hoZ3+X0Ilr3XW9QQMmdFG5TIz/yqAE9n9QM8wRsoB5uvXBGvU6CIzyIjzqnnO308V4eYgY1WL3iKOV7eYeumKQ1LnNMs5N27ziDs1oPkBeLhvTHy8Kq0765UHKHVMC3YdHH2zl/LD6ZuVlgXZlgAmx6EGzbz4PmqX6iDen3azI8ps5CnKYPPqOvqSYCLGTTZosfaOHhbgbQCCPNXU3xHn/5j+jnqVntoUXVJKjVK0/mTrn9+LOYwo/lEvpNxPwKWK5KFobAuXa4Y86/0WHb4jNlCzb//4VkrZ+/3Hu7X2QthAv42AlR63xgFXy3T/GVfLw8V0RlU+1eg4sNFgaFFH1qSPofN/28NhP6pm0aytIl+2g44xJ5J0BsAUxv6IpITHo65Y6sL91QRNF4i9N3xFXvdZQeyA5GNw1GeFtcWMQuTzqoOYSN6DipmDDO6Lny9Zj+eaxtfjGjQY0/kOoC6PaaTn7rkH0/ppG1XKiYi6GxecT9MUQQs</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>B001-1</cbc:ID><cbc:IssueDate>2021-02-27</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:InvoiceTypeCode listID=\"0101\">03</cbc:InvoiceTypeCode><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON ONCE CON 80/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cbc:PayableAmount currencyID=\"PEN\">11.80</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:InvoiceLine><cbc:ID>1</cbc:ID><cbc:InvoicedQuantity unitCode=\"KGM\">1</cbc:InvoicedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">11.8</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[QUESO EDAM ARGENTINO MOLDE  X KILO]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>12120001000</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">10</cbc:PriceAmount></cac:Price></cac:InvoiceLine></Invoice>\n', 'RwR2nXczE/hSSHk/qa8pb9UxJJA=', '1', '0', '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', 'B001-1', 'La Boleta numero B001-1, ha sido aceptada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `nombre`, `fecha_registro`) VALUES
(1, 'Charcuteria', '2021-02-06 11:09:40'),
(3, 'Galletas', '2021-02-06 11:09:40'),
(4, 'Quesos', '2021-02-06 11:09:40');

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
  `num_documento` varchar(11) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `apellido`, `direccion`, `telefono`, `num_documento`, `fecha_registro`) VALUES
(1, 'VICTOR HUGO', 'JIMENEZ TORERO', '', '', '25750816', '2021-02-22 20:59:50');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` int(11) NOT NULL,
  `comprobante` varchar(20) NOT NULL,
  `num_comprobante` varchar(40) NOT NULL,
  `descripcion` varchar(25) NOT NULL,
  `fecha` date NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `id_usuario` varchar(10) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `id_compra` int(11) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
-- Estructura de tabla para la tabla `dosimetria`
--

CREATE TABLE `dosimetria` (
  `id` int(11) NOT NULL,
  `codigo` varchar(45) DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `unidad` varchar(30) NOT NULL,
  `inventario_inicial` decimal(10,2) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `usuario` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `dosimetria`
--

INSERT INTO `dosimetria` (`id`, `codigo`, `descripcion`, `unidad`, `inventario_inicial`, `fecha_registro`, `usuario`) VALUES
(1, '3000', 'SAL DE CURA', 'KGM', '0.00', '2021-02-15 14:40:25', 'ana'),
(2, '3001', 'SAL INDUSTRIAL', 'KGM', '0.00', '2021-02-15 14:40:44', 'ana'),
(3, '3002', 'PURA SAL XTEND10', 'KGM', '0.00', '2021-02-15 14:41:16', 'ana'),
(4, '3003', 'ERITORBATO DE SODIO', 'KGM', '0.00', '2021-02-15 14:41:35', 'ana'),
(5, '3004', 'DEXTROSA', 'KGM', '0.00', '2021-02-15 14:42:01', 'ana'),
(6, '3005', 'CARRAGEL', 'KGM', '0.00', '2021-02-15 14:42:25', 'ana'),
(7, '3006', 'FOSFATO', 'KGM', '0.00', '2021-02-15 14:43:09', 'ana'),
(8, '3007', 'VIENA RED', 'KGM', '0.00', '2021-02-15 14:43:56', 'ana'),
(9, '3008', 'WIENNER GOLD', 'KGM', '0.00', '2021-02-15 14:44:18', 'ana'),
(11, '3010', 'SABOR JAMON INGLES', 'KGM', '0.00', '2021-02-15 14:45:25', 'ana'),
(12, '3011', 'FECULA DE PAPA', 'KGM', '0.00', '2021-02-15 14:45:47', 'ana'),
(13, '3012', 'PROTEINA CONCENTRADA SOYA', 'KGM', '0.00', '2021-02-15 14:46:37', 'ana'),
(14, '3013', 'PROTEINA AISLADA DE SOYA', 'KGM', '0.00', '2021-02-15 14:48:29', 'ana'),
(15, '3014', 'AMARILLO 6', 'KGM', '0.00', '2021-02-15 14:50:35', 'ana'),
(16, '3015', 'MONTE  CARMIN', 'KGM', '0.00', '2021-02-15 14:59:24', 'ana'),
(17, '3016', 'MORBIXINA', 'KGM', '0.00', '2021-02-15 15:00:53', 'ana'),
(18, '3017', 'PAPIKRA 3000', 'KGM', '0.00', '2021-02-15 15:01:36', 'ana'),
(19, '3018', 'HUMO LIQUIDO', 'KGM', '0.00', '2021-02-15 15:02:21', 'ana'),
(20, '3019', 'COOKED HAM FLAVOURING', 'KGM', '0.00', '2021-02-15 15:04:20', 'ana'),
(21, '3020', 'AJO EN POLVO', 'KGM', '0.00', '2021-02-15 15:04:56', 'ana'),
(22, '3021', 'PIMIENTA BANCA', 'KGM', '0.00', '2021-02-15 15:05:30', 'ana'),
(24, '3022', 'PIMIENTA NEGRA', 'KGM', '0.00', '2021-02-23 11:36:50', 'ana'),
(25, '3023', 'COMINO EN POLVO', 'KGM', '0.00', '2021-02-23 11:37:14', 'ana'),
(26, '3024', 'TOMILLO EN POLVO', 'KGM', '0.00', '2021-02-23 11:37:37', 'ana'),
(27, '3025', 'OREGANO SECO', 'KGM', '0.00', '2021-02-23 11:38:05', 'ana'),
(28, '3026', 'CEBOLLA EN POLVO', 'KGM', '0.00', '2021-02-23 11:38:31', 'ana'),
(29, '3027', 'NUEZ MOSCADA ', 'KGM', '0.00', '2021-02-23 11:39:01', 'ana'),
(30, '3028', 'GLUTAMATO MONOSODICO', 'KGM', '0.00', '2021-02-23 11:39:24', 'ana'),
(31, '3029', 'AZUCAR', 'KGM', '0.00', '2021-02-23 11:39:44', 'ana');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dosimetria_movimientos`
--

CREATE TABLE `dosimetria_movimientos` (
  `id` int(11) NOT NULL,
  `codigo_insumo` varchar(45) NOT NULL,
  `movimiento` varchar(50) NOT NULL,
  `unidad` varchar(30) NOT NULL,
  `cantidad_ingreso` decimal(10,2) DEFAULT NULL,
  `cantidad_salida` decimal(10,2) DEFAULT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `usuario` varchar(20) NOT NULL,
  `fecha_movimiento` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `dosimetria_movimientos`
--

INSERT INTO `dosimetria_movimientos` (`id`, `codigo_insumo`, `movimiento`, `unidad`, `cantidad_ingreso`, `cantidad_salida`, `cantidad`, `usuario`, `fecha_movimiento`) VALUES
(1, '3021', 'entrada', 'KGM', '20.00', '0.00', '20.00', 'adops', '2021-02-25 23:29:34'),
(2, '3021', 'entrada', 'KGM', '5.00', '0.00', '25.00', 'admin', '2021-02-25 23:32:43'),
(3, '3021', 'salida', 'KGM', '0.00', '2.00', '23.00', 'admin', '2021-02-25 23:33:05'),
(4, '3021', 'salida', 'KGM', '0.00', '3.00', '20.00', 'admin', '2021-02-26 00:40:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresas`
--

CREATE TABLE `empresas` (
  `id` int(11) NOT NULL,
  `razon_social` varchar(300) DEFAULT NULL,
  `direccion` varchar(200) NOT NULL,
  `num_documento` varchar(15) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `departamento` varchar(50) NOT NULL,
  `provincia` varchar(50) NOT NULL,
  `distrito` varchar(50) NOT NULL,
  `estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `empresas`
--

INSERT INTO `empresas` (`id`, `razon_social`, `direccion`, `num_documento`, `telefono`, `departamento`, `provincia`, `distrito`, `estado`) VALUES
(1, 'LA ESQUINA DE LA PLANICIE S.A.C', 'AV. DEL PARQUE NRO. 510 URB.  LA PLANICIE  (ALTURA DE LA MUNICIPALIDAD DE LA MOLINA)', '20492926869', '', 'LIMA', 'LIMA', 'LA MOLINA', 'ACTIVO'),
(2, 'MUNDO VEGETAL S.A.C', 'CAL.ENRIQUE DEL HORNE NRO. 149 URB.  LAS VIÃ‘ITAS', '20506852090', NULL, 'LIMA', 'LIMA', 'BARRANCO', 'ACTIVO'),
(3, 'NAJARRO CHOQUICOTA CARMEN CARINA', 'CAR.PANAMERICANA SUR - KM 24 ', '10430396043', NULL, 'LIMA', 'LIMA', 'LURIN', 'ACTIVO'),
(4, 'DENICOLAY GUSTAVO ADOLFO', 'CAL.FRANCISCO MASIAS 2770 DPTO. 301 ', '15606078932', NULL, 'LIMA', 'LIMA', 'LINCE', 'ACTIVO'),
(5, 'MIRCH E.I.R.L.', 'AV. JAVIER PRADO ESTE NRO. 2050 INT. M41 URB.  SAN BORJA NORTE', '20601895596', NULL, 'LIMA', 'LIMA', 'SAN BORJA', 'ACTIVO'),
(6, 'PIADINA PRIME S.A.C', 'AV. LOS CONQUISTADORES NRO. 256 INT. 402 URB.  FUNDO CONDE DE SAN ISIDRO  (FRENTE A C.C.CAMINO REAL)', '20604018456', NULL, 'LIMA', 'LIMA', 'SAN ISIDRO', 'ACTIVO'),
(7, 'LUCAFFE MARKET S.A.C.', 'OTR.MARTIR OLAYA MZA. I LOTE. 9 A.F.  MARTIR OLAYA', '20606690674', NULL, 'LIMA', 'LIMA', 'PUNTA HERMOSA', 'ACTIVO'),
(8, 'ESTELA DAVILA ANIBAL', 'AV.MANUEL OLGUIN 171 URB.LOS GRANADOS COSTADO UNIV. DE LIMA ', '10105761622', NULL, 'LIMA', 'LIMA', 'SANTIAGO DE SURCO ', 'ACTIVO'),
(9, 'ITALIAN FINE FOODS S.A.C.', 'CAL.LA MAR NRO. 1318 DPTO. 205', '20604732591', NULL, 'LIMA', 'LIMA', 'MIRAFLORES', 'ACTIVO'),
(10, 'JULIETA CAFE SOCIEDAD ANONIMA CERRADA - JULIETA CAFE S.A.C.', 'CAL.LOS LIBERTADORES NRO. 260', '20555969300', NULL, 'LIMA', 'LIMA', 'SAN ISIDRO', 'ACTIVO'),
(13, 'ART & SUN GOURMET S.R.L.', 'MZA. 2 LOTE. 15 URB.  EL SILENCIO', '20606471361', NULL, 'LIMA', 'LIMA', 'PUNTA HERMOSA', 'ACTIVO'),
(14, 'NEGOCIOS Y REPRESENTACIONES M Y M ASOCIADOS SOCIEDAD DE RESPONSABILIDAD LIMITADA', 'AV. PANAMERICANA NORTE NRO. 1192 BAR.  BARRIO NUEVO CANCAS  (FRENTE A FERRETERIA DINO)', '20606944218', NULL, 'TUMBES', 'CONTRALMIRANTE VILLAR', 'CANOAS DE PUNTA SAL', 'ACTIVO'),
(15, 'ADMINISTRADORA CABO MERLIN S.A.C.', 'AV. DEL PARQUE SUR NRO. 668 URB.  CORPAC', '20603717695', NULL, 'LIMA', 'LIMA', 'SAN BORJA', 'ACTIVO'),
(16, 'BONO S.A.C.', 'AV. MARISCAL LA MAR NRO. 1263 INT. 308', '20606195568', NULL, 'LIMA', 'LIMA', 'MIRAFLORES', 'ACTIVO'),
(17, 'PIZZA FACTORY S.A.C.', 'AV. COMANDANTE ESPINAR NRO. 266 INT. 103 URB.  SURQUILLO', '20601644216', NULL, 'LIMA', 'LIMA', 'MIRAFLORES', 'ACTIVO'),
(18, 'BRASA BRAVA E.I.R.L', 'CAL.LOS COCOS NRO. 118 URB.  TAYACAJA', '20549400419', NULL, 'LIMA', 'LIMA', 'EL AGUSTINO', 'ACTIVO'),
(19, 'CAFFE MARIA S.A.C.', 'CAL.AMADOR MERINO REYNA NRO. 461 RES.  SAN ISIDRO  (ENTRE FRANCISCO MASIAS Y RIVERA NAV.)', '20600423526', NULL, 'LIMA', 'LIMA', 'SAN ISIDRO', 'ACTIVO'),
(20, 'D\'TODO MARKET S.A.C.', 'AV. ANGAMOS OESTE NRO. 863 DPTO. 2 URB.  CHACARILLA SANTA CRUZ EL ROSARIO  (MIRAFLORES)', '20606147806', NULL, 'LIMA', 'LIMA', 'MIRAFLORES', 'ACTIVO'),
(21, 'INVERSIONES CAYU E.I.R.L.', 'AV. BRIGIDA SILVA DE OCHOA NRO. 218 URB.  PANDO ET. DOS', '20606499389', NULL, 'LIMA', 'LIMA', 'SAN MIGUEL', 'ACTIVO'),
(22, 'INDUSTRIAL SOLUTIONS OF PERU S.A.C.', 'PJ. JOSE DE ACOSTA NRO. 167 DPTO. 301', '20512706496', NULL, 'LIMA', 'LIMA', 'MAGDALENA DEL MAR', 'ACTIVO'),
(23, 'MORE VILCHEZ CRISTOBAL', 'AV. LAS TUNAS 343 URB. SALAMANCA ESPALDA DE PLAZA VEA ', '10401857813', '5545454545', 'LIMA', 'LIMA', 'ATE', 'ACTIVO'),
(40, 'CHEVES ABARCA PEDRO MARTIN', 'JR HUARAZ 15123 TDA 5 BREÃ‘A ', '10079663994', '-', 'LIMA', 'LIMA', 'BREÃ‘A ', 'ACTIVO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `id` int(11) NOT NULL,
  `xml` text NOT NULL,
  `hash` varchar(200) NOT NULL,
  `success` varchar(50) NOT NULL,
  `code` varchar(20) NOT NULL,
  `zip` text NOT NULL,
  `numero` varchar(40) NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `presentacion` varchar(50) NOT NULL,
  `unidad` varchar(5) NOT NULL,
  `granel` decimal(10,2) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `peso` decimal(10,2) NOT NULL,
  `merma` decimal(10,2) NOT NULL,
  `observacion` text NOT NULL,
  `fecha_produccion` datetime NOT NULL,
  `fecha_vencimiento` datetime DEFAULT NULL,
  `estado` varchar(20) NOT NULL,
  `ciclo` int(2) NOT NULL,
  `id_usuario` int(10) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`id`, `id_producto`, `presentacion`, `unidad`, `granel`, `cantidad`, `peso`, `merma`, `observacion`, `fecha_produccion`, `fecha_vencimiento`, `estado`, `ciclo`, `id_usuario`, `fecha_registro`) VALUES
(1, 55, 'molde', 'KGM', '2.00', '4.00', '4.00', '2.00', '', '2021-02-26 00:00:00', '2021-02-28 00:00:00', '1', 2, 1, '2021-02-27 01:55:23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notas`
--

CREATE TABLE `notas` (
  `id` int(11) NOT NULL,
  `id_usuario` varchar(10) DEFAULT NULL,
  `id_cliente` int(11) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `monto_igv` decimal(10,2) NOT NULL,
  `valor_neto` decimal(10,2) NOT NULL,
  `valor_total` decimal(10,2) DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `tipoDoc` varchar(3) NOT NULL,
  `comprobante` varchar(15) NOT NULL,
  `nro_comprobante` varchar(100) NOT NULL,
  `fecha` datetime NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notascredito`
--

CREATE TABLE `notascredito` (
  `id` int(11) NOT NULL,
  `xml` text NOT NULL,
  `hash` varchar(200) NOT NULL,
  `success` varchar(50) NOT NULL,
  `code` varchar(20) NOT NULL,
  `zip` text NOT NULL,
  `numero` varchar(40) NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `notascredito`
--

INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(1, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>8eZ+7yehT/4tk/Dk3iE9jmPDU8I=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>o3yvY97b7WO+Q6fJg7KK+v3F9PI1w5K7TzcPR0ni6iFIlZ1dVVvWFF7j046dK0g2G8zORs1KDMI930xiuX12R9HWeHDS8O/RR9MKNiHO1fDKnkGIHr8lLUDMqAmORQBkhj4q1GgUROvXnSoteXkCTSW6BaU4O0PmZHXHB/c2qEactaN33m/ek+k/e6TUgt3+6EfT6jyRdplvI0BRHnul7ptPZsdWqxxGKSayuk3yU8GrJPMP2+OmvYlWRQpr4rSiicDl1iW9N/3r4Az9f4/nZdntyuyLYoFTPuLKxo9VNRD/CKQGD0tRI30FGvNvNrH7uB8Ve99ucNPy0Mq5MBHgVA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGwzCCBKugAwIBAgIIdTIhS+Uw/fQwDQYJKoZIhvcNAQENBQAwYTELMAkGA1UEBhMCUEUxPDA6BgNVBAoMM1JlZ2lzdHJvIE5hY2lvbmFsIGRlIElkZW50aWZpY2FjacOzbiB5IEVzdGFkbyBDaXZpbDEUMBIGA1UEAwwLRUNFUC1SRU5JRUMwHhcNMTcwODExMDI0OTIzWhcNMjUwODExMDI0OTIzWjBsMQswCQYDVQQGEwJQRTE8MDoGA1UECgwzUmVnaXN0cm8gTmFjaW9uYWwgZGUgSWRlbnRpZmljYWNpw7NuIHkgRXN0YWRvIENpdmlsMR8wHQYDVQQDDBZFQ0VQLVJFTklFQyBDQSBDbGFzcyAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkObO179U75/EHdruSQSxAWx1/iosJ9PN0hqcvv2H/TJbBsH3aUQ+/dXkV43Z91s9BQv9KURZUD7NxwvGV+pyg3+JE8n03LsfjkSxG2Z/LdDjwhxagKkXp1aqYxwNWvRh5WRmRQhR8VhjVVgoLPEKLOZQFRSVyI5jPiKeBVGVrEjeFYYw+m1LGF0raWgvvSOy7sywsM+xobP5sKMTLpEsfaFGYQQbL4+si9FEihvaymo73YHLah/bPDmE3+DoQvjct5mJQW/uzxs4gP3eGqMomEU+omhchCCPFxXr6UhGCpGUdAblhbPhHGy+R46+/8wKj67VQ8qBOlxqQ0RJfvsjQ5W7CPesCFEimL5VHA0rt5AxK4N/A5wd2iffKsOgjKeaUtnt1qulNdfzeoZOyS2+/NObLGaqsLln1vJctICEoDk1QZxvFsa+EAEMVuRy87R4KBRM4+LRMbpEAxSC6Kjq7faf4X+dD9gDAfVQCEvwf40gf1HdoUghJVTuW/Ul8Usv4Cr0G9K3pbzDvswcXkO7WTmTyhbscEV8Y3Yxd8NTBLQoLsfrqttsWjWGd0AnmY2EuPhyvo6s0iJbCBldGHXDYwerjmtxg/cj20IUPm+ofmmKJgYyKnehwp19X/B3NTdTPueRUTfP8bJYyGWqArowAqbkyKj/2rMqguzurBWk0kMCAwEAAaOCAXIwggFuMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUIq/zX+7hRX1M737j39JSfMvOe3UwRgYIKwYBBQUHAQEEOjA4MDYGCCsGAQUFBzAChipodHRwOi8vd3d3LnJlbmllYy5nb2IucGUvY3J0L3NoYTIvZWNlcC5jcnQwEQYDVR0gBAowCDAGBgRVHSAAMD0GA1UdJQQ2MDQGCCsGAQUFBwMCBggrBgEFBQcDBAYKKwYBBAGCNxQCAgYIKwYBBQUHAwkGCCsGAQUFBwMBMG4GA1UdHwRnMGUwMKAuoCyGKmh0dHA6Ly9jcmwucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAxoC+gLYYraHR0cDovL2NybDIucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAdBgNVHQ4EFgQUQxVu8NPRaxspM0EtVaxxItE8pV0wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBDQUAA4ICAQBaZVtF5V2pGCvIXytSfjGCQNot388WBRJUvisy8CMlZnkE2iRFWlcxLvZNaFdt84FqLvNxYaOYkBJxNORU8lIPJRh4J7BQMYQp1fUKFyrKEZBdFxX/nHFKnR0ERJQyLwNqo68nM24VgoC82BgCZCJpe5mref0aJyzsCGAhwbuSiyrpSxiDgRaTLPheRTBkb+M6EEDFPCooRUrex/6VdXWqHSox6HwlcjYxzo5UqjfVjstbUqRRuWs6RSmuPSzhtvLHO+/aqP7yf6sQ+a0OB/pyJS+G5j0BvG+QeiZalX4KUMiteaidaw81ilJg5295GuEJn6NvXwpHPc1uLTM0YagniLy97N7WqCc+bIWlRaK1E5+ixQfrIWyIkUFsWoUCOfHC3IofXJmz6z1UDIeJ6awA2pxFLh8HeVawY/j2E0xY5RW3uoBxuCzlaBTbHPJ/MWjW4aMT8ePsQCygrOMvagTGXO90wI/YaqO2Rq9jbQoJStM3vlUJ79dJZT/fzbeF8ivoN0nh+zE0aUzYr+TI6V0oX6q9Q703ixgE+xVkFissf13og0C3scmPiDBPRQa6vQaSeUcF7Bl2eFk87YdioXcNw8w/dZmNA1IpZc+2vpGn7ueBi0dy7JiEDSGsY9/DnkMzRjFmSe+NHjJXdJaEkD7U77U3e1S3uqETCsAjsyloYQ==</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>BB01-1</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON ONCE CON 80/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>B001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>B001-1</cbc:ID><cbc:DocumentTypeCode>03</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">11.80</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"KGM\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">11.8</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[QUESO EDAM ARGENTINO MOLDE  X KILO]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>12120001000</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">10</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', '8eZ+7yehT/4tk/Dk3iE9jmPDU8I=', '1', '0', 'UEsDBBQAAgAIAKSbXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgApJtcUmM4cD++BAAAGg8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUJCMDEtMS54bWy1V1Fz4jYQfr9foXFmeu21RLYJELvATYAkZS6XXklI00dhC6M5W3IlGUJ/fVc2GMM5c3DtTfIgVrvffvuttILu+5ckRksqFRO8ZznntoUoD0TIeNSzpo83jUvrff9Nl0j/Kk1jFhANjhOqUsEVRRDMlU9kz8ok9wVRTPmcJFT5KqUBm2/8/WwW+ypY0IT4Lyqsg2q41gaNvugT4YYiSQS/ftGUmzLgI0BSrtUONJgF3wQ6APegFpB8G+BVFEkaEU3rQEPVsxZapz7Gq9XqfNU8FzLCrm3b2PYw+ISKRWdbbyVIWvoXidQ5bBl7HmgWmPIljUVKsdXvgrT+dHBXKqW+NBWWipYcVrrffWARJzqTm54fxRPOjQmj4ZjPRf8NQt0h4YKDPjH7J9foI9ULEaKrOBKS6UXyCqyDHdvANuhL0AicC372J3gbQY1+Fs6xS4ZHg9oXW66NREh6JhVpqAVpOe4GckLnVMJ1oGg6GfcsyxjB/CgJV3MhE1UYqqavpt2TaNucsKG27IvUJ4IeIxAA4kPm3RGLqNInKgaKnFV1KnGeSJzRfrRui4+f/0qC5tR7Hod/t+2fl96HZ1uT4fLuZTV68uK7m+X8riMvr29nbpM3rwcdulpMnpypN70b0+dsNF9jPVk9/XH/263E7vC2E/V6XVzNYvqDywbBUcP7Z616IoqId58kW8LNQ5/pGr0dUE0+wRWF602lfou40ChL3xUwlajuB7rOMbvPLdsbEU2KlYkq7jog38P1D1GwM23wi4SAUME/DM7RxkplVD5QyUhctRjg0+ErsTlWgXufJTMqT0fbi64m2NLFO2VwqdZOR1jXzxT85fDBNSMKZrc/HvWdtnPRarvOhWd7zS7eWItdQ2dkxHRt12nYbsO9fLRtP//fuJYuu4hHBgLVuOX23G37Oh1gF757m3vuOYDj+a7n296+8wabBH5Fn00txvIwvb96rFRXOgq5/kSkXhe2fDkOQcbyvSlhXNtpwp/rtVo7IPx61HajOC8mIF9VmBQ7+MATv0YOrinTJC4LvNKaBIsk77nZN82VnMS725tnhRnbPzvQwNiKRDVB+GvJcI3O9wK6dWF7Lmqg6xhOejKDRy0QCZUBnGYU0hjRhCkhYQ8FWZLGZpsjsJvJCcUiGEJkFsNbHwpAGd/f/O6jHPJHLkLhI2tPqVJCCy1JLCTsWz9thBX6gFYbAO8ISqVYMg6Ecj6hSFjAYibQnKngv5Fs75Gc0IgpLfOjcBWGkiqVExuygvsxlJuFkuZLYySAGspmMKfFMcypQssfzly39Wtc0MwpNn30ZLIaD/iSCc3OoJ2SwMoUCAcXdiMowWkeVcx4dEwZnaKMkKbQOGIOkPjfxe8cJ77IoNz1QzYzN1Wvj2F/uWFvANl3YH55FPNRnj7QrzI295HykMrvM8twbYIJDShbnpCzbbecDhR9fM6aFCMBAoPrdvJvuZSf8ldhM8wgxWBgOw1n+1rs7Hsvy1CE8GTtPym5LfcaURVIlua8YIiA5mZ+oKGkoTkTHPhIgYpEv6AFQcp0mQQ01SQkBWoVY1tbtYBdWXvD+6CAUrI690IvljKwH9mTdsNtdVr2pdM+pSV7KXB9U3D9T9v+v1BLAQIAABQAAgAIAKSbXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACACkm1xSYzhwP74EAAAaDwAAGwAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1CQjAxLTEueG1sUEsFBgAAAAACAAIAfQAAAB0FAAAAAA==', 'BB01-1', 'La Nota de Credito numero BB01-1, ha sido aceptada'),
(2, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>k5FUnmz3GSuqA1dq/YPujBXMGhI=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>mdV32YUeDsDQ7aFolepQaVeftmDHJv6eNdLkvUJz3mCpcaCRwnh6x/mUh+Vo1r5M/58j0qUtJjTayLL83Of3qopP6ytrvSI9zTVuaqxsposCuN/tOfJEK4jd95OeBKtv3MZyyAm9Ge5uOqEw+6tA0yni1J8EuFJi/7h1bq4zayry41I+kdVZH4UXv7+iagEM3jIhocjJcQmOxtt0k7mH/zcep4soEpClDjpmtQgUrm+iBwLuusQKIIOk+CU9ANF8zTbeEtEj1igOncfYHEqqajqbwiOzxBH+s+bp2R5f8BCrpAQwvQuznO8uOLn77J48KjYx0pGn7gRnUZx7lC8nxA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>BB01-2</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON ONCE CON 80/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>B001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>B001-1</cbc:ID><cbc:DocumentTypeCode>03</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">11.80</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"KGM\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">11.8</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[QUESO EDAM ARGENTINO MOLDE  X KILO]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>12120001000</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">10</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'k5FUnmz3GSuqA1dq/YPujBXMGhI=', '1', '0', 'UEsDBBQAAgAIABKgXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAEqBcUizrb4S+BAAAGg8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUJCMDEtMi54bWy1V21z4jYQ/n6/QuPM9NpriWwT3lzgBkLujmmaEEIu134TsmJUbMsjyeTl13dlgzGcMwfX3iQfxGr32WeflVbQff8UhWjFpOIi7lnOqW0hFlPh8zjoWXezD7W29b7/pkukN0iSkFOiwXHKVCJixRAEx8ojsmelMvYEUVx5MYmY8lTCKH9Y+3vpPPQUXbCIeE/Kr4KqudYajT3pI+HORRSJ+OJJs9iUAR8BksVabUHpnH4X6BDcaSUg+T7AQRBIFhDNqkB91bMWWicexo+Pj6eP9VMhA+zato3tDgYfX/HgZOOtBEkK/zyROoUtY88CzQKzeMVCkTBs9bsgrXc3vCyUUl+bcktJyxhWut+95UFMdCrXPT+IJ5wbE8b8cfwg+m8Q6p6TWMSgT8hfMo3+ZHohfDQIAyG5XkSvwDrYsQ1sjT3RGnXO4pN78DaCGv0snGEXDA8Gtc82XGuRkOxEKlJTC9Jw3DXklD0wCdeBobvpuGdZxgjmmSSxehAyUrmhbPpm2h2JNs3xa2rDPk99JOghAgEg3mfeHfGAKX2kYqDISVmnAuczCVPWb6uXzpSnyezzkjUXEzz6pMlH2pn8NZss587ATz/eL9s381XrAtMl/Xt5fXkeBC8387Mv9JNwpqkzWfyq2v/4jWEa2sPrwXBA7q9ver0uLmcx/cFFg+Co4d2zVj4RecS7ieQruHloyZ7R2yHTZAJXFK43k/otioVGafIuhylFdf9gzxlm90vD7oyIJvnKROV3HZCv4Pr7iG5Na/w8ISCU8PeDM7SxUimTt0xyEpYtBvh4+FJshpXjXqXRnMnj0Xaiywk2dPFWGVyotdUR1tUzBX89fHDFiILZ7Y1HfafpnDWaZ3a91XI6Xby25ruGzsiI6dquU7Pdmtue2baX/a9dC5dtxIyDQBVumT1z27xOe9i5787mjnsG4GbA9dau8xqbUK+kz7oWY7m9uxrMStUVjkI+T4jUz7ktW459kLF4bwoY13bq8Od2Go0tEH49arORnxcTkK1KTPIdvOeJXyMH15RrEhYFDrQmdBFlPTf7prkyJuH29mZZYcb2T/Y0MLY8UUUQ/lYyXKHzlYBundkdF9XQRQgnPZrDo0ZFxCSF04x8FiIWcSUk7CGaRklotmMEdjM5oVgEQ4jMQ3jrfQEo46sP1x7KIH+OhS88ZO0oVUhooRUJhYR965e1sELv0WoC4CVBiRQrHgOhjI8vIk55yAV64Ir+N5LNHZJTFnClZXYUBr4vmVIZsXOecz+Ecj1X0nxpDARQQ+kc5rQ4hDlTaPXTies2fg9zmhnFuoc+m6zGA75kQrNTaKcksDIFwsGF3QBKcOoHFTMeHVJGKy/DZwk0jpgDJP538VuHiS9SKPf5Np2bm6qfD2HfXrM3gPwHMG8fxHyUpaf6VcbmPrLYZ/LHzDJcmWDKKOOrI3I27YbTgqIPz1mRYiRAYHDdTP4Nl+JT9iqshxmkGA5tp+ZuXoutfedlORc+PFm7T0pmy7xGTFHJk4wXDBHQ3MwPdC6Zb85EDHykQHmi39CCIGW6TChLNPFJjlrG2NRWLmBb1s7w3iugkKzKPdeLJxzsB/akWXMbrYbddprHtGQnBa5uCq7+adv/F1BLAQIAABQAAgAIABKgXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACAASoFxSLOtvhL4EAAAaDwAAGwAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1CQjAxLTIueG1sUEsFBgAAAAACAAIAfQAAAB0FAAAAAA==', 'BB01-2', 'La Nota de Credito numero BB01-2, ha sido aceptada');
INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(3, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>JhEK3k7MLKHeUSyyXhvnJbc3bgs=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>FiYT4cjAAje+hAP9i/Dj6zgeOwlav/IrI3YrTMs4le1QDSb5teaQ/ugUMXYGrpG2YkVIsGTXeeWQpFJr6pFATYOXclO2U+u31TVGln8J2EenqZd+KzxHKFBIQqXteYd1XS1k2Ym1eKMozABz84fVORx9+E+34zuCFQSga393esg9/7w39ebQiNVs8axfPCs1HkzC7pwXB7mLCnU0p38tuEd2I67nszFzwNg5qblAJORBpN6EeOTYv29ay7CiUykiZK5UsTDITU0UmqVzzVGtmMcO9YXrx1ikTDmASBzS8uAcawtA+kpQ0VEWdb+cYWIe3ZCZbMqtQrI/WKH3uzFtiA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-3</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON ONCE CON 80/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20606499389</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[INVERSIONES CAYU E.I.R.L.]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[AV. BRIGIDA SILVA DE OCHOA NRO. 218 URB.  PANDO ET. DOS]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">11.80</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"KGM\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">11.8</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[QUESO EDAM ARGENTINO MOLDE  X KILO]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>12120001000</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">10</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'JhEK3k7MLKHeUSyyXhvnJbc3bgs=', '1', '0', 'UEsDBBQAAgAIAEOgXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAQ6BcUunnCb/CBAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtMy54bWy1V21z4jYQ/n6/QmNmeu1NiWzz7gI3BJIrvSTN5e2afhO2YtTYkk+SSciv78oGYzhnDq69ST6I1e6zzz4rraD//jmO0IJKxQQfWM6RbSHKfREwHg6s25vTetd6P3zTJ9IbJUnEfKLB8YqqRHBFEQRz5RE5sFLJPUEUUx4nMVWeSqjPHlb+XjqLPOXPaUy8ZxVUQdVda4VGn/WBcGMRx4KfPGvKTRnwESAp12oD6s/87wI9Bne/EpB8H+AoDCUNiaZVoIEaWHOtEw/jp6eno6fGkZAhdm3bxnYPg0+gWFhbeytBksI/T6SOYMvYs0CzwJQvaCQSiq1hH6T1bo/PCqXU16bcUtKSw0oP+9cs5ESnctXzvXjCuTFhNJjyBzF8g1B/TLjgoE/EXjKNzqmeiwCNolBIpufxK7AOdmwDW6fPft13mrz2GbyNoEY/C2fYBcO9Qe3mmms9FpLWpCJ1NSctx11BXtEHKuE6UHR7NR1YljGC+UYSrh6EjFVuKJu+mXZLonVzgrpas89THwi6j0AAiHeZ9ycspEofqBgoUivrVODckSilw/GduL69fGk/z+a9D5f3zUsejWef1Pns2L/vBORDZ+SfOW3qfrk9F+PfPy9Ys/vwx/nf7fDu4wl+TJ++NI/POuEivg9fHllnefPP5KI7+TQY9HE5i+kPLhoERw1vn7Xyicgj3l1KtoCbhx7pEr09pppcwhWF602lfou40ChN3uUwpaj+R7rMMPt/tezehGiSr0xUftcB+QKuf4D8jWmFnycEhBL+bnCGNlUqpfKaSkaissUAHw5fis2wctyLNJ5ReTjaVnQ5wZou3iiDC7U2OsK6eqbgr4cPrhhRMLu96WTotJ1mq9103LbtOH28sua7hs7EiOnarlO33brbvbFtL/tfuRYum4gbBgJVuGX2zG39Ou1g575bm1vuGYALqK5nt7edV9jE90r6rGoxluvbi9FNqbrCUcjlJZF6mduy5TQAGYv3poBxbacBf26v1doA4dej1hv5eTEB2arEJN/BO574NXJwTZkmUVHgSGviz+Os52bfNFdyEm1ub5YVZuywtqOBseWJKoLwt5LhCp0vBHSrafdcVEcnEZz0eAaPmi9iKn04zSigEaIxU0LCHvLTOInMNkdgN5MTikUwhMgsgrc+EIAyvTj900MZ5M9cBMJD1pZShYQWWpBISNi3flkJK/QOrTYAnhGUSLFgHAhlfAIRM59FTKAHpvz/RrK9RfKKhkxpmR2FURBIqlRGbMxy7vtQbuRKmi+NoQBqKJ3BnBb7MKcKLX6quW7rtyinmVFseOjOZDUe8CUTmp1COyWBlSkQDi7shlCC09irmOlknzI6eRkBTaBxxBwg8b+L39lPfJFCucvrdGZuql7uw767Ym8A2Q9g3t2L+SRL7+tXGZv7SHlA5Y+ZZbgywRX1KVsckLNtt5wOFL1/zooUEwECg+t68q+5FJ+yV2E1zCDF6ant1Bvr12Jj33pZxiKAJ2v7SclsmdeEKl+yJOMFQwQ0N/MDjSUNzJngwEcKlCf6Fc0JUqbLxKeJJgHJUcsY69rKBWzK2hreOwUUklW553qxhIF9z56066Yr7Wav1+j2DunKVhZc3Rdc/et2+C9QSwECAAAUAAIACABDoFxSAAAAAAIAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAAZHVtbXkvUEsBAgAAFAACAAgAQ6BcUunnCb/CBAAAHQ8AABsAAAAAAAAAAQAAAAAAJgAAAFItMjA2MDUxNzQwOTUtMDctRkYwMS0zLnhtbFBLBQYAAAAAAgACAH0AAAAhBQAAAAA=', 'FF01-3', 'La Nota de Credito numero FF01-3, ha sido aceptada'),
(4, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>rqaPBlPfeC/sYB96069QSCVgd6s=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>hVQ9z/HWOEFT6xp+TyXXXfhonX3CsuuyO9GA7hQaIIgNHSR2/oswjyywM1efv1NoviMDeNsuvUPjf44zWzDpnr9ZWBnc9/6JWhpcEfe6QXZO4cun14tKKn8gkj5QE5zLciFm9iuZz2ONXsR2aY7dbTZSx2SuajaEgqynjLoZZGNMG9aeH+9hmtTeAbfzUbEEsD7DYb88NeEHXa91bxSK/ZpNgp545VvwBe4Uib4PAhQr1tSFPKWAsSkJjnQn+9T3A8qpMXKwz4P3zamysc+dAbzXthbXettmucOaBI23LfNd4jMZwyyL3iJjWzNsDhdS34oX8WPxuhnl/W6XsVPm+Q==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGdDCCBFygAwIBAgIIBuVEi//Q7T0wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAyMDMxNTlaFw0zMzA4MTAyMDMxNTlaMGExCzAJBgNVBAYTAlBFMTwwOgYDVQQKDDNSZWdpc3RybyBOYWNpb25hbCBkZSBJZGVudGlmaWNhY2nDs24geSBFc3RhZG8gQ2l2aWwxFDASBgNVBAMMC0VDRVAtUkVOSUVDMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJvyMiRwB1BO0KMkFH9tkjCqnyF9ZkTMkQg3SIk+qxFWq8Bv4K1MaO0aWe4/5vdaRI2NW/E61C+q76bAAaR/nwfPTBPStBW6WKerwZ4w+2OFCF0UaioCJ6P1SRETsRYesNDFeU/FJD7+o7MTt1s3nxPzsqcOgiORXO7Zs8RmhRdLmhi+LOZHxx6xXngd7bpk/ustCb3XHKHJFjSdLED5EInAZ+JhTZsI8qvMqE5nV0+cBNCpvvAazFp4R9J2vH4W1Abr8xIXoxXhQXIxTjoJWDX0RgANBbv10NqHf6xOwCtJgALc2bzUzNZd6QhsiVe18kDJGjD34KvqTO8Oyk98gwKomzrkEavXA3LrP8aCxtxX9URugtSKdH9GRgu4zm8632A9X76MjkhdApvyQa7iA+s4JZWhN5QbGYTTDBWeYjktcbEnGyfX/o1zEOqnYsPqn8nS0O1b52pV6OYwYuRKhw1bD/flk0Z28CQI20sJM1LBXHgXtALE8n59/m/yElk7u71QZqGdCY2e2wi6H+7L7V9C7eOeJnf/5WD1oUa6F/yswj47Lelp4peVXZg7PJ3IGugCbBHtl42j04Je+/+8E2DJomVJl6oFlZzk38dIF00QaWGp6dv4L1PFVDRG5XkIIdF7GmLcbO5iY01/sRbhBruejx+VmtA2zwGOUlpfbwUCAwEAAaOCAR0wggEZMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwPQYDVR0lBDYwNAYIKwYBBQUHAwIGCCsGAQUFBwMEBgorBgEEAYI3FAICBggrBgEFBQcDCQYIKwYBBQUHAwEwdAYDVR0fBG0wazAzoDGgL4YtaHR0cDovL2NybC5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMDSgMqAwhi5odHRwOi8vY3JsMi5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMB0GA1UdDgQWBBQir/Nf7uFFfUzvfuPf0lJ8y857dTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAGqyEZiEtBM/ZuQ/2UBxXHticPgnRMrW0p3KD+7JbiGrSTKvRUOczeqm4OwRP4j2+wFYAlTG1UtBz2F4rcY1nvycDXRw+Q7DXf6PopIbncPiYAziZuqw0DH0Dl5crFxoQ+AZhWJh+vmi2RLK2pJLHd7gAEYUGJmiAWXK5RN6b9rb6KA+N9bNvekA9QGNm7KnhZo5Fu4XNbp7FdlQE3IVBxZH3J6eiWtOal11SpZAP7eYBjDtay2jUWla0XrTE62WKhj6n+yBiowPLPSP/EW+DgAUw0fPDW8BKoXUiDsQVU1ewNC3FgwchuAM+a+E7+6OoOLomNQ1pTqT8QM7XTq1RW1c+x5fxlGnEnJ14UAC2nz1KWF6cDkXreh6C5jpOV9ZVQ9/nI05tyAWvENz0lKVNareI0TPbQACm6NGYay1wLCeZIXsy7bBll0EhdRhL8k4hrdDSeonS8+oJwHVVGRDRlGPF4aM61HDCxdi5Pon/XmIWqC6DMV/j97LVqjVOXeOmvrGPiWqBZu4jVmWktiJw1oaPPTM2BA+j/KJLN/xlm3O1ApEVrtbGlUqHDTxeurOBGvqZOJ5ulKGPOzyM1gB71U2pCJwn93W/gxVxCxpIhtCoVz/KdPSxz2ppIx/bYYWo6u9Fd+E8c6GUXH877/VRKVrm0pf2ntWnSjRjh5/6gY+</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-4</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON DOS CON 36/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10401857813</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[MORE VILCHEZ CRISTOBAL]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[AV. LAS TUNAS 343 URB. SALAMANCA ESPALDA DE PLAZA VEA ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">0.36</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">2.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">0.36</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">2.36</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">2.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">2.36</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">0.36</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">2.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">0.36</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">2</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'rqaPBlPfeC/sYB96069QSCVgd6s=', '1', '0', 'UEsDBBQAAgAIAIemXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAh6ZcUhNRhHa/BAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtNC54bWy1V21z2jgQ/t5foTEz17v2iGzz7gM6CTQ9pjmaSSC93DfZVoymtuRKgoT8+lvZYAx1ptC7TvJBrHafffZZaQX9d09JjFZUKib4wHLObAtRHoiQ8WhgzWeX9a71bviqT6R3nqYxC4gGxxuqUsEVRRDMlUfkwFpK7gmimPI4SajyVEoD9rDx95Z+7KlgQRPiPamwCqruWhs0+qRPhBuJJBH8/ZOm3JQBHwGScq12oIEf/BDoBbgHlYDkxwDPo0jSiGhaBRqqgbXQOvUwfnx8PHtsnAkZYde2bWz3MPiEikW1rbcSJC3880TqDLaMPQs0C0z5isYipdga9kFab35xVSilvjXllpKWHFZ62L9lESd6KTc9P4onnBsTRsMJfxDDVwj1R4QLDvrE7DnT6C+qFyJE53EkJNOL5AVYBzu2ga3Tp6AeOE1e+wzeRlCjn4Uz7ILh0aB2c8u1nghJa1KRulqQluNuIG/oA5VwHSia30wGlmWMYJ5JwtWDkInKDWXTd9PuSbRtTlhXW/Z56hNBjxEIAPEh8/6YRVTpExUDRWplnQqcOxIv6fBjY3Ixmbb12978/kvn89t2p+fPnz+snzvkuvdPz1ctP9Hj8E+f2D67CyLp3o8W8Inei2azS9TFs/tpftWbrmdJ2/8Q+did3X59HAz6uJzF9AcXDYKjhvfPWvlE5BFvriVbwc1DX+gavb6gmlzDFYXrTaV+jbjQaJm+yWFKUf2PdJ1h9v9u2b0x0SRfmaj8rgPyFK5/iIKdaYOfJwSEEv5hcIY2UWpJ5S2VjMRliwE+Hb4Um2HluNNl4lN5OtpedDnBli7eKYMLtXY6wrp6puBvhw+uGFEwu73JeOi0nWar3XEazWbP7uONNd81dMZGTNd2nbrt1t3uzLa97H/jWrjsImYMBKpwy+yZ2/Z1OsDOffc299wzANf2Wq7nNPedN9gk8Er6bGoxltv59HxWqq5wFHJ9TaRe57ZsOQlBxuK9KWBc22nAn9trtXZA+OWo7UZ+XkxAtioxyXfwgSd+iRxcU6ZJXBR4rjUJFknWc7Nvmis5iXe3N8sKM3ZYO9DA2PJEFUH4e8lwhc5TAd1q2j0X1dH7GE564sOjFoiEygBOMwppjGjClJCwh4JlksZmmyOwm8kJxSIYQsSP4a0PBaBMppefPJRB/spFKDxk7SlVSGihFYmFhH3rt42wQh/QagPgFUGpFCvGgVDGJxQJC1jMBHpgKvhvJNt7JG9oxJSW2VE4D0NJlcqIjVjO/RjKjVxJ86UxEkANLX2Y0+IY5lSh1S811239Eec0M4oND92ZrMYDvmRCs5fQTklgZQqEgwu7EZTgNI4qZjI+poxOXkZIU2gcMQdI/O/id44TXyyh3PXt0jc3Va+PYd/dsDeA7Ccw7x7FfJylD/SLjM19pDyk8ufMMlyZ4IYGlK1OyNm2W04Hij4+Z0WKsQCBwXU7+bdcik/Zq7AZZpDi8tJ26sVrsbPvvSwjEcKTtf+kZLbMa0xVIFma8YIhApqb+YFGkobmTHDgIwXKE/2OFgQp02US0FSTkOSoZYxtbeUCdmXtDe+DAgrJqtxzvVjKwH5kT9p1x27aTrfV6TqNU7qylwVX9wVX/7od/gtQSwECAAAUAAIACACHplxSAAAAAAIAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAAZHVtbXkvUEsBAgAAFAACAAgAh6ZcUhNRhHa/BAAAHQ8AABsAAAAAAAAAAQAAAAAAJgAAAFItMjA2MDUxNzQwOTUtMDctRkYwMS00LnhtbFBLBQYAAAAAAgACAH0AAAAeBQAAAAA=', 'FF01-4', 'La Nota de Credito numero FF01-4, ha sido aceptada');
INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(5, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>hcoiLuIeoNCEcX9ymLFyc4SS1VU=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>PnWFsODqqRY9LH6LUUFeMnqHlCJMdrzHbiQ7eYON7kJLAacZcs+53Y3YvSiLYnxPK2rsb85GOURsq58AyPdQyBSACMhE1Sbh0Oe/eWnsScbggI8yRPV97nT3sOuEyW6e8vIb1cPl7yDN9IjCyJP7a5iEfgFXh2AEnhvvqjyPrpnfoIzuCFt8OwaLT00ck+6V/mvuRBEmZM/9Ekg+D31xMZfBj8tk7TKdAx8g/QJ3Yuk58lqzhS+3w8cLPMQu+Ib/nbChoJMA+k5143NZBPgqfR2kDIhan+0Wlxhwhj/AHgYZH82SpTX7BXuyMeLESsEu+96Jk5GWzvXoBrQhgy3fDA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGwzCCBKugAwIBAgIIdTIhS+Uw/fQwDQYJKoZIhvcNAQENBQAwYTELMAkGA1UEBhMCUEUxPDA6BgNVBAoMM1JlZ2lzdHJvIE5hY2lvbmFsIGRlIElkZW50aWZpY2FjacOzbiB5IEVzdGFkbyBDaXZpbDEUMBIGA1UEAwwLRUNFUC1SRU5JRUMwHhcNMTcwODExMDI0OTIzWhcNMjUwODExMDI0OTIzWjBsMQswCQYDVQQGEwJQRTE8MDoGA1UECgwzUmVnaXN0cm8gTmFjaW9uYWwgZGUgSWRlbnRpZmljYWNpw7NuIHkgRXN0YWRvIENpdmlsMR8wHQYDVQQDDBZFQ0VQLVJFTklFQyBDQSBDbGFzcyAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkObO179U75/EHdruSQSxAWx1/iosJ9PN0hqcvv2H/TJbBsH3aUQ+/dXkV43Z91s9BQv9KURZUD7NxwvGV+pyg3+JE8n03LsfjkSxG2Z/LdDjwhxagKkXp1aqYxwNWvRh5WRmRQhR8VhjVVgoLPEKLOZQFRSVyI5jPiKeBVGVrEjeFYYw+m1LGF0raWgvvSOy7sywsM+xobP5sKMTLpEsfaFGYQQbL4+si9FEihvaymo73YHLah/bPDmE3+DoQvjct5mJQW/uzxs4gP3eGqMomEU+omhchCCPFxXr6UhGCpGUdAblhbPhHGy+R46+/8wKj67VQ8qBOlxqQ0RJfvsjQ5W7CPesCFEimL5VHA0rt5AxK4N/A5wd2iffKsOgjKeaUtnt1qulNdfzeoZOyS2+/NObLGaqsLln1vJctICEoDk1QZxvFsa+EAEMVuRy87R4KBRM4+LRMbpEAxSC6Kjq7faf4X+dD9gDAfVQCEvwf40gf1HdoUghJVTuW/Ul8Usv4Cr0G9K3pbzDvswcXkO7WTmTyhbscEV8Y3Yxd8NTBLQoLsfrqttsWjWGd0AnmY2EuPhyvo6s0iJbCBldGHXDYwerjmtxg/cj20IUPm+ofmmKJgYyKnehwp19X/B3NTdTPueRUTfP8bJYyGWqArowAqbkyKj/2rMqguzurBWk0kMCAwEAAaOCAXIwggFuMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUIq/zX+7hRX1M737j39JSfMvOe3UwRgYIKwYBBQUHAQEEOjA4MDYGCCsGAQUFBzAChipodHRwOi8vd3d3LnJlbmllYy5nb2IucGUvY3J0L3NoYTIvZWNlcC5jcnQwEQYDVR0gBAowCDAGBgRVHSAAMD0GA1UdJQQ2MDQGCCsGAQUFBwMCBggrBgEFBQcDBAYKKwYBBAGCNxQCAgYIKwYBBQUHAwkGCCsGAQUFBwMBMG4GA1UdHwRnMGUwMKAuoCyGKmh0dHA6Ly9jcmwucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAxoC+gLYYraHR0cDovL2NybDIucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAdBgNVHQ4EFgQUQxVu8NPRaxspM0EtVaxxItE8pV0wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBDQUAA4ICAQBaZVtF5V2pGCvIXytSfjGCQNot388WBRJUvisy8CMlZnkE2iRFWlcxLvZNaFdt84FqLvNxYaOYkBJxNORU8lIPJRh4J7BQMYQp1fUKFyrKEZBdFxX/nHFKnR0ERJQyLwNqo68nM24VgoC82BgCZCJpe5mref0aJyzsCGAhwbuSiyrpSxiDgRaTLPheRTBkb+M6EEDFPCooRUrex/6VdXWqHSox6HwlcjYxzo5UqjfVjstbUqRRuWs6RSmuPSzhtvLHO+/aqP7yf6sQ+a0OB/pyJS+G5j0BvG+QeiZalX4KUMiteaidaw81ilJg5295GuEJn6NvXwpHPc1uLTM0YagniLy97N7WqCc+bIWlRaK1E5+ixQfrIWyIkUFsWoUCOfHC3IofXJmz6z1UDIeJ6awA2pxFLh8HeVawY/j2E0xY5RW3uoBxuCzlaBTbHPJ/MWjW4aMT8ePsQCygrOMvagTGXO90wI/YaqO2Rq9jbQoJStM3vlUJ79dJZT/fzbeF8ivoN0nh+zE0aUzYr+TI6V0oX6q9Q703ixgE+xVkFissf13og0C3scmPiDBPRQa6vQaSeUcF7Bl2eFk87YdioXcNw8w/dZmNA1IpZc+2vpGn7ueBi0dy7JiEDSGsY9/DnkMzRjFmSe+NHjJXdJaEkD7U77U3e1S3uqETCsAjsyloYQ==</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-5</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON ONCE CON 80/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10079663994</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[CHEVES ABARCA PEDRO MARTIN]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[JR HUARAZ 15123 TDA 5 BREÃ‘A ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">11.80</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">10.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">11.8</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">10.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">1.80</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">10</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'hcoiLuIeoNCEcX9ymLFyc4SS1VU=', '1', '0', 'UEsDBBQAAgAIAMamXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAxqZcUjq8aNbGBAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtNS54bWy1V21z2jgQ/t5foXFmrnedI7LNS4IP6JCQ5LimCSGv12/CVoyutuSRZAL59beywRjqTKF3neSDWO0+++yz0go6H+dxhGZUKiZ413IObQtR7ouA8bBr3d+d146tj713HSK9fpJEzCcaHMdUJYIriiCYK4/IrpVK7gmimPI4ianyVEJ99rz099JJ5Cl/SmPizVVQBVVzrSUanes94U5FHAt+NteUmzLgI0BSrtUa1J/4PwR6Au5+JSD5McB+GEoaEk2rQAPVtaZaJx7GLy8vhy/1QyFD7Nq2je02Bp9AsfBg5a0ESQr/PJE6hC1jzwLNAlM+o5FIKLZ6HZDWuz+5LJRS35pyS0lLDivd69yykBOdymXPd+IJ58aE0WDIn0XvHUKdU8IFB30i9ppp9JnqqQhQPwqFZHoavwHrYMc2sDU692u+0+AHj+BtBDX6WTjDLhjuDGo3VlxrsZD0QCpSU1PSdNwl5Jg+UwnXgaL78bBrWcYI5jtJuHoWMla5oWz6btoNiVbNCWpqxT5PvSfoLgIBIN5m3hmwkCq9p2KgyEFZpwLngUQp7T3Xnx4vnfDxz/TrzWRx27/5hOfOP2eLxwu/8XpxPRzfnN+zxu3l/EmPXpN75+/6ha/w5+Duy/n1X2f8sfnl6GG+GAUXp6+sf7YYLSZuEIbdbgeXs5j+4KJBcNTw5lkrn4g84sNIshncPPSVLtD7E6rJCK4oXG8q9XvEhUZp8iGHKUV1PtFFhtl5atrtAdEkX5mo/K4D8hVc/wD5a9MSP08ICCX87eAMbahUSuUtlYxEZYsB3h++FJth5bhXaTyhcn+0jehyghVdvFYGF2qtdYR19UzB3w4fXDGiYHZ7w0HPaTmNZuvIbdZd1+3gpTXfNXQGRkzXdp2a7dbc4zvb9rL/pWvhso64YyBQhVtmz9xWr9MWdu67sbnhngG4ttdseE5903mJTXyvpM+yFmO5vb/q35WqKxyFXIyI1Ivcli2HAchYvDcFjGs7dfhz283mGgi/HbXayM+LCchWJSb5Dt7yxG+Rg2vKNImKAvtaE38aZz03+6a5kpNofXuzrDBjewdbGhhbnqgiCH8vGa7Q+UpAtxp220U1dBbBSY8n8Kj5IqbSh9OMAhohGjMlJOwhP42TyGxzBHYzOaFYBEOITCJ46wMBKMOr82sPZZC/chEID1kbShUSWmhGIiFh3/ptKazQW7RaAHhJUCLFjHEglPEJRMx8FjGBnpny/xvJ1gbJMQ2Z0jI7Cv0gkFSpjNgpy7nvQrmeK2m+NIYCqKF0AnNa7MKcKjT75cB1m39EOc2MYt1DDyar8YAvmdDsFNopCaxMgXBwYTeEEpz6TsUMB7uUcZSXEdAEGkfMARL/u/hHu4kvUih3cZtOzE3Vi13YHy/ZG0D2E5gf78R8kKX39ZuMzX2kPKDy58wyXJlgTH3KZnvkbNlN5wiK3j1nRYqBAIHBdTX5V1yKT9mrsBxmkOL83HZqzdVrsbZvvCynIoAna/NJyWyZ14AqX7Ik4wVDBDQ38wOdShqYM8GBjxQoT/Q7mhKkTJeJTxNNApKjljFWtZULWJe1Mby3Cigkq3LP9WIJA/uOPWnVHNs+arda9Xa7sU9XNrLg6r7g6l+3vX8BUEsBAgAAFAACAAgAxqZcUgAAAAACAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAGR1bW15L1BLAQIAABQAAgAIAMamXFI6vGjWxgQAAB0PAAAbAAAAAAAAAAEAAAAAACYAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtNS54bWxQSwUGAAAAAAIAAgB9AAAAJQUAAAAA', 'FF01-5', 'La Nota de Credito numero FF01-5, ha sido aceptada'),
(6, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>7uGNwiYvez6WLiEM6gNzkXaRrXA=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>EgkuWpbSeTwkmjd4LNMnxJ2MCrnHHNlerANURrTIfUnG/oT4qz38fhV0iz2Bj6B+iQ5qqpov2ynzl9U4nDRyUr3kxn90FlPm/NDk8FkGNABM2Ll0WwaQMXlgMmK/b6gADhyGXNYIlGCszOC4ue/SYrycGDKkFEKOhybvpmbI+FJbAdq8UvhY5rLYLzcZSyyuNOMUCKLT3ZJlymEC+EhQFGqPGRyjOeZ/cLGIM2yYiTnIc2nNpP0upToJ+1zN10A6sC4ZKjjsSKuoqGYMmKk7pGQJ1SAV9KErX8rpv0jEfLZF3o4xgHgbFAIQySPC+S9KraBKLtzG9jr7bsjbKXRQ1A==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGwzCCBKugAwIBAgIIdTIhS+Uw/fQwDQYJKoZIhvcNAQENBQAwYTELMAkGA1UEBhMCUEUxPDA6BgNVBAoMM1JlZ2lzdHJvIE5hY2lvbmFsIGRlIElkZW50aWZpY2FjacOzbiB5IEVzdGFkbyBDaXZpbDEUMBIGA1UEAwwLRUNFUC1SRU5JRUMwHhcNMTcwODExMDI0OTIzWhcNMjUwODExMDI0OTIzWjBsMQswCQYDVQQGEwJQRTE8MDoGA1UECgwzUmVnaXN0cm8gTmFjaW9uYWwgZGUgSWRlbnRpZmljYWNpw7NuIHkgRXN0YWRvIENpdmlsMR8wHQYDVQQDDBZFQ0VQLVJFTklFQyBDQSBDbGFzcyAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkObO179U75/EHdruSQSxAWx1/iosJ9PN0hqcvv2H/TJbBsH3aUQ+/dXkV43Z91s9BQv9KURZUD7NxwvGV+pyg3+JE8n03LsfjkSxG2Z/LdDjwhxagKkXp1aqYxwNWvRh5WRmRQhR8VhjVVgoLPEKLOZQFRSVyI5jPiKeBVGVrEjeFYYw+m1LGF0raWgvvSOy7sywsM+xobP5sKMTLpEsfaFGYQQbL4+si9FEihvaymo73YHLah/bPDmE3+DoQvjct5mJQW/uzxs4gP3eGqMomEU+omhchCCPFxXr6UhGCpGUdAblhbPhHGy+R46+/8wKj67VQ8qBOlxqQ0RJfvsjQ5W7CPesCFEimL5VHA0rt5AxK4N/A5wd2iffKsOgjKeaUtnt1qulNdfzeoZOyS2+/NObLGaqsLln1vJctICEoDk1QZxvFsa+EAEMVuRy87R4KBRM4+LRMbpEAxSC6Kjq7faf4X+dD9gDAfVQCEvwf40gf1HdoUghJVTuW/Ul8Usv4Cr0G9K3pbzDvswcXkO7WTmTyhbscEV8Y3Yxd8NTBLQoLsfrqttsWjWGd0AnmY2EuPhyvo6s0iJbCBldGHXDYwerjmtxg/cj20IUPm+ofmmKJgYyKnehwp19X/B3NTdTPueRUTfP8bJYyGWqArowAqbkyKj/2rMqguzurBWk0kMCAwEAAaOCAXIwggFuMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUIq/zX+7hRX1M737j39JSfMvOe3UwRgYIKwYBBQUHAQEEOjA4MDYGCCsGAQUFBzAChipodHRwOi8vd3d3LnJlbmllYy5nb2IucGUvY3J0L3NoYTIvZWNlcC5jcnQwEQYDVR0gBAowCDAGBgRVHSAAMD0GA1UdJQQ2MDQGCCsGAQUFBwMCBggrBgEFBQcDBAYKKwYBBAGCNxQCAgYIKwYBBQUHAwkGCCsGAQUFBwMBMG4GA1UdHwRnMGUwMKAuoCyGKmh0dHA6Ly9jcmwucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAxoC+gLYYraHR0cDovL2NybDIucmVuaWVjLmdvYi5wZS9hcmwvc2hhMi9lY2VwLmNybDAdBgNVHQ4EFgQUQxVu8NPRaxspM0EtVaxxItE8pV0wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBDQUAA4ICAQBaZVtF5V2pGCvIXytSfjGCQNot388WBRJUvisy8CMlZnkE2iRFWlcxLvZNaFdt84FqLvNxYaOYkBJxNORU8lIPJRh4J7BQMYQp1fUKFyrKEZBdFxX/nHFKnR0ERJQyLwNqo68nM24VgoC82BgCZCJpe5mref0aJyzsCGAhwbuSiyrpSxiDgRaTLPheRTBkb+M6EEDFPCooRUrex/6VdXWqHSox6HwlcjYxzo5UqjfVjstbUqRRuWs6RSmuPSzhtvLHO+/aqP7yf6sQ+a0OB/pyJS+G5j0BvG+QeiZalX4KUMiteaidaw81ilJg5295GuEJn6NvXwpHPc1uLTM0YagniLy97N7WqCc+bIWlRaK1E5+ixQfrIWyIkUFsWoUCOfHC3IofXJmz6z1UDIeJ6awA2pxFLh8HeVawY/j2E0xY5RW3uoBxuCzlaBTbHPJ/MWjW4aMT8ePsQCygrOMvagTGXO90wI/YaqO2Rq9jbQoJStM3vlUJ79dJZT/fzbeF8ivoN0nh+zE0aUzYr+TI6V0oX6q9Q703ixgE+xVkFissf13og0C3scmPiDBPRQa6vQaSeUcF7Bl2eFk87YdioXcNw8w/dZmNA1IpZc+2vpGn7ueBi0dy7JiEDSGsY9/DnkMzRjFmSe+NHjJXdJaEkD7U77U3e1S3uqETCsAjsyloYQ==</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGdDCCBFygAwIBAgIIBuVEi//Q7T0wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAyMDMxNTlaFw0zMzA4MTAyMDMxNTlaMGExCzAJBgNVBAYTAlBFMTwwOgYDVQQKDDNSZWdpc3RybyBOYWNpb25hbCBkZSBJZGVudGlmaWNhY2nDs24geSBFc3RhZG8gQ2l2aWwxFDASBgNVBAMMC0VDRVAtUkVOSUVDMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJvyMiRwB1BO0KMkFH9tkjCqnyF9ZkTMkQg3SIk+qxFWq8Bv4K1MaO0aWe4/5vdaRI2NW/E61C+q76bAAaR/nwfPTBPStBW6WKerwZ4w+2OFCF0UaioCJ6P1SRETsRYesNDFeU/FJD7+o7MTt1s3nxPzsqcOgiORXO7Zs8RmhRdLmhi+LOZHxx6xXngd7bpk/ustCb3XHKHJFjSdLED5EInAZ+JhTZsI8qvMqE5nV0+cBNCpvvAazFp4R9J2vH4W1Abr8xIXoxXhQXIxTjoJWDX0RgANBbv10NqHf6xOwCtJgALc2bzUzNZd6QhsiVe18kDJGjD34KvqTO8Oyk98gwKomzrkEavXA3LrP8aCxtxX9URugtSKdH9GRgu4zm8632A9X76MjkhdApvyQa7iA+s4JZWhN5QbGYTTDBWeYjktcbEnGyfX/o1zEOqnYsPqn8nS0O1b52pV6OYwYuRKhw1bD/flk0Z28CQI20sJM1LBXHgXtALE8n59/m/yElk7u71QZqGdCY2e2wi6H+7L7V9C7eOeJnf/5WD1oUa6F/yswj47Lelp4peVXZg7PJ3IGugCbBHtl42j04Je+/+8E2DJomVJl6oFlZzk38dIF00QaWGp6dv4L1PFVDRG5XkIIdF7GmLcbO5iY01/sRbhBruejx+VmtA2zwGOUlpfbwUCAwEAAaOCAR0wggEZMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwPQYDVR0lBDYwNAYIKwYBBQUHAwIGCCsGAQUFBwMEBgorBgEEAYI3FAICBggrBgEFBQcDCQYIKwYBBQUHAwEwdAYDVR0fBG0wazAzoDGgL4YtaHR0cDovL2NybC5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMDSgMqAwhi5odHRwOi8vY3JsMi5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMB0GA1UdDgQWBBQir/Nf7uFFfUzvfuPf0lJ8y857dTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAGqyEZiEtBM/ZuQ/2UBxXHticPgnRMrW0p3KD+7JbiGrSTKvRUOczeqm4OwRP4j2+wFYAlTG1UtBz2F4rcY1nvycDXRw+Q7DXf6PopIbncPiYAziZuqw0DH0Dl5crFxoQ+AZhWJh+vmi2RLK2pJLHd7gAEYUGJmiAWXK5RN6b9rb6KA+N9bNvekA9QGNm7KnhZo5Fu4XNbp7FdlQE3IVBxZH3J6eiWtOal11SpZAP7eYBjDtay2jUWla0XrTE62WKhj6n+yBiowPLPSP/EW+DgAUw0fPDW8BKoXUiDsQVU1ewNC3FgwchuAM+a+E7+6OoOLomNQ1pTqT8QM7XTq1RW1c+x5fxlGnEnJ14UAC2nz1KWF6cDkXreh6C5jpOV9ZVQ9/nI05tyAWvENz0lKVNareI0TPbQACm6NGYay1wLCeZIXsy7bBll0EhdRhL8k4hrdDSeonS8+oJwHVVGRDRlGPF4aM61HDCxdi5Pon/XmIWqC6DMV/j97LVqjVOXeOmvrGPiWqBZu4jVmWktiJw1oaPPTM2BA+j/KJLN/xlm3O1ApEVrtbGlUqHDTxeurOBGvqZOJ5ulKGPOzyM1gB71U2pCJwn93W/gxVxCxpIhtCoVz/KdPSxz2ppIx/bYYWo6u9Fd+E8c6GUXH877/VRKVrm0pf2ntWnSjRjh5/6gY+</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-6</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON CATORCE CON 16/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10079663994</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[CHEVES ABARCA PEDRO MARTIN]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[JR HUARAZ 15123 TDA 5 BREÃ‘A ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">14.16</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">12.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">14.16</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">12</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', '7uGNwiYvez6WLiEM6gNzkXaRrXA=', '1', '0', 'UEsDBBQAAgAIABOnXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAE6dcUtbC3ZDEBAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtNi54bWy1V21z2jgQ/t5foXFmrnedI7LNuw/oEEiuNC1NSNKm903YitHElnySTMj9+lvZYAx1ptC7TvJBrHafffZZaQW9t6s4QksqFRO8bzmntoUo90XAeNi37m4vah3r7eBVj0hvmCQR84kGxxlVieCKIgjmyiOyb6WSe4IopjxOYqo8lVCfPaz9vXQeecpf0Jh4KxVUQdVca41GV/pIuJGIY8HPV5pyUwZ8BEjKtdqC+nP/h0DPwN2vBCQ/BjgMQ0lDomkVaKD61kLrxMP46enp9Kl+KmSIXdu2sd3F4BMoFp5svJUgSeGfJ1KnsGXsWaBZYMqXNBIJxdagB9J6d2cfCqXUt6bcUtKSw0oPejcs5ESnct3zg3jCuTFhNJjwBzF4hVBvRLjgoE/E/sk0+kj1QgRoGIVCMr2IX4B1sGMb2Bpd+TXfafCTL+BtBDX6WTjDLhgeDGo3NlxrsZD0RCpSUwvSdNw15Iw+UAnXgaK72aRvWcYI5ltJuHoQMla5oWz6btodiTbNCWpqwz5PfSToIQIBIN5n3huzkCp9pGKgyElZpwLnM4lSOuDiy/T9u6/35P2dSsJ2OqafZtP68qscLW90d7W4VNf398mk2R6ffz67/nPpDs8fVpdPV53lfHT70X2cP4bz6wWNrvyzd3+P2+NJ46/lzXW/38PlLKY/uGgQHDW8e9bKJyKPeHMl2RJuHnqkz+j1GdXkCq4oXG8q9WvEhUZp8iaHKUX1Lulzhtm7b9rdMdEkX5mo/K4D8hSuf4D8rWmNnycEhBL+fnCGNlEqpfKGSkaissUAHw9fis2wctxpGs+pPB5tJ7qcYEMXb5XBhVpbHWFdPVPwt8MHV4womN3eZDxwWk6j2WrXux3bbfTw2prvGjpjI6Zru07Ndmtu59a2vex/7Vq4bCNuGQhU4ZbZM7fN67SHnfvubO64ZwCu7TVbXn3PeY1NfK+kz7oWY7m5mw5vS9UVjkI+XxGpn3NbtpwEIGPx3hQwru3U4c/tNptbIPxy1GYjPy8mIFuVmOQ7eM8Tv0QOrinTJCoKHGpN/EWc9dzsm+ZKTqLt7c2ywowdnOxpYGx5ooog/L1kuELnqYBuNeyui2roPIKTHs/hUfNFTKUPpxkFNEI0ZkpI2EN+GieR2eYI7GZyQrEIhhCZR/DWBwJQJtOLTx7KIH/lIhAesnaUKiS00JJEQsK+9dtaWKH3aLUA8ANBiRRLxoFQxicQMfNZxAR6YMr/byRbOyRnNGRKy+woDINAUqUyYiOWcz+Ecj1X0nxpDAVQQ+kc5rQ4hDlVaPnLies2/4hymhnFuoc+m6zGA75kQrNTaKcksDIFwsGF3RBKcOoHFTMZH1JGOy8joAk0jpgDJP538duHiS9SKPf5Jp2bm6qfD2HfWbM3gOwnMO8cxHycpff1i4zNfaQ8oPLnzDJcmWBGfcqWR+Rs2U2nDUUfnrMixViAwOC6mfwbLsWn7FVYDzNIcXFhO7XW5rXY2ndelpEI4MnafVIyW+Y1psqXLMl4wRABzc38QCNJA3MmOPCRAuWJfkcLgpTpMvFpoklActQyxqa2cgHbsnaG914BhWRV7rleLGFgP7AnrZpj2+1uq1XvdhvHdGUnC67uC67+dTv4F1BLAQIAABQAAgAIABOnXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACAATp1xS1sLdkMQEAAAdDwAAGwAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1GRjAxLTYueG1sUEsFBgAAAAACAAIAfQAAACMFAAAAAA==', 'FF01-6', 'La Nota de Credito numero FF01-6, ha sido aceptada');
INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(7, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>Czp0Ur3Co8aK78fNqrKWciljBBo=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>nCBT2yx10mwK7R+YE2DbUgFbm7xfsvq89KC+etPuTCRJbQhEDeU0rb2EGQ0wUB7HWvhzxX2GWysjpTZRPO9xpUFRaSXYTwUuMBp/v9el0pnsjBi2pGu/u1mufUjbjNKyrxJfZGvvZoAtaqWUtASmRi4MO0BmiUhnl3jWeDmwCc8SeMvdWJVSHu3e8ZJ46pPr3MbKeXWj0wiNNunJigtPiy426EM8t8RuvU4lqcbqdfI+RUtxQR/9M+RcFvMttKFVe1CgeZ0pgx2lf3M+MVIom2MzSZ97HZMlwtEWn/OQl+3/CNvjdFhby6j8zx/lvs3NwJDdLBnClHWnNzuaHonR1A==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-7</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON CATORCE CON 16/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10079663994</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[CHEVES ABARCA PEDRO MARTIN]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[JR HUARAZ 15123 TDA 5 BREÃ‘A ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">14.16</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">12.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">14.16</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">12</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'Czp0Ur3Co8aK78fNqrKWciljBBo=', '1', '0', 'UEsDBBQAAgAIADmnXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAOadcUr+wC4XBBAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtNy54bWy1V1F32jYUfu+v0HHOWbduRLbBEDygh4Smo0tZFkLW7U3YilFrS44kk9BfvysbjKHOKXTrSR7E1b3f/e53pSvovX5KYrSkUjHB+5ZzaluI8kCEjEd9a3Z72TizXg9e9Ij0h2kas4BocLyhKhVcUQTBXPlE9q1Mcl8QxZTPSUKVr1IasPu1v5/NY18FC5oQ/0mFdVAN11qj0Sd9JNyFSBLB3zxpyk0Z8BEgKddqCxrMg28CPQf3oBaQfBvgMIokjYimdaCh6lsLrVMf48fHx9PH5qmQEXZt28Z2F4NPqFh0svFWgqSlf5FIncKWseeBZoEpX9JYpBRbgx5I68/Or0ql1JemwlLRksNKD3pTFnGiM7nu+UE84dyYMBqO+b0YvECod0G44KBPzD7nGr2neiFCNIwjIZleJM/AOtixDWyDPgWNwGnxk7/A2whq9LNwjl0yPBjUbm24NhIh6YlUpKEWxHPcNeQNvacSrgNFs5tx37KMEcy3knB1L2SiCkPV9NW0OxJtmhM21IZ9kfpI0EMEAkC8z7w3YhFV+kjFQJGTqk4lzh2JMzq48ty7+ecg7JK3c89uN9/9NstaD1cJmXTvPpC/Z6Nw+o4kl+6nR3E9abXwDX07Ov+AM+Loh/feP+qBqtXHju62pj+fpXLiNIfen1dRv9/D1SymP7hsEBw1vHvWqieiiHh1LdkSbh76RFfo5TnV5BquKFxvKvVLxIVGWfqqgKlE9X6nqxyz98GzuyOiSbEyUcVdB+QJXP8QBVvTGr9ICAgV/P3gHG2sVEbllEpG4qrFAB8PX4nNsQrcSZbMqTwebSe6mmBDF2+VwaVaWx1hXT9T8JfDB9eMKJjd/ng0cNpOy2t3Wh2naXs9vLYWu4bOyIjp2q7TsN2Ge3Zr237+v3YtXbYRtwwEqnHL7bnb5nXawy58dzZ33HMA1/a9ju85u85rbBL4FX3WtRjLdDYZ3laqKx2FXF0TqVeFLV+OQ5CxfG9KGNd2mvDndr2KTPj5qM1GcV5MQL6qMCl28J4nfo4cXFOmSVwWONSaBIsk77nZN82VnMTb25tnhRk7ONnTwNiKRDVB+GvJcI3OEwHdatldFzXQmxhOejKHRy0QCZUBnGYU0hjRhCkhYQ8FWZLGZpsjsJvJCcUiGEJkHsNbHwpAGU8u//BRDvkjF6HwkbWjVCmhhZYkFhL2rZ/Wwgq9R6sNgFcEpVIsGQdCOZ9QJCxgMRPonqngv5Fs75C8oRFTWuZHYRiGkiqVE7tgBfdDKDcLJc2XxkgANZTNYU6LQ5hThZY/nLiu92tc0MwpNn10Z7IaD/iSCc3OoJ2SwMoUCAcXdiMowWkeVMx4dEgZnaKMkKbQOGIOkPjfxe8cJr7IoNzVNJubm6pXh7A/W7M3gOw7MD87iPkoTx/oZxmb+0h5SOX3mWW4NsENDShbHpGzbXtOB4o+PGdNipEAgcF1M/k3XMpP+auwHmaQ4vLSdhqdzWuxte+8LBcihCdr90nJbbnXiKpAsjTnBUMENDfzA11IGpozwYGPFKhI9AtaEKRMl0lAU01CUqBWMTa1VQvYlrUzvPcKKCWrcy/0YikD+4E9aTcc2+502+1mt9s6pis7WXB9X3D9r9vBv1BLAQIAABQAAgAIADmnXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACAA5p1xSv7ALhcEEAAAdDwAAGwAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1GRjAxLTcueG1sUEsFBgAAAAACAAIAfQAAACAFAAAAAA==', 'FF01-7', 'La Nota de Credito numero FF01-7, ha sido aceptada'),
(8, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>7JJtXl+Zew8O9R6cRPVS+SEtiuE=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>mbzirfWgAguEDIwJz2Fz+aEOGc35/W2iqFHxoa83QUA06Z0Az0NOQ33CVY6zwBF5EEosMtZbbMBRD0VxmYbalfiZgE4iUQNhi9RLVfGXeRwAxyLA+J8cG0uBmxEON7twYyr4HJyqsCQlBGsYoCdTagDwc9gijMkJEfSAHHbqf4X/7MH4nAEfUX/bUgjQMDoCV/si3iHqyENi7J3pq1DSJAzh4qZR2MgI4bxILNgT7StE78ZrhDA1TcZXKQsf1UbpIfbVuWiowbhUiSAVSqYm7FMjvCXCCa+AEdDX596SYwUgEuoQ3Hj/AP89cx3pWQyHYGMK+zDn9NuBIemGaSH4QQ==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGdDCCBFygAwIBAgIIBuVEi//Q7T0wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAyMDMxNTlaFw0zMzA4MTAyMDMxNTlaMGExCzAJBgNVBAYTAlBFMTwwOgYDVQQKDDNSZWdpc3RybyBOYWNpb25hbCBkZSBJZGVudGlmaWNhY2nDs24geSBFc3RhZG8gQ2l2aWwxFDASBgNVBAMMC0VDRVAtUkVOSUVDMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJvyMiRwB1BO0KMkFH9tkjCqnyF9ZkTMkQg3SIk+qxFWq8Bv4K1MaO0aWe4/5vdaRI2NW/E61C+q76bAAaR/nwfPTBPStBW6WKerwZ4w+2OFCF0UaioCJ6P1SRETsRYesNDFeU/FJD7+o7MTt1s3nxPzsqcOgiORXO7Zs8RmhRdLmhi+LOZHxx6xXngd7bpk/ustCb3XHKHJFjSdLED5EInAZ+JhTZsI8qvMqE5nV0+cBNCpvvAazFp4R9J2vH4W1Abr8xIXoxXhQXIxTjoJWDX0RgANBbv10NqHf6xOwCtJgALc2bzUzNZd6QhsiVe18kDJGjD34KvqTO8Oyk98gwKomzrkEavXA3LrP8aCxtxX9URugtSKdH9GRgu4zm8632A9X76MjkhdApvyQa7iA+s4JZWhN5QbGYTTDBWeYjktcbEnGyfX/o1zEOqnYsPqn8nS0O1b52pV6OYwYuRKhw1bD/flk0Z28CQI20sJM1LBXHgXtALE8n59/m/yElk7u71QZqGdCY2e2wi6H+7L7V9C7eOeJnf/5WD1oUa6F/yswj47Lelp4peVXZg7PJ3IGugCbBHtl42j04Je+/+8E2DJomVJl6oFlZzk38dIF00QaWGp6dv4L1PFVDRG5XkIIdF7GmLcbO5iY01/sRbhBruejx+VmtA2zwGOUlpfbwUCAwEAAaOCAR0wggEZMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwPQYDVR0lBDYwNAYIKwYBBQUHAwIGCCsGAQUFBwMEBgorBgEEAYI3FAICBggrBgEFBQcDCQYIKwYBBQUHAwEwdAYDVR0fBG0wazAzoDGgL4YtaHR0cDovL2NybC5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMDSgMqAwhi5odHRwOi8vY3JsMi5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMB0GA1UdDgQWBBQir/Nf7uFFfUzvfuPf0lJ8y857dTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAGqyEZiEtBM/ZuQ/2UBxXHticPgnRMrW0p3KD+7JbiGrSTKvRUOczeqm4OwRP4j2+wFYAlTG1UtBz2F4rcY1nvycDXRw+Q7DXf6PopIbncPiYAziZuqw0DH0Dl5crFxoQ+AZhWJh+vmi2RLK2pJLHd7gAEYUGJmiAWXK5RN6b9rb6KA+N9bNvekA9QGNm7KnhZo5Fu4XNbp7FdlQE3IVBxZH3J6eiWtOal11SpZAP7eYBjDtay2jUWla0XrTE62WKhj6n+yBiowPLPSP/EW+DgAUw0fPDW8BKoXUiDsQVU1ewNC3FgwchuAM+a+E7+6OoOLomNQ1pTqT8QM7XTq1RW1c+x5fxlGnEnJ14UAC2nz1KWF6cDkXreh6C5jpOV9ZVQ9/nI05tyAWvENz0lKVNareI0TPbQACm6NGYay1wLCeZIXsy7bBll0EhdRhL8k4hrdDSeonS8+oJwHVVGRDRlGPF4aM61HDCxdi5Pon/XmIWqC6DMV/j97LVqjVOXeOmvrGPiWqBZu4jVmWktiJw1oaPPTM2BA+j/KJLN/xlm3O1ApEVrtbGlUqHDTxeurOBGvqZOJ5ulKGPOzyM1gB71U2pCJwn93W/gxVxCxpIhtCoVz/KdPSxz2ppIx/bYYWo6u9Fd+E8c6GUXH877/VRKVrm0pf2ntWnSjRjh5/6gY+</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>BB01-8</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON VEINTICINCO CON 96/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>B001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>B001-1</cbc:ID><cbc:DocumentTypeCode>03</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">3.96</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">22.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">3.96</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">25.96</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">2</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">22.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">12.98</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">3.96</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">22.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">3.96</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">11</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', '7JJtXl+Zew8O9R6cRPVS+SEtiuE=', '1', '0', 'UEsDBBQAAgAIAI+pXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAj6lcUgJj+da+BAAAGg8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUJCMDEtOC54bWy1V1Fz2jgQfu+v0JiZ6117RLYJJPiADoRmQi/NtYSknXsTtmLU2JIryRDu19/KNsZQZwq96yQPYrX77bffSivovXmKI7SkUjHB+5ZzYluIcl8EjId962522Ty33gxe9Ij0hkkSMZ9ocJxSlQiuKIJgrjwi+1YquSeIYsrjJKbKUwn12UPh76XzyFP+gsbEe1JBHVTTtQo0+qSPhLsQcSz42ydNuSkDPgIk5VptQf25/0OgI3D3awHJjwEOw1DSkGhaBxqovrXQOvEwXq1WJ6vWiZAhdm3bxnYXg0+gWNjYeCtBktI/T6ROYMvYs0CzwJQvaSQSiq1BD6T17kbXpVLqW1NuqWjJYaUHvVsWcqJTWfT8IJ5wbkwYDSb8QQxeINS7IFxw0Cdi/2Qavad6IQI0jEIhmV7Ez8A62LENbJM++U3fOeWNT+BtBDX6WTjDLhkeDGqfbrg2YyFpQyrSVAvSdtwCckofqITrQNHddNK3LGME80wSrh6EjFVuqJq+m3ZHok1zgqbasM9THwl6iEAAiPeZ98YspEofqRgo0qjqVOLckyilg3s5vDy7WsvL68fFV3Yr+MdW+O71ehUsbpeTr9L5POOXcZhMPt2zkfqy6Hy8n75bqCv/ZmjHo/CKpa9bw+ljhMP33ce/HwXtdmeTs1W/38PVLKY/uGwQHDW8e9aqJyKPePVBsiXcPPRI1+jliGryAa4oXG8q9UvEhUZp8iqHqUT1/qTrDLP3uW13x0STfGWi8rsOyDdw/QPkb00Ffp4QECr4+8EZ2kSplMpbKhmJqhYDfDx8JTbDynFv0nhO5fFoO9HVBBu6eKsMLtXa6gjr+pmCvx0+uGZEwez2JuOB03FO253zVtt23NMeLqz5rqEzNmK6tus0bbfpns9s28v+C9fSZRsxYyBQjVtmz9w2r9Medu67s7njngG4jue4XsvedS6wie9V9ClqMZbbu5vhrFJd6Sjk+gORep3bsuUkABnL96aEcW2nBX9ut93eAuHnozYb+XkxAdmqwiTfwXue+DlycE2ZJlFZ4FBr4i/irOdm3zRXchJtb2+WFWbsoLGngbHliWqC8PeS4RqdbwR069TuuqiJ3kZw0uM5PGq+iKn04TSjgEaIxkwJCXvIT+MkMtscgd1MTigWwRAi8wje+kAAyuTm8i8PZZC/chEID1k7SpUSWmhJIiFh3/qtEFboPVodALwmKJFiyTgQyvgEImY+i5hAD0z5/41kZ4fklIZMaZkdhWEQSKpURuyC5dwPodzKlTRfGkMB1FA6hzktDmFOFVr+0nDd9h9RTjOj2PLQvclqPOBLJjQ7hXZKAitTIBxc2A2hBKd1UDGT8SFlnOVlBDSBxhFzgMT/Lv7ZYeKLFMpd36Zzc1P1+hD25wV7A8h+AvPzg5iPs/S+fpaxuY+UB1T+nFmGaxNMqU/Z8oicHbvtnEHRh+esSTEWIDC4bib/hkv5KXsVimEGKUYj22mWT8vWvvOyXIgAnqzdJyWzZV5jqnzJkowXDBHQ3MwPdCFpYM4EBz5SoDzR72hBkDJdJj5NNAlIjlrF2NRWLWBb1s7w3iuglKzOPdeLJQzsB/ak03TbZ2373Okc05KdFLi+Kbj+p+3gX1BLAQIAABQAAgAIAI+pXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACACPqVxSAmP51r4EAAAaDwAAGwAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1CQjAxLTgueG1sUEsFBgAAAAACAAIAfQAAAB0FAAAAAA==', 'BB01-8', 'La Nota de Credito numero BB01-8, ha sido aceptada');
INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(9, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>Bd4+6q9XRF6Ypt978k2t56gbYm0=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>eLz0wOMet6X2VmuNTfq7WgVlVTQKT0aktFtSy/QIVhFaIJwQyGVyoai249rYjwdzb+SBDN4GN42FYNCBt5p8zJALwGgqetgvp69oBedRv1bvXfbv4AezedOumCSBVereMgtInZbK0xXUTocKGFVpeY7d7srPcPKPN4mwWr1+MeYDq4YOLQsdt3xRjBRQYmkBCt+ZxjokHfVjE5Jh5951cWn4yav1+DNA366PGe3ust5iEhEm6MyzBm4c8zfK177wbmJJeC2vxTHt6x3VKtKwPbYVl1S2Y3LPlp/LWDRtDtP99I9SwdyK/nEm14oacAw85axyDzBLKLkIB2OGK1es6g==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGdDCCBFygAwIBAgIIBuVEi//Q7T0wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAyMDMxNTlaFw0zMzA4MTAyMDMxNTlaMGExCzAJBgNVBAYTAlBFMTwwOgYDVQQKDDNSZWdpc3RybyBOYWNpb25hbCBkZSBJZGVudGlmaWNhY2nDs24geSBFc3RhZG8gQ2l2aWwxFDASBgNVBAMMC0VDRVAtUkVOSUVDMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJvyMiRwB1BO0KMkFH9tkjCqnyF9ZkTMkQg3SIk+qxFWq8Bv4K1MaO0aWe4/5vdaRI2NW/E61C+q76bAAaR/nwfPTBPStBW6WKerwZ4w+2OFCF0UaioCJ6P1SRETsRYesNDFeU/FJD7+o7MTt1s3nxPzsqcOgiORXO7Zs8RmhRdLmhi+LOZHxx6xXngd7bpk/ustCb3XHKHJFjSdLED5EInAZ+JhTZsI8qvMqE5nV0+cBNCpvvAazFp4R9J2vH4W1Abr8xIXoxXhQXIxTjoJWDX0RgANBbv10NqHf6xOwCtJgALc2bzUzNZd6QhsiVe18kDJGjD34KvqTO8Oyk98gwKomzrkEavXA3LrP8aCxtxX9URugtSKdH9GRgu4zm8632A9X76MjkhdApvyQa7iA+s4JZWhN5QbGYTTDBWeYjktcbEnGyfX/o1zEOqnYsPqn8nS0O1b52pV6OYwYuRKhw1bD/flk0Z28CQI20sJM1LBXHgXtALE8n59/m/yElk7u71QZqGdCY2e2wi6H+7L7V9C7eOeJnf/5WD1oUa6F/yswj47Lelp4peVXZg7PJ3IGugCbBHtl42j04Je+/+8E2DJomVJl6oFlZzk38dIF00QaWGp6dv4L1PFVDRG5XkIIdF7GmLcbO5iY01/sRbhBruejx+VmtA2zwGOUlpfbwUCAwEAAaOCAR0wggEZMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwPQYDVR0lBDYwNAYIKwYBBQUHAwIGCCsGAQUFBwMEBgorBgEEAYI3FAICBggrBgEFBQcDCQYIKwYBBQUHAwEwdAYDVR0fBG0wazAzoDGgL4YtaHR0cDovL2NybC5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMDSgMqAwhi5odHRwOi8vY3JsMi5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMB0GA1UdDgQWBBQir/Nf7uFFfUzvfuPf0lJ8y857dTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAGqyEZiEtBM/ZuQ/2UBxXHticPgnRMrW0p3KD+7JbiGrSTKvRUOczeqm4OwRP4j2+wFYAlTG1UtBz2F4rcY1nvycDXRw+Q7DXf6PopIbncPiYAziZuqw0DH0Dl5crFxoQ+AZhWJh+vmi2RLK2pJLHd7gAEYUGJmiAWXK5RN6b9rb6KA+N9bNvekA9QGNm7KnhZo5Fu4XNbp7FdlQE3IVBxZH3J6eiWtOal11SpZAP7eYBjDtay2jUWla0XrTE62WKhj6n+yBiowPLPSP/EW+DgAUw0fPDW8BKoXUiDsQVU1ewNC3FgwchuAM+a+E7+6OoOLomNQ1pTqT8QM7XTq1RW1c+x5fxlGnEnJ14UAC2nz1KWF6cDkXreh6C5jpOV9ZVQ9/nI05tyAWvENz0lKVNareI0TPbQACm6NGYay1wLCeZIXsy7bBll0EhdRhL8k4hrdDSeonS8+oJwHVVGRDRlGPF4aM61HDCxdi5Pon/XmIWqC6DMV/j97LVqjVOXeOmvrGPiWqBZu4jVmWktiJw1oaPPTM2BA+j/KJLN/xlm3O1ApEVrtbGlUqHDTxeurOBGvqZOJ5ulKGPOzyM1gB71U2pCJwn93W/gxVxCxpIhtCoVz/KdPSxz2ppIx/bYYWo6u9Fd+E8c6GUXH877/VRKVrm0pf2ntWnSjRjh5/6gY+</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-9</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON CATORCE CON 16/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10079663994</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[CHEVES ABARCA PEDRO MARTIN]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[JR HUARAZ 15123 TDA 5 BREÃ‘A ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">14.16</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">12.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">14.16</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">12</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'Bd4+6q9XRF6Ypt978k2t56gbYm0=', '1', '0', 'UEsDBBQAAgAIAJWqXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgAlapcUpy55mPDBAAAHQ8AABsAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtOS54bWy1V21z2jgQ/t5foTEz17veEdnmJeADOkkINyQNzRDSXD4KWzG62pIryZD019/KBmOoM4XedZIPYrX77LPPSivovX+OI7SkUjHB+5ZzYluIcl8EjId96342qnes94M3PSK9sySJmE80OE6pSgRXFEEwVx6RfSuV3BNEMeVxElPlqYT67Gnt76XzyFP+gsbEe1ZBFVTdtdZo9FkfCXch4ljwy2dNuSkDPgIk5VptQf25/0Og5+DuVwKSHwM8C0NJQ6JpFWig+tZC68TDeLVanawaJ0KG2LVtG9tdDD6BYmFt460ESQr/PJE6gS1jzwLNAlO+pJFIKLYGPZDWuz//UCilvjXllpKWHFZ60LtjISc6leueH8QTzo0Jo8GYP4nBG4R6F4QLDvpE7Gum0Q3VCxGgsygUkulF/Aqsgx3bwNbps1/3nSavPYC3EdToZ+EMu2B4MKjd3HCtx0LSmlSkrhak5bhryCl9ohKuA0X303HfsowRzDNJuHoSMla5oWz6btodiTbNCepqwz5PfSToIQIBIN5n3huykCp9pGKgSK2sU4HziUQpHVyt2qf33ck1V4tw5Fw/Ln5fPgj29HD1pXFtPz/8tWpfXv0jEtd3V7L19XH25SZpNdLPN9KOPt4HIzq5epyoq0t5M+9Mp7Gmjeub+d2q3+/hchbTH1w0CI4a3j1r5RORR7y7lWwJNw99pi/o7TnV5BauKFxvKvVbxIVGafIuhylF9a7pS4bZ+7tld4dEk3xlovK7DsgTuP4B8remNX6eEBBK+PvBGdpYqZTKOyoZicoWA3w8fCk2w8pxJ2k8p/J4tJ3ocoINXbxVBhdqbXWEdfVMwd8OH1wxomB2e+PhwGk7zVa702m6btvt4bU13zV0hkZM13aduu3W3c7Mtr3sf+1auGwjZgwEqnDL7Jnb5nXaw859dzZ33DMA1/Fc22u6u85rbOJ7JX3WtRjL3f3kbFaqrnAU8uWWSP2S27LlOAAZi/emgHFtpwF/brfV2gLh16M2G/l5MQHZqsQk38F7nvg1cnBNmSZRUeCZ1sRfxFnPzb5pruQk2t7eLCvM2EFtTwNjyxNVBOHvJcMVOk8EdKtpd11UR5cRnPR4Do+aL2IqfTjNKKARojFTQsIe8tM4icw2R2A3kxOKRTCEyDyCtz4QgDKejD56KIP8lYtAeMjaUaqQ0EJLEgkJ+9Zva2GF3qPVBsAPBCVSLBkHQhmfQMTMZxET6Ikp/7+RbO+QnNKQKS2zo3AWBJIqlRG7YDn3Qyg3ciXNl8ZQADWUzmFOi0OYU4WWv9Rct/VnlNPMKDY89MlkNR7wJROanUI7JYGVKRAOLuyGUILTOKiY8fCQMk7zMgKaQOOIOUDifxf/9DDxRQrlvtylc3NT9csh7Dtr9gaQ/QTmnYOYD7P0vn6VsbmPlAdU/pxZhisTTKlP2fKInG275ZxC0YfnrEgxFCAwuG4m/4ZL8Sl7FdbDDFKMRrZT725ei61952W5EAE8WbtPSmbLvIZU+ZIlGS8YIqC5mR/oQtLAnAkOfKRAeaI/0IIgZbpMfJpoEpActYyxqa1cwLasneG9V0AhWZV7rhdLGNgP7Em77tj2abfdbnS7zWO6spMFV/cFV/+6HfwLUEsBAgAAFAACAAgAlapcUgAAAAACAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAGR1bW15L1BLAQIAABQAAgAIAJWqXFKcueZjwwQAAB0PAAAbAAAAAAAAAAEAAAAAACYAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtOS54bWxQSwUGAAAAAAIAAgB9AAAAIgUAAAAA', 'FF01-9', 'La Nota de Credito numero FF01-9, ha sido aceptada'),
(10, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>e8PgVQAvM1PEmkZKCzckJdXhiVY=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>uT6KnBNsRC6LWYs+HswESQ0nRzklIuO7kaAztN8xAQeI7E89ZhxgqtZc0H5J4wRwlX1wt8OI36jUQHkeedxvzK9TZDJhIBUTEvcODD4yeML9YRjlJy5C9NuQv1ySkctMHIu8KJCaPTroZj8s5NvgjMAz4aqWmSahlByVL1CQ9ogk3TYqQy2uLaMZnvGSr35/bTLBz2a5nMQmymwMkhlwSGop6UJWAiO5x7WGyrdhtEzs74Afqi4jkrQdEgytyH6jys/9IX5urFvPN7Z7M9lZZuQb/m1GeE1Hc+PB4p4bhAC1DunuOKbYr4UCUVIsKK9fq2DeiJHR8JD3JUsciSmwaA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>FF01-10</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON VEINTISIETE CON 14/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>F001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>F001-1</cbc:ID><cbc:DocumentTypeCode>01</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">10401857813</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[MORE VILCHEZ CRISTOBAL]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[AV. LAS TUNAS 343 URB. SALAMANCA ESPALDA DE PLAZA VEA ]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">4.14</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">23.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">4.14</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">27.14</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">23.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">27.14</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">4.14</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">23.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">4.14</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">23</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', 'e8PgVQAvM1PEmkZKCzckJdXhiVY=', '1', '0', 'UEsDBBQAAgAIANiqXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgA2KpcUuXqFGDDBAAAIA8AABwAAABSLTIwNjA1MTc0MDk1LTA3LUZGMDEtMTAueG1stVdtc+I2EP5+v0LjzPTaS4ls8xLiAjcEkgvTNJcm5PryTdiK0cWWXEmGkF/flW2M4Zw5uPYm+SBWu88++6y0gt775zhCCyoVE7xvOSe2hSj3RcB42LceppeNrvV+8KZHpDdMkoj5RIPjHVWJ4IoiCObKI7JvpZJ7giimPE5iqjyVUJ89Fv5eOos85c9pTLxnFdRBNVyrQKPP+kC4kYhjwS+eNeWmDPgIkJRrtQH1Z/43gZ6Du18LSL4NcBiGkoZE0zrQQPWtudaJh/FyuTxZNk+EDLFr2za2zzD4BIqFR2tvJUhS+ueJ1AlsGXsWaBaY8gWNREKxNeiBtN7D+XWplPrSlFsqWnJY6UHvnoWc6FQWPd+LJ5wbE0aDCX8UgzcI9UaECw76ROwl0+g3quciQMMoFJLpefwKrIMd28A26LPf8J0WP/oDvI2gRj8LZ9glw71B7daaayMWkh5JRRpqTtqOW0De0Ucq4TpQ9HA36VuWMYJ5KglXj0LGKjdUTV9NuyXRujlBQ63Z56kPBN1HIADEu8x7YxZSpQ9UDBQ5qupU4nwiUUoHx250HDx8XpKb8+loNCUv18sn/fJ7+vdIffgw+mfoThNNPnbD5u3xxcXqST3Z/lVwGjRvQ3J5/zL5y/fT9Iro+HrUnq6uR3oWr64+Dvv9Hq5mMf3BZYPgqOHts1Y9EXnEu1vJFnDz0BNdobfnVJNbuKJwvanUbxEXGqXJuxymEtX7la4yzN6fbftsTDTJVyYqv+uAfAPXP0D+xlTg5wkBoYK/G5yhTZRKqbynkpGoajHAh8NXYjOsHPcmjWdUHo62FV1NsKaLN8rgUq2NjrCunyn4y+GDa0YUzG5vMh44HafV7nTPOt1u+6yHC2u+a+iMjZiu7ToN22243alte9l/4Vq6bCKmDASqccvsmdv6ddrBzn23NrfcMwDX8VzXa+04F9jE9yr6FLUYy/3DzXBaqa50FHJ1S6Re5bZsOQlAxvK9KWFc22nCn3vWbm+A8OtR6438vJiAbFVhku/gHU/8Gjm4pkyTqCxwqDXx53HWc7Nvmis5iTa3N8sKM3ZwtKOBseWJaoLw15LhGp1vBHSrZZ+5qIEuIjjp8QweNV/EVPpwmlFAI0RjpoSEPeSncRKZbY7AbiYnFItgCJFZBG99IABlcnP50UMZ5I9cBMJD1pZSpYQWWpBISNi3fiqEFXqHVgcArwlKpFgwDoQyPoGImc8iJtAjU/5/I9nZInlHQ6a0zI7CMAgkVSojNmI5930oN3MlzZfGUAA1lM5gTot9mFOFFj8cuW77lyinmVFseuiTyWo84EsmNDuFdkoCK1MgHFzYDaEEp7lXMZPxPmWc5mUENIHGEXOAxP8u/ul+4osUyl3dpzNzU/VqH/bdgr0BZN+BeXcv5uMsva9fZWzuI+UBld9nluHaBHfUp2xxQM6O3XZOoej9c9akGAsQGFzXk3/NpfyUvQrFMIMUl5e203Ds9XOx2dh6WkYigDdr+03JbJnXmCpfsiQjBlMERDcDBI0kDcyh4EBIClRk+hnNCVKmz8Sn8JUsIDlsFWRdXbWETWFb43u3hFK1Ov9cMpYwsO/Zlg4gt2yn2z7tOs1DGrOVBde3Btf/wB38C1BLAQIAABQAAgAIANiqXFIAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAAAAAAAAABkdW1teS9QSwECAAAUAAIACADYqlxS5eoUYMMEAAAgDwAAHAAAAAAAAAABAAAAAAAmAAAAUi0yMDYwNTE3NDA5NS0wNy1GRjAxLTEwLnhtbFBLBQYAAAAAAgACAH4AAAAjBQAAAAA=', 'FF01-10', 'La Nota de Credito numero FF01-10, ha sido aceptada');
INSERT INTO `notascredito` (`id`, `xml`, `hash`, `success`, `code`, `zip`, `numero`, `message`) VALUES
(11, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<CreditNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>+6A1ZGqyaabnbDvxXIoYDvzI1wY=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>v3GjiB3vqnbaIdw1gP9QHP2VIuktyIRxX+smWV4AQqHfg3VxS2G6hRneYthGrs08XB9kDC3lWDtsC7JRFhz2OPFb+uRlM4ABLj3Kz5hzp/J05EfwGJ11WTpmK4dOGJwxGn33FKtrptRH2oWUFBIoO1DB+IVLG5bhO7ECzNMJ/U/hcJSnmMADz8HLHLu17/etO7lSzev4HOLdvKSduFTUJUuZ8N0sAfsxtCmE2nL2NOA/ujc0UQXPLxNptg6+1dhoHGJpcnvPsLDRuY7tH3l+QNV6Jg4fN54hjkHn2mqHtb/uyKCaX1MPbePYy1MvVg/sLrZvPRyLOGrRUpg+wfsUGg==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGLDCCBBSgAwIBAgIIXn/yNYNbKk8wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAxNzMxNTJaFw00MjA4MTAxNzMxNTJaMHIxCzAJBgNVBAYTAlBFMUIwQAYDVQQKDDlFbnRpZGFkIGRlIENlcnRpZmljYWNpw7NuIE5hY2lvbmFsIHBhcmEgZWwgRXN0YWRvIFBlcnVhbm8xHzAdBgNVBAMMFkVDRVJORVAgUEVSVSBDQSBST09UIDMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC2vL2la6NIgUWwoyA7CdnqjuiVlYrp5/MX01RCXrn5tDvuobS/Afb2unu0oVRsw6jYcpDP0bNnaPuBhlaOFKhjbOVJvA3US+b+9Ek2cKekCzJyQLNWb6R/m2ggTGGGGITOGayNklsrMOvNPP8F/T48bxOnUDupGVMpuKLMzz9xASBF0DhofKOxC/eEuU/irr6dnmbFDtFFdrJr/4cGlnYiYerwPw4Knu4br6uJ6KfKXE1P5r7eoli4n3JxBhUi0NK/mMc8CypJkZXC+LZ2bv7nNGgZpVk0v4yen/uX5VkuIevMYPyNi2EengxwIJOSexZPBMITH37RqiGQ2NDsN1EopFqXpddwyMIJMClr4ZsVnQZhddOKLxZmPt1P/GPy8VM763LkKWnHueq842GQ2CWrUa0U8R8Y4iJRUn/qOlyJYdveDNfLufgF/5YML5UrcXjq+j6r54je02nY6dgZ3oI8CP9HaNRvsrFbRt9bnRlwVlXQr8/iFoyAyBnClhs0KpxGAy0v4pBB6OtL0yTp7NeBY1FMY8tFAQNP5HkZ3v684j2kJ/T3wPwfCQuQuLY1bztbp/bfxjZGkkrznqSLbOO/+tJUBeAeditx8H3d61RpAo1QNpXHLKIXJz6k5/bpYT4nQuUDkHZ0vv68j9SVEyd77lfMt0qWHV/yp3uEYZ0OAQIDAQABo4HFMIHCMBIGA1UdEwEB/wQIMAYBAf8CAQIwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwSQYIKwYBBQUHAQEEPTA7MDkGCCsGAQUFBzAChi1odHRwOi8vd3d3LnJlbmllYy5nb2IucGUvY3J0L3NoYTIvZWNlcm5lcC5jcnQwEQYDVR0gBAowCDAGBgRVHSAAMB0GA1UdDgQWBBQf6SkgYdIxQrXd/VIivt0Oz/JHhzAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAEQP8rU4dSIY9ZQts3a6/vFvb1hNvETmvxhx/DhI7GkWAuiXANVBL/x1jeDJnKmXaOThQWAzBCVbuyrD1LB+ptvOGB6Lti6MG1heGvOmFMgzprqH9J4AF8w2IfyfbgzCaTTOrGp88lS959h3mqOLmfcq3xR+MFAN7JGvWPcsbaLj8sFqYI1t1JN/hoZ3+X0Ilr3XW9QQMmdFG5TIz/yqAE9n9QM8wRsoB5uvXBGvU6CIzyIjzqnnO308V4eYgY1WL3iKOV7eYeumKQ1LnNMs5N27ziDs1oPkBeLhvTHy8Kq0765UHKHVMC3YdHH2zl/LD6ZuVlgXZlgAmx6EGzbz4PmqX6iDen3azI8ps5CnKYPPqOvqSYCLGTTZosfaOHhbgbQCCPNXU3xHn/5j+jnqVntoUXVJKjVK0/mTrn9+LOYwo/lEvpNxPwKWK5KFobAuXa4Y86/0WHb4jNlCzb//4VkrZ+/3Hu7X2QthAv42AlR63xgFXy3T/GVfLw8V0RlU+1eg4sNFgaFFH1qSPofN/28NhP6pm0aytIl+2g44xJ5J0BsAUxv6IpITHo65Y6sL91QRNF4i9N3xFXvdZQeyA5GNw1GeFtcWMQuTzqoOYSN6DipmDDO6Lny9Zj+eaxtfjGjQY0/kOoC6PaaTn7rkH0/ppG1XKiYi6GxecT9MUQQs</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>BB01-11</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON CATORCE CON 16/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>B001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>B001-1</cbc:ID><cbc:DocumentTypeCode>03</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:LegalMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">14.16</cbc:PayableAmount></cac:LegalMonetaryTotal><cac:CreditNoteLine><cbc:ID>1</cbc:ID><cbc:CreditedQuantity unitCode=\"NIU\">1</cbc:CreditedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">12.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">14.16</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">12</cbc:PriceAmount></cac:Price></cac:CreditNoteLine></CreditNote>\n', '+6A1ZGqyaabnbDvxXIoYDvzI1wY=', '1', '0', 'UEsDBBQAAgAIAOOrXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgA46tcUksyn3rBBAAAHQ8AABwAAABSLTIwNjA1MTc0MDk1LTA3LUJCMDEtMTEueG1stVfbcts2EH3PV2DomaZNKoOkbjYrKSNbcas2djyynaSPELmm0JAEDYCyla/vgqQoSqEnUtqM/QAtds+ePQsspMGbpzgiS5CKi2RoOce2RSDxRcCTcGjd3V60Tqw3oxcDJr1xmkbcZxodZ6BSkSggGJwoj8mhlcnEE0xx5SUsBuWpFHx+X/p72TzylL+AmHlPKmiCarlWiQZP+kC4cxHHInn7pCExZeBHhIREqw2oP/e/C/QM3f1GQPZ9gOMwlBAyDU2ggRpaC61Tj9LHx8fjx/axkCF1bdum9ilFn0Dx8GjtrQRLK/8ikTrGLWPPA82CQrKESKRArdEApfXuzt5VSqmvTYWlpmWCKz0a3PAwYTqTZc/34onnxoRBME3uxegFIYNzlogE9Yn4l1yjS9ALEZBxFArJ9SJ+Btahjm1gW/Dkt3ynkxx9RG8jqNHPojl2xXBvULuz5tqKhYQjqVhLLVjXcUvIGdyDxOsA5G42HVqWMaL5VrJE3QsZq8JQN30z7ZZE6+YELbVmX6Q+EHQfgRCQ7jIfTHgISh+oGCpyVNepwvnAogxG2U3wxzS4pne/jx2n/Tdwlj08zm79Fdx/7EiYqQ446iF4vVpMLi//vJDd1eoBHqafPjr911/OHh6d1Hn38M/7kMYXn88n6jK7yD69Hg+HA1rPYvpDqwbhUaPbZ61+IoqIV9eSL/Hmkc+wIi/PQLNrvKJ4vUHqlyQRmmTpqwKmFjX4C1Y55uBT1z6dMM2KlYkq7joiX+H1D4i/MZX4RUJEqOHvBudoU6UykDcgOYvqFgN8OHwtNscqcK+yeA7ycLSt6HqCNV26UYZWam10xHXzTKFfDx/aMKJwdnvTycjpOZ1u77TT67fd/oCW1mLX0JkYMV3bdVq223JPbm3by/9L18plE3HLUaAGt9yeu61fpx3swndrc8s9B3Adr+14dn/bucRmvlfTp6zFWG7ursa3teoqRyFX10zqVWHLl9MAZazemwrGtZ02/rmn3e4GiD4ftd4ozosJyFc1JsUO3fGkz5HDa8o1i6oCx1ozfxHnPTf7prkyYdHm9uZZccaOjnY0MLYiUUMQ/VYy2qDzlcBudexTl7TI2whPejzHR80XMUgfTzMJICIQcyUk7hE/i9PIbCcE7WZyYrEEhxCbR/jWBwJRplcX7z2SQ/6ciEB4xNpSqpLQIksWCYn71i+lsELv0Ooh4DtGUimWPEFCOZ9AxNznERfkniv/v5HsbZGcQciVlvlRGAeBBKVyYue84L4P5XahpPnSGAqkRrI5zmmxD3NQZPnTket2f4sKmjnFtkc+mKzGA79kYrMzbKdkuDIF4sHF3RBLcNp7FTOd7FNGvygjgBQbx8wBEv+7+P39xBcZlru6yebmpurVPuxPSvYGkP8A5id7MZ/k6X39LGNzHyEJQP6YWUYbE8zAB748IGfP7jp9LHr/nA0pJgIFRtf15F9zqT7lr0I5zDDF2ZnttBxn/VxsNraelnMR4Ju1/abkttxrAsqXPM2J4RRB0c0AIecSAnMoEiQkBSkz/UoWjCjTZ+ZDqlnACtg6yLq6egmbwrbG924JlWpN/oVkPOVo37MtvZbb7XftE6d3SFe2UtDmvtDmX7ejfwFQSwECAAAUAAIACADjq1xSAAAAAAIAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAAZHVtbXkvUEsBAgAAFAACAAgA46tcUksyn3rBBAAAHQ8AABwAAAAAAAAAAQAAAAAAJgAAAFItMjA2MDUxNzQwOTUtMDctQkIwMS0xMS54bWxQSwUGAAAAAAIAAgB+AAAAIQUAAAAA', 'BB01-11', 'La Nota de Credito numero BB01-11, ha sido aceptada'),
(12, '<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<DebitNote xmlns=\"urn:oasis:names:specification:ubl:schema:xsd:DebitNote-2\" xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\" xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"><ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent><ds:Signature Id=\"SignIMM\">\n  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/>\n    <ds:SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/>\n  <ds:Reference URI=\"\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><ds:DigestValue>ZoQ0idqotkvH4650f4Ana13v8SM=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>B6oq2QaIcibR9IPzVu0SF0wIJv1YKuHbIgvJz8CxLdCRuTpzVpwjdWkO5yyE+x40eEx18GJIijjT5lo55IX8Oal1tVzX2ecQF2D2YEA++HaCzI+svrynLj2fprTLiW+6RmfdvZCq+hUSOBsEDYxTfeEeBYrMYGEcG777tgQCbBAV4TMdiGwcc4OVGwzKbQsGhOWrBxqxJfwviA1ng5Dgh+6CTfJdEEXLFhgjS1U82Zs3Wp79KJkvoYLslGR7taYrShnGY87uww9R5N4kq5Y5HJLRcwTTF7jtFa1vlN8BEcqsKCk58HtG/ok5ai1nedq6k2LV/mQN3ySPmwWjHbUJkA==</ds:SignatureValue>\n<ds:KeyInfo><ds:X509Data><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>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</ds:X509Certificate><ds:X509Certificate>MIIGdDCCBFygAwIBAgIIBuVEi//Q7T0wDQYJKoZIhvcNAQENBQAwcjELMAkGA1UEBhMCUEUxQjBABgNVBAoMOUVudGlkYWQgZGUgQ2VydGlmaWNhY2nDs24gTmFjaW9uYWwgcGFyYSBlbCBFc3RhZG8gUGVydWFubzEfMB0GA1UEAwwWRUNFUk5FUCBQRVJVIENBIFJPT1QgMzAeFw0xNzA4MTAyMDMxNTlaFw0zMzA4MTAyMDMxNTlaMGExCzAJBgNVBAYTAlBFMTwwOgYDVQQKDDNSZWdpc3RybyBOYWNpb25hbCBkZSBJZGVudGlmaWNhY2nDs24geSBFc3RhZG8gQ2l2aWwxFDASBgNVBAMMC0VDRVAtUkVOSUVDMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApJvyMiRwB1BO0KMkFH9tkjCqnyF9ZkTMkQg3SIk+qxFWq8Bv4K1MaO0aWe4/5vdaRI2NW/E61C+q76bAAaR/nwfPTBPStBW6WKerwZ4w+2OFCF0UaioCJ6P1SRETsRYesNDFeU/FJD7+o7MTt1s3nxPzsqcOgiORXO7Zs8RmhRdLmhi+LOZHxx6xXngd7bpk/ustCb3XHKHJFjSdLED5EInAZ+JhTZsI8qvMqE5nV0+cBNCpvvAazFp4R9J2vH4W1Abr8xIXoxXhQXIxTjoJWDX0RgANBbv10NqHf6xOwCtJgALc2bzUzNZd6QhsiVe18kDJGjD34KvqTO8Oyk98gwKomzrkEavXA3LrP8aCxtxX9URugtSKdH9GRgu4zm8632A9X76MjkhdApvyQa7iA+s4JZWhN5QbGYTTDBWeYjktcbEnGyfX/o1zEOqnYsPqn8nS0O1b52pV6OYwYuRKhw1bD/flk0Z28CQI20sJM1LBXHgXtALE8n59/m/yElk7u71QZqGdCY2e2wi6H+7L7V9C7eOeJnf/5WD1oUa6F/yswj47Lelp4peVXZg7PJ3IGugCbBHtl42j04Je+/+8E2DJomVJl6oFlZzk38dIF00QaWGp6dv4L1PFVDRG5XkIIdF7GmLcbO5iY01/sRbhBruejx+VmtA2zwGOUlpfbwUCAwEAAaOCAR0wggEZMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUH+kpIGHSMUK13f1SIr7dDs/yR4cwPQYDVR0lBDYwNAYIKwYBBQUHAwIGCCsGAQUFBwMEBgorBgEEAYI3FAICBggrBgEFBQcDCQYIKwYBBQUHAwEwdAYDVR0fBG0wazAzoDGgL4YtaHR0cDovL2NybC5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMDSgMqAwhi5odHRwOi8vY3JsMi5yZW5pZWMuZ29iLnBlL2FybC9zaGEyL2VjZXJuZXAuY3JsMB0GA1UdDgQWBBQir/Nf7uFFfUzvfuPf0lJ8y857dTAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQENBQADggIBAGqyEZiEtBM/ZuQ/2UBxXHticPgnRMrW0p3KD+7JbiGrSTKvRUOczeqm4OwRP4j2+wFYAlTG1UtBz2F4rcY1nvycDXRw+Q7DXf6PopIbncPiYAziZuqw0DH0Dl5crFxoQ+AZhWJh+vmi2RLK2pJLHd7gAEYUGJmiAWXK5RN6b9rb6KA+N9bNvekA9QGNm7KnhZo5Fu4XNbp7FdlQE3IVBxZH3J6eiWtOal11SpZAP7eYBjDtay2jUWla0XrTE62WKhj6n+yBiowPLPSP/EW+DgAUw0fPDW8BKoXUiDsQVU1ewNC3FgwchuAM+a+E7+6OoOLomNQ1pTqT8QM7XTq1RW1c+x5fxlGnEnJ14UAC2nz1KWF6cDkXreh6C5jpOV9ZVQ9/nI05tyAWvENz0lKVNareI0TPbQACm6NGYay1wLCeZIXsy7bBll0EhdRhL8k4hrdDSeonS8+oJwHVVGRDRlGPF4aM61HDCxdi5Pon/XmIWqC6DMV/j97LVqjVOXeOmvrGPiWqBZu4jVmWktiJw1oaPPTM2BA+j/KJLN/xlm3O1ApEVrtbGlUqHDTxeurOBGvqZOJ5ulKGPOzyM1gB71U2pCJwn93W/gxVxCxpIhtCoVz/KdPSxz2ppIx/bYYWo6u9Fd+E8c6GUXH877/VRKVrm0pf2ntWnSjRjh5/6gY+</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature></ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions><cbc:UBLVersionID>2.1</cbc:UBLVersionID><cbc:CustomizationID>2.0</cbc:CustomizationID><cbc:ID>BB01-12</cbc:ID><cbc:IssueDate>2021-02-28</cbc:IssueDate><cbc:IssueTime>00:00:00</cbc:IssueTime><cbc:Note languageLocaleID=\"1000\"><![CDATA[SON CATORCE CON 16/100 SOLES]]></cbc:Note><cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode><cac:DiscrepancyResponse><cbc:ReferenceID>B001-1</cbc:ReferenceID><cbc:ResponseCode>01</cbc:ResponseCode><cbc:Description>PRUEBA</cbc:Description></cac:DiscrepancyResponse><cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>B001-1</cbc:ID><cbc:DocumentTypeCode>03</cbc:DocumentTypeCode></cac:InvoiceDocumentReference></cac:BillingReference><cac:Signature><cbc:ID>20605174095</cbc:ID><cac:SignatoryParty><cac:PartyIdentification><cbc:ID>20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[VVIAN FOODS S.A.C]]></cbc:Name></cac:PartyName></cac:SignatoryParty><cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#GREENTER-SIGN</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment></cac:Signature><cac:AccountingSupplierParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"6\">20605174095</cbc:ID></cac:PartyIdentification><cac:PartyName><cbc:Name><![CDATA[]]></cbc:Name></cac:PartyName><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VVIAN FOODS S.A.C]]></cbc:RegistrationName><cac:RegistrationAddress><cbc:ID/><cbc:AddressTypeCode>0000</cbc:AddressTypeCode><cbc:CityName/><cbc:CountrySubentity/><cbc:District/><cac:AddressLine><cbc:Line><![CDATA[AV. PARDO Y ALIAGA NÂ° 699 INT. 802]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty><cac:AccountingCustomerParty><cac:Party><cac:PartyIdentification><cbc:ID schemeID=\"1\">25750816</cbc:ID></cac:PartyIdentification><cac:PartyLegalEntity><cbc:RegistrationName><![CDATA[VICTOR HUGO JIMENEZ TORERO]]></cbc:RegistrationName><cac:RegistrationAddress><cac:AddressLine><cbc:Line><![CDATA[]]></cbc:Line></cac:AddressLine><cac:Country><cbc:IdentificationCode>PE</cbc:IdentificationCode></cac:Country></cac:RegistrationAddress></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:RequestedMonetaryTotal><cbc:PayableAmount currencyID=\"PEN\">14.16</cbc:PayableAmount></cac:RequestedMonetaryTotal><cac:DebitNoteLine><cbc:ID>1</cbc:ID><cbc:DebitedQuantity unitCode=\"NIU\">1</cbc:DebitedQuantity><cbc:LineExtensionAmount currencyID=\"PEN\">12.00</cbc:LineExtensionAmount><cac:PricingReference><cac:AlternativeConditionPrice><cbc:PriceAmount currencyID=\"PEN\">14.16</cbc:PriceAmount><cbc:PriceTypeCode>01</cbc:PriceTypeCode></cac:AlternativeConditionPrice></cac:PricingReference><cac:TaxTotal><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID=\"PEN\">12.00</cbc:TaxableAmount><cbc:TaxAmount currencyID=\"PEN\">2.16</cbc:TaxAmount><cac:TaxCategory><cbc:Percent>18</cbc:Percent><cbc:TaxExemptionReasonCode>10</cbc:TaxExemptionReasonCode><cac:TaxScheme><cbc:ID>1000</cbc:ID><cbc:Name>IGV</cbc:Name><cbc:TaxTypeCode>VAT</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal></cac:TaxTotal><cac:Item><cbc:Description><![CDATA[CHORIZO OXFORD 500GRS]]></cbc:Description><cac:SellersItemIdentification><cbc:ID>97506200600</cbc:ID></cac:SellersItemIdentification></cac:Item><cac:Price><cbc:PriceAmount currencyID=\"PEN\">12</cbc:PriceAmount></cac:Price></cac:DebitNoteLine></DebitNote>\n', 'ZoQ0idqotkvH4650f4Ana13v8SM=', '1', '0', 'UEsDBBQAAgAIAAquXFIAAAAAAgAAAAAAAAAGAAAAZHVtbXkvAwBQSwMEFAACAAgACq5cUhvPL6y/BAAAHA8AABwAAABSLTIwNjA1MTc0MDk1LTA4LUJCMDEtMTIueG1stVddd9o4EH3vr9BxztnutktkO0CIF+ghoUlo0myXj3ZfhS2MurbkSDL5+PU7so0x1DmF7vYkD2I0c+fOHWkE3XePcYRWVComeM9yjm0LUe6LgPGwZ82ml42O9a7/qkukN0iSiPlEg+OYqkRwRREEc+UR2bNSyT1BFFMeJzFVnkqozxaFv5fOI0/5SxoT71EFdVAN1yrQ6KM+EO5CxLHg7x815aYM+AiQlGu1AfXn/g+BnoO7XwtIfgxwEIaShkTTOtBA9ayl1omH8cPDw/HDybGQIXZt28b2GQafQLHwaO2tBElK/zyROoYtY88CzQJTvqKRSCi2+l2Q1pud35ZKqW9NuaWiJYeV7ncnLOREp7Lo+V484dyYMBqM+EL0XyHUvSBccNAnYs+ZRh+pXooADaJQSKaX8QuwDnZsA9ugj37Dd5r86At4G0GNfhbOsEuGe4PazTXXRiwkPZKKNNSStBy3gBzTBZVwHSiajUc9yzJGME8l4WohZKxyQ9X03bRbEq2bEzTUmn2e+kDQfQQCQLzLvDtkIVX6QMVAkaOqTiXOZxKltH+/sM+vW8+XH8LFLZvN2kmzHd9cjeLxYnXFsDNarj6c3t+kAZUPI/7Ff3sySifNv9rUXqm3WnTCyyn5OvloX10/R+71/WSimi4jD71eF1ezmP7gskFw1PD2WaueiDzizSfJVnDz0D/0Cb0+p5p8gisK15tK/RpxoVGavMlhKlHdG/qUYXb/btlnQ6JJvjJR+V0H5Du4/gHyN6YCP08ICBX83eAMbaRUSuWESkaiqsUAHw5fic2wcty7NJ5TeTjaVnQ1wZou3iiDS7U2OsK6fqbgb4cPrhlRMLu90bDvtJ1m69Ru2fZZp9XFhTXfNXSGRkzXdp2G7TbcztS2vey/cC1dNhFTBgLVuGX2zG39Ou1g575bm1vuGYDreM2O59rbzgU28b2KPkUtxjKZ3Q2mlepKRyGfPhGpn3JbthwFIGP53pQwru2cwJ971qrIhF+OWm/k58UEZKsKk3wH73jil8jBNWWaRGWBA62Jv4yznpt901zJSbS5vVlWmLH9ox0NjC1PVBOEv5cM1+h8J6BbTfvMRQ30PoKTHs/hUfNFTKUPpxkFNEI0ZkpI2EN+GieR2eYI7GZyQrEIhhCZR/DWBwJQRneXf3oog/yVi0B4yNpSqpTQQisSCQn71m+FsELv0GoD4C1BiRQrxoFQxicQMfNZxARaMOX/N5LtLZJjGjKlZXYUBkEgqVIZsQuWc9+H8kmupPnSGAqghtI5zGmxD3Oq0OqXI9dt/RHlNDOKJx76bLIaD/iSCc1OoZ2SwMoUCAcXdkMowTnZq5jRcJ8yTvMyAppA44g5QOJ/F/90P/FFCuU+TdK5uan6aR/2nYK9AWQ/gXlnL+bDLL2vX2Rs7iPl8PT/nFmGaxOMqU/Z6oCcbbvlnELR++esSTEUIDC4rif/mkv5KXsVimEGKc7PbafhuOvnYrOx9bRciADerO03JbNlXkOqfMmSjBhMERDdDBA0pHNzJjjwkQIViX5HS4KUaTPxaaJJQHLUKsa6uGoFm7q2pvduBaVodf65YixhYN+zK+2G2zpt2R2nfUhTtlLg+rbg+h+3/X8BUEsBAgAAFAACAAgACq5cUgAAAAACAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAGR1bW15L1BLAQIAABQAAgAIAAquXFIbzy+svwQAABwPAAAcAAAAAAAAAAEAAAAAACYAAABSLTIwNjA1MTc0MDk1LTA4LUJCMDEtMTIueG1sUEsFBgAAAAACAAIAfgAAAB8FAAAAAA==', 'BB01-12', 'La Nota de Debito numero BB01-12, ha sido aceptada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nota_detalle`
--

CREATE TABLE `nota_detalle` (
  `id` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` varchar(50) NOT NULL,
  `unidad_medida` varchar(5) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `peso` decimal(10,2) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `descuento` int(2) DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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

--
-- Volcado de datos para la tabla `pma__navigationhiding`
--

INSERT INTO `pma__navigationhiding` (`username`, `item_name`, `item_type`, `db_name`, `table_name`) VALUES
('marife', 'ventas', 'table', 'frdash', '');

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
('marife', '[{\"db\":\"frdash\",\"table\":\"nota_detalle\"},{\"db\":\"frdash\",\"table\":\"venta_detalle\"},{\"db\":\"frdash\",\"table\":\"notas\"},{\"db\":\"frdash\",\"table\":\"boletas\"},{\"db\":\"frdash\",\"table\":\"ventas\"},{\"db\":\"frdashdev\",\"table\":\"notas\"},{\"db\":\"frdashdev\",\"table\":\"notascredito\"},{\"db\":\"frdash\",\"table\":\"notascredito\"},{\"db\":\"frdashdev\",\"table\":\"nota_detalle\"},{\"db\":\"frdash\",\"table\":\"inventario\"}]');

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
('marife', 'frdash', 'compras', '{\"sorted_col\":\"`id_proveedor`  DESC\"}', '2021-01-27 20:03:19'),
('marife', 'frdash', 'detalle_compras', '{\"sorted_col\":\"`id_compra`  DESC\"}', '2021-02-11 04:48:41'),
('marife', 'frdash', 'dosimetria', '{\"sorted_col\":\"`dosimetria`.`id`  DESC\"}', '2021-02-13 15:41:51'),
('marife', 'frdash', 'inventario', '{\"sorted_col\":\"`id`  DESC\"}', '2021-02-27 15:44:04'),
('marife', 'frdash', 'productos', '{\"sorted_col\":\"`id`  ASC\"}', '2021-02-23 17:35:27'),
('marife', 'frdash', 'ventas', '{\"sorted_col\":\"`id`  DESC\"}', '2021-02-27 17:07:23');

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
  `peso` decimal(10,2) NOT NULL,
  `costo` decimal(10,2) NOT NULL,
  `IGV` decimal(10,2) NOT NULL DEFAULT '0.00',
  `precio_sugerido` decimal(10,2) NOT NULL DEFAULT '0.00',
  `id_categoria` int(11) NOT NULL,
  `id_subcategoria` int(11) NOT NULL,
  `usuario` varchar(30) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo`, `nombre`, `peso`, `costo`, `IGV`, `precio_sugerido`, `id_categoria`, `id_subcategoria`, `usuario`, `fecha_registro`) VALUES
(4, '97506200600', 'CHORIZO OXFORD 500GRS', '500.00', '15.68', '2.43', '22.76', 1, 1, 'ana', '2021-02-06 11:06:45'),
(6, '97506200250', 'CHORIZO OXFORD COCKTAIL 250GRS', '250.00', '7.32', '1.12', '10.45', 1, 1, 'ana', '2021-02-06 11:06:45'),
(8, '97505200250', 'CHORIZO FINAS HIERBAS COCKTAIL 250GRS', '250.00', '7.67', '1.17', '10.96', 1, 1, 'ana', '2021-02-06 11:06:45'),
(9, '97505200400', 'CHORIZO FINAS HIERBAS 500GRS', '500.00', '11.80', '1.80', '16.86', 1, 1, 'ana', '2021-02-06 11:06:45'),
(12, '97519200600', 'CHORIZO SWEET SPICY 500GRS', '500.00', '19.00', '3.42', '22.42', 1, 1, 'ana', '2021-02-06 11:06:45'),
(13, '88006200240', 'FRANKFURTER 240GRS', '240.00', '7.32', '1.12', '10.45', 1, 2, 'ana', '2021-02-06 11:06:45'),
(14, '88006200250', 'FRANKFURTER COCKTAIL 250GRS', '250.00', '7.73', '1.18', '11.04', 1, 2, 'ana', '2021-02-06 11:06:45'),
(15, '88006200450', 'FRANKFURTER MUNICIPAL 450GRS', '450.00', '13.69', '2.09', '19.55', 1, 2, 'ana', '2021-02-06 11:06:45'),
(16, '88006201000', 'FRANKFURTER X 1KG', '1000.00', '27.14', '4.14', '38.77', 1, 2, 'ana', '2021-02-06 11:06:45'),
(17, '88006201001', 'FRANKFURTER GASTRONOMICO X1KG', '1000.00', '19.47', '2.97', '27.81', 1, 2, 'ana', '2021-02-06 11:06:45'),
(18, '88006202000', 'FRANKFURTER GASTRONOMICO X 2KG', '2000.00', '37.76', '5.76', '53.94', 1, 2, 'ana', '2021-02-06 11:06:45'),
(19, '88007200250', 'VIENESA 250GRS', '250.00', '5.31', '0.81', '7.59', 1, 2, 'ana', '2021-02-06 11:06:45'),
(24, '95011200240', 'MORCILLA 240 GRS', '240.00', '5.31', '0.81', '7.59', 1, 3, 'ana', '2021-02-06 11:06:45'),
(25, '95011200250', 'MORCILLA COCKTAIL 250GRS', '250.00', '5.90', '0.90', '8.43', 1, 3, 'admin', '2021-02-06 11:06:45'),
(27, '66660000200', 'BONDIOLA AHUMADA  X200GRS', '200.00', '8.85', '1.35', '12.64', 1, 3, 'admin', '2021-02-06 11:06:45'),
(28, '66660000500', 'BONDIOLA AHUMADA X500GRS', '500.00', '18.29', '2.79', '26.13', 1, 3, 'ana', '2021-02-06 11:06:45'),
(29, '77700000001', 'TOCINO AHUMADO NATURAL PZ X KILO', '1000.00', '36.58', '5.58', '52.26', 1, 3, 'ana', '2021-02-06 11:06:45'),
(30, '77700000200', 'TOCINO AHUMADO NATURAL 200GRS', '200.00', '9.44', '1.44', '13.49', 1, 3, 'ana', '2021-02-06 11:06:45'),
(31, '77700000500', 'TOCINO AHUMADO NATURAL 500GRS', '500.00', '20.53', '3.13', '29.33', 1, 3, 'ana', '2021-02-06 11:06:45'),
(32, '97510200250', 'CHISTORRA HUACHANA 250GRS', '250.00', '10.62', '1.62', '15.17', 1, 3, 'ana', '2021-02-06 11:06:45'),
(33, '97510200350', 'LONGANIZA HUACHANA PZ', '350.00', '6.30', '1.13', '10.62', 1, 3, 'ana', '2021-02-06 11:06:45'),
(34, '64015203000', 'JAMON PIZZERO MOLDE X KILO', '1000.00', '21.24', '3.24', '30.34', 1, 4, 'ana', '2021-02-06 11:06:45'),
(36, '64015200500', 'JAMON PIZZERO X500G', '500.00', '11.21', '1.71', '16.01', 1, 4, 'ana', '2021-02-06 11:06:45'),
(37, '64016205000', 'JAMON INGLES MOLDE X KILO', '1000.00', '35.58', '5.43', '50.82', 1, 4, 'ana', '2021-02-06 11:06:45'),
(38, '64016200250', 'JAMON INGLES X300GRS', '300.00', '12.74', '1.62', '18.21', 1, 4, 'ana', '2021-02-06 11:06:45'),
(40, '64021203000', 'JAMON DEL PAIS MOLDE X KILO', '1000.00', '33.50', '6.03', '56.47', 1, 4, 'ana', '2021-02-06 11:06:45'),
(43, '88800000002', 'LOMO AHUMADO ARTESANAL PZ X KILO', '1000.00', '32.00', '5.76', '53.94', 1, 3, 'ana', '2021-02-06 11:06:45'),
(44, '88800000250', 'LOMO AHUMADO  ARTESANAL LONJEADO 250GRS', '250.00', '11.21', '1.71', '16.01', 1, 3, 'ana', '2021-02-06 11:06:45'),
(45, '99900000001', 'JAMON  LA NONNA MOLDE X KILO', '1000.00', '35.40', '5.40', '50.57', 1, 4, 'ana', '2021-02-06 11:06:45'),
(46, '99900000250', 'JAMON LA NONNA X 250GRS', '250.00', '10.62', '1.62', '15.17', 1, 4, 'ana', '2021-02-06 11:06:45'),
(49, '11110000001', 'JAMON \"EL TATA\" X KILO', '1000.00', '40.12', '6.12', '57.31', 1, 4, 'ana', '2021-02-06 11:06:45'),
(50, '11110000250', 'JAMON \"EL TATA\" X 300GRS', '300.00', '14.16', '1.80', '20.23', 1, 4, 'ana', '2021-02-06 11:06:45'),
(52, '11120000001', 'JAMON TATA A LAS FINAS HIERBAS X KILO', '1000.00', '44.84', '6.84', '64.06', 1, 4, 'ana', '2021-02-06 11:06:45'),
(54, '11120000500', 'JAMON TATA A LAS FINAS HIERBAS 500GR', '500.00', '21.00', '3.78', '35.40', 1, 4, 'ana', '2021-02-06 11:06:45'),
(55, '12120001000', 'QUESO EDAM ARGENTINO MOLDE  X KILO', '1000.00', '34.75', '6.25', '58.57', 4, 6, 'ana', '2021-02-06 11:06:45'),
(56, '12120000300', 'QUESO EDAM ARGENTINO X 300GRS', '300.00', '10.38', '1.87', '17.50', 4, 6, 'ana', '2021-02-06 11:06:45'),
(57, '12130001000', 'QUESO EDAM HOLANDES MOLDE X KILO', '1000.00', '35.59', '6.41', '60.00', 4, 6, 'ana', '2021-02-06 11:06:45'),
(58, '12130000300', 'QUESO EDAM HOLANDES X 300GRS', '300.00', '10.59', '1.91', '17.86', 4, 6, 'ana', '2021-02-06 11:06:45'),
(60, '14140000500', 'QUESO MOZZARELLA X 500G', '500.00', '17.80', '3.20', '30.00', 4, 6, 'ana', '2021-02-06 11:06:45'),
(63, '19190001640', 'SANDWICH FRANZ', '0.00', '8.30', '1.49', '14.00', 1, 2, 'ana', '2021-02-06 11:06:45'),
(64, '19190001660', 'SANDWICH LA NONNA', '0.00', '8.30', '1.49', '14.00', 1, 3, 'ana', '2021-02-06 11:06:45'),
(69, '18180001414', 'FUGAZZA GRANDE', '0.00', '11.86', '2.14', '20.00', 1, 3, 'ana', '2021-02-06 11:06:45'),
(73, '13130000678', 'SALCHICHA SICILIANA 450GR', '450.00', '29.66', '5.34', '50.00', 1, 2, 'ana', '2021-02-06 11:06:45'),
(80, '97519200250', 'CHORIZO   SWEET SPICY COCKTAIL 250GRS', '250.00', '10.03', '0.00', '13.33', 1, 1, 'ana', '2021-02-06 11:06:45'),
(81, '0123456789', 'PEPPERONI', '1000.00', '24.00', '0.00', '27.12', 1, 4, 'ana', '2021-02-09 21:33:43'),
(84, '98529900500', 'CHORIZO DULCE FRANZ X 500GR', '500.00', '16.02', '0.00', '0.00', 1, 3, 'ana', '2021-02-23 11:55:31'),
(85, '98519800500', 'CHORIZO F.HIERBAS FRANZ X 500GR', '500.00', '13.14', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 11:57:17'),
(86, '98599900500', 'CHORIZO AHUMADO X 500 GR', '500.00', '15.68', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 11:58:20'),
(89, '64021200250', 'JAMON DEL PAIS X250 GR', '250.00', '9.50', '0.00', '0.00', 1, 4, 'admin', '2021-02-23 12:14:43'),
(91, '1065', 'JAMON PIZZERO X 200 GR', '200.00', '2.54', '0.00', '0.00', 1, 4, 'ana', '2021-02-23 12:24:51'),
(96, '1026', 'JAMON INGLES X 200 GR', '200.00', '6.44', '0.00', '0.00', 1, 4, 'ana', '2021-02-23 12:28:06'),
(97, '1069', 'Chorizo finas hierbas x 7 unidades 1KG', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:46:02'),
(98, '1070', 'Chorizo F. hierbas Franz x 7 unidades 1KG', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:46:49'),
(99, '1071', 'Chorizo Oxford x 7 unidades 1KG', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:47:29'),
(100, '1072', 'Chorizo Parrillero Ahumado x 7 unidades 1KG', '1000.00', '38.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:48:04'),
(101, '1073', 'Morcilla Granel x7 unid X 1 kg', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:48:54'),
(102, '1074', 'Chistorra Huachana x 7 unid x 1 kg ', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-23 12:49:56'),
(103, '1054', 'CHORIZO OXFORD x 1kg PRECOCIDO', '1000.00', '33.00', '0.00', '0.00', 1, 1, 'ana', '2021-02-24 15:05:27');

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
  `distrito` varchar(50) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sub_categorias`
--

CREATE TABLE `sub_categorias` (
  `id` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sub_categorias`
--

INSERT INTO `sub_categorias` (`id`, `id_categoria`, `nombre`, `fecha_registro`) VALUES
(1, 1, 'Chorizos', '2021-02-06 11:10:00'),
(2, 1, 'Salchichas', '2021-02-06 11:10:00'),
(3, 1, 'Especiales', '2021-02-06 11:10:00'),
(4, 1, 'Jamones', '2021-02-06 11:10:00'),
(5, 3, 'Galletas General', '2021-02-06 11:10:00'),
(6, 4, 'Quesos en General', '2021-02-21 22:24:27');

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
('2', 'noemi', '123', 'ADMINISTRADOR', 'logo-franz.png'),
('3', 'ana', '123', 'administrador', 'logo-franz.png'),
('4', 'yohalis', '123', 'administrador', 'logo-franz.png');

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
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`id`, `nombre`, `apellidos`, `dni`, `razon_social`, `ruc`, `fecha_registro`) VALUES
(1, 'Francisco', 'De la Villa', '10219082', '--', '0', '2021-02-10 16:41:13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id` int(11) NOT NULL,
  `id_usuario` varchar(10) DEFAULT NULL,
  `id_vendedor` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `monto_igv` decimal(10,2) NOT NULL,
  `valor_neto` decimal(10,2) NOT NULL,
  `valor_total` decimal(10,2) DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `comprobante` varchar(15) NOT NULL,
  `nro_comprobante` varchar(100) NOT NULL,
  `fecha` datetime NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id`, `id_usuario`, `id_vendedor`, `id_cliente`, `igv`, `monto_igv`, `valor_neto`, `valor_total`, `estado`, `comprobante`, `nro_comprobante`, `fecha`, `fecha_registro`) VALUES
(1, '1', 1, 1, '0.18', '1.80', '10.00', '11.80', '1', 'Boleta', 'B0011', '2021-02-27 00:00:00', '2021-02-28 10:47:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

CREATE TABLE `venta_detalle` (
  `id` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `unidad_medida` varchar(5) NOT NULL,
  `cantidad` decimal(10,4) NOT NULL,
  `peso` decimal(10,2) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `descuento` int(2) DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `id_venta`, `id_producto`, `unidad_medida`, `cantidad`, `peso`, `precio`, `descuento`, `subtotal`, `fecha_registro`) VALUES
(2, 1, 55, 'KGM', '1.0000', '0.00', '10.00', NULL, '10.00', '2021-02-28 10:47:30');

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
,`num_comprobante` varchar(40)
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
-- Indices de la tabla `boletas`
--
ALTER TABLE `boletas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fac_index` (`id`);

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
-- Indices de la tabla `dosimetria`
--
ALTER TABLE `dosimetria`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `dosimetria_movimientos`
--
ALTER TABLE `dosimetria_movimientos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `empresas`
--
ALTER TABLE `empresas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `num_documento` (`num_documento`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fac_index` (`id`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `notas`
--
ALTER TABLE `notas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `notascredito`
--
ALTER TABLE `notascredito`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `nota_detalle`
--
ALTER TABLE `nota_detalle`
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
-- Indices de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_venta` (`id_venta`);

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
-- AUTO_INCREMENT de la tabla `boletas`
--
ALTER TABLE `boletas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `detalle_productos`
--
ALTER TABLE `detalle_productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `dosimetria`
--
ALTER TABLE `dosimetria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT de la tabla `dosimetria_movimientos`
--
ALTER TABLE `dosimetria_movimientos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `empresas`
--
ALTER TABLE `empresas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;
--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `notas`
--
ALTER TABLE `notas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `notascredito`
--
ALTER TABLE `notascredito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT de la tabla `nota_detalle`
--
ALTER TABLE `nota_detalle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;
--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `sub_categorias`
--
ALTER TABLE `sub_categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
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

--
-- Filtros para la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD CONSTRAINT `venta_detalle_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `venta_detalle_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
