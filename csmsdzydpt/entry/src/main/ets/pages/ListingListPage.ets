import { router } from '@kit.ArkUI';
import { ListingBrief } from '../models/Listing';
import { FilterParams, SearchParams } from '../models/Review';
import { ListingApi } from '../services/api/ListingApi';
import { TabBar } from '../components/common/TabBar';
import { ListingCard } from '../components/listing/ListingCard';
import { ListingMapView } from '../components/map/ListingMapView';

@Component
export struct FilterBar {
  @Prop cities: string[] = [];
  @Prop city: string = '';
  @Prop roomType: string = '';
  @Prop sortBy: string = 'newest';
  onFilterChange: (key: string, value: string) => void = () => {};

  build() {
    Column() {
      // Filter chips row 1
      Scroll() {
        Row() {
          this.filterChip('默认', this.city === '' ? '城市' : this.city, 'city');
          this.filterChip('默认', this.roomType === '' ? '户型' : this.roomType, 'roomType');
          this.filterChip('默认', '价格', 'price');
          this.filterChip('默认', '评分', 'rating');
        }
        .padding({ left: 16, right: 16 });
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off);

      // Sort row
      Row() {
        this.sortChip('综合排序', 'newest');
        this.sortChip('价格低→高', 'price_asc');
        this.sortChip('价格高→低', 'price_desc');
        this.sortChip('评分最高', 'rating');
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 4 });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: 8, bottom: 6 });
  }

  @Builder
  filterChip(defaultValue: string, label: string, key: string): void {
    Text(label)
      .fontSize(12)
      .fontColor(label !== key ? '#FF6B35' : '#666666')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .border({ width: 1, color: label !== key ? '#FF6B35' : '#EEEEEE' })
      .backgroundColor(label !== key ? '#FFF8F5' : '#F5F5F5')
      .margin({ right: 8 })
      .onClick(() => {
        // Cycle through options
        if (key === 'city') {
          const idx = this.cities.indexOf(this.city);
          const next = this.cities[(idx + 1) % Math.max(this.cities.length, 1)];
          this.onFilterChange('city', next === this.city ? '' : next);
        } else if (key === 'roomType') {
          const types = ['', 'entire_place', 'private_room', 'shared_room'];
          const idx = types.indexOf(this.roomType);
          this.onFilterChange('roomType', types[(idx + 1) % types.length]);
        }
      });
  }

  @Builder
  sortChip(label: string, value: string): void {
    Text(label)
      .fontSize(12)
      .fontColor(this.sortBy === value ? '#FF6B35' : '#999999')
      .fontWeight(this.sortBy === value ? FontWeight.Medium : FontWeight.Normal)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .onClick(() => {
        this.onFilterChange('sortBy', value);
      });
  }
}

@Entry
@Component
struct ListingListPage {
  @State currentTab: number = 1;
  @State listings: ListingBrief[] = [];
  @State cities: string[] = [];
  @State isLoading: boolean = true;
  @State isLoadingMore: boolean = false;
  @State showMap: boolean = false;
  @State hasMore: boolean = true;

  // Filter state
  @State filter: FilterParams = new FilterParams();
  @State sortBy: string = 'newest';

  onTabChange(index: number): void {
    this.currentTab = index;
    const pages = ['pages/HomePage', 'pages/ListingListPage', 'pages/OrderListPage', 'pages/UserCenterPage'];
    if (index !== 1) {
      router.pushUrl({ url: pages[index] });
    }
  }

  aboutToAppear(): void {
    this.loadInitial();
  }

  async loadInitial(): Promise<void> {
    this.isLoading = true;
    this.filter.page = 1;
    try {
      const cities = await ListingApi.getCities();
      const data = await ListingApi.getList(this.buildParams());
      this.cities = cities || [];
      this.listings = data.list || [];
      this.hasMore = data.page < data.totalPages;
    } catch (err) {
      this.listings = [];
      this.cities = [];
    }
    this.isLoading = false;
  }

  async loadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) return;
    this.isLoadingMore = true;
    this.filter.page++;
    try {
      const data = await ListingApi.getList(this.buildParams());
      this.listings = this.listings.concat(data.list || []);
      this.hasMore = data.page < data.totalPages;
    } catch (err) {
      this.filter.page--;
    }
    this.isLoadingMore = false;
  }

  buildParams(): SearchParams {
    const params = new SearchParams();
    params.page = this.filter.page;
    params.page_size = this.filter.pageSize;
    params.sort_by = this.filter.sortBy;
    if (this.filter.keyword) params.keyword = this.filter.keyword;
    if (this.filter.city) params.city = this.filter.city;
    if (this.filter.roomType) params.room_type = this.filter.roomType;
    if (this.filter.minPrice) params.min_price = this.filter.minPrice;
    if (this.filter.maxPrice) params.max_price = this.filter.maxPrice;
    if (this.filter.minRating) params.min_rating = this.filter.minRating;
    return params;
  }

  onFilterChange(key: string, value: string): void {
    if (key === 'sortBy') {
      this.filter.sortBy = value;
    } else if (key === 'city') {
      this.filter.city = value;
    } else if (key === 'roomType') {
      this.filter.roomType = value;
    }
    this.filter.page = 1;
    this.loadInitial();
  }

  build() {
    Column() {
      // Top bar
      Row() {
        Text('探索民宿')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A');

        Blank();

        Text(this.showMap ? '📋 列表' : '🗺️ 地图')
          .fontSize(13)
          .fontColor('#FF6B35')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(14)
          .border({ width: 1, color: '#FF6B35' })
          .onClick(() => {
            this.showMap = !this.showMap;
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 });

      // Filter bar
      FilterBar({
        cities: this.cities,
        city: this.filter.city,
        roomType: this.filter.roomType,
        sortBy: this.filter.sortBy,
        onFilterChange: (key: string, value: string) => this.onFilterChange(key, value)
      });

      if (this.showMap) {
        // Map view
        ListingMapView({
          listings: this.listings,
          centerLat: this.listings.length > 0 ? this.listings[0].latitude : 31.0,
          centerLng: this.listings.length > 0 ? this.listings[0].longitude : 115.0,
          onListingTap: (id: number) => {
            router.pushUrl({
              url: 'pages/ListingDetailPage',
              params: { listingId: id }
            });
          }
        })
          .layoutWeight(1);
      } else if (this.isLoading) {
        Row() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.listings.length === 0) {
        Row() {
          Column() {
            Text('🔍')
              .fontSize(48)
              .margin({ bottom: 12 });
            Text('没有找到匹配的房源')
              .fontSize(14)
              .fontColor('#999999');
          }
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        // Lazy loading list
        List() {
          LazyForEach(new ListingDataSource(this.listings), (item: ListingBrief, index: number) => {
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
                .padding({ left: 16, right: 16 });
            }
          }, (item: ListingBrief) => item.id.toString());

          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoadingMore) {
                  LoadingProgress().width(24).height(24).color('#FF6B35');
                } else {
                  Text('上拉加载更多')
                    .fontSize(12)
                    .fontColor('#999999');
                }
              }
              .width('100%')
              .height(40)
              .justifyContent(FlexAlign.Center)
              .onAppear(() => {
                this.loadMore();
              });
            }
          }
        }
        .cachedCount(5)
        .layoutWeight(1);
      }

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
}

// LazyForEach data source
class ListingDataSource implements IDataSource {
  private dataArray: ListingBrief[];
  private listener: DataChangeListener | null = null;

  constructor(data: ListingBrief[]) {
    this.dataArray = data;
  }

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): ListingBrief {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listener = listener;
  }

  unregisterDataChangeListener(): void {
    this.listener = null;
  }
}

