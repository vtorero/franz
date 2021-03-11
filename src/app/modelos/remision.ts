import { Company } from "./Boleta/company";
import { Details } from "./Boleta/details";
import { Destinatario } from "./destinatario";
import { Envio } from "./envio";

export class Remision {
    constructor(
        public tipoDoc:string,
        public serie:string,
        public correlativo:string,
        public destinatario:Destinatario,
        public nro_doc_transportista:string,
        public nombre_transportista:string,
        public nro_placa:string,
        public motivo:string,
        public fechaEmision:any,
        public company:Company,
        public bultos:number,
        public peso:number,
        public envio:Envio,
        public details:Array<Details>,
        public observacion:string
        ){}
}

