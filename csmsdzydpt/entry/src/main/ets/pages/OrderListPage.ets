import { router } from '@kit.ArkUI';
import { OrderBrief } from '../models/Order';
import { OrderApi } from '../services/api/OrderApi';
import { MockData } from '../services/MockData';
import { TabBar } from '../components/common/TabBar';
import { OrderCard } from '../components/order/OrderCard';
import { EmptyView } from '../components/common/EmptyView';

interface StatusTab {
  label: string;
  value: string;
}

@Entry
@Component
struct OrderListPage {
  @State currentTab: number = 2;
  @State orders: OrderBrief[] = [];
  @State activeStatus: string = 'all';
  @State isLoading: boolean = true;

  private statusTabs: StatusTab[] = [
    { label: '全部', value: 'all' },
    { label: '待支付', value: 'pending_payment' },
    { label: '已确认', value: 'confirmed' },
    { label: '已入住', value: 'checked_in' },
    { label: '已完成', value: 'completed' },
    { label: '已取消', value: 'cancelled' }
  ];

  onTabChange(index: number): void {
    this.currentTab = index;
    const pages = ['pages/HomePage', 'pages/ListingListPage', 'pages/OrderListPage', 'pages/UserCenterPage'];
    if (index !== 2) {
      router.pushUrl({ url: pages[index] });
    }
  }

  aboutToAppear(): void {
    this.loadOrders();
  }

  onPageShow(): void {
    this.loadOrders();
  }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const status = this.activeStatus === 'all' ? undefined : this.activeStatus;
      const data = await OrderApi.getOrders(status);
      this.orders = data || [];
    } catch (err) {
      const allOrders = MockData.getOrders();
      if (this.activeStatus === 'all') {
        this.orders = allOrders;
      } else {
        const filtered: OrderBrief[] = [];
        for (let i = 0; i < allOrders.length; i++) {
          if (allOrders[i].status === this.activeStatus) {
            filtered.push(allOrders[i]);
          }
        }
        this.orders = filtered;
      }
    }
    this.isLoading = false;
  }

  onStatusChange(value: string): void {
    this.activeStatus = value;
    this.loadOrders();
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('我的订单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A');
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 });

      // Status tabs
      Scroll() {
        Row() {
          ForEach(this.statusTabs, (tab: StatusTab) => {
            Text(tab.label)
              .fontSize(13)
              .fontColor(this.activeStatus === tab.value ? '#FF6B35' : '#666666')
              .fontWeight(this.activeStatus === tab.value ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .border({
                width: { bottom: this.activeStatus === tab.value ? 2 : 0 },
                color: '#FF6B35'
              })
              .onClick(() => this.onStatusChange(tab.value));
          });
        }
        .padding({ left: 4, right: 4 });
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .padding({ bottom: 8 });

      // Order list
      if (this.isLoading) {
        Row() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.orders.length === 0) {
        EmptyView({
          icon: '📭',
          message: '暂无相关订单'
        })
          .layoutWeight(1);
      } else {
        List() {
          ForEach(this.orders, (order: OrderBrief) => {
            ListItem() {
              OrderCard({
                order: order,
                onTap: () => {
                  router.pushUrl({
                    url: 'pages/OrderDetailPage',
                    params: { orderId: order.id }
                  });
                }
              })
                .padding({ left: 16, right: 16 });
            }
          });
        }
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
