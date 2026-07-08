@Component
export struct EmptyView {
  @Prop icon: string = '📭';
  @Prop message: string = '暂无数据';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 12 });

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999');
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
