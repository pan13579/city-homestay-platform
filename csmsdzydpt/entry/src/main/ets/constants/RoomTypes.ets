export function getRoomTypeLabel(type: string): string {
  const map: Record<string, string> = {
    'entire_place': '整套房源',
    'private_room': '独立房间',
    'shared_room': '合住房间'
  };
  return map[type] || type;
}

export function getRoomTypeIcon(type: string): string {
  const map: Record<string, string> = {
    'entire_place': '🏠',
    'private_room': '🚪',
    'shared_room': '🛏️'
  };
  return map[type] || '🏠';
}
