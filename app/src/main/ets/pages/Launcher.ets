import { router } from '@kit.ArkUI';

@Entry
@Component
struct Launcher {
  @State message: string = 'Hello World';

  timer?:number;

  onPageShow(): void {
    this.timer = setInterval(()=>{
      router.pushUrl({url: 'pages/Login'})
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