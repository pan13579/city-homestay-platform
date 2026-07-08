@Component
export struct AmenityList {
  @Prop amenities: string[] = [];

  // Amenity icon mapping
  private getIcon(name: string): string {
    const map: Record<string, string> = {
      'WiFi': '📶',
      '空调': '❄️',
      '洗衣机': '👕',
      '厨房': '🍳',
      '热水器': '🔥',
      '吹风机': '💨',
      '洗发水': '🧴',
      '沐浴露': '🧼',
      '浴缸': '🛁',
      '投影仪': '📽️',
      '智能家居': '🤖',
      '烘干机': '🌪️',
      '海景阳台': '🌊',
      '私人泳池': '🏊',
      '花园': '🌺',
      '暖气': '☀️',
      '办公桌': '🪑',
      '打印机': '🖨️',
      '咖啡机': '☕',
      '健身房': '💪',
      '烧烤架': '🥩',
      '免费停车': '🚗',
      '自行车租赁': '🚲',
      '茶具': '🍵',
      '汉服体验': '👘',
      '早餐': '🥐',
      '下午茶': '🍰',
      '管家服务': '🤵',
      '游戏机': '🎮',
      '黑胶唱片机': '🎵',
      '猫': '🐱',
      '火锅设备': '🍲',
      '书法体验': '✍️',
      '古城导览': '🗺️',
      '洗衣服务': '🧺',
      '升降桌': '🪑',
      '共享办公': '💼',
      '洗衣房': '🧺'
    };
    return map[name] || '✅';
  }

  build() {
    Column() {
      Text('配套设施')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 12 });

      Grid() {
        ForEach(this.amenities, (item: string) => {
          GridItem() {
            Column() {
              Text(this.getIcon(item))
                .fontSize(24)
                .margin({ bottom: 4 });
              Text(item)
                .fontSize(11)
                .fontColor('#666666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .alignItems(HorizontalAlign.Center);
          }
        });
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 });
  }
}
