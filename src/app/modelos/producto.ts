export class Producto {
    constructor(
        public codigo:string,
        public nombre:string,
        public nombrecategoria:string,
        public costo: number,
        public igv : number,
        public precio:number,
        public categoria:number
        
    ){}
}
