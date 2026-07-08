import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State opacityValue: number = 0;

  aboutToAppear(): void {
    // Fade in animation
    animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
      this.opacityValue = 1;
    });

    // Navigate to HomePage after splash
    setTimeout(() => {
      animateTo({ duration: 400, curve: Curve.EaseIn }, () => {
        this.opacityValue = 0;
      });
      setTimeout(() => {
        router.replaceUrl({ url: 'pages/HomePage' });
      }, 400);
    }, 1500);
  }

  build() {
    Column() {
      Column() {
        // Logo
        Text('🏠')
          .fontSize(72)
          .margin({ bottom: 16 });

        Text('城宿短租')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 8 });

        Text('发现美好的家')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.8);
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FF6B35')
      .opacity(this.opacityValue);
    }
    .width('100%')
    .height('100%');
  }
}
