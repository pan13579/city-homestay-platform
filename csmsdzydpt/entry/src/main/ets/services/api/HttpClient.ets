import { http } from '@kit.NetworkKit';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { ApiResponse } from '../../models/ApiResponse';

export class HttpClient {
  static async request<T>(method: http.RequestMethod, path: string, body?: Object): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const url = path.startsWith('http') ? path : `${ApiEndpoints.BASE_URL}${path}`;

      const options: http.HttpRequestOptions = {
        method: method,
        header: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer demo-token-2024'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      };

      if (body) {
        options.extraData = JSON.stringify(body);
      }

      const response = await httpRequest.request(url, options);

      if (response.responseCode === 200 || response.responseCode === 201) {
        const resultStr = typeof response.result === 'string'
          ? response.result
          : JSON.stringify(response.result);

        const result = JSON.parse(resultStr) as ApiResponse<T>;
        if (result.code === 0) {
          return result.data as T;
        }
        throw new Error(result.message || '请求失败');
      }

      throw new Error(`HTTP ${response.responseCode}: 请求失败`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : '网络请求失败';
      throw new Error(msg);
    } finally {
      httpRequest.destroy();
    }
  }

  static async get<T>(path: string): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.GET, path);
  }

  static async post<T>(path: string, body?: Object): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.POST, path, body);
  }

  static async put<T>(path: string, body?: Object): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.PUT, path, body);
  }
}
