/* global axios */
import ApiClient from './ApiClient';

class SaturnAutoRepliesAPI extends ApiClient {
  constructor() {
    super('saturn/auto_replies', { accountScoped: true });
  }

  getForAgent(agentId) {
    return axios.get(`/api/v1/accounts/${this.accountIdFromRoute}/saturn/auto_replies`, {
      params: { agent_id: agentId }
    });
  }

  create(agentId, data) {
    return axios.post(
      `/api/v1/accounts/${this.accountIdFromRoute}/saturn/auto_replies`,
      { ...data, agent_id: agentId }
    );
  }

  delete(id) {
    return axios.delete(
      `/api/v1/accounts/${this.accountIdFromRoute}/saturn/auto_replies/${id}`
    );
  }

  get accountIdFromRoute() {
    const currentRoute = window.location.pathname;
    const match = currentRoute.match(/accounts\/(\d+)/);
    return match ? match[1] : null;
  }
}

export default new SaturnAutoRepliesAPI();
