export class Company {
    constructor(
        public ruc: string,
        public razonSocial: string,
        public address:{direccion: string}
    ){}
}