import { DetalleCompra } from "./detalleCompra";

export class Compra {
    constructor(
        public comprobante:string,
        public num_comprobante:string,
        public descripcion:string,
        public fecha:Date,
        public id_proveedor:string,
        public razon_social :string,
        public id_usuario:string,
        public detalleCompra:Array<DetalleCompra>,
        ){}
}
