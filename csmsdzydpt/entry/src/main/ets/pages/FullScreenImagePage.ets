import { router } from '@kit.ArkUI';
import { ApiEndpoints } from '../constants/ApiEndpoints';

@Entry
@Component
struct FullScreenImagePage {
  @State images: string[] = [];
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      try {
        const imagesStr = String(params['images'] || '[]');
        this.images = JSON.parse(imagesStr) as string[];
      } catch {
        this.images = [];
      }
      this.currentIndex = Number(params['currentIndex'] || 0);
    }
  }

  build() {
    Column() {
      Stack() {
        // Image swiper
        Swiper() {
          ForEach(this.images, (img: string, index: number) => {
            Image(ApiEndpoints.getImageUrl(img))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .draggable(true);
          });
        }
        .width('100%')
        .height('100%')
        .index(this.currentIndex)
        .indicator(
          new DotIndicator()
            .color('#66FFFFFF')
            .selectedColor('#FF6B35')
        );

        // Close button
        Button() {
          Text('✕')
            .fontSize(20)
            .fontColor('#FFFFFF');
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#66000000')
        .position({ x: 16, y: 16 })
        .onClick(() => {
          router.back();
        });

        // Counter
        Text(`${this.currentIndex + 1} / ${this.images.length}`)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .borderRadius(12)
          .backgroundColor('#66000000')
          .position({ x: '50%', y: 16 })
          .translate({ x: '-50%', y: 0 });
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000');
  }
}
