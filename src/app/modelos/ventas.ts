import { DetalleVenta } from "./detalleVenta";
export class Venta {
    constructor(
        public id:number,
        public id_usuario:string,
        public id_vendedor:number,
        public cliente:any,
        public	estado:number,
        public comprobante:string,
        public fecha:string,
        public valor_total:number,
        public detalleVenta:Array<DetalleVenta>,
        ){}
}