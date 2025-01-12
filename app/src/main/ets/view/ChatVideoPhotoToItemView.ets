import { router } from "@kit.ArkUI";

@Preview({
  title:'chatImageToview'
})
@Component
export struct ChatVideoPhotoToItemView {
  private sender:string = '';
  private url: string = '';
  private thumburl: string = '';
  private video: boolean = false;
  @State imageWidth: number = 100;
  @State imageHeight: number = 100;

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
        Image(this.video?this.thumburl:this.url)
          .width(this.imageWidth)
          .height(this.imageHeight)
          .objectFit(ImageFit.Contain)
          .backgroundColor($r('app.color.chat_txt_to_bg_color'))
          .margin({
            right: '5vp'
          })
          .onComplete((msg)=>{
            if (msg) {
              let w = px2vp(msg.width);
              let h = px2vp(msg.height)
              this.imageWidth = 200;
              let tmp = w/this.imageWidth;
              this.imageHeight = h/tmp;
            }
          })
          .onClick(()=>{
            if (this.video) {
              // goto video play page
              router.pushUrl({
                url: 'pages/VideoShow',
                params: {
                  url:this.url,
                  thumburl:this.thumburl
                }
              });
            } else {
              router.pushUrl({
                url: 'pages/PhotoShow',
                params: {
                  url:this.url
                }
              })
            }
          })
        if (this.video) {
          Image($r('app.media.ic_record_play'))
            .width('50vp')
            .height('50vp')
            .margin({
              left: '75vp',
              top: -this.imageHeight/2
            })
        }
      }
      .alignItems(HorizontalAlign.End)
      Image($r('app.media.user'))
        .width($r('app.float.user_icon_width'))
        .height($r('app.float.user_icon_height'))
    }
    .width('100%')
    .height(this.imageHeight)
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('app.color.list_item_bg_color_p')) //
  }
}