import { ApiEndpoints } from '../../constants/ApiEndpoints';

@Component
export struct ListingCarousel {
  @Prop images: string[] = [];
  onImageTap: (index: number) => void = () => {};

  build() {
    if (this.images && this.images.length > 0) {
      Stack() {
        Swiper() {
          ForEach(this.images, (img: string, index: number) => {
            Image(ApiEndpoints.getImageUrl(img))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                this.onImageTap(index);
              });
          });
        }
        .width('100%')
        .height('100%')
        .indicator(
          new DotIndicator()
            .color('#99FFFFFF')
            .selectedColor('#FF6B35')
        );
      }
      .width('100%')
      .height(280);
    } else {
      // Placeholder when no images
      Row() {
        Text('🏠')
          .fontSize(48)
          .fontColor('#CCCCCC');
      }
      .width('100%')
      .height(280)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F5F5F5');
    }
  }
}
