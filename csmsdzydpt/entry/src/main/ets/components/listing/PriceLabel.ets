@Component
export struct PriceLabel {
  @Prop price: number = 0;
  @Prop fontSize: number = 20;

  build() {
    Row() {
      Text('¥')
        .fontSize(this.fontSize * 0.7)
        .fontColor('#FF6B35')
        .fontWeight(FontWeight.Bold);

      Text(this.price.toString())
        .fontSize(this.fontSize)
        .fontColor('#FF6B35')
        .fontWeight(FontWeight.Bold);

      Text('/晚')
        .fontSize(this.fontSize * 0.6)
        .fontColor('#999999');
    }
    .alignItems(VerticalAlign.Center);
  }
}
