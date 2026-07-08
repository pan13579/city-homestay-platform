interface TabItem {
  icon: string;
  label: string;
  index: number;
}

@Component
export struct TabBar {
  @Prop currentIndex: number = 0;
  onChange: (index: number) => void = () => {};

  private tabs: TabItem[] = [
    { icon: '🏠', label: '首页', index: 0 } as TabItem,
    { icon: '🔍', label: '探索', index: 1 } as TabItem,
    { icon: '📋', label: '订单', index: 2 } as TabItem,
    { icon: '👤', label: '我的', index: 3 } as TabItem
  ];

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItem) => {
        Column() {
          Text(tab.icon)
            .fontSize(22)
            .margin({ bottom: 2 });

          Text(tab.label)
            .fontSize(10)
            .fontColor(this.currentIndex === tab.index ? '#FF6B35' : '#999999');
        }
        .width('25%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.onChange(tab.index);
        })
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .padding({ bottom: 8 })
    .shadow({
      radius: 8,
      color: '#10000000',
      offsetY: -2
    })
  }
}
