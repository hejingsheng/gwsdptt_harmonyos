import { ChatListItemView } from "../view/ChatListItemView";
import { ChatParam } from "../service/ChatModel";
import { router } from "@kit.ArkUI";
import * as MsgConversationDB from "../db/MsgConversationDB"
import { getRDB } from "../db/DBManager"
import { GWSDKManager } from "../service/GWSDKManager";
import { MsgConversationBean } from "../db/MsgConversationBean";

@Component
export struct ChatListView {
  @State message: string = 'chatlist';
  private conversations :Array<MsgConversationBean> = [];

  aboutToAppear(): void {
    MsgConversationDB.queryConvList(getRDB(),GWSDKManager.getInstance().getUserInfo().id.toString())
      .then((list:MsgConversationBean[]) => {
        this.conversations = list;
      })
  }

  build() {
    List() {
      ForEach(this.conversations, (item : MsgConversationBean)=>{
        ListItem() {
          ChatListItemView({conv:item})
        }
        .onClick(()=>{
          let chatparam = new ChatParam(item.convId, item.convType, item.convNm)
          router.pushUrl({
            url: 'pages/Chat',
            params: chatparam
          })
        })
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