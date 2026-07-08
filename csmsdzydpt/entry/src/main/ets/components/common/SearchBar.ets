@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索目的地、民宿名称';
  onTap: () => void = () => {};

  build() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ right: 8 });

      Text(this.placeholder)
        .fontSize(14)
        .fontColor('#999999')
        .layoutWeight(1);
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
    .borderRadius(22)
    .onClick(() => this.onTap());
  }
}
