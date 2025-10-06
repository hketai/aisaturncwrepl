import SaturnAgents from './Index.vue';
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
          name: 'saturn_agents',
          component: SaturnAgents,
          meta: {
            permissions: ['administrator'],
          },
        },
      ],
    },
  ],
};
