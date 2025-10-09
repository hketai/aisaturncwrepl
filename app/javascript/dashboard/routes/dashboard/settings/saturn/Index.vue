<script setup>
import { computed, onMounted, onBeforeUnmount, ref, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useAccount } from 'dashboard/composables/useAccount';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import SaturnAPI from 'dashboard/api/saturn';

const { t } = useI18n();
const { currentAccount } = useAccount();

import SaturnPageLayout from './components/SaturnPageLayout.vue';
import AgentCard from './components/AgentCard.vue';
import CreateAgentDialog from './components/CreateAgentDialog.vue';
import DeleteAgentDialog from './components/DeleteAgentDialog.vue';
import HandoffDialog from './components/HandoffDialog.vue';
import EmptyState from './components/EmptyState.vue';

const router = useRouter();
const agents = ref([]);
const loading = ref(true);
const selectedAgent = ref(null);

const createDialogRef = ref(null);
const deleteDialogRef = ref(null);
const handoffDialogRef = ref(null);

const fetchAgents = async () => {
  try {
    loading.value = true;
    const response = await SaturnAPI.get();
    agents.value = response.data.payload || [];
  } catch (error) {
    useAlert(t('SATURN.AGENTS.ERROR_LOAD'));
    console.error('Error fetching agents:', error);
  } finally {
    loading.value = false;
  }
};

const handleCreate = () => {
  selectedAgent.value = null;
  nextTick(() => createDialogRef.value?.dialogRef?.open());
};

const handleAction = ({ action, id }) => {
  selectedAgent.value = agents.value.find(agent => id === agent.id);
  
  nextTick(() => {
    if (action === 'edit') {
      createDialogRef.value?.dialogRef?.open();
    } else if (action === 'delete') {
      deleteDialogRef.value?.dialogRef?.open();
    } else if (action === 'handoff') {
      handoffDialogRef.value?.dialogRef?.open();
    } else if (action === 'viewKnowledge') {
      router.push({
        name: 'saturn_knowledge_sources',
        params: { agentId: id },
      });
    } else if (action === 'inboxConnections') {
      router.push({
        name: 'saturn_inbox_connections',
        params: { agentId: id },
      });
    }
  });
};

const handleToggleStatus = async ({ id, enabled }) => {
  try {
    await SaturnAPI.update(id, {
      agent: { enabled }
    });
    
    const index = agents.value.findIndex(a => a.id === id);
    if (index !== -1) {
      agents.value[index].enabled = enabled;
    }
    
    const statusText = enabled ? t('SATURN.AGENTS.ENABLED') : t('SATURN.AGENTS.DISABLED');
    useAlert(`${t('SATURN.AGENTS.STATUS_UPDATED')} ${statusText}`);
  } catch (error) {
    useAlert(t('SATURN.AGENTS.ERROR_UPDATE_STATUS'));
    console.error('Error updating agent status:', error);
  }
};

const handleAgentCreated = (agent) => {
  agents.value.push(agent);
};

const handleCreateFailed = (agentName) => {
  agents.value = agents.value.filter(a => !a._optimistic || a.name !== agentName);
};

const handleAgentUpdated = (updatedAgent) => {
  const index = agents.value.findIndex(a => a.id === updatedAgent.id);
  if (index !== -1) {
    agents.value[index] = updatedAgent;
  } else {
    const optimisticIndex = agents.value.findIndex(a => a._optimistic);
    if (optimisticIndex !== -1) {
      agents.value[optimisticIndex] = updatedAgent;
    }
  }
};

const deletedAgent = ref(null);

const handleAgentDeleted = (agentId) => {
  deletedAgent.value = agents.value.find(a => a.id === agentId);
  agents.value = agents.value.filter(a => a.id !== agentId);
};

const handleAgentRestore = (agentId) => {
  if (deletedAgent.value && deletedAgent.value.id === agentId) {
    agents.value.push(deletedAgent.value);
    deletedAgent.value = null;
  }
};

const handleDialogClose = () => {
  selectedAgent.value = null;
};

const handleWebSocketAgentCreated = (data) => {
  const exists = agents.value.find(a => a.id === data.id);
  if (!exists) {
    agents.value.push(data);
  }
};

const handleWebSocketAgentUpdated = (data) => {
  const index = agents.value.findIndex(a => a.id === data.id);
  if (index !== -1) {
    agents.value[index] = data;
  }
};

const handleWebSocketAgentDeleted = (data) => {
  agents.value = agents.value.filter(a => a.id !== data.id);
};

onMounted(() => {
  fetchAgents();
  
  emitter.on(BUS_EVENTS.SATURN_AGENT_CREATED, handleWebSocketAgentCreated);
  emitter.on(BUS_EVENTS.SATURN_AGENT_UPDATED, handleWebSocketAgentUpdated);
  emitter.on(BUS_EVENTS.SATURN_AGENT_DELETED, handleWebSocketAgentDeleted);
});

onBeforeUnmount(() => {
  emitter.off(BUS_EVENTS.SATURN_AGENT_CREATED, handleWebSocketAgentCreated);
  emitter.off(BUS_EVENTS.SATURN_AGENT_UPDATED, handleWebSocketAgentUpdated);
  emitter.off(BUS_EVENTS.SATURN_AGENT_DELETED, handleWebSocketAgentDeleted);
});

const showLimitWarning = computed(() => {
  if (!currentAccount.value?.ai_conversation_limit) return false;
  const remaining = currentAccount.value.ai_conversations_remaining || 0;
  const limit = currentAccount.value.ai_conversation_limit;
  return remaining <= limit * 0.2;
});

const limitWarningMessage = computed(() => {
  if (!currentAccount.value) return '';
  const remaining = currentAccount.value.ai_conversations_remaining || 0;
  const count = currentAccount.value.ai_conversation_count || 0;
  const limit = currentAccount.value.ai_conversation_limit;
  
  if (remaining === 0) {
    return t('SATURN.LIMIT.REACHED', { count, limit });
  }
  return t('SATURN.LIMIT.WARNING', { remaining, limit });
});
</script>

<template>
  <SaturnPageLayout
    :header-title="$t('SATURN.AGENTS.TITLE')"
    :button-label="$t('SATURN.AGENTS.CREATE_BUTTON')"
    :is-fetching="loading"
    :is-empty="!agents.length"
    :show-pagination-footer="false"
    @click="handleCreate"
  >
    <template #emptyState>
      <EmptyState @create="handleCreate" />
    </template>

    <template #body>
      <div class="flex flex-col gap-4">
        <div
          v-if="showLimitWarning"
          class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 mb-4"
        >
          <div class="flex items-start gap-3">
            <fluent-icon
              icon="warning"
              size="20"
              class="text-yellow-600 dark:text-yellow-400 mt-0.5"
            />
            <div class="flex-1">
              <p class="text-sm text-yellow-800 dark:text-yellow-200 font-medium">
                {{ limitWarningMessage }}
              </p>
            </div>
          </div>
        </div>

        <AgentCard
          v-for="agent in agents"
          :id="agent.id"
          :key="agent.id"
          :name="agent.name"
          :description="agent.description || $t('SATURN.AGENTS.NO_DESCRIPTION')"
          :updated-at="agent.updated_at || agent.created_at"
          :enabled="agent.enabled !== false"
          @action="handleAction"
          @toggle-status="handleToggleStatus"
        />
      </div>
    </template>
  </SaturnPageLayout>

  <CreateAgentDialog
    ref="createDialogRef"
    :selected-agent="selectedAgent"
    @created="handleAgentCreated"
    @updated="handleAgentUpdated"
    @createFailed="handleCreateFailed"
    @close="handleDialogClose"
  />

  <DeleteAgentDialog
    ref="deleteDialogRef"
    :agent="selectedAgent"
    @deleted="handleAgentDeleted"
    @restore="handleAgentRestore"
    @close="handleDialogClose"
  />

  <HandoffDialog
    ref="handoffDialogRef"
    :selected-agent="selectedAgent"
    @updated="handleAgentUpdated"
    @close="handleDialogClose"
  />
</template>
