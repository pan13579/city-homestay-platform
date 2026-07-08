import { HttpClient } from './HttpClient';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

export class UserInfo {
  id: number = 0;
  username: string = '';
  nickname: string = '';
  phone: string = '';
  avatar_url: string = '';
}

export class LoginResult {
  user: UserInfo = new UserInfo();
  token: string = '';
}

export class UserApi {
  static async login(username: string): Promise<LoginResult> {
    const body = new LoginBody();
    body.username = username;
    return HttpClient.post<LoginResult>(ApiEndpoints.USERS_LOGIN, body);
  }

  static async getProfile(): Promise<UserInfo> {
    return HttpClient.get<UserInfo>(ApiEndpoints.USERS_PROFILE);
  }

  static async updateProfile(data: UserInfo): Promise<UserInfo> {
    return HttpClient.put<UserInfo>(ApiEndpoints.USERS_PROFILE, data);
  }
}

class LoginBody {
  username: string = '';
}
