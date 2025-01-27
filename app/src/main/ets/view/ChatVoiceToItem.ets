import { AudioPlayer } from "../utils/PlayUtils";

@Preview({
  title:'ChatVoiceToItemView'
})

@Component
export struct ChatVoiceToItemView {
  @State voiceAnim:AnimationStatus = AnimationStatus.Initial;
  private playing:boolean = false;
  private sender:string = 'user';
  private url: string = '';

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
        ImageAnimator()
          .images([
            {
              src: $r('app.media.ic_msg_voice_me03'),
              width:5,
              height:5,
              duration: 100
            },
            {
              src: $r('app.media.ic_msg_voice_me01'),
              width:5,
              height:5,
              duration: 300
            },
            {
              src: $r('app.media.ic_msg_voice_me02'),
              width:5,
              height:5,
              duration: 300
            },
            {
              src: $r('app.media.ic_msg_voice_me03'),
              width:5,
              height:5,
              duration: 300
            }
          ])
          .state(this.voiceAnim).reverse(false)
          .fillMode(FillMode.None).iterations(-1)
          .width($r('app.float.chat_voice_item_width'))
          .height($r('app.float.chat_voice_item_height'))
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .backgroundColor($r('app.color.chat_txt_to_bg_color'))
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
            if (this.playing) {
              AudioPlayer.getInstance().avPlayerStop();
              this.voiceAnim = AnimationStatus.Stopped;
            }
            else {
              AudioPlayer.getInstance().avPlayerLive(this.url, (state: number) => {
                if (state == 1) {
                  this.voiceAnim = AnimationStatus.Stopped;
                  this.playing = false;
                } else {
                  this.voiceAnim = AnimationStatus.Running;
                  this.playing = true;
                }
              });
            }
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