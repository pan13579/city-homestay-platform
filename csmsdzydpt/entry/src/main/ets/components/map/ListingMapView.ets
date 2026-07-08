import { ListingBrief } from '../../models/Listing';

interface MapPoint {
  listing: ListingBrief;
  x: number;
  y: number;
}

@Component
export struct ListingMapView {
  @Prop listings: ListingBrief[] = [];
  @Prop centerLat: number = 31.0;
  @Prop centerLng: number = 115.0;
  onListingTap: (id: number) => void = () => {};

  @State mapScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private points: MapPoint[] = [];
  private panLastX: number = 0;
  private panLastY: number = 0;

  aboutToAppear(): void {
    this.calcPoints();
  }

  calcPoints(): void {
    let minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    if (this.listings.length > 0) {
      for (let i = 0; i < this.listings.length; i++) {
        const l = this.listings[i];
        if (l.latitude < minLat) minLat = l.latitude;
        if (l.latitude > maxLat) maxLat = l.latitude;
        if (l.longitude < minLng) minLng = l.longitude;
        if (l.longitude > maxLng) maxLng = l.longitude;
      }
    } else {
      minLat = this.centerLat - 5; maxLat = this.centerLat + 5;
      minLng = this.centerLng - 5; maxLng = this.centerLng + 5;
    }

    const latPad = Math.max((maxLat - minLat) * 0.2, 1);
    const lngPad = Math.max((maxLng - minLng) * 0.2, 1);
    minLat -= latPad; maxLat += latPad;
    minLng -= lngPad; maxLng += lngPad;

    this.points = [];
    for (let i = 0; i < this.listings.length; i++) {
      const l = this.listings[i];
      this.points.push({
        listing: l,
        x: (l.longitude - minLng) / (maxLng - minLng),
        y: 1 - (l.latitude - minLat) / (maxLat - minLat)
      });
    }
  }

  build() {
    Column() {
      Stack() {
        // 地图主体
        Column() {
          // 渐变背景
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [
                ['#D4E8F0', 0],
                ['#E8F0D8', 0.35],
                ['#F5F0E0', 0.6],
                ['#E8E0D0', 1]
              ]
            });

          // 网格
          ForEach([1, 2, 3, 4], (n: number) => {
            Column()
              .width('100%')
              .height(1)
              .backgroundColor('#18000000')
              .margin({ top: '20%' });
          });
          ForEach([1, 2, 3, 4], (n: number) => {
            Row()
              .width(1)
              .height('100%')
              .backgroundColor('#18000000')
              .position({ x: (n * 20) + '%', y: 0 });
          });

          // 房源标记
          ForEach(this.points, (pt: MapPoint) => {
            Column() {
              Text('📍')
                .fontSize(24 * this.mapScale);

              Column() {
                Text(pt.listing.title)
                  .fontSize(9 * this.mapScale)
                  .fontColor('#FFFFFF')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .padding({
                left: 4 * this.mapScale,
                right: 4 * this.mapScale,
                top: 1,
                bottom: 1
              })
              .borderRadius(3)
              .backgroundColor('#CC222222');

              Text('¥' + pt.listing.base_price + '/晚')
                .fontSize(8 * this.mapScale)
                .fontColor('#E55A2B')
                .fontWeight(FontWeight.Bold);
            }
            .alignItems(HorizontalAlign.Center)
            .hitTestBehavior(HitTestMode.Block)
            .position({ x: (pt.x * 100) + '%', y: (pt.y * 100) + '%' })
            .translate({ x: '-50%', y: '-100%' })
            .onClick(() => {
              this.onListingTap(pt.listing.id);
            });
          });
        }
        .width('100%')
        .height('100%')
        .offset({ x: this.offsetX, y: this.offsetY })
        .scale({ x: this.mapScale, y: this.mapScale });

        // 缩放控制
        Column() {
          Button('+')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width(32)
            .height(32)
            .borderRadius(4)
            .backgroundColor('#FFFFFF')
            .fontColor('#333333')
            .shadow({ radius: 4, color: '#30000000' })
            .onClick(() => {
              this.mapScale = Math.min(this.mapScale + 0.3, 3);
            });

          Divider().width(20).color('#EEEEEE');

          Button('-')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width(32)
            .height(32)
            .borderRadius(4)
            .backgroundColor('#FFFFFF')
            .fontColor('#333333')
            .shadow({ radius: 4, color: '#30000000' })
            .onClick(() => {
              this.mapScale = Math.max(this.mapScale - 0.3, 0.5);
            });

          Divider().width(20).color('#EEEEEE').margin({ top: 4, bottom: 4 });

          Button('⟲')
            .fontSize(16)
            .width(32)
            .height(32)
            .borderRadius(4)
            .backgroundColor('#FFFFFF')
            .fontColor('#333333')
            .shadow({ radius: 4, color: '#30000000' })
            .onClick(() => {
              this.mapScale = 1;
              this.offsetX = 0;
              this.offsetY = 0;
            });
        }
        .position({ x: '100%', y: 8 })
        .translate({ x: '-100%' })
        .margin({ right: 8 });

        // 底部署名
        Column() {
          Text(this.listings.length + ' 个房源')
            .fontSize(10)
            .fontColor('#666666')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(3)
            .backgroundColor('#DDFFFFFF');
        }
        .position({ x: '100%', y: '100%' })
        .translate({ x: '-100%', y: '-100%' })
        .margin({ right: 8, bottom: 8 });
      }
      .width('100%')
      .layoutWeight(1)
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.All, distance: 5 })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetX = this.panLastX + event.offsetX;
            this.offsetY = this.panLastY + event.offsetY;
          })
          .onActionEnd(() => {
            this.panLastX = this.offsetX;
            this.panLastY = this.offsetY;
          })
      );
    }
    .width('100%')
    .height('100%');
  }
}
