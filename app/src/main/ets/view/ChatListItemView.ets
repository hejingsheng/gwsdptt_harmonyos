import { MsgConversationBean } from "../db/MsgConversationBean";
import { ChatParam } from "../service/ChatModel";
import TimeUtils from "../utils/TimeUtils"
import { router } from "@kit.ArkUI";

@Component
export struct ChatListItemView {
  @State isPress: boolean = false;
  //@State conv: MsgConversationBean = new MsgConversationBean(0, '', 0, 0, '', 0, 0, 0, '', 0, '', 0);
  @ObjectLink conv: MsgConversationBean;
  @Link allUnReadMsgnum:number;
  build() {
    RelativeContainer() {
      Badge({
        count: this.conv.msgUnReadCnt,
        position: BadgePosition.RightTop,
        style: {
          badgeSize: 12,
          badgeColor: $r('app.color.chat_list_tag_color')
        }
      }){
        Image(this.conv.convType == 0? $r('app.media.ic_member_online_blue'):$r('app.media.ic_group_p_blue'))
          .alignRules({
            center: {anchor: '__container__', align: VerticalAlign.Center},
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
      .id('sessicon')
      .width($r('app.float.list_icon_size'))
      .height($r('app.float.list_icon_size'))
      .margin({
        left: '5vp'
      })
      .alignRules({
        center: {anchor: '__container__', align: VerticalAlign.Center},
      })
      Text(this.conv.convNm)
        .id('sessname')
        .height('auto')
        .fontSize($r('app.float.text_size_normal'))
        .fontColor($r('app.color.text_base_color'))
        .alignRules({
          top: {
            anchor: "sessicon",
            align: VerticalAlign.Top
          },
          left: {
            anchor: 'sessicon',
            align: HorizontalAlign.End
          }
        })
        .margin({
          left: '18vp'
        })
      Text(this.conv.lastMsgContent)
        .id('groupid')
        .height('auto')
        .fontWeight(FontWeight.Normal)
        .fontSize($r('app.float.text_size_small'))
        .fontColor($r('app.color.text_hint_color'))
        .alignRules({
          top: {
            anchor: 'sessname',
            align: VerticalAlign.Bottom
          },
          left: {
            anchor: 'sessicon',
            align: HorizontalAlign.End
          }
        })
        .margin({
          top: '2vp',
          left: '20vp'
        })
      Text(TimeUtils.formatDateTime(this.conv.lastMsgTime*1000, 'YYYY-MM-DD HH:mm:ss'))
        .height('auto')
        .fontWeight(FontWeight.Normal)
        .fontSize($r('app.float.text_size_smallS'))
        .fontColor($r('app.color.text_hint_color'))
        .margin({
          right: '5vp'
        })
        .alignRules({
          top: {
            anchor: "sessicon",
            align: VerticalAlign.Top
          },
          right: {
            anchor: '__container__',
            align: HorizontalAlign.End
          }
        })
    }
    .width('100%')
    .height($r('app.float.char_list_item_height_size'))
    .backgroundColor(this.isPress ? $r('app.color.list_item_bg_color_p'): $r('app.color.list_item_bg_color'))
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPress = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPress = false;
      }
    })
    .onClick(()=>{
      this.allUnReadMsgnum -= this.conv.msgUnReadCnt;
      this.conv.msgUnReadCnt = 0;
      let chatparam = new ChatParam(this.conv.convId, this.conv.convType, this.conv.convNm)
      router.pushUrl({
        url: 'pages/Chat',
        params: chatparam
      })
    })
  }
}