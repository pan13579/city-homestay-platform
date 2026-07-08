@Component
export struct RatingInput {
  @Link rating: number;
  @Prop starSize: number = 32;

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5], (star: number) => {
        Text(star <= this.rating ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(star <= this.rating ? '#FFB800' : '#DDDDDD')
          .margin({ right: 4 })
          .onClick(() => {
            this.rating = star;
          });
      });
    }
    .justifyContent(FlexAlign.Center);
  }
}
