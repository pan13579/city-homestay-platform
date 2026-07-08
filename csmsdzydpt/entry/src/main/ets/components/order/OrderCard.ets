import { OrderBrief } from '../../models/Order';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { getStatusLabel, getStatusColor } from '../../constants/OrderStatus';
import { DateUtil } from '../../utils/DateUtil';
import { PriceUtil } from '../../utils/PriceUtil';

@Component
export struct OrderCard {
  @Prop order: OrderBrief | null = null;
  onTap: () => void = () => {};

  build() {
    if (this.order) {
      Column() {
        Row() {
          // Listing cover
          Image(this.order.listing_cover
            ? ApiEndpoints.getImageUrl(this.order.listing_cover)
            : '')
            .width(80)
            .height(70)
            .objectFit(ImageFit.Cover)
            .borderRadius(8);

          Column() {
            Row() {
              Text(this.order.listing_title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1);

              Text(getStatusLabel(this.order.status))
                .fontSize(11)
                .fontColor(getStatusColor(this.order.status))
                .fontWeight(FontWeight.Medium);
            }
            .width('100%');

            Text(`${DateUtil.formatDisplayDate(this.order.check_in)} - ${DateUtil.formatDisplayDate(this.order.check_out)}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 });

            Text(`${this.order.nights}晚 · ${this.order.listing_city}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 });

            Text(PriceUtil.formatDetail(this.order.total_price))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B35')
              .margin({ top: 4 });
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%');
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 10 })
      .shadow({ radius: 4, color: '#10000000', offsetY: 1 })
      .onClick(() => this.onTap());
    }
  }
}
