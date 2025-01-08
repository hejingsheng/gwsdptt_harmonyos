@Preview({
  title:'ChatVoiceFromItemView'
})

@Component
export struct ChatVoiceFromItemView {
  private sender:string = '';
  private url: string = '';

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
        Image($r('app.media.ic_msg_voice_me'))
          .width($r('app.float.chat_voice_item_width'))
          .height($r('app.float.chat_voice_item_height'))
          .objectFit(ImageFit.Contain)
          .backgroundColor($r('app.color.chat_txt_from_bg_color'))
          .clip(true)
          .borderRadius(5)
          .padding({
            right:'45vp'
          })
          .margin({
            left: '5vp'
          })
          .onClick(()=>{
            // play voice
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