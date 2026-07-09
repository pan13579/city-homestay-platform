import { HttpClient } from './HttpClient';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { AuthStorage } from '../../utils/AuthStorage';

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

export class RegisterResult {
  user: UserInfo = new UserInfo();
  token: string = '';
}

export class UserApi {
  static async register(username: string, password: string): Promise<RegisterResult> {
    const body = new RegisterBody();
    body.username = username;
    body.password = password;
    return HttpClient.post<RegisterResult>(ApiEndpoints.USERS_REGISTER, body);
  }

  static async login(username: string, password: string): Promise<LoginResult> {
    const body = new LoginBody();
    body.username = username;
    body.password = password;
    return HttpClient.post<LoginResult>(ApiEndpoints.USERS_LOGIN, body);
  }

  static async getProfile(): Promise<UserInfo> {
    return HttpClient.get<UserInfo>(ApiEndpoints.USERS_PROFILE);
  }

  static async updateProfile(data: UserInfo): Promise<UserInfo> {
    return HttpClient.put<UserInfo>(ApiEndpoints.USERS_PROFILE, data);
  }

  /**
   * Save auth data to persistent storage after login/register.
   * Must be called from a component context.
   */
  static async saveAuth(ctx: Context, result: LoginResult | RegisterResult): Promise<void> {
    await AuthStorage.saveAuth(ctx, result.token, result.user);
  }

  /**
   * Logout and clear stored auth data.
   * Must be called from a component context.
   */
  static async logout(ctx: Context): Promise<void> {
    await AuthStorage.clearAuth(ctx);
  }
}

class LoginBody {
  username: string = '';
  password: string = '';
}

class RegisterBody {
  username: string = '';
  password: string = '';
}
