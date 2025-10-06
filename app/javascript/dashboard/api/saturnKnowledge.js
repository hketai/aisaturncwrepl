/* global axios */
import ApiClient from './ApiClient';

class SaturnKnowledgeAPI extends ApiClient {
  constructor() {
    super('saturn/knowledge_sources', { accountScoped: true });
  }

  getForAgent(agentId) {
    return axios.get(`${this.url}?agent_id=${agentId}`);
  }

  createForAgent(agentId, data) {
    const payload = { ...data };
    if (payload.knowledge_source) {
      payload.knowledge_source.agent_profile_id = agentId;
    }
    return axios.post(this.url, payload);
  }

  updateForAgent(agentId, id, data) {
    return axios.patch(`${this.url}/${id}`, data);
  }

  deleteForAgent(agentId, id) {
    return axios.delete(`${this.url}/${id}`);
  }
}

export default new SaturnKnowledgeAPI();
