import { router } from '@kit.ArkUI';

@Entry
@Component
struct PhotoShow {
  @State url: string = '';

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as Record<string, string>;
      this.url = param['url'];
    }
  }

  build() {
    Column() {
      Image(this.url)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .height('100%')
    .width('100%')
  }
}