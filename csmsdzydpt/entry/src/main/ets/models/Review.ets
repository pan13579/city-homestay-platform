export class Review {
  id: number = 0;
  user_id: number = 0;
  user_name: string = '';
  user_avatar: string = '';
  listing_id: number = 0;
  listing_title: string = '';
  listing_city: string = '';
  order_id: number = 0;
  rating: number = 0;
  content: string = '';
  images: string[] = [];
  created_at: string = '';
}

export class CalendarDayInfo {
  date: string = '';
  price: number = 0;
  isAvailable: boolean = true;
  isPast: boolean = false;
  isSelected: boolean = false;
  isInRange: boolean = false;
  isCheckIn: boolean = false;
  isCheckOut: boolean = false;
}

export class DateRange {
  checkIn: string = '';
  checkOut: string = '';
}

export class FilterParams {
  keyword: string = '';
  city: string = '';
  roomType: string = '';
  minPrice: number = 0;
  maxPrice: number = 0;
  minRating: number = 0;
  sortBy: string = 'newest';
  page: number = 1;
  pageSize: number = 20;
}

export class SearchParams {
  page: number = 1;
  page_size: number = 20;
  sort_by: string = 'newest';
  keyword: string = '';
  city: string = '';
  room_type: string = '';
  min_price: number = 0;
  max_price: number = 0;
  min_rating: number = 0;
}

export interface CalendarMonthData {
  listingId: number;
  month: string;
  basePrice: number;
  days: Record<string, CalendarDayInfo>;
}
