import SaturnAgents from './Index.vue';
import KnowledgeSources from './KnowledgeSources.vue';
import InboxConnections from './InboxConnections.vue';
import AutoReplies from './AutoReplies.vue';
import { frontendURL } from '../../../../helper/URLHelper';
import SettingsWrapper from '../SettingsWrapper.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/saturn-agents'),
      meta: {
        permissions: ['administrator'],
      },
      component: SettingsWrapper,
      children: [
        {
          path: '',
          name: 'saturn_agents_index',
          component: SaturnAgents,
          meta: {
            permissions: ['administrator'],
          },
        },
        {
          path: ':agentId/knowledge-sources',
          name: 'saturn_knowledge_sources',
          component: KnowledgeSources,
          meta: {
            permissions: ['administrator'],
          },
        },
        {
          path: ':agentId/inbox-connections',
          name: 'saturn_inbox_connections',
          component: InboxConnections,
          meta: {
            permissions: ['administrator'],
          },
        },
        {
          path: ':agentId/auto-replies',
          name: 'saturn_auto_replies',
          component: AutoReplies,
          meta: {
            permissions: ['administrator'],
          },
        },
      ],
    },
  ],
};
