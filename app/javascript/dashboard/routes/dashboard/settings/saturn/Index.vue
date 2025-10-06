<script setup>
import { computed, onMounted, ref, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';

import PageLayout from 'dashboard/components-next/captain/PageLayout.vue';
import AgentCard from './components/AgentCard.vue';
import CreateAgentDialog from './components/CreateAgentDialog.vue';
import DeleteAgentDialog from './components/DeleteAgentDialog.vue';
import EmptyState from './components/EmptyState.vue';

const router = useRouter();
const agents = ref([]);
const loading = ref(true);
const selectedAgent = ref(null);

const createDialogRef = ref(null);
const deleteDialogRef = ref(null);

const fetchAgents = async () => {
  try {
    loading.value = true;
    const response = await SaturnAPI.get();
    agents.value = response.data.payload || [];
  } catch (error) {
    useAlert('Failed to load agents');
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
    } else if (action === 'viewKnowledge') {
      router.push({
        name: 'saturn_knowledge_sources',
        params: { agentId: id },
      });
    }
  });
};

const handleAgentCreated = (agent) => {
  agents.value.push(agent);
};

const handleAgentUpdated = (updatedAgent) => {
  const index = agents.value.findIndex(a => a.id === updatedAgent.id);
  if (index !== -1) {
    agents.value[index] = updatedAgent;
  }
};

const handleAgentDeleted = (agentId) => {
  console.log('🎯 handleAgentDeleted called with ID:', agentId);
  console.log('📋 Agents before filter:', agents.value.map(a => a.id));
  agents.value = agents.value.filter(a => a.id !== agentId);
  console.log('📋 Agents after filter:', agents.value.map(a => a.id));
};

const handleDialogClose = () => {
  selectedAgent.value = null;
};

onMounted(() => {
  fetchAgents();
});
</script>

<template>
  <PageLayout
    header-title="Saturn AI Agents"
    button-label="Create Agent"
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
        <AgentCard
          v-for="agent in agents"
          :id="agent.id"
          :key="agent.id"
          :name="agent.name"
          :description="agent.description || 'No description'"
          :updated-at="agent.updated_at || agent.created_at"
          @action="handleAction"
        />
      </div>
    </template>
  </PageLayout>

  <CreateAgentDialog
    ref="createDialogRef"
    :selected-agent="selectedAgent"
    @created="handleAgentCreated"
    @updated="handleAgentUpdated"
    @close="handleDialogClose"
  />

  <DeleteAgentDialog
    ref="deleteDialogRef"
    :agent="selectedAgent"
    @deleted="handleAgentDeleted"
    @close="handleDialogClose"
  />
</template>
