<script setup>
import { ref, onMounted, onBeforeUnmount, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import SaturnInboxConnectionsAPI from 'dashboard/api/saturnInboxConnections';
import InboxesAPI from 'dashboard/api/inboxes';
import SaturnAPI from 'dashboard/api/saturn';

const { t } = useI18n();

import SaturnPageLayout from './components/SaturnPageLayout.vue';
import CardLayout from 'dashboard/components-next/CardLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const route = useRoute();
const agentId = computed(() => route.params.agentId);

const agent = ref({ name: 'Agent' });
const allInboxes = ref([]);
const connectedInboxes = ref([]);
const loading = ref(true);

const availableInboxes = computed(() => {
  const connectedIds = new Set(connectedInboxes.value.map(c => c.inbox.id));
  return allInboxes.value.filter(inbox => !connectedIds.has(inbox.id));
});

const fetchData = async () => {
  loading.value = true;
  try {
    const [inboxesResponse, connectionsResponse] = await Promise.all([
      InboxesAPI.get(),
      SaturnInboxConnectionsAPI.getForAgent(agentId.value),
    ]);
    
    allInboxes.value = inboxesResponse.data.payload || [];
    connectedInboxes.value = connectionsResponse.data.payload || [];
    
    const agentResponse = await SaturnAPI.show(agentId.value);
    agent.value = agentResponse.data;
  } catch (error) {
    useAlert(t('SATURN.INBOX_CONNECTIONS.ERROR_LOAD'));
  } finally {
    loading.value = false;
  }
};

const handleConnect = async (inbox) => {
  const optimisticConnection = {
    id: `temp-${Date.now()}`,
    inbox: inbox,
    auto_respond: true,
    connection_settings: {},
    _optimistic: true,
  };
  
  connectedInboxes.value.push(optimisticConnection);
  
  try {
    const response = await SaturnInboxConnectionsAPI.create(agentId.value, {
      inbox_id: inbox.id,
      auto_respond: true,
    });
    
    const index = connectedInboxes.value.findIndex(c => c._optimistic);
    if (index !== -1) {
      connectedInboxes.value[index] = response.data;
    }
    
    useAlert(t('SATURN.INBOX_CONNECTIONS.SUCCESS_CONNECT'));
  } catch (error) {
    connectedInboxes.value = connectedInboxes.value.filter(c => !c._optimistic);
    useAlert(t('SATURN.INBOX_CONNECTIONS.ERROR_CONNECT'));
  }
};

const handleDisconnect = async (connection) => {
  const connectionData = { ...connection };
  connectedInboxes.value = connectedInboxes.value.filter(c => c.inbox.id !== connection.inbox.id);
  
  try {
    await SaturnInboxConnectionsAPI.delete(agentId.value, connection.inbox.id);
    useAlert(t('SATURN.INBOX_CONNECTIONS.SUCCESS_DISCONNECT'));
  } catch (error) {
    connectedInboxes.value.push(connectionData);
    useAlert(t('SATURN.INBOX_CONNECTIONS.ERROR_DISCONNECT'));
  }
};

const handleWebSocketConnectionCreated = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    const exists = connectedInboxes.value.find(c => c.inbox.id === data.inbox.id);
    if (!exists) {
      connectedInboxes.value.push(data);
    }
  }
};

const handleWebSocketConnectionUpdated = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    const index = connectedInboxes.value.findIndex(c => c.id === data.id);
    if (index !== -1) {
      connectedInboxes.value[index] = data;
    }
  }
};

const handleWebSocketConnectionDeleted = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    connectedInboxes.value = connectedInboxes.value.filter(c => c.inbox.id !== data.inbox_id);
  }
};

onMounted(() => {
  fetchData();
  
  emitter.on(BUS_EVENTS.SATURN_INBOX_CONNECTION_CREATED, handleWebSocketConnectionCreated);
  emitter.on(BUS_EVENTS.SATURN_INBOX_CONNECTION_UPDATED, handleWebSocketConnectionUpdated);
  emitter.on(BUS_EVENTS.SATURN_INBOX_CONNECTION_DELETED, handleWebSocketConnectionDeleted);
});

onBeforeUnmount(() => {
  emitter.off(BUS_EVENTS.SATURN_INBOX_CONNECTION_CREATED, handleWebSocketConnectionCreated);
  emitter.off(BUS_EVENTS.SATURN_INBOX_CONNECTION_UPDATED, handleWebSocketConnectionUpdated);
  emitter.off(BUS_EVENTS.SATURN_INBOX_CONNECTION_DELETED, handleWebSocketConnectionDeleted);
});
</script>

<template>
  <SaturnPageLayout
    :header-title="`${agent?.name || $t('SATURN.AGENTS.TITLE')} - ${$t('SATURN.INBOX_CONNECTIONS.TITLE')}`"
    :back-url="{ name: 'saturn_agents_index' }"
    button-label=""
    :is-fetching="loading"
    :is-empty="false"
    :show-pagination-footer="false"
  >
    <template #body>
      <div class="space-y-6">
        <div v-if="connectedInboxes.length > 0">
          <h3 class="text-base font-semibold text-n-slate-12 mb-4">{{ $t('SATURN.INBOX_CONNECTIONS.CONNECTED_TITLE') }}</h3>
          <div class="flex flex-col gap-3">
            <CardLayout
              v-for="connection in connectedInboxes"
              :key="connection.inbox.id"
              class="!p-5"
            >
              <div class="flex items-start justify-between gap-4">
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 mb-2">
                    <h4 class="text-lg font-semibold text-n-slate-12 truncate">
                      {{ connection.inbox.name }}
                    </h4>
                    <span
                      v-if="connection._optimistic"
                      class="text-xs px-2 py-0.5 bg-blue-100 text-blue-700 rounded-full dark:bg-blue-900/30 dark:text-blue-300"
                    >
                      Connecting...
                    </span>
                  </div>
                  <p class="text-sm text-n-slate-11">
                    Channel: {{ connection.inbox.channel_type || 'Unknown' }}
                  </p>
                </div>
                <Button
                  color="slate"
                  size="sm"
                  :disabled="connection._optimistic"
                  class="hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-900/20"
                  @click="handleDisconnect(connection)"
                >
                  <template #prefixIcon>
                    <i class="i-lucide-unlink"></i>
                  </template>
                  {{ $t('SATURN.INBOX_CONNECTIONS.DISCONNECT_BUTTON') }}
                </Button>
              </div>
            </CardLayout>
          </div>
        </div>

        <div v-if="availableInboxes.length > 0">
          <h3 class="text-base font-semibold text-n-slate-12 mb-4">Available Inboxes</h3>
          <div class="flex flex-col gap-3">
            <CardLayout
              v-for="inbox in availableInboxes"
              :key="inbox.id"
              class="!p-5"
            >
              <div class="flex items-start justify-between gap-4">
                <div class="flex-1 min-w-0">
                  <h4 class="text-lg font-semibold text-n-slate-12 truncate mb-2">
                    {{ inbox.name }}
                  </h4>
                  <p class="text-sm text-n-slate-11">
                    Channel: {{ inbox.channel_type || 'Unknown' }}
                  </p>
                </div>
                <Button
                  color="blue"
                  size="sm"
                  @click="handleConnect(inbox)"
                >
                  <template #prefixIcon>
                    <i class="i-lucide-link"></i>
                  </template>
                  Connect
                </Button>
              </div>
            </CardLayout>
          </div>
        </div>

        <div
          v-if="!loading && connectedInboxes.length === 0 && availableInboxes.length === 0"
          class="text-center py-12"
        >
          <div class="flex flex-col items-center gap-4">
            <div class="text-6xl text-n-weak">📥</div>
            <p class="text-lg font-medium text-n-strong">No Inboxes Found</p>
            <p class="text-sm text-n-weak max-w-md">
              {{ $t('SATURN.INBOX_CONNECTIONS.EMPTY_STATE') }}
            </p>
            <Button
              color="blue"
              size="md"
              @click="$router.push({ name: 'settings_inbox_new' })"
            >
              <template #prefixIcon>
                <i class="i-lucide-plus"></i>
              </template>
              Create Inbox
            </Button>
          </div>
        </div>
      </div>
    </template>
  </SaturnPageLayout>
</template>
