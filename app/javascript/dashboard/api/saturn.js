/* global axios */
import ApiClient from './ApiClient';

class SaturnAPI extends ApiClient {
  constructor() {
    super('saturn/agents', { accountScoped: true });
  }

  chat(agentId, message, context = {}) {
    return axios.post(`${this.url}/${agentId}/chat`, {
      message,
      context,
    });
  }
}

export default new SaturnAPI();
