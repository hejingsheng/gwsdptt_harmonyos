export class NotifiDataBean {

  public static NOTIFI_TYPE_MSG = 0;
  public static NOTIFI_TYPE_AUDIO_CALL = 1;
  public static NOTIFI_TYPE_VIDEO_CALL = 2;
  public static NOTIFI_TYPE_VIDEO_PULL = 3;
  public static NOTIFI_TYPE_VIDEO_MEETING = 4;
  public static NOTIFI_TYPE_CALL_END = 5;
  private _sendNm: string = '';

  public set sendNm(value: string) {
    this._sendNm = value;
  }

  public get sendNm(): string {
    return this._sendNm;
  }

  private _recvType: number = 0;  // user msg or group msg

  public set recvType(value: number) {
    this._recvType = value;
  }

  public get recvType(): number {
    return this._recvType;
  }

  private _recvNm: string = '';

  public set recvNm(value: string) {
    this._recvNm = value;
  }

  public get recvNm(): string {
    return this._recvNm;
  }

  private _recvId: number = 0;

  public set recvId(value: number) {
    this._recvId = value;
  }

  public get recvId(): number {
    return this._recvId;
  }

  private _msgType: number = 0;

  public set msgType(value: number) {
    this._msgType = value;
  }

  public get msgType(): number {
    return this._msgType;
  }

  private _content: string = '';

  public set content(value: string) {
    this._content = value;
  }

  public get content(): string {
    return this._content;
  }

  private _recvIdStr: string = '';

  public set recvIdStr(value: string) {
    this._recvIdStr = value;
  }

  public get recvIdStr(): string {
    return this._recvIdStr;
  }

  private _record: boolean = false;

  public set record(value: boolean) {
    this._record = value;
  }

  public get record(): boolean {
    return this._record;
  }

  private _type: number = 0; // 0 msg   1 audio call request  2 video call request

  public set type(value: number) {
    this._type = value;
  }

  public get type(): number {
    return this._type;
  }

  private _forceNotice: boolean = false;

  public set forceNotice(value: boolean) {
    this._forceNotice = value;
  }

  public get forceNotice(): boolean {
    return this._forceNotice;
  }

  constructor() {
  }

}