import { gwsdPttSdk } from 'gwsdptt_sdk'

@Component
export struct MeView {

  build() {
    Column() {
      Text(gwsdPttSdk.pttGetVersion())
        .id('ChatListView')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}