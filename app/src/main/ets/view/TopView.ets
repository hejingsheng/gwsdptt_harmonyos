import Animator, { AnimatorResult } from "@ohos.animator";
import { faceDetector } from "@kit.CoreVisionKit";

export class ViewItem {
  public title: ResourceStr = 'hello';
  public leftImg: Resource = $r('app.media.ic_top_back_day');
  public leftImgSelect: Resource = $r('app.media.ic_top_back_p');
  public showLeft: boolean = false;
  public rightImg: Resource = $r('app.media.ic_top_logining_day');
  public rightImgSelect: Resource = $r('app.media.ic_top_logining_day');
  constructor(title: ResourceStr) {
    this.title = title;
  }
}

@Component
export struct View {

  @State viewItem: ViewItem = new ViewItem('hello');
  @State isLeftPress: boolean = false;
  @State isRightPress: boolean = false;
  @Prop  showRight: boolean = false;
  @Prop  rotateVal: number = 0;

  onLeftClick?: () => void;
  onRightClick?: () => void;

  build() {
    Row() {
      Image(this.isLeftPress? this.viewItem.leftImgSelect : this.viewItem.leftImg)
        .width(40)
        .height(40)
        .visibility((this.onLeftClick||this.viewItem.showLeft)?Visibility.Visible:Visibility.Hidden)
        .onClick(()=>{
          if (this.onLeftClick) {
            this.onLeftClick();
          }
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down) {
            this.isLeftPress = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.isLeftPress = false;
          }
        })
      Text(this.viewItem.title)
        .textAlign(TextAlign.Center)
      Image(this.isRightPress? this.viewItem.rightImgSelect : this.viewItem.rightImg)
        .width(40)
        .height(40)
        .rotate({angle : this.rotateVal})
        .visibility((this.onRightClick||this.showRight)?Visibility.Visible:Visibility.Hidden)
        .onClick(()=>{
          if (this.onRightClick) {
            this.onRightClick();
          }
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down) {
            this.isRightPress = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.isRightPress = false;
          }
        })
    }
    .flexGrow(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(50)
    .backgroundColor($r('app.color.top_view_color'))
  }
}
