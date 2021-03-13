import { Company } from "./Boleta/company";
import { Destinatario } from "./destinatario";
import { Envio } from "./envio";
import { Guiadetalle } from "./guiadetalle";

export class Remision {
    constructor(
        public tipoDoc:string,
        public serie:string,
        public correlativo:any,
        public destinatario:Destinatario,
        public fechaemision:any,
        public company:Company,
        public envio:Envio,
        public details:Array<Guiadetalle>,
        public observacion:string,
        public usuario :string
        ){}
}

