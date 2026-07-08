import { ListingBrief } from '../models/Listing';
import { OrderBrief } from '../models/Order';
import { UserInfo } from './api/UserApi';

export class MockData {
  static getRecommendedListings(): ListingBrief[] {
    const list: ListingBrief[] = [];
    list.push(MockData.makeListing(1, '西湖边的温馨小屋', '杭州', '杭州市西湖区龙井路88号', 'entire_place', 358, 4.8, 126, 30.2395, 120.135, 2, 1, 1));
    list.push(MockData.makeListing(2, '外滩景观公寓', '上海', '上海市黄浦区中山东一路18号', 'entire_place', 688, 4.9, 89, 31.239, 121.49, 4, 2, 2));
    list.push(MockData.makeListing(3, '鼓浪屿海景民宿', '厦门', '厦门市思明区鼓浪屿安海路35号', 'private_room', 288, 4.7, 203, 24.448, 118.068, 2, 1, 1));
    list.push(MockData.makeListing(5, '三亚海棠湾度假别墅', '三亚', '三亚市海棠区海棠北路168号', 'entire_place', 1588, 5.0, 42, 18.31, 109.73, 8, 4, 5));
    list.push(MockData.makeListing(6, '北京胡同四合院', '北京', '北京市东城区南锣鼓巷胡同56号', 'private_room', 428, 4.8, 178, 39.937, 116.403, 2, 1, 1));
    list.push(MockData.makeListing(10, '重庆解放碑江景民宿', '重庆', '重庆市渝中区解放碑八一路9号', 'entire_place', 388, 4.7, 143, 29.561, 106.576, 4, 2, 2));
    return list;
  }

  static makeListing(id: number, title: string, city: string, address: string, roomType: string,
    price: number, rating: number, reviews: number, lat: number, lng: number,
    guests: number, bedrooms: number, beds: number): ListingBrief {
    const b = new ListingBrief();
    b.id = id;
    b.title = title;
    b.city = city;
    b.address = address;
    b.room_type = roomType;
    b.base_price = price;
    b.avg_rating = rating;
    b.review_count = reviews;
    b.images = [];
    b.latitude = lat;
    b.longitude = lng;
    b.max_guests = guests;
    b.bedrooms = bedrooms;
    b.beds = beds;
    return b;
  }

  static getCities(): string[] {
    const cities: string[] = [];
    cities.push('三亚');
    cities.push('上海');
    cities.push('北京');
    cities.push('南京');
    cities.push('厦门');
    cities.push('大理');
    cities.push('广州');
    cities.push('成都');
    cities.push('杭州');
    cities.push('深圳');
    cities.push('西安');
    cities.push('重庆');
    return cities;
  }

  static getUserProfile(): UserInfo {
    const u = new UserInfo();
    u.id = 1;
    u.username = 'demo_user';
    u.nickname = '旅行达人小王';
    u.phone = '138****0000';
    return u;
  }

  static getUpcomingStay(): OrderBrief {
    const o = new OrderBrief();
    o.id = 1;
    o.listing_id = 1;
    o.listing_title = '西湖边的温馨小屋';
    o.listing_cover = '';
    o.listing_city = '杭州';
    o.check_in = '2026-07-15';
    o.check_out = '2026-07-17';
    o.nights = 2;
    o.total_price = 837.6;
    o.status = 'pending_payment';
    o.created_at = '2026-07-08';
    return o;
  }

  static getOrders(): OrderBrief[] {
    const orders: OrderBrief[] = [];
    orders.push(MockData.makeOrder(1, 1, '西湖边的温馨小屋', '杭州', '2026-07-11', '2026-07-13', 2, 837.6, 'pending_payment'));
    orders.push(MockData.makeOrder(2, 2, '外滩景观公寓', '上海', '2026-07-15', '2026-07-17', 2, 1613.6, 'confirmed'));
    orders.push(MockData.makeOrder(3, 4, '成都太古里潮流公寓', '成都', '2026-07-07', '2026-07-10', 3, 1142.4, 'checked_in'));
    orders.push(MockData.makeOrder(4, 5, '三亚海棠湾度假别墅', '三亚', '2026-07-03', '2026-07-06', 3, 5440.4, 'completed'));
    orders.push(MockData.makeOrder(5, 3, '鼓浪屿海景民宿', '厦门', '2026-07-20', '2026-07-22', 2, 652.1, 'cancelled'));
    return orders;
  }

  static makeOrder(id: number, listingId: number, title: string, city: string,
    checkIn: string, checkOut: string, nights: number, price: number, status: string): OrderBrief {
    const o = new OrderBrief();
    o.id = id;
    o.listing_id = listingId;
    o.listing_title = title;
    o.listing_cover = '';
    o.listing_city = city;
    o.check_in = checkIn;
    o.check_out = checkOut;
    o.nights = nights;
    o.total_price = price;
    o.status = status;
    o.created_at = '2026-07-08';
    return o;
  }
}
