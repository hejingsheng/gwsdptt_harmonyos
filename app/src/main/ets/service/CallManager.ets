import { hilog } from "@kit.PerformanceAnalysisKit";
import AppAbility from "../appability/AppAbility";
import { NotificationService } from "./NotificationService";

export class CallStateResult {
  public notice:boolean = false;
  public interrupt:boolean = false;
  public oldstate:number = 0;
  public newstate:number = 0;
}

export class CallManager {

  public static CALL_STATE_IDLE = 0;
  public static CALL_STATE_PTT_GROUP_CALL = CallManager.CALL_STATE_IDLE;
  public static CALL_STATE_PTT_TMP_GROUP_CALL = 1;
  public static CALL_STATE_AUDIO_VIDEO_CALL = 2;

  static INSTANCE:CallManager = new CallManager();
  static getInstance() {
    return CallManager.INSTANCE;
  }

  private callState = CallManager.CALL_STATE_IDLE;
  private constructor() {
  }

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'CallManager=%{public}s', msg);
  }

  public enterPttGroupCall() {
    this.callState = CallManager.CALL_STATE_PTT_GROUP_CALL;
  }

  public exitPttGroupCall() {
    this.callState = CallManager.CALL_STATE_IDLE;
  }

  public enterPttTmpGroupCall() {
    this.callState = CallManager.CALL_STATE_PTT_TMP_GROUP_CALL;
  }

  public exitPttTmpGroupCall() {
    this.callState = CallManager.CALL_STATE_IDLE;
  }

  public enterAudioVideoCall() {
    this.callState = CallManager.CALL_STATE_AUDIO_VIDEO_CALL;
  }

  public exitAudioVideoCall(type: number) {
    this.log('exit audio or video call reset idle:'+type);
    this.callState = CallManager.CALL_STATE_IDLE;
  }

  public getCallState() : number {
    return this.callState;
  }

  public checkCallStateSwitch(newstate: number) : Promise<CallStateResult> {
    let caninterrupt = false;
    let neednotice = false;
    if (!NotificationService.getInstance().isForeground()) {
      neednotice = true;
    }
    else {
      neednotice = false;
    }
    if (newstate > this.callState) {
      caninterrupt = true;
      this.log('current call state:'+this.callState+' need switch to:'+newstate);
    }
    else {
      caninterrupt = false;
    }
    let result:CallStateResult = new CallStateResult();
    result.notice = neednotice;
    result.interrupt = caninterrupt;
    result.oldstate = this.callState;
    result.newstate = newstate;
    let promise = new Promise<CallStateResult>((resolve, reject) => {
      try {
        resolve(result);
      } catch (e) {
        reject('error');
      }
    });
    return promise;
  }

}