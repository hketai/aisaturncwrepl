/* global axios */
import ApiClient from './ApiClient';

class SaturnInboxConnectionsAPI extends ApiClient {
  constructor() {
    super('saturn/inbox_connections', { accountScoped: true });
  }

  getForAgent(agentId) {
    return axios.get(`/api/v1/accounts/${this.accountIdFromRoute}/saturn/agents/${agentId}/inbox_connections`);
  }

  create(agentId, data) {
    return axios.post(
      `/api/v1/accounts/${this.accountIdFromRoute}/saturn/agents/${agentId}/inbox_connections`,
      data
    );
  }

  delete(agentId, inboxId) {
    return axios.delete(
      `/api/v1/accounts/${this.accountIdFromRoute}/saturn/agents/${agentId}/inbox_connections`,
      { data: { inbox_id: inboxId } }
    );
  }

  get accountIdFromRoute() {
    const currentRoute = window.location.pathname;
    const match = currentRoute.match(/accounts\/(\d+)/);
    return match ? match[1] : null;
  }
}

export default new SaturnInboxConnectionsAPI();
