@Component
export struct ProfileHeader {
  @Prop nickname: string = '旅行达人小王';
  @Prop phone: string = '138****0000';
  @Prop avatar: string = '';

  build() {
    Column() {
      // Avatar
      Column() {
        Text(this.nickname.substring(0, 1))
          .fontSize(32)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold);
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor('#FF8F5E')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 });

      Text(this.nickname)
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 });

      Text(this.phone)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .opacity(0.8);
    }
    .width('100%')
    .padding({ top: 32, bottom: 32 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FF6B35')
    .borderRadius({ bottomLeft: 24, bottomRight: 24 });
  }
}
