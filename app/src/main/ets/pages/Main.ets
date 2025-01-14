import * as TopView from '../view/TopView'
import { ChatListView } from './ChatList';
import { GroupListView } from './GroupList';
import { MeView } from './Me';
import { common } from '@kit.AbilityKit';
import AppAbility from '../appability/AppAbility';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { OfflineEventBean } from '../service/OfflineEventBean';
import { promptAction } from '@kit.ArkUI';

class tabBarItem {
  normalImg?: Resource;
  selectImg?: Resource;
  txt?: ResourceStr;
  index: number = 0;
  flag: boolean = false;
}

@Entry
@Component
struct Main {

  @State currendIndex: number = 0;
  @State viewItem: TopView.ViewItem = new TopView.ViewItem($r('app.string.main_tab_chat'));
  @State showRight: boolean = false;
  @State rotateVal: number = 0;
  @State unReadMsgNum: number = 0;
  private tabController: TabsController = new TabsController();
  private ctx:common.UIAbilityContext|undefined;
  private timer:number = 0;

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'GWSDKManager=%{public}s', msg);
  }

  aboutToAppear(): void {
    this.ctx = getContext(this) as common.UIAbilityContext;
    this.ctx.eventHub.on('login', (result:number)=>{
      if (result === 0) {
        this.stop();
        this.showRight = false;
      }
      else {
        promptAction.showToast({
          message:$r('app.string.hint_login_failure'),
          duration:2000
        })
      }
    });
    this.ctx.eventHub.on('offline', (code:number, reason:string)=>{
      this.log('offline:'+code);
      if (code === OfflineEventBean.OFFLINE_REASON_KICKOUT_CODE) {
        promptAction.showToast({
          message:$r('app.string.hint_loging_otherterminals'),
          duration:2000
        })
      }
      else if (code === OfflineEventBean.OFFLINE_REASON_ERROR_CODE) {
        promptAction.showToast({
          message:$r('app.string.hint_network_err'),
          duration:2000
        })
      }
      this.showRight = true;
      this.start();
    });
  }

  onBackPress(): boolean | void {
    (getContext(this) as common.UIAbilityContext).windowStage.getMainWindowSync().minimize().then(()=>{
      this.log('goto back');
    });
    return true;
  }

  private start(): void {
    this.timer = setInterval(()=>{
      this.rotateVal += 10;
      if (this.rotateVal >= 360) {
        this.rotateVal = 0;
      }
    }, 40);
  }

  private stop(): void {
    if (this.timer != 0) {
      clearInterval(this.timer);
      this.timer = 0;
    }
  }

  @Builder tabBarBuild(item: tabBarItem) {
    Column() {
      if (!item.flag) {
        Image(this.currendIndex === item.index ? item.selectImg : item.normalImg)
          .width(25)
          .height(25)
        Text(item.txt)
          .fontColor(this.currendIndex === item.index ? $r('app.color.text_select_color') :
          $r('app.color.text_base_color'))
      }
      else {
        Badge({
          count: this.unReadMsgNum,
          position: BadgePosition.RightTop,
          style: {
            badgeSize: 12,
            badgeColor: $r('app.color.chat_list_tag_color')
          }
        }){
          Image(this.currendIndex === item.index ? item.selectImg : item.normalImg)
        }
        .width(25)
        .height(25)
        Text(item.txt)
          .fontColor(this.currendIndex === item.index ? $r('app.color.text_select_color') :
          $r('app.color.text_base_color'))
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.tab_background_color'))
    .onClick(()=>{
      this.currendIndex = item.index;
      this.tabController.changeIndex(this.currendIndex);
    })
  }

  build() {
    RelativeContainer() {
      if (this.currendIndex !== 2) {
        TopView.View({ showRight: this.showRight, rotateVal: this.rotateVal, viewItem: this.viewItem})
          .id('topview')
          .alignRules({
            top: {
              anchor: "__container__",
              align: VerticalAlign.Top
            }
          })
      }
      Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
        TabContent() {
          ChatListView({allUnReadMsgNum:this.unReadMsgNum});
        }
        .tabBar(this.tabBarBuild({
          normalImg: $r('app.media.ic_main_tab_chat_day'),
          selectImg: $r('app.media.ic_main_tab_chat_p'),
          txt: $r('app.string.main_tab_chat'),
          index: 0,
          flag:true
        }))

        TabContent() {
          GroupListView();
        }
        .tabBar(this.tabBarBuild({
          normalImg: $r('app.media.ic_main_tab_grp_day'),
          selectImg: $r('app.media.ic_main_tab_grp_p'),
          txt: $r('app.string.main_tab_grp'),
          index: 1,
          flag:false
        }))

        TabContent() {
          MeView();
        }
        .tabBar(this.tabBarBuild({
          normalImg: $r('app.media.ic_main_tab_me_day'),
          selectImg: $r('app.media.ic_main_tab_me_p'),
          txt: $r('app.string.main_tab_my'),
          index: 2,
          flag:false
        }))
      }
      .id('tabitem')
      .alignRules({
        top: {
          anchor: "topview",
          align: VerticalAlign.Bottom
        },
        bottom: {
          anchor: "__container__",
          align: VerticalAlign.Bottom
        }
      })
      .vertical(false)
      .barWidth('100%')
      .barHeight(70)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .tabIndex(0)
      .backgroundColor($r('app.color.page_background_color'))
      .onChange((index: number) => {
        this.currendIndex = index;
        if (this.currendIndex === 0) {
          this.viewItem.title = $r('app.string.main_tab_chat');
        } else if (this.currendIndex === 1) {
          this.viewItem.title = $r('app.string.main_tab_grp');
        } else {
          this.viewItem.title = $r('app.string.main_tab_my');
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}


