import { GWMsgBean } from "gwsdptt_sdk";

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

export class ChatTime {
  public id:string = 'time';
  public time:number = 0;

  constructor(time: number) {
    this.time = time;
  }
}

export class ChatFileSelectParam {
  public filepath:string;
  public filetype:number;
  public copy:boolean;

  constructor(filepath: string, filetype: number, copy: boolean) {
    this.filepath = filepath;
    this.filetype = filetype;
    this.copy = copy;
  }
}

@Sendable
export class ChatFileUploadParam {
  public filepath:string;
  public filetype:number;
  public filepathThumb:string;

  constructor(filepath: string, filetype: number, filepathThumb: string) {
    this.filepath = filepath;
    this.filetype = filetype;
    this.filepathThumb = filepathThumb;
  }


}

export class ChatFileMsgParam {

  public static VIDEO_FILE_TYPE:number = 0;
  public static PHOTO_FILE_TYPE:number = 1;
  public static VOICE_FILE_TYPE:number = 2;

  public filepath:string;
  public filetype:number;
  public filepathThumb:string;
  public msg:GWMsgBean;

  constructor(filepath: string, filetype: number, filepathThumb: string, msg: GWMsgBean) {
    this.filepath = filepath;
    this.filetype = filetype;
    this.filepathThumb = filepathThumb;
    this.msg = msg;
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