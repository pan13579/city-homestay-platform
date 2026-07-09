export class ApiEndpoints {
  // 可通过偏好设置修改服务器地址
<<<<<<< Updated upstream
  static BASE_URL: string = 'http://10.21.195.23:3001';
=======
  static BASE_URL: string = 'http://192.168.43.109:3001';
>>>>>>> Stashed changes

  // 房源
  static readonly LISTINGS = `${ApiEndpoints.BASE_URL}/api/listings`;
  static readonly LISTINGS_RECOMMENDED = `${ApiEndpoints.BASE_URL}/api/listings/recommended`;
  static readonly LISTINGS_CITIES = `${ApiEndpoints.BASE_URL}/api/listings/cities`;

  // 订单
  static readonly ORDERS = `${ApiEndpoints.BASE_URL}/api/orders`;
  static readonly ORDERS_UPCOMING = `${ApiEndpoints.BASE_URL}/api/orders/upcoming`;
  static readonly ORDERS_CALCULATE = `${ApiEndpoints.BASE_URL}/api/orders/calculate`;
  static readonly ORDERS_CHECK = `${ApiEndpoints.BASE_URL}/api/orders/check`;

  // 评价
  static readonly REVIEWS = `${ApiEndpoints.BASE_URL}/api/reviews`;

  // 用户
  static readonly USERS_LOGIN = `${ApiEndpoints.BASE_URL}/api/users/login`;
  static readonly USERS_PROFILE = `${ApiEndpoints.BASE_URL}/api/users/profile`;

  // 上传
  static readonly UPLOAD = `${ApiEndpoints.BASE_URL}/api/upload`;

  static setBaseUrl(url: string): void {
    ApiEndpoints.BASE_URL = url;
  }

  static getImageUrl(path: string): string {
    if (!path) return '';
    if (path.startsWith('http')) return path;
    return `${ApiEndpoints.BASE_URL}${path}`;
  }
}
