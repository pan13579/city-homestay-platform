import { Review } from '../../models/Review';
import { RatingStars } from '../common/RatingStars';

@Component
export struct ReviewCard {
  @Prop review: Review | null = null;

  build() {
    if (this.review) {
      Column() {
        Row() {
          // Avatar placeholder
          Text('👤')
            .fontSize(20)
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#F5F5F5')
            .textAlign(TextAlign.Center);

          Column() {
            Text(this.review.user_name || '匿名用户')
              .fontSize(13)
              .fontColor('#1A1A1A')
              .fontWeight(FontWeight.Medium);

            Row() {
              RatingStars({ rating: this.review.rating, starSize: 12 });
              Text(this.review.created_at?.substring(0, 10) || '')
                .fontSize(11)
                .fontColor('#CCCCCC')
                .margin({ left: 8 });
            };
          }
          .margin({ left: 10 })
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%');

        if (this.review.content) {
          Text(this.review.content)
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
            .margin({ top: 10 })
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }

        // Review images if any
        if (this.review.images && this.review.images.length > 0) {
          Row() {
            ForEach(this.review.images.slice(0, 4), (img: string) => {
              Image(img)
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(4)
                .margin({ right: 6 });
            });
          }
          .width('100%')
          .margin({ top: 8 });
        }
      }
      .width('100%')
      .padding({ left: 0, right: 0, top: 12, bottom: 12 });
    }
  }
}
