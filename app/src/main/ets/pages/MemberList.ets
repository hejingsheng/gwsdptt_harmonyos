import * as TopView from '../view/TopView'
import { router } from '@kit.ArkUI';
import { ListItemView } from '../view/ListItemView';
import { ChatParam } from '../service/ChatModel';
import { GWGroupBean } from 'gwsdptt_sdk/src/main/ets/bean/GWGroupListBean';
import { GWSDKManager } from '../service/GWSDKManager';
import { GWType, MemberInfo } from 'gwsdptt_sdk';
import { List as array }  from '@kit.ArkTS';

@Entry
@Component
struct MemberList {

  @State viewItem: TopView.ViewItem = new TopView.ViewItem($r('app.string.title_group_member'));
  private groupname: string = '';
  private gid: number = 0;
  private type: number = 0;

  @State members: MemberInfo[] = [];

  private updateMemberList() {
    let i:number = 0;
    let members: array<MemberInfo> = GWSDKManager.getInstance().getMemberList();
    for (let membersElement of members) {
      this.members[i] = membersElement;
      i++;
    }
  }

  aboutToAppear(): void {
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as GWGroupBean;
      this.groupname = param.name;
      this.gid = param.gid;
      this.type = param.type;
    }
    GWSDKManager.getInstance().registerPttObserver({
      onPttEvent:(event: number, data: string, data1: number) => {
        if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_MEMBER) {
          this.updateMemberList();
        }
      },
      onMsgEvent:(event: number, data: string) => {

      }
    });
    GWSDKManager.getInstance().queryMember(this.gid, this.type);
  }

  aboutToDisappear(): void {
    GWSDKManager.getInstance().registerPttObserver(undefined);
  }

  build() {
    Column() {
      TopView.View({
        showRight: false,
        rotateVal: 0,
        viewItem: this.viewItem,
        onLeftClick: ()=>{
          router.back();
        },
      })
        .id('topview')
        .alignRules({
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          }
        })
      List(){
        ForEach(this.members, (item : MemberInfo)=>{
          ListItem() {
            ListItemView({
              listIcon: $r('app.media.ic_member_online_blue'),
              listContent: item.name
            })
          }
          .onClick(()=>{
            let chatparam = new ChatParam(item.uid, 0, item.name)
            router.pushUrl({
              url: 'pages/Chat',
              params: chatparam
            })
          })
        },(item: MemberInfo) => JSON.stringify(item.uid))
      }
      .width('100%')
      .divider({
        strokeWidth: $r('app.float.line_height'),
        color: $r('app.color.colorLine2'),
        startMargin: '10vp',
        endMargin: '10vp'
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background_color'))
  }
}