import { router } from '@kit.ArkUI';
import { ListingDetail, ListingBrief } from '../models/Listing';
import { OrderDetail } from '../models/Order';
import { ListingApi } from '../services/api/ListingApi';
import { OrderApi, PriceInfo } from '../services/api/OrderApi';
import { BookingInfoCard } from '../components/booking/BookingInfoCard';
import { GuestCounter } from '../components/booking/GuestCounter';
import { PriceBreakdown } from '../components/booking/PriceBreakdown';
import { DateUtil } from '../utils/DateUtil';

@Entry
@Component
struct BookingPage {
  private listingId: number = 0;
  @State checkIn: string = '';
  @State checkOut: string = '';
  @State guests: number = 1;
  @State nights: number = 1;

  @State listing: ListingDetail | null = null;
  @State priceInfo: PriceInfo | null = null;

  @State isLoading: boolean = true;
  @State isSubmitting: boolean = false;
  @State contactName: string = '旅行达人小王';
  @State contactPhone: string = '13800138000';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.listingId = Number(params['listingId'] || 0);
      this.checkIn = String(params['checkIn'] || '');
      this.checkOut = String(params['checkOut'] || '');
      this.guests = Number(params['guests'] || 1);
      this.nights = DateUtil.getNights(this.checkIn, this.checkOut);
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const listingResult = await ListingApi.getDetail(this.listingId);
      const priceInfoResult = await OrderApi.calculatePrice(this.listingId, this.checkIn, this.checkOut);
      this.listing = listingResult;
      this.priceInfo = priceInfoResult;
    } catch (err) {
      // Error
    }
    this.isLoading = false;
  }

  async onSubmit(): Promise<void> {
    if (this.isSubmitting) return;
    this.isSubmitting = true;
    try {
      const order = await OrderApi.createOrder(
        this.listingId, this.checkIn, this.checkOut, this.guests
      );

      // Simulate payment automatically
      const paidOrder = await OrderApi.pay(order.id);

      // Navigate to order detail
      router.replaceUrl({
        url: 'pages/OrderDetailPage',
        params: { orderId: paidOrder.id, paymentSuccess: true }
      });
    } catch (err) {
      const msg = err instanceof Error ? err.message : '下单失败，请重试';
      // Show error toast
    }
    this.isSubmitting = false;
  }

  build() {
    Column() {
      // Header
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        });

        Text('确认预订')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('').width(60);
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.listing) {
        Scroll() {
          Column() {
            // Booking info card
            Row() {
              BookingInfoCard({
                listing: this.listing as ListingBrief | null,
                checkIn: this.checkIn,
                checkOut: this.checkOut,
                guests: this.guests
              });
            }
            .width('100%');

            // Guest counter
            Row() {
              GuestCounter({
                guests: this.guests,
                maxGuests: this.listing.max_guests
              });
            }
            .width('100%');

            // Contact info
            Column() {
              Text('联系人信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .width('100%')
                .margin({ bottom: 12 });

              Row() {
                Text('姓名')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: this.contactName })
                  .fontSize(14)
                  .layoutWeight(1)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding(10)
                  .onChange((value: string) => {
                    this.contactName = value;
                  });
              }
              .width('100%')
              .margin({ bottom: 8 });

              Row() {
                Text('电话')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: this.contactPhone })
                  .fontSize(14)
                  .layoutWeight(1)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding(10)
                  .type(InputType.PhoneNumber)
                  .onChange((value: string) => {
                    this.contactPhone = value;
                  });
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 12 });

            // Price breakdown
            if (this.priceInfo) {
              Row() {
                PriceBreakdown({
                  nights: this.priceInfo.nights,
                  basePricePerNight: this.listing.base_price,
                  baseTotal: this.priceInfo.baseTotal,
                  cleaningFee: this.priceInfo.cleaningFee,
                  serviceFee: this.priceInfo.serviceFee,
                  totalPrice: this.priceInfo.totalPrice
                });
              }
              .width('100%');
            }

            // Cancellation policy note
            Column() {
              Text('📋 取消政策')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .margin({ bottom: 4 });
              Text('入住前24小时可免费取消，逾期取消将收取首晚房费。')
                .fontSize(12)
                .fontColor('#999999')
                .lineHeight(18);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFF8E1')
            .borderRadius(12)
            .margin({ top: 12, bottom: 80 });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8 });
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }

      // Submit button
      Row() {
        if (this.priceInfo) {
          Column() {
            Text(`总价: ¥${this.priceInfo.totalPrice.toFixed(2)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B35');
            Text(`${this.nights}晚 · ${this.guests}位房客`)
              .fontSize(11)
              .fontColor('#999999');
          }
          .alignItems(HorizontalAlign.Start);
        }

        Blank();

        Button() {
          Row() {
            if (this.isSubmitting) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#FFFFFF');
            } else {
              Text('提交订单并支付')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF');
            }
          };
        }
        .enabled(!this.isSubmitting && this.priceInfo !== null)
        .backgroundColor(this.isSubmitting ? '#CCCCCC' : '#FF6B35')
        .borderRadius(24)
        .padding({ left: 24, right: 24 })
        .onClick(() => this.onSubmit());
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 8, color: '#10000000', offsetY: -2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
