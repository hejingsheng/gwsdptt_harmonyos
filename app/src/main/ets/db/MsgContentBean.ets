export class MsgContentBean {
  public id:number;
  public loginUid:string;
  public convId:number;
  public convType:number;
  public senderId:string;
  public senderNm:string;
  public senderType:number;
  public recvId:string;
  public recvNm:string;
  public recvType:number;
  public msgType:number;
  public content:string;
  public url:string;
  public thumburl:string;
  public playtime:number;
  public time:number;

  constructor(id: number,loginUid: string, convId: number, convType: number, senderId: string, senderNm: string,
    senderType: number, recvId: string, recvNm: string, recvType: number, msgType: number, content: string, url: string,
    thumburl: string, playtime: number, time: number) {
    this.id = id;
    this.loginUid = loginUid;
    this.convId = convId;
    this.convType = convType;
    this.senderId = senderId;
    this.senderNm = senderNm;
    this.senderType = senderType;
    this.recvId = recvId;
    this.recvNm = recvNm;
    this.recvType = recvType;
    this.msgType = msgType;
    this.content = content;
    this.url = url;
    this.thumburl = thumburl;
    this.playtime = playtime;
    this.time = time;
  }

}