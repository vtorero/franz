export class Inventario {
        constructor(
        public id:number,
        public id_producto:number,
        public granel :number,
        public cantidad:number,
        public peso:number,
        public merma:number,
        public estado:number,
        public ciclo:number,
        public id_usuario:number,
        public presentacion:string,
        public observacion:string,
        public fecha_produccion:string,
        public fecha_vencimiento:string,
        public nombre:string
        ){}
}
