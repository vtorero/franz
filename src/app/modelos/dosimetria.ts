export class Categoria {
    constructor(
        public id:number,
        public codigo:string,
        public descripcion:string,
        public inventario_inicial:number,
        public fecha_registro:string,
        public id_usuario:number,
        ){}
}
