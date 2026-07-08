import { router } from '@kit.ArkUI';
import { Review } from '../models/Review';
import { HttpClient } from '../services/api/HttpClient';
import { ApiEndpoints } from '../constants/ApiEndpoints';
import { ReviewCard } from '../components/review/ReviewCard';
import { EmptyView } from '../components/common/EmptyView';

@Entry
@Component
struct MyReviewsPage {
  @State reviews: Review[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadReviews();
  }

  async loadReviews(): Promise<void> {
    this.isLoading = true;
    try {
      const data = await HttpClient.get<Review[]>(`${ApiEndpoints.REVIEWS}/user`);
      this.reviews = data || [];
    } catch (err) {
      this.reviews = [];
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(14)
            .fontColor('#1A1A1A');
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());

        Text('我的评价')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('').width(60);
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#FF6B35');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.reviews.length === 0) {
        EmptyView({ icon: '📝', message: '暂无评价记录' })
          .layoutWeight(1);
      } else {
        List() {
          ForEach(this.reviews, (review: Review) => {
            ListItem() {
              Column() {
                ReviewCard({ review: review });
                if (review.listing_title) {
                  Text(`房源: ${review.listing_title}`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 });
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12, right: 12, bottom: 8 });
            }
          });
        }
        .layoutWeight(1);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
