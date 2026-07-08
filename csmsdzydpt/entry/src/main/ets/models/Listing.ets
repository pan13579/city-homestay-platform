export class NearbyPlace {
  name: string = '';
  type: string = '';
  distance: string = '';
}

export class ListingBrief {
  id: number = 0;
  title: string = '';
  city: string = '';
  address: string = '';
  room_type: string = '';
  base_price: number = 0;
  avg_rating: number = 0;
  review_count: number = 0;
  images: string[] = [];
  latitude: number = 0;
  longitude: number = 0;
  max_guests: number = 1;
  bedrooms: number = 1;
  beds: number = 1;
}

export class ListingDetail {
  id: number = 0;
  title: string = '';
  description: string = '';
  address: string = '';
  city: string = '';
  latitude: number = 0;
  longitude: number = 0;
  room_type: string = '';
  max_guests: number = 1;
  bedrooms: number = 1;
  beds: number = 1;
  bathrooms: number = 1;
  amenities: string[] = [];
  base_price: number = 0;
  cleaning_fee: number = 0;
  service_fee_percent: number = 10;
  avg_rating: number = 0;
  review_count: number = 0;
  images: string[] = [];
  host_name: string = '';
  host_avatar: string = '';
  nearby: NearbyPlace[] = [];
  status: string = '';
}
