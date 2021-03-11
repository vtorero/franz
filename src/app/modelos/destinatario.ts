export class Destinatario {
    constructor(
        public tipoDoc: string,
        public numDoc: string,
        public rznSocial: string,
        public address: {direccion: string}
        ){}
}
