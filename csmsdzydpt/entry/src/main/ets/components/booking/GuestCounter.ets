@Component
export struct GuestCounter {
  @Link guests: number;
  @Prop maxGuests: number = 8;

  build() {
    Row() {
      Text('入住人数')
        .fontSize(15)
        .fontColor('#1A1A1A');

      Blank();

      Button('-')
        .fontSize(18)
        .fontColor(this.guests <= 1 ? '#CCCCCC' : '#FF6B35')
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(this.guests <= 1 ? '#F5F5F5' : '#FFF0EB')
        .enabled(this.guests > 1)
        .onClick(() => {
          if (this.guests > 1) this.guests--;
        });

      Text(this.guests.toString())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width(40)
        .textAlign(TextAlign.Center);

      Button('+')
        .fontSize(18)
        .fontColor(this.guests >= this.maxGuests ? '#CCCCCC' : '#FF6B35')
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(this.guests >= this.maxGuests ? '#F5F5F5' : '#FFF0EB')
        .enabled(this.guests < this.maxGuests)
        .onClick(() => {
          if (this.guests < this.maxGuests) this.guests++;
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 });
  }
}
