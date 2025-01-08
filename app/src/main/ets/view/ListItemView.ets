@Component
export struct ListItemView {
  private listIcon: Resource = $r('app.media.ic_group_p_blue');
  private listContent: string = '';
  @State isPress: boolean = false;
  build() {
    Row() {
      Image(this.listIcon)
        .width($r('app.float.list_icon_size'))
        .height($r('app.float.list_icon_size'))
        .margin({left: 10})
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
      Text(this.listContent)
        .margin({left: 10})
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
    }
    .width('100%')
    .height($r('app.float.list_item_height_size'))
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