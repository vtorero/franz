export class Inventario {
        constructor(
        public id:number,
        public id_producto:number,
        public presentacion:string,
        public unidad:string,
        public cantidad:number,
        public observacion:string,
        public fecha_produccion:string,
        public estado:number,
        public ciclo:number,
        public id_usuario:number,
        public nombre:string
        ){}
}
