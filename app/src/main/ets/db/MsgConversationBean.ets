@Observed
export class MsgConversationBean {
  public id:number;
  public loginUid:string;
  public convId:number;
  public convType:number;
  public convNm:string;
  public msgCnt:number;
  public msgUnReadCnt:number;
  public lastMsgId:number;
  public lastMsgSenderNm:string;
  public lastMsgType:number;
  public lastMsgContent:string;
  public lastMsgTime:number;

  constructor(id:number, loginUid: string, convId: number, convType: number, convNm: string, msgCnt: number, msgUnReadCnt: number,
    lastMsgId: number, lastMsgSenderNm: string, lastMsgType: number, lastMsgContent: string, lastMsgTime: number) {
    this.id = id;
    this.loginUid = loginUid;
    this.convId = convId;
    this.convType = convType;
    this.convNm = convNm;
    this.msgCnt = msgCnt;
    this.msgUnReadCnt = msgUnReadCnt;
    this.lastMsgId = lastMsgId;
    this.lastMsgSenderNm = lastMsgSenderNm;
    this.lastMsgType = lastMsgType;
    this.lastMsgContent = lastMsgContent;
    this.lastMsgTime = lastMsgTime;
  }

}