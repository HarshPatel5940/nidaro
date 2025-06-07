import type { Env } from '../types';

export class GSTPortalService {
  private baseUrl = 'https://services.gst.gov.in';
  private searchPageUrl = `${this.baseUrl}/services/searchtpbypan`;
  private captchaUrl = `${this.baseUrl}/services/captcha`;
  private apiUrl = `${this.baseUrl}/services/api/get/gstndtls`;
  private taxpayerDetailsUrl = `${this.baseUrl}/services/api/search/taxpayerDetails`;

  private getHeaders() {
    return {
      'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      DNT: '1',
      Connection: 'keep-alive',
    };
  }

  async initializeSession(): Promise<Response> {
    const headers = {
      ...this.getHeaders(),
      Accept:
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      Referer: 'https://services.gst.gov.in/',
    };

    return fetch(this.searchPageUrl, { headers });
  }

  async getCaptcha(): Promise<{
    success: boolean;
    captchaBase64?: string;
    cookies?: string;
    error?: string;
  }> {
    try {
      // Initialize session first
      await this.initializeSession();

      const randomParam = Math.random();
      const captchaUrlWithParam = `${this.captchaUrl}?rnd=${randomParam}`;

      const headers = {
        ...this.getHeaders(),
        Accept: 'image/avif,image/jxl,image/webp,image/png,image/svg+xml,image/*;q=0.8,*/*;q=0.5',
        Referer: this.searchPageUrl,
      };

      const response = await fetch(captchaUrlWithParam, { headers });

      if (!response.ok) {
        return { success: false, error: 'Failed to fetch captcha' };
      }

      const imageBuffer = await response.arrayBuffer();
      const captchaBase64 = btoa(String.fromCharCode(...new Uint8Array(imageBuffer)));
      const cookies = response.headers.get('set-cookie') || '';

      return {
        success: true,
        captchaBase64: `data:image/png;base64,${captchaBase64}`,
        cookies,
      };
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }

  async queryPanToGst(
    panNumber: string,
    captchaSolution: string,
    cookies: string
  ): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const payload = { panNO: panNumber, captcha: captchaSolution };

      const headers = {
        ...this.getHeaders(),
        Accept: 'application/json, text/plain, */*',
        'Content-Type': 'application/json;charset=utf-8',
        Origin: this.baseUrl,
        Referer: this.searchPageUrl,
        Cookie: cookies,
      };

      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        return { success: false, error: 'Failed to query PAN to GST' };
      }

      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }

  async getTaxpayerDetails(
    gstin: string,
    captchaSolution: string,
    cookies: string
  ): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const payload = { gstin, captcha: captchaSolution };

      const headers = {
        ...this.getHeaders(),
        Accept: 'application/json, text/plain, */*',
        'Content-Type': 'application/json;charset=utf-8',
        Origin: this.baseUrl,
        Referer: `${this.baseUrl}/services/searchtp`,
        Cookie: cookies,
      };

      const response = await fetch(this.taxpayerDetailsUrl, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        return { success: false, error: 'Failed to get taxpayer details' };
      }

      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }

  async getGoodsServices(
    gstin: string,
    cookies: string
  ): Promise<{ success: boolean; data?: any; error?: string }> {
    try {
      const url = `${this.baseUrl}/services/api/search/goodservice?gstin=${gstin}`;

      const headers = {
        ...this.getHeaders(),
        Accept: 'application/json, text/plain, */*',
        Referer: `${this.baseUrl}/services/searchtp`,
        Cookie: cookies,
      };

      const response = await fetch(url, { headers });

      if (!response.ok) {
        return { success: false, error: 'Failed to get goods and services' };
      }

      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }
}
