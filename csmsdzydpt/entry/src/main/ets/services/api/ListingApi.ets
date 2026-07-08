import { HttpClient } from './HttpClient';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { ListingBrief, ListingDetail } from '../../models/Listing';
import { PaginatedData } from '../../models/ApiResponse';
import { CalendarDayInfo, SearchParams } from '../../models/Review';

export interface CalendarResult {
  listingId: number;
  month: string;
  basePrice: number;
  days: Record<string, CalendarDayInfo>;
}

export class ListingApi {
  static async getList(params: SearchParams): Promise<PaginatedData<ListingBrief>> {
    const parts: string[] = [];
    if (params.page) parts.push(`page=${params.page}`);
    if (params.page_size) parts.push(`page_size=${params.page_size}`);
    if (params.sort_by) parts.push(`sort_by=${encodeURIComponent(params.sort_by)}`);
    if (params.keyword) parts.push(`keyword=${encodeURIComponent(params.keyword)}`);
    if (params.city) parts.push(`city=${encodeURIComponent(params.city)}`);
    if (params.room_type) parts.push(`room_type=${encodeURIComponent(params.room_type)}`);
    if (params.min_price) parts.push(`min_price=${params.min_price}`);
    if (params.max_price) parts.push(`max_price=${params.max_price}`);
    if (params.min_rating) parts.push(`min_rating=${params.min_rating}`);
    const query = parts.join('&');

    return HttpClient.get<PaginatedData<ListingBrief>>(
      `${ApiEndpoints.LISTINGS}?${query}`
    );
  }

  static async getRecommended(limit: number = 5): Promise<ListingBrief[]> {
    return HttpClient.get<ListingBrief[]>(
      `${ApiEndpoints.LISTINGS_RECOMMENDED}?limit=${limit}`
    );
  }

  static async getDetail(id: number): Promise<ListingDetail> {
    return HttpClient.get<ListingDetail>(`${ApiEndpoints.LISTINGS}/${id}`);
  }

  static async getCities(): Promise<string[]> {
    return HttpClient.get<string[]>(ApiEndpoints.LISTINGS_CITIES);
  }

  static async getCalendar(listingId: number, month: string): Promise<CalendarResult> {
    return HttpClient.get<CalendarResult>(
      `${ApiEndpoints.LISTINGS}/${listingId}/calendar?month=${month}`
    );
  }
}
