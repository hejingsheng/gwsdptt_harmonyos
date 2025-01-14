import { numberToTime } from '../utils/Utils';

@Preview({
  title:'ChatAVCallToItemView'
})

@Component
export struct ChatAVCallToItemView {
  private sender:string = '';
  private time: string = '100';
  private video: boolean = false;

  build() {
    Row() {
      Column(){
        Text(this.sender)
          .id('name')
          .fontSize($r('app.float.text_size_normal'))
          .fontColor($r('app.color.chat_txt_color'))
          .margin({
            right: '3vp'
          })
        Row(){
          Text(Number(this.time) <= 0?
            $r('app.string.not_connected'):
            $r('app.string.talk_time',numberToTime(Number(this.time))))
            .fontSize($r('app.float.text_size_normal'))
            .fontColor($r('app.color.chat_txt_color'))
            .margin({
              left:'5vp',
              right:'5vp'
            })
          Image(this.video?$r('app.media.ic_msg_video_call_day'):$r('app.media.ic_msg_voice_call_day'))
            .width($r('app.float.chat_avcall_icon_size'))
            .height($r('app.float.chat_avcall_icon_size'))
            .objectFit(ImageFit.Contain)
            .margin({
              right:'10vp'
            })
            .onClick(()=>{

            })
        }
        .width('auto')
        .height($r('app.float.chat_voice_item_height'))
        .backgroundColor($r('app.color.chat_txt_to_bg_color'))
        .clip(true)
        .borderRadius(5)
        .margin({
          left: '5vp'
        })
      }
      .alignItems(HorizontalAlign.End)
      Image($r('app.media.user'))
        .width($r('app.float.user_icon_width'))
        .height($r('app.float.user_icon_height'))
    }
    .width('100%')
    .height('auto')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('app.color.list_item_bg_color_p')) //
  }
}