import { router } from '@kit.ArkUI';
import { TabBar } from '../components/common/TabBar';
import { ProfileHeader } from '../components/user/ProfileHeader';
import { UserApi, UserInfo } from '../services/api/UserApi';
import { OrderApi } from '../services/api/OrderApi';
import { MockData } from '../services/MockData';
import { OrderBrief } from '../models/Order';

@Entry
@Component
struct UserCenterPage {
  @State currentTab: number = 3;
  @State user: UserInfo | null = null;
  @State orderCounts: Record<string, number> = {};
  @State isLoading: boolean = true;

  onTabChange(index: number): void {
    this.currentTab = index;
    const pages = ['pages/HomePage', 'pages/ListingListPage', 'pages/OrderListPage', 'pages/UserCenterPage'];
    if (index !== 3) {
      router.pushUrl({ url: pages[index] });
    }
  }

  aboutToAppear(): void {
    this.loadData();
  }

  onPageShow(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const user = await UserApi.getProfile();
      const orders = await OrderApi.getOrders();
      this.user = user;

      // Count by status
      const counts: Record<string, number> = {};
      const orderList = orders || [];
      for (let i = 0; i < orderList.length; i++) {
        const status = orderList[i].status;
        counts[status] = (counts[status] || 0) + 1;
        counts['all'] = (counts['all'] || 0) + 1;
      }
      this.orderCounts = counts;
    } catch (err) {
      this.user = MockData.getUserProfile();
      const orderList = MockData.getOrders();
      const counts: Record<string, number> = {};
      for (let i = 0; i < orderList.length; i++) {
        const s = orderList[i].status;
        counts[s] = (counts[s] || 0) + 1;
        counts['all'] = (counts['all'] || 0) + 1;
      }
      this.orderCounts = counts;
    }
    this.isLoading = false;
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
      } else {
        Column() {
          // Profile header
          ProfileHeader({
            nickname: this.user?.nickname || '旅行达人小王',
            phone: this.user?.phone || '138****0000'
          });

          Scroll() {
            Column() {
              // Order stats
              Column() {
                Text('我的订单')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .width('100%')
                  .margin({ bottom: 12 });

                Row() {
                  this.statItem('📋', '全部', this.orderCounts['all'] || 0, 'all');
                  this.statItem('⏳', '待支付', this.orderCounts['pending_payment'] || 0, 'pending_payment');
                  this.statItem('✅', '已确认', this.orderCounts['confirmed'] || 0, 'confirmed');
                  this.statItem('🏠', '已入住', this.orderCounts['checked_in'] || 0, 'checked_in');
                  this.statItem('✔️', '已完成', this.orderCounts['completed'] || 0, 'completed');
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceEvenly);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, top: -16, bottom: 12 });

              // Menu items
              Column() {
                this.menuItem('📋', '我的订单', '查看全部订单', () => {
                  router.pushUrl({ url: 'pages/OrderListPage' });
                });
                Divider().strokeWidth(0.5).color('#F0F0F0');
                this.menuItem('⭐', '我的评价', '查看历史评价', () => {
                  router.pushUrl({ url: 'pages/MyReviewsPage' });
                });
                Divider().strokeWidth(0.5).color('#F0F0F0');
                this.menuItem('❤️', '收藏房源', '已收藏的民宿', () => {
                  router.pushUrl({ url: 'pages/FavoritesPage' });
                });
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 12 });

              Column() {
                this.menuItem('⚙️', '设置', '', () => {});
                Divider().strokeWidth(0.5).color('#F0F0F0');
                this.menuItem('❓', '帮助与反馈', '', () => {});
                Divider().strokeWidth(0.5).color('#F0F0F0');
                this.menuItem('ℹ️', '关于城宿短租', 'v1.0.0', () => {});
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 80 });
            }
            .width('100%');
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1);
        }
        .width('100%')
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

  @Builder
  statItem(icon: string, label: string, count: number, status: string): void {
    Column() {
      Text(icon)
        .fontSize(22)
        .margin({ bottom: 4 });
      Text(count.toString())
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A');
      Text(label)
        .fontSize(11)
        .fontColor('#999999')
        .margin({ top: 2 });
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/OrderListPage'
      });
    });
  }

  @Builder
  menuItem(icon: string, title: string, subtitle: string, onClick: () => void): void {
    Row() {
      Text(icon)
        .fontSize(20);
      Text(title)
        .fontSize(15)
        .fontColor('#1A1A1A')
        .margin({ left: 12 })
        .layoutWeight(1);
      if (subtitle) {
        Text(subtitle)
          .fontSize(12)
          .fontColor('#999999');
      }
      Text('›')
        .fontSize(18)
        .fontColor('#CCCCCC')
        .margin({ left: 4 });
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .onClick(onClick);
  }
}
