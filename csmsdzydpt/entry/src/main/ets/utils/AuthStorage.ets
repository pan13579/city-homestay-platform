import { preferences } from '@kit.ArkData';
import { UserInfo } from '../services/api/UserApi';

const STORE_NAME = 'auth_store';
const KEY_TOKEN = 'token';
const KEY_USER_ID = 'user_id';
const KEY_USERNAME = 'username';
const KEY_NICKNAME = 'nickname';
const KEY_PHONE = 'phone';
const KEY_AVATAR = 'avatar_url';

export class AuthStorage {
  // In-memory state
  private static token: string = '';
  private static user: UserInfo | null = null;
  private static initialized: boolean = false;

  /**
   * Initialize from persisted preferences. Call once at app startup from a component.
   */
  static async init(context: Context): Promise<void> {
    if (AuthStorage.initialized) return;
    try {
      const prefs = await preferences.getPreferences(context, STORE_NAME);
      AuthStorage.token = (await prefs.get(KEY_TOKEN, '')) as string;

      const userId = (await prefs.get(KEY_USER_ID, 0)) as number;
      if (userId > 0 && AuthStorage.token) {
        const user = new UserInfo();
        user.id = userId;
        user.username = (await prefs.get(KEY_USERNAME, '')) as string;
        user.nickname = (await prefs.get(KEY_NICKNAME, '')) as string;
        user.phone = (await prefs.get(KEY_PHONE, '')) as string;
        user.avatar_url = (await prefs.get(KEY_AVATAR, '')) as string;
        AuthStorage.user = user;
      }
    } catch (_) {
      // Preferences not available, continue with empty state
    }
    AuthStorage.initialized = true;
  }

  /**
   * Save authentication data after login/register.
   * Call from a component context.
   */
  static async saveAuth(ctx: Context, token: string, user: UserInfo): Promise<void> {
    AuthStorage.token = token;
    AuthStorage.user = user;
    try {
      const prefs = await preferences.getPreferences(ctx, STORE_NAME);
      await prefs.put(KEY_TOKEN, token);
      await prefs.put(KEY_USER_ID, user.id);
      await prefs.put(KEY_USERNAME, user.username);
      await prefs.put(KEY_NICKNAME, user.nickname);
      await prefs.put(KEY_PHONE, user.phone);
      await prefs.put(KEY_AVATAR, user.avatar_url);
      await prefs.flush();
    } catch (_) {
      // Preferences write failed, in-memory state is still set
    }
  }

  /**
   * Clear authentication data on logout.
   * Call from a component context.
   */
  static async clearAuth(ctx: Context): Promise<void> {
    AuthStorage.token = '';
    AuthStorage.user = null;
    try {
      const prefs = await preferences.getPreferences(ctx, STORE_NAME);
      await prefs.delete(KEY_TOKEN);
      await prefs.delete(KEY_USER_ID);
      await prefs.delete(KEY_USERNAME);
      await prefs.delete(KEY_NICKNAME);
      await prefs.delete(KEY_PHONE);
      await prefs.delete(KEY_AVATAR);
      await prefs.flush();
    } catch (_) {
      // Preferences clear failed
    }
  }

  /**
   * Get the current auth token (synchronous, for HttpClient).
   */
  static getToken(): string {
    return AuthStorage.token;
  }

  /**
   * Get the current user info (synchronous).
   */
  static getUser(): UserInfo | null {
    return AuthStorage.user;
  }

  /**
   * Check if user is logged in.
   */
  static isLoggedIn(): boolean {
    return AuthStorage.token !== '' && AuthStorage.user !== null;
  }
}
