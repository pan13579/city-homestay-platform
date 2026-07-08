@Component
export struct LoadingView {
  @Prop message: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#FF6B35');

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
