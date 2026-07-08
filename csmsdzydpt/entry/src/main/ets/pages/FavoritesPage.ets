import { router } from '@kit.ArkUI';
import { ListingBrief } from '../models/Listing';
import { ListingApi } from '../services/api/ListingApi';
import { ListingCard } from '../components/listing/ListingCard';
import { EmptyView } from '../components/common/EmptyView';
import { preferences } from '@kit.ArkData';

@Entry
@Component
struct FavoritesPage {
  @State favorites: ListingBrief[] = [];
  @State isLoading: boolean = true;
  private favoriteIds: number[] = [];

  aboutToAppear(): void {
    this.loadFavorites();
  }

  onPageShow(): void {
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    this.isLoading = true;
    try {
      const prefs = await preferences.getPreferences(getContext(this), 'favorites');
      const str = await prefs.get('ids', '[]');
      this.favoriteIds = JSON.parse(str as string) as number[];
      this.favorites = [];
      for (let i = 0; i < this.favoriteIds.length; i++) {
        try {
          const detail = await ListingApi.getDetail(this.favoriteIds[i]);
          const brief = new ListingBrief();
          brief.id = detail.id;
          brief.title = detail.title;
          brief.city = detail.city;
          brief.address = detail.address;
          brief.room_type = detail.room_type;
          brief.base_price = detail.base_price;
          brief.avg_rating = detail.avg_rating;
          brief.review_count = detail.review_count;
          brief.images = detail.images;
          brief.latitude = detail.latitude;
          brief.longitude = detail.longitude;
          brief.max_guests = detail.max_guests;
          brief.bedrooms = detail.bedrooms;
          brief.beds = detail.beds;
          this.favorites.push(brief);
        } catch (e) {
          // skip invalid listings
        }
      }
    } catch (err) {
      this.favorites = [];
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());

        Text('收藏房源')
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
      } else if (this.favorites.length === 0) {
        EmptyView({ icon: '❤️', message: '还没有收藏房源\n去房源详情页点击收藏按钮吧' })
          .layoutWeight(1);
      } else {
        List() {
          ForEach(this.favorites, (item: ListingBrief) => {
            ListItem() {
              ListingCard({
                listing: item,
                onTap: () => {
                  router.pushUrl({
                    url: 'pages/ListingDetailPage',
                    params: { listingId: item.id }
                  });
                }
              })
                .padding({ left: 12, right: 12 });
            }
          });
        }
        .layoutWeight(1);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
