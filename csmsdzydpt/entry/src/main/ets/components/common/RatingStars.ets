@Component
export struct RatingStars {
  @Prop rating: number = 0;
  @Prop starSize: number = 14;
  @Prop showValue: boolean = false;

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5], (star: number) => {
        Text(star <= Math.round(this.rating) ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(star <= Math.round(this.rating) ? '#FFB800' : '#DDDDDD')
          .margin({ right: 1 });
      });

      if (this.showValue) {
        Text(this.rating.toFixed(1))
          .fontSize(this.starSize)
          .fontColor('#FFB800')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 4 });
      }
    }
    .alignItems(VerticalAlign.Center);
  }
}
