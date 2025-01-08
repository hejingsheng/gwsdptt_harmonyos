import { Session } from '../service/SessionModel';
import * as TopView from '../view/TopView'
import { router } from '@kit.ArkUI';
import { ChatMsg, ChatParam } from '../service/ChatModel';
import { ChatInputView } from '../view/ChatInputView';
import { ChatTxtToItemView } from '../view/ChatTxtToItemView';
import { ChatTxtFromItemView } from '../view/ChatTxtFromItemView';
import { ChatVideoPhotoToItemView } from '../view/ChatVideoPhotoToItemView';
import { faceDetector } from '@kit.CoreVisionKit';
import { ChatVideoPhotoFromItemView } from '../view/ChatVideoPhotoFromItemView';
import { ChatAVCallToItemView } from '../view/ChatAVCallToItem';
import { ChatAVCallFromItemView } from '../view/ChatAVCallFromItem';
import { ChatVoiceToItemView } from '../view/ChatVoiceToItem';
import { ChatVoiceFromItemView } from '../view/ChatVoiceFromItem';
import { ChatInputViewEvent } from '../view/ChatInputView'

class InputViewEvent implements ChatInputViewEvent {
  onStartVoice(): void {
    console.log('start voice');
  }

  onStopVoice(): void {
    console.log('stop voice');
  }

  onCancelVoice(): void {
    console.log('cancel voice');
  }

  onSendTxt(value: string): void {
    console.log('request send msg:'+value);
  }

  onPhoto(): void {
    console.log('open photo');
  }

  onVideo(): void {
    console.log('open video');
  }

  onLocation(): void {
    console.log('location');
  }

  onPttCall(): void {
    console.log('ptt call');
  }

  onVoiceCall(): void {
    console.log('voice call');
  }

  onVideoCall(): void {
    console.log('video call');
  }
}

@Entry
@Component
struct Chat {
  private chatMsgList :ChatMsg[] = [];
  @State viewItem: TopView.ViewItem = new TopView.ViewItem('');
  private charparam :ChatParam = new ChatParam(0, 0, '');
  private chatlistScroller: Scroller = new Scroller();
  private timer:number = 0;

  private chatinputevent:InputViewEvent = new InputViewEvent();

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as ChatParam;
      this.charparam = param;
      this.viewItem = new TopView.ViewItem(this.charparam.convNm)
    }
    this.chatMsgList[0] = new ChatMsg(0, '1', 'user1', 0, 1103, 'hello', '', '', 0, 1735286634);
    this.chatMsgList[1] = new ChatMsg(0, '1', 'user1', 0, 1103, 'hello', '', '', 0, 1735286634);
    this.chatMsgList[2] = new ChatMsg(1, '2', 'user2', 0, 1, '89', '', '', 0, 1735286644);
    this.chatMsgList[3] = new ChatMsg(2, '1', 'user1', 0, 1104, '', 'http://chn-gwsd-fs-ex.hawk-sight.com:8790/group2/M00/31/31/o4YBAGb1NGaAKpZiAAdJJ4jMa8M087.jpg', '', 0, 1735286654);
    this.chatMsgList[4] = new ChatMsg(3, '2', 'user2', 0, 1103, 'hi', '', '', 0, 1735286664);
    this.chatMsgList[5] = new ChatMsg(4, '1', 'user1', 0, 1, '78', '', '', 0, 1735286674);
    this.chatMsgList[6] = new ChatMsg(5, '2', 'user2', 0, 1105, '', '', 'http://chn-gwsd-fs-ex.hawk-sight.com:8790/group2/M00/31/31/o4YBAGb1NGaAKpZiAAdJJ4jMa8M087.jpg', 0, 1735286684);
    this.chatMsgList[7] = new ChatMsg(6, '1', 'user1', 0, 1103, 'hello', '', '', 0, 1735286694);
    this.chatMsgList[8] = new ChatMsg(7, '2', 'user2', 0, 1105, '', '', 'http://chn-gwsd-fs-ex.hawk-sight.com:8790/group2/M00/31/31/o4YBAGb1NGaAKpZiAAdJJ4jMa8M087.jpg', 0, 1735286704);
    this.chatMsgList[9] = new ChatMsg(8, '1', 'user1', 0, 1103, 'hello', '', '', 0, 1735286714);
    this.chatMsgList[10] = new ChatMsg(9, '1', 'user1', 0, 1104, '', 'http://chn-gwsd-fs-ex.hawk-sight.com:8790/group2/M00/31/31/o4YBAGb1NGaAKpZiAAdJJ4jMa8M087.jpg', '', 0, 1735286724);
    this.chatMsgList[11] = new ChatMsg(10, '2', 'user2', 0, 0, '0', '', '', 0, 1735286734);
    this.chatMsgList[12] = new ChatMsg(11, '2', 'user2', 0, 0, '55', '', '', 0, 1735286744);
    this.chatMsgList[13] = new ChatMsg(12, '1', 'user1', 0, 0, '0', '', '', 0, 1735286754);
    this.chatMsgList[14] = new ChatMsg(13, '1', 'user1', 0, 0, '103', '', '', 0, 1735286764);
    this.chatMsgList[15] = new ChatMsg(14, '2', 'user2', 0, 1103, '哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈', '', '', 0, 1735286774);
    this.chatMsgList[16] = new ChatMsg(15, '1', 'user1', 0, 1103, '哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈', '', '', 0, 1735286784);
    this.chatMsgList[17] = new ChatMsg(16, '2', 'user2', 0, 1103, '哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈', '', '', 0, 1735286794);
    this.chatMsgList[18] = new ChatMsg(17, '2', 'user2', 0, 1106, '', '', '', 0, 1735286804);
    this.chatMsgList[19] = new ChatMsg(18, '1', 'user1', 0, 1106, '', '', '', 0, 1735286814);
    this.chatMsgList[20] = new ChatMsg(19, '1', 'user1', 0, 1103, '好好好好好好好好好好好好好好好好好好好好好好好好好好好好', '', '', 0, 1735286824);
    this.chatMsgList[21] = new ChatMsg(20, '1', 'user1', 0, 1, '0', '', '', 0, 1735286834);
  }

  onPageShow(): void {
    this.timer = setInterval(()=>{
      this.chatlistScroller.scrollToIndex(6, true);
      clearInterval(this.timer)
    }, 300);
  }

  build() {
    RelativeContainer() {
      TopView.View({
        showRight: false,
        rotateVal: 0,
        viewItem: this.viewItem,
        onLeftClick: ()=>{
          router.back();
        }
      })
        .id('topview')
        .alignRules({
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          }
        })
      List({scroller: this.chatlistScroller}) {
        ForEach(this.chatMsgList, (item : ChatMsg)=>{
          ListItem() {
            if (item.senderId === '1') {
              if (item.msgType === 1103) {
                ChatTxtToItemView({ sender: item.senderNm, content: item.content });
              } else if (item.msgType === 1104) {
                ChatVideoPhotoToItemView({ sender: item.senderNm, url: item.url, video: false});
              } else if (item.msgType === 1105) {
                ChatVideoPhotoToItemView({ sender: item.senderNm, url: item.url, thumburl: item.thumburl, video: true});
              } else if (item.msgType === 1106) {
                ChatVoiceToItemView({ sender: item.senderNm, url: item.url });
              } else if (item.msgType === 0) {
                ChatAVCallToItemView({ sender: item.senderNm, time: item.content, video: false});
              } else if (item.msgType === 1) {
                ChatAVCallToItemView({ sender: item.senderNm, time: item.content, video: true});
              }
            } else {
              if (item.msgType === 1103) {
                ChatTxtFromItemView({ sender: item.senderNm, content: item.content });
              } else if (item.msgType === 1104) {
                ChatVideoPhotoFromItemView({ sender: item.senderNm, url: item.url, video: false});
              } else if (item.msgType === 1105) {
                ChatVideoPhotoFromItemView({ sender: item.senderNm, url: item.url, thumburl: item.thumburl, video: true});
              } else if (item.msgType === 1106) {
                ChatVoiceFromItemView({ sender: item.senderNm, url: item.url });
              } else if (item.msgType === 0) {
                ChatAVCallFromItemView({ sender: item.senderNm, time: item.content, video: false});
              } else if (item.msgType === 1) {
                ChatAVCallFromItemView({ sender: item.senderNm, time: item.content, video: true});
              }
            }
          }
        },(item: ChatMsg) => item.id.toString())
      }
      .width('100%')
      .alignRules({
        top: {
          anchor: 'topview',
          align: VerticalAlign.Bottom
        },
        bottom: {
          anchor: 'inputview',
          align: VerticalAlign.Top
        }
      })
      ChatInputView({inputViewEvent:this.chatinputevent})
        .id('inputview')
        .width('100%')
        .height('auto')
        .alignRules({
          bottom:{
            anchor: "__container__",
            align: VerticalAlign.Bottom
          }
        })
    }
    .height('100%')
    .width('100%')
  }
}