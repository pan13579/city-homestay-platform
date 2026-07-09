@Component
export struct ProfileHeader {
  @Prop nickname: string = '点击登录';
  @Prop phone: string = '';
  @Prop avatar: string = '';
  @Prop isLoggedIn: boolean = false;

  build() {
    Column() {
      // Avatar
      Column() {
        if (this.isLoggedIn) {
          Text(this.nickname.substring(0, 1))
            .fontSize(32)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold);
        } else {
          Text('👤')
            .fontSize(32);
        }
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor(this.isLoggedIn ? '#FF8F5E' : 'rgba(255, 255, 255, 0.3)')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 });

      Text(this.nickname)
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 });

      if (this.isLoggedIn && this.phone) {
        Text(this.phone)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .opacity(0.8);
      }

      if (!this.isLoggedIn) {
        Text('登录/注册，享受更多服务')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .opacity(0.8);
      }
    }
    .width('100%')
    .padding({ top: 32, bottom: 32 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FF6B35')
    .borderRadius({ bottomLeft: 24, bottomRight: 24 });
  }
}
