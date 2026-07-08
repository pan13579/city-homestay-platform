import { router } from '@kit.ArkUI';
import { ReviewApi } from '../services/api/ReviewApi';
import { RatingInput } from '../components/review/RatingInput';

@Entry
@Component
struct ReviewSubmitPage {
  private orderId: number = 0;
  private listingId: number = 0;
  @State rating: number = 0;
  @State content: string = '';
  @State isSubmitting: boolean = false;
  @State submitSuccess: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.orderId = Number(params['orderId'] || 0);
      this.listingId = Number(params['listingId'] || 0);
    }
  }

  async onSubmit(): Promise<void> {
    if (this.rating === 0) {
      // Show error: please rate
      return;
    }
    if (this.isSubmitting) return;
    this.isSubmitting = true;
    try {
      await ReviewApi.submit(this.orderId, this.rating, this.content, []);
      this.submitSuccess = true;
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (err) {
      const msg = err instanceof Error ? err.message : '提交失败';
    }
    this.isSubmitting = false;
  }

  build() {
    Column() {
      // Header
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());

        Text('写评价')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('').width(60);
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      if (this.submitSuccess) {
        Column() {
          Text('✅')
            .fontSize(64)
            .margin({ bottom: 16 });
          Text('评价提交成功！')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A');
          Text('感谢您的评价')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Scroll() {
          Column() {
            // Rating section
            Column() {
              Text('您的评分')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .margin({ bottom: 16 });

              RatingInput({ rating: this.rating, starSize: 40 });

              Text(this.getRatingLabel())
                .fontSize(14)
                .fontColor('#FFB800')
                .margin({ top: 8 });
            }
            .width('100%')
            .padding(24)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 12, right: 12, top: 12, bottom: 12 })
            .alignItems(HorizontalAlign.Center);

            // Content section
            Column() {
              Text('评价内容')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .width('100%')
                .margin({ bottom: 12 });

              TextArea({ placeholder: '分享您的入住体验，帮助其他旅行者...' })
                .width('100%')
                .height(150)
                .fontSize(14)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding(12)
                .onChange((value: string) => {
                  this.content = value;
                });
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 12, right: 12, bottom: 80 });
          }
          .width('100%');
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }

      // Submit button
      if (!this.submitSuccess) {
        Row() {
          Button() {
            if (this.isSubmitting) {
              LoadingProgress().width(20).height(20).color('#FFFFFF');
            } else {
              Text('提交评价')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF');
            }
          }
          .enabled(!this.isSubmitting && this.rating > 0)
          .width('100%')
          .height(48)
          .backgroundColor(this.rating > 0 && !this.isSubmitting ? '#FF6B35' : '#CCCCCC')
          .borderRadius(24)
          .onClick(() => this.onSubmit());
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 8, color: '#10000000', offsetY: -2 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  getRatingLabel(): string {
    const labels = ['请选择评分', '非常差', '较差', '一般', '很好', '非常棒！'];
    return labels[this.rating] || '';
  }
}
