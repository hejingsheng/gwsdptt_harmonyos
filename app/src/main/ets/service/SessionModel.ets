export class Session {
  public id: number = 0;
  public type: number = 0;
  public name: string = '';
  public unread: number = 0;
  public lastmsg: string = '';
  public lastmsgts: string = '';

  constructor(id: number, type: number, name: string, unread: number, lastmsg: string, lastmsgts: string) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.unread = unread;
    this.lastmsg = lastmsg;
    this.lastmsgts = lastmsgts;
  }

}