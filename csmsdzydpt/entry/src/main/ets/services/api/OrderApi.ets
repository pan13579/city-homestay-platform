import { HttpClient } from './HttpClient';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { OrderBrief, OrderDetail } from '../../models/Order';

export class PriceInfo {
  nights: number = 0;
  baseTotal: number = 0;
  cleaningFee: number = 0;
  serviceFee: number = 0;
  totalPrice: number = 0;
}

export class OrderApi {
  static async getOrders(status?: string): Promise<OrderBrief[]> {
    const query = status ? `?status=${status}` : '';
    return HttpClient.get<OrderBrief[]>(`${ApiEndpoints.ORDERS}${query}`);
  }

  static async getUpcoming(): Promise<OrderBrief | null> {
    return HttpClient.get<OrderBrief | null>(ApiEndpoints.ORDERS_UPCOMING);
  }

  static async getDetail(id: number): Promise<OrderDetail> {
    return HttpClient.get<OrderDetail>(`${ApiEndpoints.ORDERS}/${id}`);
  }

  static async calculatePrice(listingId: number, checkIn: string, checkOut: string): Promise<PriceInfo> {
    const body = new OrderCalcBody();
    body.listing_id = listingId;
    body.check_in = checkIn;
    body.check_out = checkOut;
    return HttpClient.post<PriceInfo>(ApiEndpoints.ORDERS_CALCULATE, body);
  }

  static async createOrder(listingId: number, checkIn: string, checkOut: string, guests: number): Promise<OrderDetail> {
    const body = new OrderCreateBody();
    body.listing_id = listingId;
    body.check_in = checkIn;
    body.check_out = checkOut;
    body.guests = guests;
    return HttpClient.post<OrderDetail>(ApiEndpoints.ORDERS, body);
  }

  static async pay(orderId: number): Promise<OrderDetail> {
    return HttpClient.post<OrderDetail>(`${ApiEndpoints.ORDERS}/${orderId}/pay`);
  }

  static async cancel(orderId: number): Promise<OrderDetail> {
    return HttpClient.post<OrderDetail>(`${ApiEndpoints.ORDERS}/${orderId}/cancel`);
  }

  static async checkin(orderId: number): Promise<OrderDetail> {
    return HttpClient.post<OrderDetail>(`${ApiEndpoints.ORDERS}/${orderId}/checkin`);
  }

  static async complete(orderId: number): Promise<OrderDetail> {
    return HttpClient.post<OrderDetail>(`${ApiEndpoints.ORDERS}/${orderId}/complete`);
  }
}

class OrderCalcBody {
  listing_id: number = 0;
  check_in: string = '';
  check_out: string = '';
}

class OrderCreateBody {
  listing_id: number = 0;
  check_in: string = '';
  check_out: string = '';
  guests: number = 1;
}
