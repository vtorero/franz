import { Transportista } from "./transportista";

export class Envio {
    constructor(
    public modTraslado:string,
    public codTraslado:string,
    public desTraslado:string,
    public fecTraslado:string,
    public codPuerto:string,
    public indTransbordo:string,
    public pesoTotal:number,
    public undPesoTotal:string,
    public numBultos :number,
    public ubigueo_partida:string,
    public direccion_partida:string,
    public ubigueo_llegada:string,
    public direccion_llegada:string,
    public transportista:Transportista

    ){}
}