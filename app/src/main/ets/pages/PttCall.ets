import * as TopView from '../view/TopView'
import { PromptAction, promptAction, router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { PttCallParam } from '../service/CallParam';
import { GWSDKManager } from '../service/GWSDKManager';
import { GWGroupListBean, GWRequestSpeakBean, GWSpeakNotifyBean, GWTempGroupBean,
  GWTempGroupNotifyBean,
  GWType } from 'gwsdptt_sdk';
import AppAbility from '../appability/AppAbility';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CallManager } from '../service/CallManager';
import call from '@ohos.telephony.call';

@Entry
@Component
struct PttCall {
  @State viewItem: TopView.ViewItem = new TopView.ViewItem('');
  @State spkAnimalState:AnimationStatus = AnimationStatus.Stopped;
  @State pttAnimalState:AnimationStatus = AnimationStatus.Stopped;
  @State speakinfo:ResourceStr = '';
  private pttParam :PttCallParam = new PttCallParam(0, '', 0, false);
  private spkSucc:boolean = false;

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'PttCall=%{public}s', msg);
  }

  private updateSpeaker(state: number, txt: ResourceStr) {
    if (state === 1) {
      this.spkAnimalState = AnimationStatus.Running;
      this.speakinfo = txt;
    }
    else {
      this.spkAnimalState = AnimationStatus.Stopped;
      this.speakinfo = $r('app.string.hint_Idle_waiting');
    }
  }

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as PttCallParam;
      this.pttParam = param;
      GWSDKManager.getInstance().registerPttObserver({
        onPttEvent:(event: number, data: string, data1: number) => {
          if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_JOIN_GROUP) {
            let json = JSON.parse(data);
            let gwGroupListBean: GWGroupListBean = (json as GWGroupListBean);
            if (gwGroupListBean.result === 0) {
              this.log('join group success');
            } else {
              promptAction.showToast({
                message: $r('app.string.failure'),
                duration: 2000
              });
              router.back();
            }
          }
          else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_SPEAK) {
            let json = JSON.parse(data);
            let gwSpeakNotifyBean: GWSpeakNotifyBean = (json as GWSpeakNotifyBean);
            if (gwSpeakNotifyBean.uid !== 0) {
              this.updateSpeaker(1, gwSpeakNotifyBean.name);
            }
            else {
              this.updateSpeaker(2, '');
            }
          }
          else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_REQUEST_MIC) {
            let json = JSON.parse(data);
            let gwRequestSpeakBean: GWRequestSpeakBean = (json as GWRequestSpeakBean);
            if (gwRequestSpeakBean.result !== 0) {
              this.log('request speak fail');
              promptAction.showToast({
                message: $r('app.string.failure'),
                duration: 2000
              });
            }
            else {
              this.log('request speak success');
              this.updateSpeaker(1, $r('app.string.local_equipment_speak'));
              this.spkSucc = true;
            }
          }
          else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_TMP_GROUP_ACTIVE) {
            let json = JSON.parse(data);
            let gwTempGroupBean: GWTempGroupBean = (json as GWTempGroupBean);
            if (gwTempGroupBean.result === 0) {
              this.log('tmp group success');
            }
            else if (gwTempGroupBean.result === 1) {
              this.log('exit tmp group');
              router.back();
            }
            else {
              this.log('tmp group fail');
              router.back();
            }
          }
          else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_TMP_GROUP_PASSIVE) {
            let json = JSON.parse(data);
            let gwTempGroupNotifyBean: GWTempGroupNotifyBean = (json as GWTempGroupNotifyBean);
            if (gwTempGroupNotifyBean.status === 0) {
              this.log('release tmp group');
              router.back();
            }
          }
        },
        onMsgEvent:(event: number, data: string) => {

        }
      });
      if (this.pttParam.pttType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_GROUP
        || this.pttParam.pttType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_GROUP) {
        this.viewItem = new TopView.ViewItem($r('app.string.title_group_call'));
        GWSDKManager.getInstance().joinGroup(this.pttParam.pttId, this.pttParam.pttType);
      }
      else {
        this.viewItem = new TopView.ViewItem($r('app.string.title_temp_call'));
        CallManager.getInstance().enterPttTmpGroupCall();
        if (this.pttParam.pttCreate) {
          let uids: Uint32Array = new Uint32Array(1);
          uids[0] = this.pttParam.pttId;
          GWSDKManager.getInstance().tempGroup(uids, 1);
        }
      }
    }
  }

  aboutToDisappear(): void {
    CallManager.getInstance().exitPttTmpGroupCall();
    if (this.pttParam.pttType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER) {
      let uids:Uint32Array = new Uint32Array(1);
      uids[0] = 0;
      GWSDKManager.getInstance().tempGroup(uids, 1);
    }
    GWSDKManager.getInstance().registerPttObserver(undefined);
  }

  private getPttCallTypeTxt() : ResourceStr {
    if (this.pttParam.pttType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_GROUP
        || this.pttParam.pttType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_GROUP) {
      return $r('app.string.hint_poc_current_group', this.pttParam.pttName);
    }
    else {
      return $r('app.string.hint_poc_current_member', this.pttParam.pttName);
    }
  }

  build() {
    Column() {
      TopView.View({
        showRight: false,
        rotateVal: 0,
        viewItem: this.viewItem,
        onLeftClick: ()=>{
          router.back();
        }
      })
        .id('topview')
        .alignRules({
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          }
        })
      RelativeContainer() {
        Text(this.getPttCallTypeTxt())
          .id('calltype')
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({
            right: $r('app.float.left_right_margin_size'),
            top:$r('app.float.pttcall_top_magin_size')
          })
          .fontColor(Color.White)
          .fontSize($r('app.float.text_size_normalX'))
        Image($r('app.media.ic_open_voice'))
          .width($r('app.float.pttcall_voice_toggle_size'))
          .height($r('app.float.pttcall_voice_toggle_size'))
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .margin({
            right: $r('app.float.left_right_margin_size'),
            top:$r('app.float.pttcall_top_magin_size')
          })
          .onClick(()=>{

          })
        Text(this.pttParam.pttId.toString())
          .fontSize($r('app.float.text_size_largeXXX'))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .fontColor(Color.White)
        ImageAnimator()
          .images([
            {
              src: $r('app.media.ic_animation_speak_01'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_02'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_03'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_04'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_05'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_06'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_07'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_08'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_09'),
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_10'),
              duration: 150
            }
          ])
          .state(this.spkAnimalState).reverse(false)
          .fillMode(FillMode.None).iterations(-1)
          .width('100%').height($r('app.float.pttcall_animal_height'))
          .margin({ top: '15vp', bottom: '5vp' })
          .alignRules({
            bottom: { anchor: 'speakinfo', align: VerticalAlign.Top }
          })

        Row(){
          Text(this.speakinfo)
            .fontColor(Color.White)
            .fontSize($r('app.float.text_size_largeX'))
        }
        .id('speakinfo')
        .width('100%')
        .height($r('app.float.item_size_s'))
        .justifyContent(FlexAlign.Center)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
      }
      .width('100%')
      .height('50%')
      .backgroundColor($r('app.color.ptt_view_color'))
      RelativeContainer() {
        ImageAnimator()
          .images([
            {
              src: $r('app.media.ic_blue_microphone_videovoice1'),
              duration: 300
            },
            {
              src: $r('app.media.ic_blue_microphone_videovoice2'),
              duration: 300
            },
            {
              src: $r('app.media.ic_blue_microphone_videovoice3'),
              duration: 300
            }
          ])
          .state(this.pttAnimalState).reverse(false)
          .fillMode(FillMode.None).iterations(-1)
          .width($r('app.float.ptt_button_size'))
          .height($r('app.float.ptt_button_size'))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onTouch((event)=>{
            if (event.type === TouchType.Down) {
              this.pttAnimalState = AnimationStatus.Running;
              GWSDKManager.getInstance().startSpeak();
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.pttAnimalState = AnimationStatus.Stopped;
              GWSDKManager.getInstance().stopSpeak();
              if (this.spkSucc) {
                this.updateSpeaker(2, '');
              }
            }
          })
      }
      .width('100%')
      .height('50%')
    }
    .height('100%')
    .width('100%')
  }
}