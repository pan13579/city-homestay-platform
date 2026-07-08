import { router } from '@kit.ArkUI';
import { ListingDetail } from '../models/Listing';
import { Review, DateRange } from '../models/Review';
import { ListingApi } from '../services/api/ListingApi';
import { ReviewApi } from '../services/api/ReviewApi';
import { preferences } from '@kit.ArkData';
import { ListingCarousel } from '../components/listing/ListingCarousel';
import { AmenityList } from '../components/listing/AmenityList';
import { DatePriceCalendar } from '../components/calendar/DatePriceCalendar';
import { ListingMapView } from '../components/map/ListingMapView';
import { RatingStars } from '../components/common/RatingStars';
import { ReviewCard } from '../components/review/ReviewCard';
import { PriceLabel } from '../components/listing/PriceLabel';
import { getRoomTypeLabel } from '../constants/RoomTypes';
import { DateUtil } from '../utils/DateUtil';
import { PriceUtil } from '../utils/PriceUtil';

interface NearbyPlace {
  name: string;
  type: string;
  distance: string;
}

@Entry
@Component
struct ListingDetailPage {
  private listingId: number = 0;
  @State listing: ListingDetail | null = null;
  @State reviews: Review[] = [];
  @State isLoading: boolean = true;
  @State selectedDates: DateRange = new DateRange();
  @State totalPrice: number = 0;
  @State activeTab: string = 'info';
  @State isFavorited: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['listingId']) {
      this.listingId = Number(params['listingId']);
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const detail = await ListingApi.getDetail(this.listingId);
      const reviewData = await ReviewApi.getByListing(this.listingId, 1);
      this.listing = detail;
      this.reviews = reviewData.list || [];
      await this.loadFavoriteStatus();
    } catch (err) {
      // Handle error
    }
    this.isLoading = false;
  }

  async loadFavoriteStatus(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), 'favorites');
      const str = await prefs.get('ids', '[]');
      const ids: number[] = JSON.parse(str as string);
      this.isFavorited = ids.indexOf(this.listingId) >= 0;
    } catch (e) {
      this.isFavorited = false;
    }
  }

  async toggleFavorite(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), 'favorites');
      const str = await prefs.get('ids', '[]');
      const ids: number[] = JSON.parse(str as string);
      const idx = ids.indexOf(this.listingId);
      if (idx >= 0) {
        ids.splice(idx, 1);
      } else {
        ids.push(this.listingId);
      }
      this.isFavorited = idx < 0;
      await prefs.put('ids', JSON.stringify(ids));
      await prefs.flush();
    } catch (e) {
      // fail silently
    }
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
      } else if (!this.listing) {
        Column() {
          Text('房源不存在').fontSize(16).fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        // Top nav bar (back button overlaid on carousel)
        Stack() {
          // Image carousel
          ListingCarousel({
            images: this.listing!.images || [],
            onImageTap: (index: number) => {
              router.pushUrl({
                url: 'pages/FullScreenImagePage',
                params: {
                  images: JSON.stringify(this.listing!.images || []),
                  currentIndex: index
                }
              });
            }
          });

          // Back button
          Row() {
            Button() {
              Text('←')
                .fontSize(20)
                .fontColor('#FFFFFF');
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#66000000')
            .onClick(() => {
              router.back();
            });

            Blank();

            Button() {
              Text(this.isFavorited ? '❤️' : '🤍')
                .fontSize(16);
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#66000000')
            .onClick(() => {
              this.toggleFavorite();
            });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })
          .position({ x: 0, y: 0 });
        }
        .width('100%')
        .height(280);

        // Scrollable content
        Scroll() {
          Column() {
            // Title and basic info
            Column() {
              Row() {
                Text(getRoomTypeLabel(this.listing!.room_type))
                  .fontSize(11)
                  .fontColor('#FF6B35')
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .backgroundColor('#FFF0EB');
              }
              .margin({ bottom: 8 });

              Text(this.listing!.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .width('100%')
                .margin({ bottom: 8 });

              Row() {
                Text(`📍 ${this.listing!.address}`)
                  .fontSize(13)
                  .fontColor('#999999')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1);
              }
              .width('100%')
              .margin({ bottom: 8 });

              Row() {
                RatingStars({ rating: this.listing!.avg_rating, starSize: 14, showValue: true });
                Text(` · ${this.listing!.review_count}条评价`)
                  .fontSize(13)
                  .fontColor('#999999');
                Blank();
                Text(`${this.listing!.max_guests}人入住 · ${this.listing!.bedrooms}室${this.listing!.beds}床${this.listing!.bathrooms}卫`)
                  .fontSize(12)
                  .fontColor('#666666');
              }
              .width('100%');

              Divider().strokeWidth(1).color('#F0F0F0').margin({ top: 12, bottom: 12 });

              Row() {
                Text('👩‍💼')
                  .fontSize(24);
                Column() {
                  Text(`房东: ${this.listing!.host_name}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1A1A1A');
                  Text('已验证房东')
                    .fontSize(11)
                    .fontColor('#4CAF50');
                }
                .margin({ left: 8 })
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 12, right: 12, top: 12, bottom: 12 });

            // Tab switcher
            Row() {
              this.detailTabButton('房源详情', 'info');
              this.detailTabButton('配套设施', 'amenities');
              this.detailTabButton(`评价(${this.listing!.review_count})`, 'reviews');
            }
            .width('100%')
            .padding({ left: 12, right: 12, bottom: 8 });

            // Tab content
            if (this.activeTab === 'info') {
              // Description
              Column() {
                Text('房源介绍')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .width('100%')
                  .margin({ bottom: 8 });

                Text(this.listing!.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 12 });

              // Nearby
              if (this.listing!.nearby && this.listing!.nearby.length > 0) {
                Column() {
                  Text('周边设施')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1A1A1A')
                    .width('100%')
                    .margin({ bottom: 8 });

                  ForEach(this.listing!.nearby, (place: NearbyPlace) => {
                    Row() {
                      Text(this.getNearbyIcon(place.type))
                        .fontSize(16);
                      Text(place.name)
                        .fontSize(13)
                        .fontColor('#1A1A1A')
                        .layoutWeight(1);
                      Text(place.type)
                        .fontSize(11)
                        .fontColor('#999999')
                        .margin({ right: 8 });
                      Text(place.distance)
                        .fontSize(12)
                        .fontColor('#FF6B35');
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                    .border({ width: { bottom: 0.5 }, color: '#F0F0F0' });
                  });
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .margin({ left: 12, right: 12, bottom: 12 });
              }

              // Map
              Column() {
                Text('📍 位置信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .width('100%')
                  .margin({ bottom: 8 });

                ListingMapView({
                  listings: [{
                    id: this.listing!.id,
                    title: this.listing!.title,
                    city: this.listing!.city,
                    latitude: this.listing!.latitude,
                    longitude: this.listing!.longitude,
                    base_price: this.listing!.base_price,
                    images: [],
                    address: '',
                    room_type: '',
                    avg_rating: 0,
                    review_count: 0,
                    max_guests: 0,
                    bedrooms: 0,
                    beds: 0
                  }],
                  centerLat: this.listing!.latitude,
                  centerLng: this.listing!.longitude
                })
                  .height(200);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 12 });

            } else if (this.activeTab === 'amenities') {
              // Amenities
              AmenityList({ amenities: this.listing!.amenities || [] });
            } else {
              // Reviews
              Column() {
                Text('住客评价')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .width('100%')
                  .margin({ bottom: 12 });

                if (this.reviews.length === 0) {
                  Text('暂无评价')
                    .fontSize(14)
                    .fontColor('#999999')
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .padding({ top: 20, bottom: 20 });
                } else {
                  ForEach(this.reviews, (review: Review) => {
                    ReviewCard({ review: review });
                  });
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 12 });
            }

            // Price calendar
            Column() {
              Text('📅 选择入住日期')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .width('100%')
                .margin({ bottom: 8 });

              DatePriceCalendar({
                listingId: this.listingId,
                selectedDates: this.selectedDates,
                totalPrice: this.totalPrice
              });

              if (this.selectedDates.checkIn && this.selectedDates.checkOut) {
                Row() {
                  Column() {
                    Text(`${DateUtil.formatDisplayDate(this.selectedDates.checkIn)} - ${DateUtil.formatDisplayDate(this.selectedDates.checkOut)}`)
                      .fontSize(13)
                      .fontColor('#1A1A1A');
                    Text(`${DateUtil.getNights(this.selectedDates.checkIn, this.selectedDates.checkOut)}晚`)
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .alignItems(HorizontalAlign.Start);

                  Blank();

                  Text(PriceUtil.formatDetail(this.totalPrice))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF6B35');
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 });
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 12, right: 12, bottom: 80 });
          }
          .width('100%');
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1);

        // Bottom booking bar
        Row() {
          Column() {
            PriceLabel({ price: this.listing!.base_price, fontSize: 18 });

            if (this.selectedDates.checkIn && this.selectedDates.checkOut) {
              Text(`${DateUtil.formatDisplayRange(this.selectedDates.checkIn, this.selectedDates.checkOut)} · ${DateUtil.getNights(this.selectedDates.checkIn, this.selectedDates.checkOut)}晚`)
                .fontSize(11)
                .fontColor('#999999');
            }
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          Button() {
            Row() {
              Text('立即预订')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF');

              if (this.totalPrice > 0) {
                Text(` ${PriceUtil.formatDetail(this.totalPrice)}`)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .opacity(0.9);
              }
            };
          }
          .enabled(this.selectedDates.checkIn !== '' && this.selectedDates.checkOut !== '')
          .backgroundColor(this.selectedDates.checkIn && this.selectedDates.checkOut ? '#FF6B35' : '#CCCCCC')
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .onClick(() => {
            if (this.selectedDates.checkIn && this.selectedDates.checkOut) {
              router.pushUrl({
                url: 'pages/BookingPage',
                params: {
                  listingId: this.listing!.id,
                  checkIn: this.selectedDates.checkIn,
                  checkOut: this.selectedDates.checkOut,
                  guests: 1
                }
              });
            }
          });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 8, color: '#10000000', offsetY: -2 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  detailTabButton(label: string, tab: string): void {
    Text(label)
      .fontSize(14)
      .fontColor(this.activeTab === tab ? '#FF6B35' : '#999999')
      .fontWeight(this.activeTab === tab ? FontWeight.Bold : FontWeight.Normal)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .border({
        width: { bottom: this.activeTab === tab ? 2 : 0 },
        color: this.activeTab === tab ? '#FF6B35' : 'transparent'
      })
      .onClick(() => {
        this.activeTab = tab;
      });
  }

  getNearbyIcon(type: string): string {
    const map: Record<string, string> = { '景点': '🏛️', '交通': '🚇', '购物': '🛍️', '餐饮': '🍽️', '生活': '🏪', '娱乐': '🎭' };
    return map[type] || '📍';
  }
}
