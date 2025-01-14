import * as TopView from '../view/TopView'
import { promptAction, router } from '@kit.ArkUI';
import { ChatParam } from '../service/ChatModel';
import { GWGroupBean } from 'gwsdptt_sdk/src/main/ets/bean/GWGroupListBean';
import { PttCallParam } from '../service/CallParam';
import { MsgDB } from '../db/MsgDB';
import { GWSDKManager } from '../service/GWSDKManager';

@Component
struct FuncItemView {
  @State image: Resource = $r('app.media.ic_chat');
  @State text: ResourceStr = '';
  @State press :boolean = false;

  build() {
    Row() {
      Image(this.image)
        .width($r('app.float.list_icon_size'))
        .height($r('app.float.list_icon_size'))
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
      Text(this.text)
        .fontColor(this.press?$r('app.color.text_select_color'):$r('app.color.text_base_color'))
        .margin({
          left: 10
        })
    }
    .width('100%')
    .height($r('app.float.item_size'))
    .backgroundColor(this.press? $r('app.color.list_item_bg_color_p'):$r('app.color.list_item_bg_color'))
    .justifyContent(FlexAlign.Center)
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.press = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.press = false;
      }
    })
  }
}

@Entry
@Component
struct GroupDetail {

  @State viewItem: TopView.ViewItem = new TopView.ViewItem($r('app.string.title_group_detail'));
  @State groupname: string = '';
  @State gid: number = 0;
  private type: number = 0;

  private getUid() : string {
    return GWSDKManager.getInstance().getUserInfo().id.toString();
  }

  aboutToAppear(): void {
    this.viewItem.rightImg = $r('app.media.ic_more_detail_day');
    this.viewItem.rightImgSelect = $r('app.media.ic_more_detail_p');
    if (router.getParams() != undefined && router.getParams() != null) {
      let param = router.getParams() as GWGroupBean;
      this.groupname = param.name;
      this.gid = param.gid;
      this.type = param.type;
    }
  }

  @Builder buildGroupTitle() {
    RelativeContainer(){
      Image($r('app.media.ic_gw_menu_group_64'))
        .id('groupicon')
        .width($r('app.float.group_icon_size'))
        .height($r('app.float.group_icon_size'))
      Text(this.groupname)
        .id('groupname')
        .height('auto')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.text_size_largeXXX'))
        .alignRules({
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          },
          left: {
            anchor: 'groupicon',
            align: HorizontalAlign.End
          }
        })
        .margin({
          left: '10vp'
        })
      Text(this.gid.toString())
        .id('groupid')
        .height('auto')
        .fontWeight(FontWeight.Normal)
        .fontSize($r('app.float.text_size_largeX'))
        .alignRules({
          top: {
            anchor: 'groupname',
            align: VerticalAlign.Bottom
          },
          left: {
            anchor: 'groupicon',
            align: HorizontalAlign.End
          }
        })
        .margin({
          left: '10vp'
        })
    }
    .width('100%')
    .height($r('app.float.group_detail_title_size'))
    .margin({
      top: '5vp'
    })
    Divider()
      .width('100%')
      .vertical(false)
      .color($r('app.color.colorLine'))
      .strokeWidth(1)
  }

  build() {
    Column() {
      TopView.View({
        showRight: true,
        rotateVal: 0,
        viewItem: this.viewItem,
        onLeftClick: ()=>{
          router.back();
        },
        onRightClick: ()=>{
          let param = new GWGroupBean();
          param.gid = this.gid;
          param.name = this.groupname;
          param.type = this.type;
          router.pushUrl({
            url:'pages/MemberList',
            params: param
          });
        }
      })
        .id('topview')
        .alignRules({
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          }
        })
      this.buildGroupTitle();
      Divider()
        .width('100%')
        .vertical(false)
        .color($r('app.color.colorLine'))
        .strokeWidth(1)
        .margin({
          top:30
        })
      FuncItemView({image:$r('app.media.ic_chat'), text:$r('app.string.send_msg')})
        .onClick(()=>{
          let chatparam = new ChatParam(this.gid, this.type, this.groupname)
          router.pushUrl({
            url: 'pages/Chat',
            params: chatparam
          })
        })
      Divider()
        .width('100%')
        .vertical(false)
        .color($r('app.color.colorLine'))
        .strokeWidth(1)
      FuncItemView({image:$r('app.media.ic_pttcall'), text:$r('app.string.half_duplex')})
        .onClick(()=>{
          let pttCallparam = new PttCallParam(this.gid, this.groupname, this.type, false);
          router.pushUrl({
            url: 'pages/PttCall',
            params: pttCallparam
          })
        })
      Divider()
        .width('100%')
        .vertical(false)
        .color($r('app.color.colorLine'))
        .strokeWidth(1)
      FuncItemView({image:$r('app.media.ic_notice'), text:$r('app.string.group_announcement')})
        .onClick(()=>{
          promptAction.showToast({
            message:$r('app.string.hint_exploit_ing'),
            duration:2000
          });
        })
      Divider()
        .width('100%')
        .vertical(false)
        .color($r('app.color.colorLine'))
        .strokeWidth(1)
      FuncItemView({image:$r('app.media.ic_delete'), text:$r('app.string.del_msg')})
        .onClick(()=>{
          MsgDB.getINSTANCE().deleteConv(this.getUid(), this.gid, this.type);
          promptAction.showToast({
            message:$r('app.string.successed'),
            duration:2000
          });
        })
      Divider()
        .width('100%')
        .vertical(false)
        .color($r('app.color.colorLine'))
        .strokeWidth(1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background_color'))
  }
}