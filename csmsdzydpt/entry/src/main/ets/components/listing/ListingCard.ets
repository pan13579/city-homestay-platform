import { ListingBrief } from '../../models/Listing';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { getRoomTypeLabel } from '../../constants/RoomTypes';
import { PriceUtil } from '../../utils/PriceUtil';
import { RatingStars } from '../common/RatingStars';

@Component
export struct ListingCard {
  @Prop listing: ListingBrief | null = null;
  onTap: () => void = () => {};

  build() {
    if (this.listing) {
      Column() {
        // Image
        Stack() {
          Image(this.listing.images && this.listing.images.length > 0
            ? ApiEndpoints.getImageUrl(this.listing.images[0])
            : '')
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 12, topRight: 12 });

          // Room type badge
          Text(getRoomTypeLabel(this.listing.room_type))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor('#66000000')
            .position({ x: 8, y: 8 });

          // Price badge
          Text(PriceUtil.getPerNight(this.listing.base_price))
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(4)
            .backgroundColor('#CCFF6B35')
            .position({ x: '100%', y: '100%' })
            .translate({ x: '-100%', y: '-100%' })
            .margin({ right: 8, bottom: 8 });
        }
        .width('100%')
        .height(140);

        // Info
        Column() {
          Text(this.listing.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%');

          Row() {
            Text(this.listing.city)
              .fontSize(12)
              .fontColor('#999999');
            Blank();
            Row() {
              RatingStars({ rating: this.listing.avg_rating, starSize: 12 });
              Text(` ${this.listing.review_count}条评价`)
                .fontSize(11)
                .fontColor('#999999');
            }
          }
          .width('100%')
          .margin({ top: 4 });
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 })
      .shadow({
        radius: 4,
        color: '#10000000',
        offsetY: 1
      })
      .onClick(() => {
        this.onTap();
      });
    }
  }
}
