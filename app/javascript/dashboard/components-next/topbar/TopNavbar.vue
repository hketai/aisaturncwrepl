<script setup>
import { h, computed, onMounted, ref } from 'vue';
import { useAccount } from 'dashboard/composables/useAccount';
import { useMapGetter } from 'dashboard/composables/store';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';

import TopNavItem from './TopNavItem.vue';
import SidebarProfileMenu from '../sidebar/SidebarProfileMenu.vue';
import ChannelLeaf from '../sidebar/ChannelLeaf.vue';
import Logo from 'next/icon/Logo.vue';

const globalConfig = useMapGetter('globalConfig/get');

const emit = defineEmits([
  'closeKeyShortcutModal',
  'openKeyShortcutModal',
  'showCreateAccountModal',
  'toggleAccountModal',
]);

const showMobileMenu = ref(false);

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value;
};

const { accountScopedRoute } = useAccount();
const store = useStore();
const { t } = useI18n();
const route = useRoute();

const inboxes = useMapGetter('inboxes/getInboxes');
const labels = useMapGetter('labels/getLabelsOnSidebar');
const teams = useMapGetter('teams/getMyTeams');
const contactCustomViews = useMapGetter('customViews/getContactCustomViews');
const conversationCustomViews = useMapGetter(
  'customViews/getConversationCustomViews'
);

onMounted(() => {
  store.dispatch('labels/get');
  store.dispatch('inboxes/get');
  store.dispatch('notifications/unReadCount');
  store.dispatch('teams/get');
  store.dispatch('attributes/get');
  store.dispatch('customViews/get', 'conversation');
  store.dispatch('customViews/get', 'contact');
});

const sortedInboxes = computed(() =>
  inboxes.value.slice().sort((a, b) => a.name.localeCompare(b.name))
);

const newReportRoutes = () => [
  {
    name: 'Reports Agent',
    label: t('SIDEBAR.REPORTS_AGENT'),
    to: accountScopedRoute('agent_reports_index'),
    activeOn: ['agent_reports_show'],
  },
  {
    name: 'Reports Label',
    label: t('SIDEBAR.REPORTS_LABEL'),
    to: accountScopedRoute('label_reports_index'),
  },
  {
    name: 'Reports Inbox',
    label: t('SIDEBAR.REPORTS_INBOX'),
    to: accountScopedRoute('inbox_reports_index'),
    activeOn: ['inbox_reports_show'],
  },
  {
    name: 'Reports Team',
    label: t('SIDEBAR.REPORTS_TEAM'),
    to: accountScopedRoute('team_reports_index'),
    activeOn: ['team_reports_show'],
  },
];

const reportRoutes = computed(() => newReportRoutes());

const menuItems = computed(() => {
  return [
    {
      name: 'Conversation',
      label: t('SIDEBAR.CONVERSATIONS'),
      icon: 'i-ph-chat-circle-thin',
      children: [
        {
          name: 'All',
          label: t('SIDEBAR.ALL_CONVERSATIONS'),
          activeOn: ['inbox_conversation'],
          to: accountScopedRoute('home'),
        },
        {
          name: 'Mentions',
          label: t('SIDEBAR.MENTIONED_CONVERSATIONS'),
          activeOn: ['conversation_through_mentions'],
          to: accountScopedRoute('conversation_mentions'),
        },
        {
          name: 'Unattended',
          activeOn: ['conversation_through_unattended'],
          label: t('SIDEBAR.UNATTENDED_CONVERSATIONS'),
          to: accountScopedRoute('conversation_unattended'),
        },
      ],
    },
    {
      name: 'Saturn',
      label: t('SIDEBAR.SATURN'),
      icon: 'i-ph-sparkle-thin',
      to: accountScopedRoute('saturn_agents_index'),
    },
    {
      name: 'Contacts',
      label: t('SIDEBAR.CONTACTS'),
      icon: 'i-ph-user-circle-thin',
      children: [
        {
          name: 'All Contacts',
          label: t('SIDEBAR.ALL_CONTACTS'),
          to: accountScopedRoute(
            'contacts_dashboard_index',
            {},
            { page: 1, search: undefined }
          ),
          activeOn: ['contacts_dashboard_index', 'contacts_edit'],
        },
        {
          name: 'Active',
          label: t('SIDEBAR.ACTIVE'),
          to: accountScopedRoute('contacts_dashboard_active'),
          activeOn: ['contacts_dashboard_active'],
        },
      ],
    },
    {
      name: 'Reports',
      label: t('SIDEBAR.REPORTS'),
      icon: 'i-ph-chart-line-thin',
      children: [
        {
          name: 'Report Overview',
          label: t('SIDEBAR.REPORTS_OVERVIEW'),
          to: accountScopedRoute('account_overview_reports'),
        },
        {
          name: 'Report Conversation',
          label: t('SIDEBAR.REPORTS_CONVERSATION'),
          to: accountScopedRoute('conversation_reports'),
        },
        ...reportRoutes.value,
        {
          name: 'Reports CSAT',
          label: t('SIDEBAR.CSAT'),
          to: accountScopedRoute('csat_reports'),
        },
        {
          name: 'Reports SLA',
          label: t('SIDEBAR.REPORTS_SLA'),
          to: accountScopedRoute('sla_reports'),
        },
        {
          name: 'Reports Bot',
          label: t('SIDEBAR.REPORTS_BOT'),
          to: accountScopedRoute('bot_reports'),
        },
      ],
    },
    {
      name: 'Campaigns',
      label: t('SIDEBAR.CAMPAIGNS'),
      icon: 'i-ph-megaphone-simple-thin',
      children: [
        {
          name: 'WhatsApp',
          label: t('SIDEBAR.WHATSAPP'),
          to: accountScopedRoute('campaigns_whatsapp_index'),
        },
      ],
    },
    {
      name: 'Inboxes',
      label: t('SIDEBAR.INBOXES'),
      icon: 'i-ph-tray-thin',
      to: accountScopedRoute('settings_inbox_list'),
    },
    {
      name: 'Settings',
      label: t('SIDEBAR.SETTINGS'),
      icon: 'i-ph-gear-thin',
      children: [
        {
          name: 'Settings Account Settings',
          label: t('SIDEBAR.ACCOUNT_SETTINGS'),
          icon: 'i-ph-briefcase-thin',
          to: accountScopedRoute('general_settings_index'),
        },
        {
          name: 'Settings Agents',
          label: t('SIDEBAR.AGENTS'),
          icon: 'i-ph-user-square-thin',
          to: accountScopedRoute('agent_list'),
        },
        {
          name: 'Settings Teams',
          label: t('SIDEBAR.TEAMS'),
          icon: 'i-ph-users-three-thin',
          to: accountScopedRoute('settings_teams_list'),
        },
        {
          name: 'Settings Labels',
          label: t('SIDEBAR.LABELS'),
          icon: 'i-ph-tag-thin',
          to: accountScopedRoute('labels_list'),
        },
        {
          name: 'Settings Automation',
          label: t('SIDEBAR.AUTOMATION'),
          icon: 'i-ph-flow-arrow-thin',
          to: accountScopedRoute('automation_list'),
        },
      ],
    },
  ];
});
</script>


<template>
  <header class="bg-white dark:bg-slate-900 border-b border-slate-200/60 dark:border-slate-800/60 h-14 flex items-center px-4 gap-4 flex-shrink-0 relative z-50">
    <div class="flex items-center gap-3">
      <template v-if="globalConfig.logo || globalConfig.logoDark">
        <img 
          v-if="globalConfig.logo"
          :src="globalConfig.logo" 
          alt="AISATURN" 
          :class="globalConfig.logoDark ? 'h-6 w-auto dark:hidden' : 'h-6 w-auto'"
        />
        <img 
          v-if="globalConfig.logoDark"
          :src="globalConfig.logoDark" 
          alt="AISATURN" 
          :class="globalConfig.logo ? 'h-6 w-auto hidden dark:block' : 'h-6 w-auto'"
        />
      </template>
      <Logo v-else class="size-6" />
    </div>

    <nav class="hidden md:flex items-center justify-center gap-1 flex-1 overflow-x-auto overflow-y-visible no-scrollbar">
      <TopNavItem
        v-for="item in menuItems"
        :key="item.name"
        v-bind="item"
      />
    </nav>

    <div class="flex items-center gap-2 flex-shrink-0">
      <button
        class="md:hidden p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
        @click="toggleMobileMenu"
      >
        <span class="i-ph-list text-xl" />
      </button>
      <SidebarProfileMenu
        :top-nav="true"
        @open-key-shortcut-modal="emit('openKeyShortcutModal')"
        @close="$event => {}"
      />
    </div>

    <!-- Mobile Menu -->
    <div
      v-if="showMobileMenu"
      class="md:hidden absolute top-14 left-0 right-0 bg-white dark:bg-slate-900 border-b border-slate-200/60 dark:border-slate-800/60 shadow-lg z-50 max-h-[calc(100vh-3.5rem)] overflow-y-auto"
    >
      <nav class="flex flex-col p-2">
        <TopNavItem
          v-for="item in menuItems"
          :key="item.name"
          v-bind="item"
          @item-click="showMobileMenu = false"
        />
      </nav>
    </div>
  </header>
</template>
