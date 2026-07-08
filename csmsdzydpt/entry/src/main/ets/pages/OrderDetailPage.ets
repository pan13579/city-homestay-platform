import { router } from '@kit.ArkUI';
import { OrderDetail } from '../models/Order';
import { OrderApi } from '../services/api/OrderApi';
import { ApiEndpoints } from '../constants/ApiEndpoints';
import { getStatusLabel, getStatusColor } from '../constants/OrderStatus';
import { StatusBadge } from '../components/common/StatusBadge';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';

@Entry
@Component
struct OrderDetailPage {
  private orderId: number = 0;
  @State order: OrderDetail | null = null;
  @State isLoading: boolean = true;
  @State isActionLoading: boolean = false;
  @State paymentSuccess: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.orderId = Number(params['orderId'] || 0);
      this.paymentSuccess = Boolean(params['paymentSuccess'] || false);
    }
    this.loadOrder();
  }

  async loadOrder(): Promise<void> {
    this.isLoading = true;
    try {
      this.order = await OrderApi.getDetail(this.orderId);
    } catch (err) {
      // Error
    }
    this.isLoading = false;
  }

  async onAction(action: string): Promise<void> {
    if (this.isActionLoading) return;
    this.isActionLoading = true;
    try {
      switch (action) {
        case 'pay':
          this.order = await OrderApi.pay(this.orderId);
          break;
        case 'cancel':
          this.order = await OrderApi.cancel(this.orderId);
          break;
        case 'checkin':
          this.order = await OrderApi.checkin(this.orderId);
          break;
        case 'complete':
          this.order = await OrderApi.complete(this.orderId);
          break;
      }
    } catch (err) {
      const msg = err instanceof Error ? err.message : '操作失败';
    }
    this.isActionLoading = false;
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (!this.order) {
        Column() {
          Text('订单不存在').fontSize(16).fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Column() {
      // Header
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());

        Text('订单详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('').width(60);
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      Scroll() {
        Column() {
          // Status header
          Column() {
            StatusBadge({ status: this.order!.status });

            Text(this.getStatusMessage())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .margin({ top: 8 });
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 8, bottom: 12 })
          .alignItems(HorizontalAlign.Center);

          // Listing info
          Column() {
            Row() {
              Image(this.order!.listing_cover
                ? ApiEndpoints.getImageUrl(this.order!.listing_cover)
                : '')
                .width(100)
                .height(80)
                .objectFit(ImageFit.Cover)
                .borderRadius(8);

              Column() {
                Text(this.order!.listing_title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .maxLines(2);

                Text(`📍 ${this.order!.listing_address}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 });

                Text(`👨‍💼 房东: ${this.order!.host_name}`)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 2 });
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 });
            }
            .width('100%');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, bottom: 12 });

          // Stay info
          Column() {
            this.infoRow('📅 入住日期', DateUtil.formatDisplayDate(this.order!.check_in));
            Divider().strokeWidth(0.5).color('#F0F0F0');
            this.infoRow('📅 离店日期', DateUtil.formatDisplayDate(this.order!.check_out));
            Divider().strokeWidth(0.5).color('#F0F0F0');
            this.infoRow('🌙 住宿天数', `${this.order!.nights}晚`);
            Divider().strokeWidth(0.5).color('#F0F0F0');
            this.infoRow('👤 入住人数', `${this.order!.guests}人`);
            Divider().strokeWidth(0.5).color('#F0F0F0');
            this.infoRow('🕐 下单时间', this.order!.created_at?.substring(0, 10) || '');
            if (this.order!.paid_at) {
              Divider().strokeWidth(0.5).color('#F0F0F0');
              this.infoRow('💳 支付时间', this.order!.paid_at.substring(0, 10));
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, bottom: 12 });

          // Price info
          Column() {
            Text('费用明细')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .width('100%')
              .margin({ bottom: 12 });

            this.priceRow('房费', PriceUtil.formatDetail(this.order!.base_total));
            this.priceRow('清洁费', PriceUtil.formatDetail(this.order!.cleaning_fee));
            this.priceRow('服务费', PriceUtil.formatDetail(this.order!.service_fee));
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 8, bottom: 8 });
            Row() {
              Text('实付总额')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A');
              Blank();
              Text(PriceUtil.formatDetail(this.order!.total_price))
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35');
            }
            .width('100%');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, bottom: 100 });
        }
        .width('100%');
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1);

      // Bottom action buttons
      if (this.hasActions()) {
        Row() {
          // Cancel button
          if (this.order!.status === 'pending_payment' || this.order!.status === 'confirmed') {
            Button('取消订单')
              .fontSize(14)
              .fontColor('#F44336')
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#F44336', style: BorderStyle.Solid })
              .borderRadius(24)
              .padding({ left: 24, right: 24 })
              .layoutWeight(1)
              .onClick(() => this.onAction('cancel'));
          }

          // Primary action button
          if (this.getPrimaryAction()) {
            Button() {
              if (this.isActionLoading) {
                LoadingProgress().width(20).height(20).color('#FFFFFF');
              } else {
                Text(this.getPrimaryAction()!)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF');
              }
            }
            .enabled(!this.isActionLoading)
            .backgroundColor(this.isActionLoading ? '#CCCCCC' : '#FF6B35')
            .borderRadius(24)
            .padding({ left: 24, right: 24 })
            .layoutWeight(1)
            .margin({ left: 8 })
            .onClick(() => this.onAction(this.getActionType()));
          }

          // Review button for completed orders
          if (this.order!.status === 'completed' && !this.order!.has_review) {
            Button('写评价')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor('#2EC4B6')
              .borderRadius(24)
              .padding({ left: 24, right: 24 })
              .layoutWeight(1)
              .margin({ left: 8 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ReviewSubmitPage',
                  params: { orderId: this.order!.id, listingId: this.order!.listing_id }
                });
              });
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 8, color: '#10000000', offsetY: -2 });
      }
    }
    .layoutWeight(1);
    }
  }
  .width('100%')
  .height('100%')
  .backgroundColor('#F5F5F5');
  }

  @Builder
  infoRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(100);
      Text(value)
        .fontSize(14)
        .fontColor('#1A1A1A')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1);
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 });
  }

  @Builder
  priceRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666');
      Blank();
      Text(value)
        .fontSize(14)
        .fontColor('#1A1A1A');
    }
    .width('100%')
    .margin({ bottom: 6 });
  }

  getStatusMessage(): string {
    const map: Record<string, string> = {
      'pending_payment': '订单待支付',
      'confirmed': '订单已确认，等待入住',
      'checked_in': '已入住，享受美好时光',
      'completed': '行程已结束',
      'cancelled': '订单已取消'
    };
    return map[this.order!.status] || '';
  }

  hasActions(): boolean {
    const status = this.order!.status;
    return status === 'pending_payment' || status === 'confirmed' ||
      status === 'checked_in' || (status === 'completed' && !this.order!.has_review);
  }

  getPrimaryAction(): string | null {
    const s = this.order!.status;
    if (s === 'pending_payment') return '去支付';
    if (s === 'confirmed') return '确认入住';
    if (s === 'checked_in') return '确认退房';
    return null;
  }

  getActionType(): string {
    const s = this.order!.status;
    if (s === 'pending_payment') return 'pay';
    if (s === 'confirmed') return 'checkin';
    if (s === 'checked_in') return 'complete';
    return '';
  }
}
