import { Session } from "../service/SessionModel";

@Component
export struct ChatListItemView {
  @State isPress: boolean = false;
  @State session: Session = new Session(1, 0, '', 1, '', '');;
  build() {
    RelativeContainer() {
      Badge({
        count: this.session.unread,
        position: BadgePosition.RightTop,
        style: {
          badgeSize: 12,
          badgeColor: $r('app.color.chat_list_tag_color')
        }
      }){
        Image(this.session.type == 0? $r('app.media.ic_member_online_blue'):$r('app.media.ic_group_p_blue'))
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
      Text(this.session.name)
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
      Text(this.session.lastmsg)
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
      Text(this.session.lastmsgts)
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
  }
}