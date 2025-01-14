import { numberToTime } from '../utils/Utils';
import { router } from '@kit.ArkUI';
import { AudioCallParam } from '../service/CallParam';
import { GWSDKManager } from '../service/GWSDKManager';
import { GWDuplexBean, GWMsgBean, GWType } from 'gwsdptt_sdk';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import AppAbility from '../appability/AppAbility';
import { CallManager } from '../service/CallManager';
import { MsgContentBean } from '../db/MsgContentBean';
import { MsgConversationBean } from '../db/MsgConversationBean';
import { MsgDB } from '../db/MsgDB';

@Entry
@Component
struct AudioCall {

  @State mutelocal:boolean = false;
  @State muteSpk:boolean = false;
  @State hangupPress:boolean = false;
  @State acceptPress:boolean = false;
  @State establish:boolean = false;
  @State calltime:number = 0;

  private timer:number = -1;
  private audioParam :AudioCallParam = new AudioCallParam(0, '', false);

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'AudioCall=%{public}s', msg);
  }

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as AudioCallParam;
      this.audioParam = param;
      GWSDKManager.getInstance().registerPttObserver({
        onPttEvent:(event: number, data: string, data1: number) => {
          if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_DUPLEX) {
            let json = JSON.parse(data);
            let gwDuplexBean: GWDuplexBean = (json as GWDuplexBean);
            if (gwDuplexBean.result === 0) {
              if (gwDuplexBean.status === GWType.GW_DUPLEX_STATUS.GW_PTT_DUPLEX_STATUS_ACCEPTED) {
                this.log('call establish');
                this.establish = true;
                this.calltime = 1;
              }
              else if (gwDuplexBean.status === GWType.GW_DUPLEX_STATUS.GW_PTT_DUPLEX_STATUS_END) {
                this.log('call end finish');
                GWSDKManager.getInstance().registerPttObserver(undefined);
                router.back();
              }
              else if (gwDuplexBean.status === GWType.GW_DUPLEX_STATUS.GW_PTT_DUPLEX_STATUS_START) {
                this.log('call success wait remote accept');
              }
            }
            else {
              this.log('call error');
              GWSDKManager.getInstance().registerPttObserver(undefined);
              router.back();
            }
          }
        },
        onMsgEvent:(event: number, data: string) => {

        }
      });
      if (this.audioParam.caller) {
        GWSDKManager.getInstance().fullDuplex(this.audioParam.remoteId, GWType.GW_DUPLEX_TYPE.GW_PTT_DUPLEX_ACTION_CREATE);
      }
      else {
        this.log('recv user:'+this.audioParam.remoteName+' voice call request');
      }
      CallManager.getInstance().enterAudioVideoCall();
    }
    this.startTimer();
  }

  aboutToDisappear(): void {
    this.stopTimer()
    CallManager.getInstance().exitAudioVideoCall(0);
    GWSDKManager.getInstance().registerPttObserver(undefined);
    this.saveCallRecord();
  }

  private getUid() : string {
    return GWSDKManager.getInstance().getUserInfo().id.toString();
  }

  private getUnm() : string {
    return GWSDKManager.getInstance().getUserInfo().name;
  }

  private async saveCallRecord() {
    let gwMsgBean:GWMsgBean;
    let msgContent:MsgContentBean;
    let msgConv:MsgConversationBean;
    let unreadflag = false;
    if (this.audioParam.caller) {
      gwMsgBean = GWSDKManager.getInstance().createMsgBean(GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER, this.audioParam.remoteId, this.audioParam.remoteName, 0);
    }
    else {
      gwMsgBean = GWSDKManager.getInstance().createMsgBean1(this.audioParam.remoteId.toString(), this.audioParam.remoteName,
        GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER, this.getUid(), this.getUnm(), 0);
      if (this.establish) {
        unreadflag = true;
      }
      else {
        unreadflag = false;
      }
    }
    if (this.establish) {
      gwMsgBean.data.content = this.calltime.toString();
    }
    else {
      gwMsgBean.data.content = '0';
    }
    msgContent = await MsgDB.getINSTANCE().saveMsgContent(this.getUid(), gwMsgBean);
    msgConv = await MsgDB.getINSTANCE().saveOrUpdateConv(msgContent, unreadflag);
    getContext(this).eventHub.emit('recvmsg', msgContent);
    getContext(this).eventHub.emit('recvconv', msgConv);
  }

  private startTimer() {
    this.timer = setInterval(() => {
      this.calltime++;
    }, 1000)
  }

  private stopTimer() {
    clearInterval(this.timer);
  }

  build() {
    Column() {
      Column(){
        Text(this.audioParam.remoteName)
          .fontColor(Color.White)
          .fontSize($r('app.float.text_size_normal'))
          .textAlign(TextAlign.Center)
        Text(numberToTime(this.calltime))
          .fontColor(Color.White)
          .fontSize($r('app.float.text_size_small'))
          .textAlign(TextAlign.Center)
          .margin({
            top: '6vp'
          })
      }
      .width('100%')
      .margin({
        top: $r('app.float.audiocall_info_top_size')
      })

      Row() {
        Image(this.mutelocal?$r('app.media.ic_video_silence_n'):$r('app.media.ic_video_silence_p'))
          .width($r('app.float.call_image_size'))
          .height($r('app.float.call_image_size'))
          .onClick(() => {
            this.mutelocal = !this.mutelocal;
          })
        Image(this.muteSpk?$r('app.media.ic_video_speaker_n'):$r('app.media.ic_video_speaker_p'))
          .width($r('app.float.call_image_size'))
          .height($r('app.float.call_image_size'))
          .margin({
            left: '30vp'
          })
          .onClick(() => {
            this.muteSpk = !this.muteSpk;
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .visibility(this.establish?Visibility.Visible:Visibility.Hidden)

      Row() {
        Image(this.hangupPress?$r('app.media.ic_video_hangup_p'):$r('app.media.ic_video_hangup_n'))
          .width($r('app.float.call_image_size'))
          .height($r('app.float.call_image_size'))
          .onTouch((event)=>{
            if (event.type === TouchType.Down) {
              this.hangupPress = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.hangupPress = false;
            }
          })
          .onClick(()=>{
            GWSDKManager.getInstance().fullDuplex(this.audioParam.remoteId, GWType.GW_DUPLEX_TYPE.GW_PTT_DUPLEX_ACTION_HANGUP);
          })
        Image(this.acceptPress?$r('app.media.ic_video_accept_p'):$r('app.media.ic_video_accept_n'))
          .width($r('app.float.call_image_size'))
          .height($r('app.float.call_image_size'))
          .onTouch((event)=>{
            if (event.type === TouchType.Down) {
              this.acceptPress = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.acceptPress = false;
            }
          })
          .visibility(this.audioParam.caller||this.establish?Visibility.Hidden:Visibility.Visible)
          .onClick(()=>{
            GWSDKManager.getInstance().fullDuplex(this.audioParam.remoteId, GWType.GW_DUPLEX_TYPE.GW_PTT_DUPLEX_ACTION_ACCEPT);
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .margin({
        bottom: $r('app.float.audiocall_info_bottom_size')
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}