import { hilog } from '@kit.PerformanceAnalysisKit'
import { promptAction, router, window } from '@kit.ArkUI'
import { GWSDKManager } from '../service/GWSDKManager'
import { GWLoginResultBean, GWType } from 'gwsdptt_sdk'
import { JSON } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import AppAbility from '../appability/AppAbility';

@Component
struct InputFloatHint{
  @State isFloatHint: boolean = false
  @State textValue: string = ''
  isEditing = false

  typeInput:InputType = InputType.Normal
  placeholder?: Resource
  onTextChange?: (value: string) => void

  build(){
    Stack(){
      TextInput({text:this.textValue})
        .width('100%')
        .height('100%')
        .borderRadius(0)
        .borderColor('#86C7CC')
        .borderWidth({bottom: 1})
        .backgroundColor(Color.Transparent)
        .type(this.typeInput)
        .showPasswordIcon(false)
        .onEditChange((isEditing)=>{
          this.isEditing = isEditing
          this.isFloatHint = this.isEditing || this.textValue !==''
        })
        .onChange((value)=>{
          this.textValue = value
          this.isFloatHint = this.isEditing || this.textValue !== ''
          if(this.onTextChange){
            this.onTextChange(this.textValue)
          }
        })
      Text(this.placeholder)
        .enabled(false)
        .fontColor(this.isFloatHint ?  '#5D7DB3' : '#E1E4EA')
        .position({x: 0, y: this.isFloatHint ? 0 : '50%'})
        .translate({x: 15, y: '-50%'})
        .animation({duration:100, curve: Curve.Linear})

      Line()
        .width('100%')
        .height(1)
        .backgroundColor('#5D7DB3')
        .position({x: 0, y: 44})
        .scale({x: this.isFloatHint ? 1 : 0, centerX: 0})
        .animation({duration: 300, curve: Curve.Linear})
      // if (this.textValue){
      //   Image($r("app.media.canel"))
      //     .width(15)
      //     .height(15)
      //     .border({width: 1, radius: 15, color: '#fffffff'})
      //     .position({x: '90%', y: '50%'})
      //     .translate({y: '-50%'})
      //     .onClick(()=>{
      //       this.textValue = ''
      //     })
      // }
    }.width('100%').height(45)
  }
}

@Entry
@Component
struct Login {
  @State account: string = 'gwsd03';
  @State password: string = '111111';

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'Login=%{public}s', msg);
  }

  aboutToAppear(): void {
    GWSDKManager.getInstance().registerPttObserver({
      onPttEvent:(event: number, data: string, data1: number) => {
        if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_LOGIN) {
          let json = JSON.parse(data);
          let gwLoginResultBean:GWLoginResultBean = (json as GWLoginResultBean);
          if (gwLoginResultBean.result === 0) {
            promptAction.showToast({
              message:$r('app.string.hint_login_succeed'),
              duration:1000
            })
            router.pushUrl({url:'pages/Main'});
          }
          else {
            promptAction.showToast({
              message:$r('app.string.hint_login_failure'),
              duration:2000
            })
          }
        }
        else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_ERROR) {
          promptAction.showToast({
            message:$r('app.string.hint_network_err'),
            duration:2000
          })
        }
      },
      onMsgEvent:(event: number, data: string) => {

      }
    });
  }

  aboutToDisappear(): void {
    GWSDKManager.getInstance().registerPttObserver(undefined);
  }

  onBackPress(): boolean | void {
    (getContext(this) as common.UIAbilityContext).terminateSelf().then((data)=>{
      this.log('exit app');
    });
    return true;
  }

  login() : void {
    GWSDKManager.getInstance().login(this.account, this.password, '12345', '54321');
  }

  build() {
    Column() {
      Image($r('app.media.ic_logo_gw_day'))
        .width($r('app.float.launch_logo_size'))
        .height($r('app.float.launch_logo_size'))
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({top:'20'})
      Text($r('app.string.title_welcome'))
        .fontSize(25)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({top:'30'});
      Column(){
        InputFloatHint({placeholder: $r('app.string.hint_account'), onTextChange: (value) => {
          this.account = value;
        }})
        Blank().height(30);
        InputFloatHint({placeholder: $r('app.string.hint_password'), onTextChange: (value) => {
          this.password = value;
        },typeInput: InputType.Password});
        Blank().height(50)
        Button($r('app.string.btn_login')).width(150)
          .onClick(()=>{
            this.log('login account:'+this.account);
            this.login();
          })
      }
      .margin({top: '30'})
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background_color'))
  }
}