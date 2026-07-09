import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { AuthStorage } from '../utils/AuthStorage';

@Entry
@Component
struct SettingsPage {
  @State notificationEnabled: boolean = true;
  @State locationEnabled: boolean = true;
  @State cacheSize: string = '--';

  aboutToAppear(): void {
    this.loadCacheSize();
  }

  async loadCacheSize(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(this), 'settings');
      const size = await prefs.get('cache_size', '0');
      const bytes = Number(size);
      if (bytes > 1024 * 1024) {
        this.cacheSize = `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
      } else if (bytes > 1024) {
        this.cacheSize = `${(bytes / 1024).toFixed(1)} KB`;
      } else {
        this.cacheSize = `${bytes} B`;
      }
    } catch (_err) {
      // 模拟缓存大小
      this.cacheSize = '23.5 MB';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(22)
            .fontColor('#1A1A1A');
        }
        .type(ButtonType.Circle)
        .width(36)
        .height(36)
        .backgroundColor('#F0F0F0')
        .onClick(() => router.back());

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        // 占位，保持标题居中
        Row().width(36).height(36);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 });

      // 可滚动内容
      Scroll() {
        Column() {
          // 账号信息
          Column() {
            Text('账号信息')
              .fontSize(13)
              .fontColor('#999999')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.Start);

            Column() {
              this.settingsItem('👤', '个人信息', '编辑昵称、头像等', () => {
                promptAction.showToast({ message: '个人信息页面开发中' });
              });
              Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 44 });
              this.settingsItem('🔒', '账号安全', '修改密码、绑定手机', () => {
                promptAction.showToast({ message: '账号安全页面开发中' });
              });
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 8 });

          // 通用设置
          Column() {
            Text('通用设置')
              .fontSize(13)
              .fontColor('#999999')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.Start);

            Column() {
              this.toggleItem('🔔', '消息通知', '接收订单和系统通知', this.notificationEnabled, (val: boolean) => {
                this.notificationEnabled = val;
              });
              Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 44 });
              this.toggleItem('📍', '位置信息', '获取附近民宿推荐', this.locationEnabled, (val: boolean) => {
                this.locationEnabled = val;
              });
              Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 44 });
              this.settingsItem('🌙', '深色模式', '跟随系统', () => {
                promptAction.showToast({ message: '深色模式跟随系统' });
              });
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 8 });

          // 隐私与数据
          Column() {
            Text('隐私与数据')
              .fontSize(13)
              .fontColor('#999999')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.Start);

            Column() {
              this.settingsItem('🛡️', '隐私政策', '', () => {
                promptAction.showToast({ message: '隐私政策页面开发中' });
              });
              Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 44 });
              this.settingsItem('📄', '用户协议', '', () => {
                promptAction.showToast({ message: '用户协议页面开发中' });
              });
              Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 44 });
              this.settingsItem('🗑️', '清除缓存', this.cacheSize, () => {
                this.showClearCacheDialog();
              });
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 8 });

          // 关于
          Column() {
            Text('关于')
              .fontSize(13)
              .fontColor('#999999')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.Start);

            Column() {
              this.settingsItem('ℹ️', '关于我们', '城市民宿预订平台 v1.0.0', () => {
                promptAction.showToast({ message: '城市民宿预订平台 v1.0.0' });
              });
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 8 });
        }
        .width('100%')
        .padding({ top: 8, bottom: 16 });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      // 退出登录按钮
      Button('退出登录')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontColor('#F44336')
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .border({ width: 1, color: '#FFCDD2' })
        .margin({ bottom: 32 })
        .onClick(() => this.logout());
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  settingsItem(icon: string, title: string, subtitle: string, onClick: () => void): void {
    Row() {
      Text(icon)
        .fontSize(18);
      Text(title)
        .fontSize(15)
        .fontColor('#1A1A1A')
        .margin({ left: 12 })
        .layoutWeight(1);
      if (subtitle) {
        Text(subtitle)
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      Text('›')
        .fontSize(18)
        .fontColor('#CCCCCC')
        .margin({ left: 8 });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(onClick);
  }

  @Builder
  toggleItem(icon: string, title: string, subtitle: string, isOn: boolean, onChange: (val: boolean) => void): void {
    Row() {
      Text(icon)
        .fontSize(18);
      Column() {
        Text(title)
          .fontSize(15)
          .fontColor('#1A1A1A');
        Text(subtitle)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1);

      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor('#FF6B35')
        .onChange((value: boolean) => onChange(value));
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 });
  }

  showClearCacheDialog(): void {
    AlertDialog.show({
      title: '清除缓存',
      message: `当前缓存大小：${this.cacheSize}，确定要清除吗？`,
      primaryButton: {
        value: '确定',
        fontColor: '#FF6B35',
        action: () => {
          this.cacheSize = '0 B';
          promptAction.showToast({ message: '缓存已清除' });
        }
      },
      secondaryButton: {
        value: '取消',
        fontColor: '#999999',
        action: () => {}
      }
    });
  }

  async logout(): Promise<void> {
    AlertDialog.show({
      title: '退出登录',
      message: '确定要退出当前账号吗？',
      primaryButton: {
        value: '确定',
        fontColor: '#F44336',
        action: async () => {
          await AuthStorage.clearAuth(getContext(this));
          router.replaceUrl({
            url: 'pages/LoginPage'
          });
        }
      },
      secondaryButton: {
        value: '取消',
        fontColor: '#999999',
        action: () => {}
      }
    });
  }
}
