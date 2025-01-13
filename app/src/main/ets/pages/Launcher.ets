import { router } from '@kit.ArkUI';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';

const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE','ohos.permission.MICROPHONE_CONTROL'];

@Entry
@Component
struct Launcher {
  @State message: string = 'Hello World';

  timer?:number;

  // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
  private reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): Promise<PermissionRequestResult> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    return atManager.requestPermissionsFromUser(context, permissions);
  }

  onPageShow(): void {
    this.timer = setInterval(()=>{
      this.reqPermissionsFromUser(permissions, getContext(this) as common.UIAbilityContext)
        .then((data) => {
          let grantStatus: Array<number> = data.authResults;
          let length: number = grantStatus.length;
          for (let i = 0; i < length; i++) {
            if (grantStatus[i] === 0) {
              // 用户授权，可以继续访问目标操作
              router.pushUrl({
                url:'pages/Login'
              })
            } else {
              // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
              return;
            }
          }
        })
      clearInterval(this.timer);
    }, 1000);
  }

  onPageHide(): void {
    clearInterval(this.timer)
  }

  build() {
    RelativeContainer() {
      Image($r('app.media.ic_logo_gw_day'))
        .id('viewLogo')
        .width($r('app.float.launch_logo_size'))
        .height($r('app.float.launch_logo_size'))
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background_color'))
  }
}