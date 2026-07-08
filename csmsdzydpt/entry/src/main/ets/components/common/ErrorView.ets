@Component
export struct ErrorView {
  @Prop message: string = '加载失败';
  onRetry: () => void = () => {};

  build() {
    Column() {
      Text('😢')
        .fontSize(48)
        .margin({ bottom: 12 });

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 16 });

      Button('重新加载')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6B35')
        .borderRadius(20)
        .padding({ left: 24, right: 24 })
        .onClick(() => {
          this.onRetry();
        });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
