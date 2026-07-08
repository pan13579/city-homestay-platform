export class PriceUtil {
  static format(price: number): string {
    if (price >= 1000) {
      return `¥${(price / 1000).toFixed(1)}k`;
    }
    return `¥${price}`;
  }

  static formatDetail(price: number): string {
    return `¥${price.toFixed(2)}`;
  }

  static getPerNight(price: number): string {
    return `${PriceUtil.format(price)}/晚`;
  }
}
