import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

// FAQ 数据结构
interface FaqItem {
  question: string;
  answer: string;
  expanded: boolean;
}

@Entry
@Component
struct HelpFeedbackPage {
  @State faqList: FaqItem[] = [
    {
      question: '如何预订民宿？',
      answer: '您可以在首页浏览心仪的民宿，点击进入详情页选择入住日期和人数后，点击"立即预订"按钮完成订单。',
      expanded: false
    },
    {
      question: '如何取消订单？',
      answer: '在"我的订单"中找到需要取消的订单，点击进入订单详情，选择"取消订单"即可。请注意查看取消政策，部分订单取消可能会产生费用。',
      expanded: false
    },
    {
      question: '支付方式有哪些？',
      answer: '我们支持微信支付、支付宝、银行卡等多种支付方式，您可以在结算页面选择最方便的支付方式。',
      expanded: false
    },
    {
      question: '如何联系房东？',
      answer: '预订成功后，您可以在订单详情页查看房东的联系方式，也可以使用站内聊天功能与房东沟通。',
      expanded: false
    },
    {
      question: '入住和退房时间？',
      answer: '标准入住时间为14:00后，退房时间为12:00前。部分民宿可能有不同的时间安排，具体以房源页面显示为准。',
      expanded: false
    }
  ];
  @State feedbackText: string = '';
  @State selectedRating: number = 0;

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

        Text('帮助与反馈')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Row().width(36).height(36);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 });

      Scroll() {
        Column() {
          // 快捷入口
          Row() {
            this.quickEntry('📞', '联系客服', () => {
              promptAction.showToast({ message: '客服电话：400-123-4567' });
            });
            this.quickEntry('📖', '使用指南', () => {
              promptAction.showToast({ message: '使用指南页面开发中' });
            });
            this.quickEntry('💬', '在线咨询', () => {
              promptAction.showToast({ message: '在线咨询功能开发中' });
            });
          }
          .width('100%')
          .padding({ top: 8, bottom: 16 })
          .justifyContent(FlexAlign.SpaceEvenly);

          // 常见问题
          Column() {
            Text('常见问题')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start);

            ForEach(this.faqList, (item: FaqItem, index: number) => {
              Column() {
                // 问题 - 点击展开/折叠
                Row() {
                  Text(item.question)
                    .fontSize(15)
                    .fontColor('#1A1A1A')
                    .layoutWeight(1);
                  Text(item.expanded ? '▲' : '▼')
                    .fontSize(12)
                    .fontColor('#999999');
                }
                .width('100%')
                .padding({ top: 14, bottom: 14, left: 16, right: 16 })
                .onClick(() => {
                  // 切换展开状态
                  item.expanded = !item.expanded;
                  this.faqList = this.faqList;
                });

                // 答案 - 条件显示
                if (item.expanded) {
                  Text(item.answer)
                    .fontSize(14)
                    .fontColor('#666666')
                    .lineHeight(22)
                    .padding({ left: 16, right: 16, bottom: 14 })
                    .width('100%');
                }
              }
              .backgroundColor('#FFFFFF')
              .borderRadius(index < this.faqList.length - 1 ? 0 : 10);
            });
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 });

          // 意见反馈
          Column() {
            Text('意见反馈')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start);

            // 评分
            Column() {
              Text('您对平台的总体评价')
                .fontSize(13)
                .fontColor('#666666')
                .margin({ bottom: 10 });

              Row() {
                ForEach(['😞', '😐', '🙂', '😊', '😍'], (emoji: string, starIndex: number) => {
                  Text(emoji)
                    .fontSize(28)
                    .margin({ left: 4, right: 4 })
                    .opacity(this.selectedRating >= starIndex + 1 ? 1 : 0.4)
                    .onClick(() => {
                      this.selectedRating = starIndex + 1;
                    });
                });
              }
              .margin({ bottom: 12 });

              if (this.selectedRating > 0) {
                Text(`您的评分：${this.selectedRating} / 5 星`)
                  .fontSize(12)
                  .fontColor('#FF6B35');
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: 16 });

            // 反馈输入框
            TextArea({ placeholder: '请输入您的意见或建议，帮助我们变得更好…', text: this.feedbackText })
              .height(120)
              .width('100%')
              .fontSize(14)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.feedbackText = value;
              });

            // 提交按钮
            Button('提交反馈')
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor(this.feedbackText.trim() ? '#FF6B35' : '#CCCCCC')
              .borderRadius(22)
              .margin({ top: 16, bottom: 8 })
              .enabled(!!this.feedbackText.trim())
              .onClick(() => this.submitFeedback());
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 });

          // 联系方式
          Text('© 2026 城市民宿预订平台 版权所有')
            .fontSize(11)
            .fontColor('#CCCCCC')
            .margin({ bottom: 32 });
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8 });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  quickEntry(icon: string, label: string, onClick: () => void): void {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 6 });
      Text(label)
        .fontSize(13)
        .fontColor('#333333');
    }
    .width(100)
    .height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(onClick);
  }

  submitFeedback(): void {
    if (this.feedbackText.trim().length === 0) {
      promptAction.showToast({ message: '请输入反馈内容' });
      return;
    }

    AlertDialog.show({
      title: '提交反馈',
      message: '感谢您的宝贵意见，我们会认真对待每一条反馈！',
      primaryButton: {
        value: '确定',
        fontColor: '#FF6B35',
        action: () => {
          // 清空反馈内容
          this.feedbackText = '';
          this.selectedRating = 0;
          promptAction.showToast({ message: '反馈提交成功' });
        }
      }
    });
  }
}
