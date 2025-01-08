@Entry
@Component
struct ScrollTextPage {
  dataLong: string =
    '俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,' +
      '俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本2,俺是超长文本2,俺是超长文本2,俺是超长文本2,' +
      '俺是超长文本2,俺是超长文本3,俺是超长文本3,俺是超长文本3,俺是超长文本3,'
  datashort3: string =
    '俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1,俺是超长文本1'
  datashort1: string =
    '俺是超长文本1,俺是超长文本1,俺是超长文本1'

  build() {
    Column() {
      //大于4行
      Scroll() {
        Text(this.dataLong)
          .width('100%')
          .backgroundColor('#c0c0c0')
      }.width('100%')
      .constraintSize({ maxHeight: 50 })//scroller高度自适应
      .margin({ top: 50, left: 10, right: 10 })
      //3行
      Scroll() {
        Text(this.datashort3)
          .width('100%')
          .backgroundColor('#c0c0c0')
      }
      .width('100%')
      .backgroundColor(Color.Red)
      .constraintSize({ maxHeight: 75 })//scroller高度自适应
      .margin({ top: 50, left: 10, right: 10 })
      //1行
      Scroll() {
        Text(this.datashort1)
          .width('100%')
          .backgroundColor('#c0c0c0')
      }.width('100%')
      .backgroundColor(Color.Red)
      .constraintSize({ maxHeight: 75 }) //scroller高度自适应
      .margin({ top: 50, left: 10, right: 10 })
    }
    .height('100%')
  }
}