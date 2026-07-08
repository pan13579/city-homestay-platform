export enum OrderStatus {
  PENDING_PAYMENT = 'pending_payment',
  CONFIRMED = 'confirmed',
  CHECKED_IN = 'checked_in',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export function getStatusLabel(status: string): string {
  const map: Record<string, string> = {
    'pending_payment': '待支付',
    'confirmed': '已确认',
    'checked_in': '已入住',
    'completed': '已完成',
    'cancelled': '已取消'
  };
  return map[status] || status;
}

export function getStatusColor(status: string): string {
  const map: Record<string, string> = {
    'pending_payment': '#FF9800',
    'confirmed': '#4CAF50',
    'checked_in': '#2196F3',
    'completed': '#9E9E9E',
    'cancelled': '#F44336'
  };
  return map[status] || '#999999';
}
