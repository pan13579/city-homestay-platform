import { ListingBrief } from '../../models/Listing';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { DateUtil } from '../../utils/DateUtil';
import { RatingStars } from '../common/RatingStars';

@Component
export struct BookingInfoCard {
  @Prop listing: ListingBrief | null = null;
  @Prop checkIn: string = '';
  @Prop checkOut: string = '';
  @Prop guests: number = 1;

  build() {
    if (this.listing) {
      Column() {
        Row() {
          // Thumbnail
          Image(this.listing.images && this.listing.images.length > 0
            ? ApiEndpoints.getImageUrl(this.listing.images[0])
            : '')
            .width(80)
            .height(60)
            .objectFit(ImageFit.Cover)
            .borderRadius(8);

          Column() {
            Text(this.listing.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Text(this.listing.address)
              .fontSize(11)
              .fontColor('#999999')
              .maxLines(1)
              .margin({ top: 2 });

            RatingStars({ rating: this.listing.avg_rating, starSize: 12 });
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 });
        }
        .width('100%');

        Divider()
          .strokeWidth(1)
          .color('#F0F0F0')
          .margin({ top: 12, bottom: 12 });

        Row() {
          Text('📅 入住')
            .fontSize(13)
            .fontColor('#666666');
          Text(DateUtil.formatDisplayDate(this.checkIn))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 });

          Blank();

          Text('📅 离店')
            .fontSize(13)
            .fontColor('#666666');
          Text(DateUtil.formatDisplayDate(this.checkOut))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 });
        }
        .width('100%');

        Row() {
          Text('👤 入住人数')
            .fontSize(13)
            .fontColor('#666666');
          Text(`${this.guests}人`)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 });
        }
        .width('100%')
        .margin({ top: 8 });
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 });
    }
  }
}
