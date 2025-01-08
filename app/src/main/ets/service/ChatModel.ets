export class ChatParam {
  public convId:number = 0;
  public convType:number = 0;
  public convNm:string = '';

  constructor(convId: number, convType: number, convNm: string) {
    this.convId = convId;
    this.convType = convType;
    this.convNm = convNm;
  }
}

export class ChatMsg {
  public id:number = 0;
  public senderId:string = '';
  public senderNm:string = '';
  public senderType:number = 0;
  public msgType:number = 0;
  public content:string = '';
  public url:string = '';
  public thumburl:string = '';
  public playtime:number = 0;
  public time:number = 0;

  constructor(id:number, senderId: string, senderNm: string, senderType: number, msgType: number, content: string, url: string,
    thumburl: string, playtime: number, time: number) {
    this.id = id;
    this.senderId = senderId;
    this.senderNm = senderNm;
    this.senderType = senderType;
    this.msgType = msgType;
    this.content = content;
    this.url = url;
    this.thumburl = thumburl;
    this.playtime = playtime;
    this.time = time;
  }


}