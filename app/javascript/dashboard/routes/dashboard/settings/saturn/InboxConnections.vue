<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import SaturnInboxConnectionsAPI from 'dashboard/api/saturnInboxConnections';
import InboxesAPI from 'dashboard/api/inboxes';
import SaturnAPI from 'dashboard/api/saturn';

import PageLayout from 'dashboard/components-next/captain/PageLayout.vue';
import CardLayout from 'dashboard/components-next/CardLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const route = useRoute();
const agentId = computed(() => route.params.agentId);

const agent = ref(null);
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
    const [agentResponse, inboxesResponse, connectionsResponse] = await Promise.all([
      SaturnAPI.show(agentId.value),
      InboxesAPI.get(),
      SaturnInboxConnectionsAPI.getForAgent(agentId.value),
    ]);
    
    agent.value = agentResponse.data;
    allInboxes.value = inboxesResponse.data.payload || [];
    connectedInboxes.value = connectionsResponse.data.payload || [];
  } catch (error) {
    useAlert('Failed to load data');
  } finally {
    loading.value = false;
  }
};

const handleConnect = async (inbox) => {
  const optimisticConnection = {
    id: `temp-${Date.now()}`,
    inbox: inbox,
    auto_respond: false,
    connection_settings: {},
    _optimistic: true,
  };
  
  connectedInboxes.value.push(optimisticConnection);
  
  try {
    const response = await SaturnInboxConnectionsAPI.create(agentId.value, {
      inbox_id: inbox.id,
      auto_respond: false,
    });
    
    const index = connectedInboxes.value.findIndex(c => c._optimistic);
    if (index !== -1) {
      connectedInboxes.value[index] = response.data;
    }
    
    useAlert('Inbox connected successfully');
  } catch (error) {
    connectedInboxes.value = connectedInboxes.value.filter(c => !c._optimistic);
    useAlert('Failed to connect inbox');
  }
};

const handleDisconnect = async (connection) => {
  const connectionData = { ...connection };
  connectedInboxes.value = connectedInboxes.value.filter(c => c.inbox.id !== connection.inbox.id);
  
  try {
    await SaturnInboxConnectionsAPI.delete(agentId.value, connection.inbox.id);
    useAlert('Inbox disconnected successfully');
  } catch (error) {
    connectedInboxes.value.push(connectionData);
    useAlert('Failed to disconnect inbox');
  }
};

const toggleAutoRespond = async (connection) => {
  const originalValue = connection.auto_respond;
  connection.auto_respond = !connection.auto_respond;
  
  try {
    await SaturnInboxConnectionsAPI.delete(agentId.value, connection.inbox.id);
    await SaturnInboxConnectionsAPI.create(agentId.value, {
      inbox_id: connection.inbox.id,
      auto_respond: connection.auto_respond,
    });
    useAlert('Auto-respond setting updated');
  } catch (error) {
    connection.auto_respond = originalValue;
    useAlert('Failed to update auto-respond setting');
  }
};

onMounted(() => {
  fetchData();
});
</script>

<template>
  <PageLayout
    :title="`Inbox Connections - ${agent?.name || 'Loading...'}`"
    description="Connect this agent to inboxes to automatically respond to customer messages"
    :is-loading="loading"
    :show-back-button="true"
    :show-new-button="false"
    :show-pagination-footer="false"
  >
    <template #body>
      <div class="space-y-6">
        <div v-if="connectedInboxes.length > 0">
          <h3 class="text-base font-semibold text-n-slate-12 mb-4">Connected Inboxes</h3>
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
                  <p class="text-sm text-n-slate-11 mb-3">
                    Channel: {{ connection.inbox.channel_type || 'Unknown' }}
                  </p>
                  <div class="flex items-center gap-2">
                    <label class="flex items-center gap-2 text-sm cursor-pointer">
                      <input
                        type="checkbox"
                        :checked="connection.auto_respond"
                        :disabled="connection._optimistic"
                        class="rounded border-n-weak"
                        @change="toggleAutoRespond(connection)"
                      />
                      <span class="text-n-slate-12 font-medium">Auto-respond to messages</span>
                    </label>
                  </div>
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
                  Disconnect
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
              You need to create at least one inbox before connecting it to this agent.
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
  </PageLayout>
</template>
