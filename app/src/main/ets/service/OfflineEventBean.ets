export class OfflineEventBean {
  public static OFFLINE_REASON_LOGOUT_CODE:number = -1;
  public static OFFLINE_REASON_KICKOUT_CODE:number = -2;
  public static OFFLINE_REASON_ERROR_CODE:number = -3;

  public code:number;
  public reason:string;

  constructor(code: number, reason: string) {
    this.code = code;
    this.reason = reason;
  }

}