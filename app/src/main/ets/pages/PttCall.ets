import * as TopView from '../view/TopView'
import { router } from '@kit.ArkUI';
import { PttCallParam } from '../service/PttCallParam';
import { GWSDKManager } from '../service/GWSDKManager';
import { GWType } from 'gwsdptt_sdk';

@Entry
@Component
struct PttCall {
  @State viewItem: TopView.ViewItem = new TopView.ViewItem('');
  @State animalState:AnimationStatus = AnimationStatus.Stopped;

  private pttParam :PttCallParam = new PttCallParam(0, '', 0, false);

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as PttCallParam;
      this.pttParam = param;
      GWSDKManager.getInstance().registerPttObserver({
        onPttEvent:(event: number, data: string, data1: number) => {

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
        let uids:Uint32Array = new Uint32Array(1);
        uids[0] = this.pttParam.pttId;
        GWSDKManager.getInstance().tempGroup(uids, 1);
      }
    }
  }

  aboutToDisappear(): void {
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
            left:'10vp',
            top: '30vp'
          })
          .fontColor(Color.White)
          .fontSize($r('app.float.text_size_normalX'))
        Image($r('app.media.ic_open_voice'))
          .width('30vp')
          .height('30vp')
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .margin({
            right:'10vp',
            top:'30vp'
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
        // Image($r('app.media.ic_animation_speak_10'))
        //   .width('100%')
        //   .height('10vp')
        //   .alignRules({
        //     bottom: { anchor: 'speakinfo', align: VerticalAlign.Top }
        //   })
        ImageAnimator()
          .images([
            {
              src: $r('app.media.ic_animation_speak_01'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_02'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_03'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_04'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_05'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_06'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_07'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_08'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_09'),
              width: '100%',
              height: '20vp',
              duration: 150
            },
            {
              src: $r('app.media.ic_animation_speak_10'),
              width: '100%',
              height: '20vp',
              duration: 150
            }
          ])
          .state(this.animalState).reverse(false)
          .fillMode(FillMode.None).iterations(-1)
          .width('100%').height('10vp')
          .margin({ top: '15vp', bottom: '5vp' })
          .alignRules({
            bottom: { anchor: 'speakinfo', align: VerticalAlign.Top }
          })

        Row(){
          Text('SPEAKING')
            .fontColor(Color.White)
            .fontSize($r('app.float.text_size_largeX'))
        }
        .id('speakinfo')
        .width('100%')
        .height('30vp')
        .justifyContent(FlexAlign.Center)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
      }
      .width('100%')
      .height('50%')
      .backgroundColor('#55C0F6')
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
          .state(this.animalState).reverse(false)
          .fillMode(FillMode.None).iterations(-1)
          .width('160vp')
          .height('160vp')
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onTouch((event)=>{
            if (event.type === TouchType.Down) {
              this.animalState = AnimationStatus.Running;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.animalState = AnimationStatus.Stopped;
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