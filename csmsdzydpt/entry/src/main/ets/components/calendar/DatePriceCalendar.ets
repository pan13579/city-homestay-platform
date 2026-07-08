import { CalendarDayInfo, DateRange } from '../../models/Review';
import { ListingApi } from '../../services/api/ListingApi';
import { DateUtil } from '../../utils/DateUtil';

@Component
export struct DatePriceCalendar {
  @Prop listingId: number = 0;
  @Link selectedDates: DateRange;
  @Link totalPrice: number;
  basePrice: number = 0;

  @State currentMonth: string = DateUtil.formatMonth(new Date());
  @State calendarDays: CalendarDayInfo[] = [];
  @State isLoading: boolean = true;
  @State selectionState: string = 'none'; // none | selecting_checkin | complete
  @State computedTotal: number = 0;

  private availabilityMap: Record<string, CalendarDayInfo> = {};

  aboutToAppear(): void {
    this.loadCalendar();
  }

  async loadCalendar(): Promise<void> {
    this.isLoading = true;
    try {
      const data = await ListingApi.getCalendar(this.listingId, this.currentMonth);
      this.basePrice = data.basePrice;
      this.availabilityMap = data.days || {};
      this.buildCalendarGrid();
      this.isLoading = false;
    } catch (err) {
      this.isLoading = false;
    }
  }

  buildCalendarGrid(): void {
    const parts = this.currentMonth.split('-').map(Number);
    const year = parts[0];
    const mon = parts[1];
    const firstDay = new Date(year, mon - 1, 1);
    const daysInMonth = new Date(year, mon, 0).getDate();
    const startDayOfWeek = firstDay.getDay();
    const today = DateUtil.getToday();

    // Build 42 cells (6 weeks)
    const days: CalendarDayInfo[] = [];
    const prevMonthDays = new Date(year, mon - 1, 0).getDate();

    // Previous month trailing days
    for (let i = startDayOfWeek - 1; i >= 0; i--) {
      const d = prevMonthDays - i;
      const prevMonth = mon === 1 ? 12 : mon - 1;
      const prevYear = mon === 1 ? year - 1 : year;
      const dateStr = `${prevYear}-${String(prevMonth).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      days.push(this.createDayInfo(dateStr, true, today));
    }

    // Current month days
    for (let d = 1; d <= daysInMonth; d++) {
      const dateStr = `${year}-${String(mon).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      days.push(this.createDayInfo(dateStr, false, today));
    }

    // Next month leading days
    const remaining = 42 - days.length;
    for (let d = 1; d <= remaining; d++) {
      const nextMonth = mon === 12 ? 1 : mon + 1;
      const nextYear = mon === 12 ? year + 1 : year;
      const dateStr = `${nextYear}-${String(nextMonth).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      days.push(this.createDayInfo(dateStr, true, today));
    }

    this.calendarDays = days;
    this.highlightRange();
  }

  createDayInfo(dateStr: string, isOtherMonth: boolean, today: string): CalendarDayInfo {
    const info = new CalendarDayInfo();
    info.date = dateStr;
    info.isPast = dateStr < today;

    if (this.availabilityMap[dateStr]) {
      const av = this.availabilityMap[dateStr];
      info.price = av.price;
      info.isAvailable = av.isAvailable && !info.isPast;
    } else if (!isOtherMonth) {
      info.price = this.basePrice;
      info.isAvailable = !info.isPast;
    } else {
      info.isAvailable = false;
    }

    return info;
  }

  highlightRange(): void {
    const checkIn = this.selectedDates.checkIn;
    const checkOut = this.selectedDates.checkOut;

    this.calendarDays.forEach((day: CalendarDayInfo) => {
      day.isCheckIn = day.date === checkIn;
      day.isCheckOut = day.date === checkOut;
      day.isInRange = checkIn !== '' && checkOut !== '' &&
        day.date > checkIn && day.date < checkOut;
      day.isSelected = day.isCheckIn || day.isCheckOut;
    });
  }

  onDayTap(day: CalendarDayInfo): void {
    if (!day.isAvailable || day.isPast) return;

    if (this.selectionState === 'none' || this.selectionState === 'complete') {
      // Start new selection: set check-in
      this.selectedDates.checkIn = day.date;
      this.selectedDates.checkOut = '';
      this.selectionState = 'selecting_checkin';
      this.computedTotal = 0;
    } else if (this.selectionState === 'selecting_checkin') {
      if (day.date === this.selectedDates.checkIn) {
        // Tap same day again: cancel selection
        this.selectedDates.checkIn = '';
        this.selectedDates.checkOut = '';
        this.selectionState = 'none';
        this.computedTotal = 0;
      } else if (day.date < this.selectedDates.checkIn) {
        // Tap before check-in: move check-in
        this.selectedDates.checkIn = day.date;
        this.computedTotal = 0;
      } else {
        // Set check-out
        this.selectedDates.checkOut = day.date;
        this.selectionState = 'complete';
        this.calculateTotal();
      }
    }

    this.highlightRange();
  }

  async calculateTotal(): Promise<void> {
    if (!this.selectedDates.checkIn || !this.selectedDates.checkOut) {
      this.computedTotal = 0;
      this.totalPrice = 0;
      return;
    }

    // Calculate locally from calendar data
    let total = 0;
    this.calendarDays.forEach((day: CalendarDayInfo) => {
      if (day.date >= this.selectedDates.checkIn && day.date < this.selectedDates.checkOut) {
        if (day.price > 0) {
          total += day.price;
        }
      }
    });

    this.computedTotal = total;
    this.totalPrice = total;
  }

  prevMonth(): void {
    this.currentMonth = DateUtil.prevMonth(this.currentMonth);
    this.loadCalendar();
  }

  nextMonth(): void {
    this.currentMonth = DateUtil.nextMonth(this.currentMonth);
    this.loadCalendar();
  }

  build() {
    Column() {
      // Month header
      Row() {
        Text('◀')
          .fontSize(16)
          .fontColor('#999999')
          .onClick(() => this.prevMonth());

        Text(DateUtil.getMonthName(this.currentMonth))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('▶')
          .fontSize(16)
          .fontColor('#999999')
          .onClick(() => this.nextMonth());
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 });

      // Weekday header
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
          Text(day)
            .fontSize(12)
            .fontColor('#999999')
            .width('14.28%')
            .textAlign(TextAlign.Center);
        });
      }
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 4 });

      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(30)
            .height(30)
            .color('#FF6B35');
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center);
      } else {
        // Calendar grid - 6 rows of 7
        Grid() {
          ForEach(this.calendarDays, (day: CalendarDayInfo) => {
            GridItem() {
              Column() {
                Text(day.date.split('-')[2])
                  .fontSize(13)
                  .fontColor(this.getDayTextColor(day))
                  .fontWeight(day.isCheckIn || day.isCheckOut ? FontWeight.Bold : FontWeight.Normal);

                if (day.price > 0 && day.isAvailable && !day.isPast) {
                  Text(`¥${day.price}`)
                    .fontSize(9)
                    .fontColor(this.getPriceColor(day))
                    .maxLines(1);
                } else {
                  Text(day.isPast ? '' : '满')
                    .fontSize(9)
                    .fontColor('#CCCCCC');
                }
              }
              .width('100%')
              .height(44)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .borderRadius(8)
              .backgroundColor(this.getDayBgColor(day))
              .onClick(() => this.onDayTap(day));
            }
          });
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(2)
        .columnsGap(2)
        .width('100%')
        .padding({ left: 4, right: 4, bottom: 12 });
      }

      // Legend
      Row() {
        Row() {
          Text('●').fontSize(10).fontColor('#FF6B35').margin({ right: 4 });
          Text('已选').fontSize(10).fontColor('#999999');
        }.margin({ right: 12 });

        Row() {
          Text('●').fontSize(10).fontColor('#BBDEFB').margin({ right: 4 });
          Text('范围').fontSize(10).fontColor('#999999');
        }.margin({ right: 12 });

        Row() {
          Text('●').fontSize(10).fontColor('#F5F5F5').margin({ right: 4 });
          Text('不可订').fontSize(10).fontColor('#999999');
        };
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 });
  }

  // Color helpers
  getDayBgColor(day: CalendarDayInfo): string {
    if (day.isCheckIn || day.isCheckOut) return '#FF6B35';
    if (day.isInRange) return '#BBDEFB';
    if (!day.isAvailable || day.isPast) return '#F5F5F5';
    return '#FFFFFF';
  }

  getDayTextColor(day: CalendarDayInfo): string {
    if (day.isCheckIn || day.isCheckOut) return '#FFFFFF';
    if (day.isInRange) return '#1976D2';
    if (!day.isAvailable || day.isPast) return '#CCCCCC';
    return '#1A1A1A';
  }

  getPriceColor(day: CalendarDayInfo): string {
    if (day.isCheckIn || day.isCheckOut) return '#FFFFFF';
    if (day.isInRange) return '#1976D2';
    return '#FF6B35';
  }
}
