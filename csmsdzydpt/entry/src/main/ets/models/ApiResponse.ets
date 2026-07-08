export class ApiResponse<T> {
  code: number = 0;
  message: string = '';
  data: T | null = null;
}

export class PaginatedData<T> {
  list: T[] = [];
  total: number = 0;
  page: number = 1;
  pageSize: number = 20;
  totalPages: number = 0;
}
