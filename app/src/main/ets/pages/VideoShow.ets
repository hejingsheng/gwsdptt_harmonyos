import { router } from '@kit.ArkUI';

@Entry
@Component
struct VideoShow {

  private videoController: VideoController = new VideoController()
  @State url: string = '';
  @State thumburl: string = '';

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as Record<string, string>;
      this.url = param['url'];
      this.thumburl = param['thumburl'];
    }
  }

  build() {
    Column({space: 10}) {
      Video({
        src: this.url,                   // 设置数据源
        previewUri: this.thumburl, // 设置封面图片
        controller: this.videoController                   // 设置控制器
      })
        .width('auto')
        .height('auto')
    }
    .width("100%")
    .height("100%")
  }
}