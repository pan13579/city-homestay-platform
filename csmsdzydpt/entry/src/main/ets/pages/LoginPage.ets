import { router } from '@kit.ArkUI';
import { UserApi } from '../services/api/UserApi';
import { AuthStorage } from '../utils/AuthStorage';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;

  aboutToAppear(): void {
    // Initialize auth storage from persisted preferences
    AuthStorage.init(getContext(this));
  }

  async handleLogin(): Promise<void> {
    // Validation
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名', duration: 2000 });
      return;
    }
    if (!this.password) {
      promptAction.showToast({ message: '请输入密码', duration: 2000 });
      return;
    }

    this.isLoading = true;
    try {
      const result = await UserApi.login(this.username.trim(), this.password);
      await UserApi.saveAuth(getContext(this), result);
      promptAction.showToast({ message: '登录成功', duration: 1500 });
      router.replaceUrl({ url: 'pages/HomePage' });
    } catch (err) {
      const msg = err instanceof Error ? err.message : '登录失败，请重试';
      promptAction.showToast({ message: msg, duration: 2000 });
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // Back button
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 });

      // Logo area
      Column() {
        Text('🏠')
          .fontSize(56)
          .margin({ bottom: 12 });

        Text('城宿短租')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ bottom: 6 });

        Text('欢迎回来，登录您的账号')
          .fontSize(14)
          .fontColor('#999999');
      }
      .width('100%')
      .padding({ top: 24, bottom: 32 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);

      // Login form
      Column() {
        // Username input
        Row() {
          Text('👤')
            .fontSize(18)
            .margin({ right: 10 });
          TextInput({ placeholder: '请输入用户名', text: this.username })
            .fontSize(15)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.username = value;
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .backgroundColor('#F9F9F9')
        .borderRadius(10)
        .margin({ bottom: 14 });

        // Password input
        Row() {
          Text('🔒')
            .fontSize(18)
            .margin({ right: 10 });
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .fontSize(15)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.password = value;
            });
          Text(this.showPassword ? '🙈' : '👁️')
            .fontSize(16)
            .margin({ left: 8 })
            .onClick(() => {
              this.showPassword = !this.showPassword;
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .backgroundColor('#F9F9F9')
        .borderRadius(10)
        .margin({ bottom: 24 });

        // Login button
        Button() {
          if (this.isLoading) {
            LoadingProgress()
              .width(22)
              .height(22)
              .color('#FFFFFF');
          } else {
            Text('登 录')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
          }
        }
        .width('100%')
        .height(48)
        .backgroundColor(this.isLoading ? '#FF9A6C' : '#FF6B35')
        .borderRadius(24)
        .enabled(!this.isLoading)
        .onClick(() => this.handleLogin());

        // Register link
        Row() {
          Text('还没有账号？')
            .fontSize(13)
            .fontColor('#999999');
          Text('立即注册')
            .fontSize(13)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.pushUrl({ url: 'pages/RegisterPage' });
            });
        }
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .padding({ left: 28, right: 28 });

      Blank();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
