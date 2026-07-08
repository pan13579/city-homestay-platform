export class DateUtil {
  static formatDate(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  static formatMonth(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    return `${y}-${m}`;
  }

  static formatDisplayDate(dateStr: string): string {
    if (!dateStr) return '';
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      return `${Number(parts[1])}月${Number(parts[2])}日`;
    }
    return dateStr;
  }

  static formatDisplayRange(checkIn: string, checkOut: string): string {
    return `${DateUtil.formatDisplayDate(checkIn)} - ${DateUtil.formatDisplayDate(checkOut)}`;
  }

  static getNights(checkIn: string, checkOut: string): number {
    const start = new Date(checkIn).getTime();
    const end = new Date(checkOut).getTime();
    return Math.max(1, Math.round((end - start) / (1000 * 60 * 60 * 24)));
  }

  static getToday(): string {
    return DateUtil.formatDate(new Date());
  }

  static getDaysInMonth(monthStr: string): number {
    const parts = monthStr.split('-').map(Number);
    const y = parts[0];
    const m = parts[1];
    return new Date(y, m, 0).getDate();
  }

  static getDayOfWeek(date: Date): number {
    return date.getDay();
  }

  static getMonthName(monthStr: string): string {
    const parts = monthStr.split('-').map(Number);
    const y = parts[0];
    const m = parts[1];
    return `${y}年${m}月`;
  }

  static prevMonth(monthStr: string): string {
    const parts = monthStr.split('-').map(Number);
    const y = parts[0];
    const m = parts[1];
    if (m === 1) return `${y - 1}-12`;
    return `${y}-${String(m - 1).padStart(2, '0')}`;
  }

  static nextMonth(monthStr: string): string {
    const parts = monthStr.split('-').map(Number);
    const y = parts[0];
    const m = parts[1];
    if (m === 12) return `${y + 1}-01`;
    return `${y}-${String(m + 1).padStart(2, '0')}`;
  }
}
