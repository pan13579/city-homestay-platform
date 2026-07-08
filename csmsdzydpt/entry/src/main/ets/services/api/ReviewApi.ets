import { HttpClient } from './HttpClient';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { Review } from '../../models/Review';
import { PaginatedData } from '../../models/ApiResponse';

export class ReviewApi {
  static async getByListing(listingId: number, page: number = 1): Promise<PaginatedData<Review>> {
    return HttpClient.get<PaginatedData<Review>>(
      `${ApiEndpoints.REVIEWS}/listing/${listingId}?page=${page}`
    );
  }

  static async submit(orderId: number, rating: number, content: string, images: string[]): Promise<Review> {
    const body = new ReviewSubmitBody();
    body.order_id = orderId;
    body.rating = rating;
    body.content = content;
    body.images = images;
    return HttpClient.post<Review>(ApiEndpoints.REVIEWS, body);
  }
}

class ReviewSubmitBody {
  order_id: number = 0;
  rating: number = 0;
  content: string = '';
  images: string[] = [];
}
