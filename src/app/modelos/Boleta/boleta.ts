import { Client } from "./client";
import { Company } from "./company";
import { Details } from "./details";
export class Boleta {
    constructor(
        public tipoOperacion:string,
        public tipoDoc:string,
        public serie:string,
        public correlativo:string,
        public fechaEmision:Date,
        public tipoMoneda:string,
        public client:Client,
        public company:Company,
        public mtoOperGravadas: number,
        public mtoIGV:number,
        public totalImpuestos:number,
        public valorVenta:number,
        public mtoImpVenta:number,
        public mtoOperExoneradas:number,
        public ublVersion: string,
        public details:Array<Details>,
        public legends:[{
            code: string,
            value: string
            }]
        ){}
}

