@Component
struct AttachBtnView {
  @State isPress:boolean = false;
  @State imgNor?:Resource = undefined;
  @State imgSel?:Resource = undefined;

  private text:ResourceStr = '';
  build() {
    Column() {
      Image(this.isPress?this.imgSel:this.imgNor)
        .width($r('app.float.attach_btn_image_size'))
        .height($r('app.float.attach_btn_image_size'))
        .alignRules({
          center: {anchor: '__container__', align: VerticalAlign.Center},
          middle: {anchor: '__container__', align: HorizontalAlign.Center}
        })
      Text(this.text)
        .width($r('app.float.attach_btn_text_size'))
        .textAlign(TextAlign.Center)
        .fontSize($r('app.float.text_size_small'))
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .onTouch((event)=>{
      if (event.type === TouchType.Down) {
        this.isPress = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPress = false;
      }
    })
  }
}

export interface ChatInputViewEvent {
  onStartVoice:() => void;
  onStopVoice:() => void;
  onCancelVoice:() => void;
  onSendTxt:(value: string) => void;
  onPhoto:() => void;
  onVideo:() => void;
  onLocation:() => void;
  onPttCall:() => void;
  onVoiceCall:() => void;
  onVideoCall:() => void;
}

@Component
export struct ChatInputView {
  @State textInputForce:boolean = false;
  @State voiceSend:boolean = false;
  @State showAttach:boolean = false;
  @State txt:string = '';
  @State press:boolean = false;

  private inputViewEvent?:ChatInputViewEvent;
  private showCall:boolean = true;

  build() {
    Column() {
      RelativeContainer() {
        Image(this.voiceSend?$r('app.media.ic_keyboard'):$r('app.media.ic_voice_send'))
          .id('start')
          .height('100%')
          .width($r('app.float.char_input_height'))
          .alignRules({
            center: {anchor: '__container__', align: VerticalAlign.Center},
          })
          .onClick(()=>{
            this.voiceSend = !this.voiceSend;
            this.textInputForce = false;
            this.showAttach = false;
          })
        RelativeContainer(){
          if (this.voiceSend) {
            Button(this.press?$r('app.string.btn_loosen_end'):$r('app.string.btn_press_speak'))
              .height('100%')
              .width('100%')
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
              })
              .onTouch((event)=>{
                if (event.type === TouchType.Down) {
                  this.press = true;
                  this.inputViewEvent?.onStartVoice();
                } else if (event.type === TouchType.Up) {
                  this.press = false;
                  this.inputViewEvent?.onStopVoice();
                } else if (event.type === TouchType.Cancel) {
                  this.press = false;
                  this.inputViewEvent?.onCancelVoice();
                }
              })
          } else {
            TextInput({text:this.txt})
              .height('100%')
              .width('100%')
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
              })
              .onFocus(()=>{
                //this.textInputForce = true;
              })
              .onChange((value)=>{
                this.txt = value
                if (this.txt.length > 0) {
                  this.textInputForce = true;
                  this.showAttach = false;
                }
                else {
                  this.textInputForce = false;
                }
              })
          }
        }
        .height('100%')
        .alignRules({
          center: {anchor: '__container__', align: VerticalAlign.Center},
          start: {anchor: 'start', align: HorizontalAlign.End},
          end: {anchor: 'end', align: HorizontalAlign.Start}
        })
        RelativeContainer() {
          if (this.textInputForce) {
            Button($r('app.string.btn_send'))
              .height('100%')
              .width('100%')
              .fontSize($r('app.float.text_size_smallS'))
              .alignRules({
                center: {anchor: '__container__', align: VerticalAlign.Center},
              })
              .onClick((event)=>{
                this.inputViewEvent?.onSendTxt(this.txt);
                this.txt = '';
              })
          } else {
            Image($r('app.media.ic_show_attach_day'))
              .height('100%')
              .width($r('app.float.char_input_height'))
              .alignRules({
                center: {anchor: '__container__', align: VerticalAlign.Center},
                middle: {anchor: '__container__', align: HorizontalAlign.Center},
              })
              .onClick(()=>{
                this.showAttach = !this.showAttach;
              })
          }
        }
        .id('end')
        .height('100%')
        .width($r('app.float.btn_send_size'))
        .alignRules({
          center: {anchor: '__container__', align: VerticalAlign.Center},
          end: {anchor: '__container__', align: HorizontalAlign.End},
        })
      }
      .width('100%')
      .height($r('app.float.char_input_height'))
      if (this.showAttach) {
        Row() {
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_camera'),
            imgSel:$r('app.media.ic_btn_camera_s'),
            text:$r('app.string.photo')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onPhoto();
            })
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_video'),
            imgSel:$r('app.media.ic_btn_video_s'),
            text:$r('app.string.Video')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onVideo();
            })
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_loc'),
            imgSel:$r('app.media.ic_btn_loc_s'),
            text:$r('app.string.location')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onLocation();
            })
        }
        .width('100%')
        .height($r('app.float.attach_btn_height'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceAround)
        Row() {
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_pttcall'),
            imgSel:$r('app.media.ic_btn_pttcall_s'),
            text:$r('app.string.pttcall')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onPttCall();
            })
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_voicecall'),
            imgSel:$r('app.media.ic_btn_voicecall_s'),
            text:$r('app.string.voicecall')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onVoiceCall();
            })
            .visibility(this.showCall?Visibility.Visible:Visibility.Hidden)
          AttachBtnView({
            imgNor:$r('app.media.ic_btn_videocall'),
            imgSel:$r('app.media.ic_btn_videocall_s'),
            text:$r('app.string.videocall')
          })
            .width('33%')
            .height('100%')
            .onClick(()=>{
              this.inputViewEvent?.onVideoCall();
            })
            .visibility(this.showCall?Visibility.Visible:Visibility.Hidden)
        }
        .width('100%')
        .height($r('app.float.attach_btn_height'))
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceAround)
      }
    }
  }
}