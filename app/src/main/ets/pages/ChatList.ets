import { ChatListItemView } from "../view/ChatListItemView";
import { Session } from "../service/SessionModel";
import { ChatParam } from "../service/ChatModel";
import { router } from "@kit.ArkUI";

@Component
export struct ChatListView {
  @State message: string = 'chatlist';
  private sessions :Session[] = [];

  aboutToAppear(): void {
    this.sessions[0] = new Session(1, 0, 'session 1', 1, 'hello', '2024-12-24 20-07-07');
    this.sessions[1] = new Session(2, 3, 'session 2', 2, '哈哈', '2024-12-24 20-17-25');
    this.sessions[2] = new Session(3, 0, 'session 3', 0, '【语音通话】', '2024-12-25 18-06-09');
    this.sessions[3] = new Session(4, 0, 'session 4', 3, '【视频通话】', '2024-12-22 22-05-17');
    this.sessions[4] = new Session(5, 3, 'session 5', 10, 'hi', '2024-12-21 09-08-07');
  }

  build() {
    List() {
      ForEach(this.sessions, (item : Session)=>{
        ListItem() {
          ChatListItemView({session:item})
        }
        .onClick(()=>{
          let chatparam = new ChatParam(item.id, item.type, item.name)
          router.pushUrl({
            url: 'pages/Chat',
            params: chatparam
          })
        })
      },(item: Session) => item.type.toString()+'_'+item.id.toString())
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