import { ListItemView } from '../view/ListItemView'
import { router } from '@kit.ArkUI';
import { GWSDKManager } from '../service/GWSDKManager';
import { GWGroupBean, GWType } from 'gwsdptt_sdk';
import { List as array }  from '@kit.ArkTS';

@Component
export struct GroupListView {

  @State isRefreshing: boolean = true;
  @State groups: GWGroupBean[] = [];
  private loadDataTimer:number = -1;

  private updateGroupList() {
    let i:number = 0;
    let groups: array<GWGroupBean> = GWSDKManager.getInstance().getGroupList();
    for (let groupsElement of groups) {
      this.groups[i] = groupsElement;
      i++;
    }
    this.isRefreshing = false;
    this.stopTimer();
  }

  private loadGroup() {
    GWSDKManager.getInstance().queryGroup();
    this.startTimer();
  }

  private startTimer() {
    this.loadDataTimer = setInterval(()=>{
      this.isRefreshing = false;
      // query fail
    }, 5000);
  }

  private stopTimer() {
    if (this.loadDataTimer != -1) {
      clearInterval(this.loadDataTimer);
    }
    this.loadDataTimer = -1;
  }

  aboutToAppear(): void {
    GWSDKManager.getInstance().registerPttObserver({
      onPttEvent:(event: number, data: string, data1: number) => {
        if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_GROUP) {
          this.updateGroupList();
        }
      },
      onMsgEvent:(event: number, data: string) => {

      }
    });
    this.loadGroup();
  }

  aboutToDisappear(): void {
    GWSDKManager.getInstance().registerPttObserver(undefined);
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }){
      List() {
        ForEach(this.groups, (item : GWGroupBean)=>{
          ListItem() {
            ListItemView({
              listIcon: $r('app.media.ic_group_p_blue'),
              listContent: item.name
            })
          }
          .onClick(()=>{
            let param = new GWGroupBean();
            param.gid = item.gid;
            param.name = item.name;
            param.type = item.type;
            router.pushUrl({
              url:'pages/GroupDetail',
              params: param
            });
          })
        },(item: GWGroupBean) => JSON.stringify(item.gid))
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
    .onRefreshing(()=>{
      this.loadGroup();
    })
  }
}