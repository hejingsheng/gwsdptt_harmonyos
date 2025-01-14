import * as TopView from '../view/TopView'
import { promptAction, router } from '@kit.ArkUI';
import { ChatFileSelectParam, ChatFileMsgParam, ChatMsg, ChatParam, ChatTime } from '../service/ChatModel';
import { ChatInputView } from '../view/ChatInputView';
import { ChatTxtToItemView } from '../view/ChatTxtToItemView';
import { ChatTxtFromItemView } from '../view/ChatTxtFromItemView';
import { ChatVideoPhotoToItemView } from '../view/ChatVideoPhotoToItemView';
import { ChatVideoPhotoFromItemView } from '../view/ChatVideoPhotoFromItemView';
import { ChatAVCallToItemView } from '../view/ChatAVCallToItem';
import { ChatAVCallFromItemView } from '../view/ChatAVCallFromItem';
import { ChatVoiceToItemView } from '../view/ChatVoiceToItem';
import { ChatVoiceFromItemView } from '../view/ChatVoiceFromItem';
import { MsgDB } from '../db/MsgDB';
import { GWSDKManager } from '../service/GWSDKManager';
import { MsgContentBean } from '../db/MsgContentBean';
import { GWMsgBean, GWType } from 'gwsdptt_sdk';
import TimeUtils from "../utils/TimeUtils"
import { common } from '@kit.AbilityKit';
import { MsgConversationBean } from '../db/MsgConversationBean';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';
import AppAbility from '../appability/AppAbility';
import { ChatFileSendService } from '../service/ChatFileSendService';
import { AudioCallParam, PttCallParam } from '../service/CallParam';

const CHATTING_TIME_SPACE = 120;

@Entry
@Component
struct Chat {
  @State chatMsgArr :Array<object> = [];
  @State viewItem: TopView.ViewItem = new TopView.ViewItem('');
  private chatparam :ChatParam = new ChatParam(0, 0, '');
  private chatlistScroller: Scroller = new Scroller();
  private timer:number = 0;
  private ctx:common.UIAbilityContext|undefined;
  private callfunc:boolean = false;

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'Chat=%{public}s', msg);
  }

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
      MsgDB.getINSTANCE().updateConvRead(this.getUid(), this.chatparam.convId, this.chatparam.convType);
      this.addMessage(msg);
    });
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
    this.timer = setInterval(()=>{
      this.chatlistScroller.scrollToIndex(this.chatMsgArr.length-1);
      clearInterval(this.timer)
    }, 300);
  }

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as ChatParam;
      this.chatparam = param;
      this.viewItem = new TopView.ViewItem(this.chatparam.convNm)
    }
    MsgDB.getINSTANCE().queryChatRecord(this.getUid(), this.chatparam.convId, this.chatparam.convType, 0, 30)
      .then((list:MsgContentBean[]) => {
        this.addMessageList(list);
        this.timer = setInterval(()=>{
          this.chatlistScroller.scrollToIndex(this.chatMsgArr.length-1, true, ScrollAlign.START);
          clearInterval(this.timer)
        }, 300);
      });
    MsgDB.getINSTANCE().updateConvRead(this.getUid(), this.chatparam.convId, this.chatparam.convType);
    this.callfunc = this.chatparam.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER?true:false;
  }

  private async openPhotoPicker() : Promise<ChatFileSelectParam> {
    let selectFile:ChatFileSelectParam = new ChatFileSelectParam('', -1);
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      await photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        this.log('PhotoViewPicker.select successfully, PhotoSelectResult uri:' + JSON.stringify(PhotoSelectResult));
        selectFile.filepath = PhotoSelectResult.photoUris[0];
        selectFile.filetype = ChatFileMsgParam.PHOTO_FILE_TYPE;
        return selectFile;
      }).catch((err: BusinessError) => {
        this.log('PhotoViewPicker.select failed with err:'+err.code+':'+err.message);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      this.log('PhotoViewPicker failed with err:'+err.code+':'+err.message);
    }
    return selectFile;
  }

  private handleFileSend(selectFile:ChatFileSelectParam) {
    let filepath = selectFile.filepath;
    let filetype = selectFile.filetype;
    let filethumb = '';
    if (filepath === '' || filepath === undefined || filetype === -1) {
      return;
    }
    let msgtype = GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO;
    if (selectFile.filetype === ChatFileMsgParam.VIDEO_FILE_TYPE) {
      // video file
      filethumb = '';
      msgtype = GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO;
    }
    else if (selectFile.filetype === ChatFileMsgParam.VOICE_FILE_TYPE) {
      msgtype = GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE;
    }
    let gwMsgBean:GWMsgBean = GWSDKManager.getInstance().createMsgBean(this.chatparam.convType, this.chatparam.convId, this.chatparam.convNm, msgtype);
    let chatFileMsgParam:ChatFileMsgParam = new ChatFileMsgParam('', 0, '', gwMsgBean);
    this.log('file send task:'+filepath);
    chatFileMsgParam.msg = gwMsgBean;
    chatFileMsgParam.filepath = filepath;
    chatFileMsgParam.filetype = filetype;
    chatFileMsgParam.filepathThumb = filethumb;
    promptAction.showToast({
      message:$r('app.string.hint_uploading'),
      duration:3000
    });
    if (!GWSDKManager.getInstance().hasMsgPermission()) {
      promptAction.showToast({
        message:$r('app.string.hint_notPermission'),
        duration:2000
      });
      return;
    }
    this.log('start file send task');
    ChatFileSendService.getINSTANCE().sendMediaFile(chatFileMsgParam, this.ctx!);
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
        .expandSafeArea([SafeAreaType.KEYBOARD])
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
      .edgeEffect(EdgeEffect.Fade)
      ChatInputView({showCall: this.callfunc, inputViewEvent: {
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
          if (value === '') {
            return;
          }
          let gwMsgBean:GWMsgBean = GWSDKManager.getInstance().createMsgBean(this.chatparam.convType, this.chatparam.convId,
            this.chatparam.convNm, GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT);
          gwMsgBean.data.content = value;
          GWSDKManager.getInstance().sendMsg(gwMsgBean);
          MsgDB.getINSTANCE().saveMsgContent(this.getUid(), gwMsgBean)
            .then((msg:MsgContentBean) => {
              MsgDB.getINSTANCE().saveOrUpdateConv(msg, false)
                .then((conv:MsgConversationBean) => {
                  this.addMessage(msg);
                  this.ctx?.eventHub.emit('recvconv', conv);
                });
            });
        },
        onPhoto:() => {
          if (!GWSDKManager.getInstance().hasMsgPermission()) {
            promptAction.showToast({
              message:$r('app.string.hint_notPermission'),
              duration:2000
            });
            return;
          }
          this.openPhotoPicker().then((selectfile:ChatFileSelectParam) => {
            this.handleFileSend(selectfile);
          })
        },
        onVideo:() => {
          promptAction.showToast({
            message:$r('app.string.hint_exploit_ing'),
            duration:2000
          });
        },
        onLocation:() => {
          promptAction.showToast({
            message:$r('app.string.hint_exploit_ing'),
            duration:2000
          });
        },
        onPttCall:() => {
          let create = false;
          if (this.chatparam.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER) {
            create = true;
          }
          else {
            create = false;
          }
          let pttCallparam = new PttCallParam(this.chatparam.convId, this.chatparam.convNm, this.chatparam.convType, create);
          router.pushUrl({
            url: 'pages/PttCall',
            params: pttCallparam
          })
        },
        onVoiceCall:() => {
          let audioCallparam = new AudioCallParam(this.chatparam.convId, this.chatparam.convNm, true);
          router.pushUrl({
            url: 'pages/AudioCall',
            params: audioCallparam
          })
        },
        onVideoCall:() => {
          promptAction.showToast({
            message:$r('app.string.hint_exploit_ing'),
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