import { router } from '@kit.ArkUI';
import { ListingBrief } from '../models/Listing';
import { OrderBrief } from '../models/Order';
import { ListingApi } from '../services/api/ListingApi';
import { OrderApi } from '../services/api/OrderApi';
import { MockData } from '../services/MockData';
import { TabBar } from '../components/common/TabBar';
import { SearchBar } from '../components/common/SearchBar';
import { ListingCard } from '../components/listing/ListingCard';
import { ApiEndpoints } from '../constants/ApiEndpoints';
import { PriceUtil } from '../utils/PriceUtil';
import { RatingStars } from '../components/common/RatingStars';

interface BannerItem {
  title: string;
  subtitle: string;
}

@Entry
@Component
struct HomePage {
  @State currentTab: number = 0;
  @State recommendedListings: ListingBrief[] = [];
  @State upcomingStay: OrderBrief | null = null;
  @State isLoading: boolean = true;
  @State isOnline: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  onPageShow(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const recommendedResult = await ListingApi.getRecommended(6);
      const upcomingResult = await OrderApi.getUpcoming();
      this.recommendedListings = recommendedResult || [];
      this.upcomingStay = upcomingResult;
      this.isOnline = true;
    } catch (err) {
      this.isOnline = false;
      this.recommendedListings = MockData.getRecommendedListings();
      this.upcomingStay = MockData.getUpcomingStay();
    }
    this.isLoading = false;
  }

  onTabChange(index: number): void {
    this.currentTab = index;
    const pages = ['pages/HomePage', 'pages/ListingListPage', 'pages/OrderListPage', 'pages/UserCenterPage'];
    if (index !== 0) {
      router.pushUrl({ url: pages[index] });
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('🏠 城宿短租')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A');

        Blank();

        Text(this.isOnline ? '🟢 在线' : '🔴 离线')
          .fontSize(11)
          .fontColor(this.isOnline ? '#4CAF50' : '#F44336')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(12)
          .backgroundColor(this.isOnline ? '#E8F5E9' : '#FFEBEE');
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 });

      // Search bar
      Row() {
        SearchBar({
          placeholder: '搜索目的地、民宿名称...',
          onTap: () => {
            router.pushUrl({ url: 'pages/ListingListPage' });
          }
        });
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 });

      // Scrollable content
      Scroll() {
        Column() {
          // Banner section
          Swiper() {
            ForEach(['🏖️', '🏔️', '🌆', '🏯'], (icon: string, index: number) => {
              Row() {
                Column() {
                  Text(this.getBannerText(index).title)
                    .fontSize(18)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold);
                  Text(this.getBannerText(index).subtitle)
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .opacity(0.8)
                    .margin({ top: 4 });
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);
                Text(icon)
                  .fontSize(48);
              }
              .width('100%')
              .height(120)
              .padding(20)
              .borderRadius(16)
              .backgroundColor(this.getBannerColor(index));
            });
          }
          .width('100%')
          .height(120)
          .margin({ left: 16, right: 16, bottom: 20 })
          .indicator(new DotIndicator().color('#99FFFFFF').selectedColor('#FFFFFF'))
          .autoPlay(true);

          // Upcoming stay card
          if (this.upcomingStay) {
            Column() {
              Row() {
                Text('📋 即将入住的行程')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A');

                Blank();

                Text('查看详情 >')
                  .fontSize(12)
                  .fontColor('#FF6B35')
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/OrderDetailPage',
                      params: { orderId: this.upcomingStay!.id }
                    });
                  });
              }
              .width('100%')
              .margin({ bottom: 12 });

              Row() {
                Image(this.upcomingStay.listing_cover
                  ? ApiEndpoints.getImageUrl(this.upcomingStay.listing_cover)
                  : '')
                  .width(60)
                  .height(60)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8);

                Column() {
                  Text(this.upcomingStay.listing_title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1A1A1A')
                    .maxLines(1);

                  Text(`${this.upcomingStay.check_in} 至 ${this.upcomingStay.check_out}`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 });

                  Row() {
                    Text(`${this.upcomingStay.nights}晚`)
                      .fontSize(12)
                      .fontColor('#666666');
                    Text(` · ${PriceUtil.formatDetail(this.upcomingStay.total_price)}`)
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF6B35');
                  }
                  .margin({ top: 2 });
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 });
              }
              .width('100%');

              if (this.upcomingStay.status === 'pending_payment') {
                Button('去支付')
                  .fontSize(13)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF6B35')
                  .borderRadius(20)
                  .padding({ left: 24, right: 24 })
                  .margin({ top: 12 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/OrderDetailPage',
                      params: { orderId: this.upcomingStay!.id }
                    });
                  });
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFF8F5')
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 20 });
          }

          // Recommended listings section
          Column() {
            Row() {
              Text('🏆 精选推荐民宿')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A');

              Blank();

              Text('查看更多 >')
                .fontSize(12)
                .fontColor('#FF6B35')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/ListingListPage' });
                });
            }
            .width('100%')
            .margin({ bottom: 12 });

            if (this.isLoading) {
              Row() {
                LoadingProgress().width(30).height(30).color('#FF6B35');
              }
              .width('100%')
              .height(160)
              .justifyContent(FlexAlign.Center);
            } else if (this.recommendedListings.length === 0) {
              Text('暂无推荐房源')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 40, bottom: 40 });
            } else {
              // Horizontal scroll of cards
              Scroll() {
                Row() {
                  ForEach(this.recommendedListings, (item: ListingBrief) => {
                    Column() {
                      Image(item.images && item.images.length > 0
                        ? ApiEndpoints.getImageUrl(item.images[0])
                        : '')
                        .width(160)
                        .height(120)
                        .objectFit(ImageFit.Cover);

                      Column() {
                        Text(item.title)
                          .fontSize(13)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#1A1A1A')
                          .maxLines(1)
                          .width('100%');

                        Row() {
                          RatingStars({ rating: item.avg_rating, starSize: 10 });
                          Text(` ${item.review_count}`)
                            .fontSize(10)
                            .fontColor('#999999');
                          Blank();
                          Text(PriceUtil.getPerNight(item.base_price))
                            .fontSize(12)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#FF6B35');
                        }
                        .width('100%')
                        .margin({ top: 4 });
                      }
                      .width('100%')
                      .padding(8)
                      .alignItems(HorizontalAlign.Start);
                    }
                    .width(160)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(10)
                    .margin({ right: 12 })
                    .shadow({ radius: 4, color: '#10000000', offsetY: 1 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/ListingDetailPage',
                        params: { listingId: item.id }
                      });
                    });
                  });
                }
                .padding({ left: 16, right: 16 });
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off);
            }
          }
          .width('100%')
          .margin({ left: 16, right: 16, bottom: 80 });
        }
        .width('100%');
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1);

      // Bottom tab bar
      TabBar({
        currentIndex: this.currentTab,
        onChange: (index: number) => this.onTabChange(index)
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  getBannerText(index: number): BannerItem {
    const banners: BannerItem[] = [
      { title: '夏日海边', subtitle: '享受清凉海风，海景民宿特惠' },
      { title: '山间避暑', subtitle: '远离城市喧嚣，山中静心之旅' },
      { title: '都市风情', subtitle: '探索城市魅力，精选城市民宿' },
      { title: '古城之旅', subtitle: '感受历史文化，古都特色民宿' }
    ];
    return banners[index] || banners[0];
  }

  getBannerColor(index: number): string {
    return ['#FF6B35', '#2EC4B6', '#4A90D9', '#E57373'][index] || '#FF6B35';
  }
}
