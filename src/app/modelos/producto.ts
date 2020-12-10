export class Producto {
    constructor(
        public codigo:string,
        public nombre:string,
        public costo: number,
        public igv : number,
        public precio:number,
        public categoria:number
    ){}
}
