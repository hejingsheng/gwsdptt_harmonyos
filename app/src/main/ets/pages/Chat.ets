import { Session } from '../service/SessionModel';
import * as TopView from '../view/TopView'
import { promptAction, router } from '@kit.ArkUI';
import { ChatMsg, ChatParam, ChatTime } from '../service/ChatModel';
import { ChatInputView } from '../view/ChatInputView';
import { ChatTxtToItemView } from '../view/ChatTxtToItemView';
import { ChatTxtFromItemView } from '../view/ChatTxtFromItemView';
import { ChatVideoPhotoToItemView } from '../view/ChatVideoPhotoToItemView';
import { ChatVideoPhotoFromItemView } from '../view/ChatVideoPhotoFromItemView';
import { ChatAVCallToItemView } from '../view/ChatAVCallToItem';
import { ChatAVCallFromItemView } from '../view/ChatAVCallFromItem';
import { ChatVoiceToItemView } from '../view/ChatVoiceToItem';
import { ChatVoiceFromItemView } from '../view/ChatVoiceFromItem';
import { ChatInputViewEvent } from '../view/ChatInputView'
import * as MsgDB from "../db/MsgDB"
import { getRDB } from "../db/DBManager"
import { GWSDKManager } from '../service/GWSDKManager';
import { MsgContentBean } from '../db/MsgContentBean';
import { GWMsgBean, GWType } from 'gwsdptt_sdk';
import TimeUtils from "../utils/TimeUtils"
import { common } from '@kit.AbilityKit';
import { MsgConversationBean } from '../db/MsgConversationBean';

const CHATTING_TIME_SPACE = 120;

@Entry
@Component
struct Chat {
  @State chatMsgArr :Array<object> = [];
  @State viewItem: TopView.ViewItem = new TopView.ViewItem('');
  private charparam :ChatParam = new ChatParam(0, 0, '');
  private chatlistScroller: Scroller = new Scroller();
  private timer:number = 0;
  private ctx:common.UIAbilityContext|undefined;

  private getUid() : string {
    return GWSDKManager.getInstance().getUserInfo().id.toString();
  }

  private addMessageList(msglist:MsgContentBean[]) {
    if (msglist.length > 0) {
      for (let msglistElement of msglist) {
        if (this.chatMsgArr.length === 0) {
          this.chatMsgArr.push(new ChatTime(msglistElement.time));
          this.chatMsgArr.push(new ChatMsg(msglistElement.id, msglistElement.senderId, msglistElement.senderNm,
            msglistElement.senderType, msglistElement.msgType, msglistElement.content,
            msglistElement.url, msglistElement.thumburl, msglistElement.playtime, msglistElement.time));
        }
        else {
          let lastMsg = this.chatMsgArr[this.chatMsgArr.length-1] as ChatMsg;
          if (msglistElement.time - lastMsg.time > CHATTING_TIME_SPACE) {
            this.chatMsgArr.push(new ChatTime(msglistElement.time));
            this.chatMsgArr.push(new ChatMsg(msglistElement.id, msglistElement.senderId, msglistElement.senderNm,
              msglistElement.senderType, msglistElement.msgType, msglistElement.content,
              msglistElement.url, msglistElement.thumburl, msglistElement.playtime, msglistElement.time));
          }
          else {
            this.chatMsgArr.push(new ChatMsg(msglistElement.id, msglistElement.senderId, msglistElement.senderNm,
              msglistElement.senderType, msglistElement.msgType, msglistElement.content,
              msglistElement.url, msglistElement.thumburl, msglistElement.playtime, msglistElement.time));
          }
        }
      }
    }
    this.ctx = getContext(this) as common.UIAbilityContext;
    this.ctx.eventHub.on('recvmsg', (msg: MsgContentBean) => {
      this.addMessage(msg);
    })
  }

  private addMessage(msg:MsgContentBean) {
    if (this.chatMsgArr.length === 0) {
      this.chatMsgArr.push(new ChatTime(msg.time));
      this.chatMsgArr.push(new ChatMsg(msg.id, msg.senderId, msg.senderNm,
        msg.senderType, msg.msgType, msg.content,
        msg.url, msg.thumburl, msg.playtime, msg.time));
      return;
    }
    let lastMsg = this.chatMsgArr[this.chatMsgArr.length-1] as ChatMsg;
    if (msg.time - lastMsg.time > CHATTING_TIME_SPACE) {
      this.chatMsgArr.push(new ChatTime(msg.time));
      this.chatMsgArr.push(new ChatMsg(msg.id, msg.senderId, msg.senderNm,
        msg.senderType, msg.msgType, msg.content,
        msg.url, msg.thumburl, msg.playtime, msg.time));
    }
    else {
      this.chatMsgArr.push(new ChatMsg(msg.id, msg.senderId, msg.senderNm,
        msg.senderType, msg.msgType, msg.content,
        msg.url, msg.thumburl, msg.playtime, msg.time));
    }
  }

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as ChatParam;
      this.charparam = param;
      this.viewItem = new TopView.ViewItem(this.charparam.convNm)
    }
    MsgDB.queryChatRecord(getRDB(), this.getUid(), this.charparam.convId, this.charparam.convType, 0, 30)
      .then((list:MsgContentBean[]) => {
        this.addMessageList(list);
      });
    MsgDB.updateConvRead(getRDB(), this.getUid(), this.charparam.convId, this.charparam.convType);
  }

  onPageShow(): void {
    this.timer = setInterval(()=>{
      //this.chatlistScroller.scrollToIndex(6, true);
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
      List({scroller: this.chatlistScroller, space: '5vp'}) {
        ForEach(this.chatMsgArr, (item : object)=>{
          ListItem() {
            if (item instanceof ChatTime) {
              Text(TimeUtils.formatDateTime(item.time*1000, 'YYYY-MM-DD HH:mm'))
                .width('100%')
                .height('auto')
                .fontSize($r('app.float.text_size_small'))
                .alignSelf(ItemAlign.Center)
                .textAlign(TextAlign.Center)
                .padding({
                  top:'5vp',
                  bottom:'5vp'
                })
                .fontColor($r('app.color.text_timer_color'))
            } else {
              if ((item as ChatMsg).senderId === this.getUid()) {
                if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
                  ChatTxtToItemView({ sender: (item as ChatMsg).senderNm, content: (item as ChatMsg).content });
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
                  ChatVideoPhotoToItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url, video: false});
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
                  ChatVideoPhotoToItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url, thumburl: (item as ChatMsg).thumburl, video: true});
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE) {
                  ChatVoiceToItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url });
                } else if ((item as ChatMsg).msgType === 0) {
                  ChatAVCallToItemView({ sender: (item as ChatMsg).senderNm, time: (item as ChatMsg).content, video: false});
                } else if ((item as ChatMsg).msgType === 1) {
                  ChatAVCallToItemView({ sender: (item as ChatMsg).senderNm, time: (item as ChatMsg).content, video: true});
                }
              } else {
                if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
                  ChatTxtFromItemView({ sender: (item as ChatMsg).senderNm, content: (item as ChatMsg).content });
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
                  ChatVideoPhotoFromItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url, video: false});
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
                  ChatVideoPhotoFromItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url, thumburl: (item as ChatMsg).thumburl, video: true});
                } else if ((item as ChatMsg).msgType === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE) {
                  ChatVoiceFromItemView({ sender: (item as ChatMsg).senderNm, url: (item as ChatMsg).url });
                } else if ((item as ChatMsg).msgType === 0) {
                  ChatAVCallFromItemView({ sender: (item as ChatMsg).senderNm, time: (item as ChatMsg).content, video: false});
                } else if ((item as ChatMsg).msgType === 1) {
                  ChatAVCallFromItemView({ sender: (item as ChatMsg).senderNm, time: (item as ChatMsg).content, video: true});
                }
              }
            }
          }
        },(item: object) => {
          if (item instanceof ChatTime) {
            let a = item as ChatTime;
            return a.id+'_'+a.time
          } else {
            let a = item as ChatMsg;
            return a.id.toString();
          }
        })
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
      ChatInputView({inputViewEvent: {
        onStartVoice:() => {

        },
        onStopVoice:() => {

        },
        onCancelVoice:() => {

        },
        onSendTxt: (value: string) => {
          if (!GWSDKManager.getInstance().hasMsgPermission()) {
            promptAction.showToast({
              message:$r('app.string.hint_notPermission'),
              duration:2000
            });
            return;
          }
          let gwMsgBean:GWMsgBean = GWSDKManager.getInstance().createMsgBean(this.charparam.convType, this.charparam.convId,
            this.charparam.convNm, GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT);
          gwMsgBean.data.content = value;
          GWSDKManager.getInstance().sendMsg(gwMsgBean);
          MsgDB.saveMsgContent(getRDB(), this.getUid(), gwMsgBean)
            .then((msg:MsgContentBean) => {
              MsgDB.saveOrUpdateConv(getRDB(), msg, false)
                .then((conv:MsgConversationBean) => {
                  this.addMessage(msg);
                  this.ctx?.eventHub.emit('recvconv', conv);
                });
            });
        },
        onPhoto:() => {

        },
        onVideo:() => {

        },
        onLocation:() => {

        },
        onPttCall:() => {

        },
        onVoiceCall:() => {

        },
        onVideoCall:() => {
          promptAction.showToast({
            message:$r('app.string.hint_login_failure'),
            duration:2000
          });
        }
      }})
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
    .backgroundColor($r('app.color.page_background_color'))
  }
}