import { Boletadetalle } from "./boletadetalle";
export class Boleta {
    constructor(
        public tipoOperacion:string,
        public tipoDoc:string,
        public serie:string,
        public correlativo:string,
        public fechaEmision:string,
        public tipoMoneda:string,
        public cliente:Array<Boletadetalle>,
        public company:Array<Boletadetalle>,
            public mtoOperGravadas: number,
            public mtoIGV:number,
            public totalImpuestos:number,
            public valorVenta:number,
            public mtoImpVenta:number,
            public ublVersion: string,
            public details:Array<Boletadetalle>,
            public legends: Array<Boletadetalle>
        ){}
}

