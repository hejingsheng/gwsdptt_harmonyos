@Component
export struct ChatTxtFromItemView {
  private sender:string = '';
  private content: string = '';

  build() {
    Row() {
      Image($r('app.media.user'))
        .width($r('app.float.user_icon_width'))
        .height($r('app.float.user_icon_height'))
      Column(){
        Text(this.sender)
          .id('name')
          .fontSize($r('app.float.text_size_normal'))
          .fontColor($r('app.color.chat_txt_color'))
          .margin({
            left: '3vp'
          })
        Text(this.content)
          .align(Alignment.Center)
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.text_size_normal'))
          .fontColor($r('app.color.chat_txt_color'))
          .backgroundColor($r('app.color.chat_txt_from_bg_color'))
          .clip(true)
          .borderRadius(5)
          .padding({
            top: '10vp',
            bottom: '10vp',
            left: '12vp',
            right: '12vp'
          })
          .constraintSize({
            maxWidth: $r('app.float.chat_txt_item_max_width')
          })
          .margin({
            left: '5vp'
          })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('auto')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('app.color.list_item_bg_color_p')) //
  }
}