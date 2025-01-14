import { ChatListItemView } from "../view/ChatListItemView";
import { MsgDB } from '../db/MsgDB';
import { GWSDKManager } from "../service/GWSDKManager";
import { MsgConversationBean } from "../db/MsgConversationBean";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { common } from "@kit.AbilityKit";
import AppAbility from "../appability/AppAbility";


@Component
export struct ChatListView {
  @State message: string = 'chatlist';
  @State conversations :Array<MsgConversationBean> = [];
  @Link allUnReadMsgNum:number;
  private ctx:common.UIAbilityContext|undefined;

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'ChatListView=%{public}s', msg);
  }

  private getUid() : string {
    return GWSDKManager.getInstance().getUserInfo().id.toString();
  }

  private calcAllUnReadMsg() {
    let num = 0;
    for (let conversationsElement of this.conversations) {
      num += conversationsElement.msgUnReadCnt;
    }
    this.allUnReadMsgNum = num;
    this.log('all unread msg='+num);
  }

  aboutToAppear(): void {
    this.log('aboutToAppear');
    MsgDB.getINSTANCE().queryConvList(this.getUid())
      .then((list:MsgConversationBean[]) => {
        this.conversations = list;
        this.conversations.sort((a:MsgConversationBean, b:MsgConversationBean) => {
          return b.lastMsgTime - a.lastMsgTime;
        });
        this.calcAllUnReadMsg();
      });
    this.ctx = getContext(this) as common.UIAbilityContext;
    this.ctx.eventHub.on('recvconv', (conv: MsgConversationBean) => {
      if (conv.id === -1) {
        this.conversations.push(conv);
        this.conversations.sort((a:MsgConversationBean, b:MsgConversationBean) => {
          return b.lastMsgTime - a.lastMsgTime;
        });
      }
      else {
        for (let i = 0; i < this.conversations.length; i++) {
          if (this.conversations[i].id === conv.id) {
            this.conversations[i].lastMsgId = conv.lastMsgId;
            this.conversations[i].lastMsgSenderNm = conv.lastMsgSenderNm;
            this.conversations[i].lastMsgType = conv.lastMsgType;
            this.conversations[i].lastMsgContent = conv.lastMsgContent;
            this.conversations[i].lastMsgTime = conv.lastMsgTime;
            this.conversations[i].msgUnReadCnt = conv.msgUnReadCnt;
          }
        }
        this.conversations.sort((a:MsgConversationBean, b:MsgConversationBean) => {
          return b.lastMsgTime - a.lastMsgTime;
        });
      }
      this.calcAllUnReadMsg();
      // MsgDB.queryConvList(getRDB(), this.getUid())
      //   .then((list:MsgConversationBean[]) => {
      //     //this.conversations = list;
      //   })
    })
  }

  aboutToDisappear(): void {
    this.log('aboutToDisappear');
  }

  build() {
    List() {
      ForEach(this.conversations, (item : MsgConversationBean)=>{
        ListItem() {
          ChatListItemView({conv:item, allUnReadMsgnum:this.allUnReadMsgNum})
        }
      },(item: MsgConversationBean) => item.convType.toString()+'_'+item.convId.toString())
    }
    .divider({
      strokeWidth: $r('app.float.line_height'),
      color: $r('app.color.colorLine2'),
      startMargin: '10vp',
      endMargin: '10vp'
    })
    .width('100%')
    .height('100%')
  }
}