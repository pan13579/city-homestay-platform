import { router } from '@kit.ArkUI';
import { TabBar } from '../components/common/TabBar';
import { ProfileHeader } from '../components/user/ProfileHeader';
import { UserApi, UserInfo } from '../services/api/UserApi';
import { OrderApi } from '../services/api/OrderApi';
import { MockData } from '../services/MockData';
import { OrderBrief } from '../models/Order';
import { AuthStorage } from '../utils/AuthStorage';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct UserCenterPage {
  @State currentTab: number = 3;
  @State user: UserInfo | null = null;
  @State orderCounts: Record<string, number> = {};
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;

  aboutToAppear(): void {
    AuthStorage.init(getContext(this)).then(() => {
      this.checkLoginState();
    });
  }

  onPageShow(): void {
    this.checkLoginState();
  }

  checkLoginState(): void {
    this.isLoggedIn = AuthStorage.isLoggedIn();
    if (this.isLoggedIn) {
      this.loadData();
    } else {
      this.isLoading = false;
    }
  }

  onTabChange(index: number): void {
    this.currentTab = index;
    const pages = ['pages/HomePage', 'pages/ListingListPage', 'pages/OrderListPage', 'pages/UserCenterPage'];
    if (index !== 3) {
      router.pushUrl({ url: pages[index] });
    }
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
      // Fallback to stored user info
      const storedUser = AuthStorage.getUser();
      if (storedUser) {
        this.user = storedUser;
      }
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

  async handleLogout(): Promise<void> {
    const result = await promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出登录吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '退出', color: '#FF6B35' }
      ]
    });
    // result.index === 1 means the "退出" button was clicked (0-indexed)
    if (result.index === 1) {
      await UserApi.logout(getContext(this));
      this.user = null;
      this.orderCounts = {};
      this.isLoggedIn = false;
      promptAction.showToast({ message: '已退出登录', duration: 1500 });
    }
  }

  build() {
    Column() {
      if (this.isLoading && this.isLoggedIn) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Column() {
          // Profile header - clickable when not logged in
          Column() {
            ProfileHeader({
              nickname: this.user?.nickname || '点击登录',
              phone: this.user?.phone || '',
              isLoggedIn: this.isLoggedIn
            });
          }
          .onClick(() => {
            if (!this.isLoggedIn) {
              router.pushUrl({ url: 'pages/LoginPage' });
            }
          });

          Scroll() {
            Column() {
              if (this.isLoggedIn) {
                // Order stats (only visible when logged in)
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
              }

              // Menu items
              if (this.isLoggedIn) {
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
              }

              Column() {
                if (this.isLoggedIn) {
                  this.menuItem('🚪', '退出登录', '', () => {
                    this.handleLogout();
                  });
                  Divider().strokeWidth(0.5).color('#F0F0F0');
                }
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
