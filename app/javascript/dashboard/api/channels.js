/* eslint no-console: 0 */
/* global axios */
/* eslint no-undef: "error" */
/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import endPoints from './endPoints';

export default {
  fetchFacebookPages(token, accountId) {
    const urlData = endPoints('fetchFacebookPages');
    urlData.params.omniauth_token = token;
    return axios.post(urlData.url(accountId), urlData.params);
  },

  whatsappWebConnect(channelId) {
    return axios.post(
      `/api/v1/accounts/${window.ACCOUNT_ID}/channels/whatsapp_web_channels/${channelId}/connect`
    );
  },

  whatsappWebDisconnect(channelId) {
    return axios.post(
      `/api/v1/accounts/${window.ACCOUNT_ID}/channels/whatsapp_web_channels/${channelId}/disconnect`
    );
  },

  whatsappWebStatus(channelId) {
    return axios.get(
      `/api/v1/accounts/${window.ACCOUNT_ID}/channels/whatsapp_web_channels/${channelId}/status`
    );
  },

  whatsappWebQRCode(channelId) {
    return axios.get(
      `/api/v1/accounts/${window.ACCOUNT_ID}/channels/whatsapp_web_channels/${channelId}/qr_code`
    );
  },
};
