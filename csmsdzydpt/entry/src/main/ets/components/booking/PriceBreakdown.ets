import { PriceUtil } from '../../utils/PriceUtil';

@Component
export struct PriceBreakdown {
  @Prop nights: number = 0;
  @Prop basePricePerNight: number = 0;
  @Prop baseTotal: number = 0;
  @Prop cleaningFee: number = 0;
  @Prop serviceFee: number = 0;
  @Prop totalPrice: number = 0;

  build() {
    Column() {
      Text('价格明细')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 12 });

      Column() {
        this.priceRow(PriceUtil.formatDetail(this.basePricePerNight), ` × ${this.nights}晚`,
          PriceUtil.formatDetail(this.baseTotal));

        if (this.cleaningFee > 0) {
          this.priceRow('清洁费', '', PriceUtil.formatDetail(this.cleaningFee));
        }

        if (this.serviceFee > 0) {
          this.priceRow('服务费', '', PriceUtil.formatDetail(this.serviceFee));
        }

        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')
          .margin({ top: 8, bottom: 8 });

        Row() {
          Text('总价')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A');
          Blank();
          Text(PriceUtil.formatDetail(this.totalPrice))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35');
        }
        .width('100%');
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 });
  }

  @Builder
  priceRow(label: string, sub: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#1A1A1A');
      Text(sub)
        .fontSize(12)
        .fontColor('#999999');
      Blank();
      Text(value)
        .fontSize(14)
        .fontColor('#1A1A1A');
    }
    .width('100%')
    .margin({ bottom: 6 });
  }
}
