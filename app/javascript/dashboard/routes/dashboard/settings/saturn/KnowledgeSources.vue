<script setup>
import { computed, onMounted, onBeforeUnmount, ref, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { emitter } from 'shared/helpers/mitt';

const { t } = useI18n();
import { BUS_EVENTS } from 'shared/constants/busEvents';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';
import SaturnAPI from 'dashboard/api/saturn';

import SaturnPageLayout from './components/SaturnPageLayout.vue';
import CardLayout from 'dashboard/components-next/CardLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import CreateKnowledgeDialog from './components/CreateKnowledgeDialog.vue';
import DeleteKnowledgeDialog from './components/DeleteKnowledgeDialog.vue';

const route = useRoute();
const agentId = computed(() => route.params.agentId);

const agent = ref(null);
const knowledgeSources = ref([]);
const loading = ref(true);
const selectedKnowledge = ref(null);

const createDialogRef = ref(null);
const deleteDialogRef = ref(null);

const fetchAgent = async () => {
  try {
    const response = await SaturnAPI.show(agentId.value);
    agent.value = response.data;
  } catch (error) {
    useAlert(t('SATURN.KNOWLEDGE.ERROR_LOAD_AGENT'));
  }
};

const fetchKnowledgeSources = async () => {
  try {
    loading.value = true;
    const response = await SaturnKnowledgeAPI.getForAgent(agentId.value);
    knowledgeSources.value = response.data.payload || [];
  } catch (error) {
    useAlert(t('SATURN.KNOWLEDGE.ERROR_LOAD'));
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleCreate = () => {
  selectedKnowledge.value = null;
  nextTick(() => createDialogRef.value?.dialogRef?.open());
};

const handleEdit = async (knowledge) => {
  try {
    // Fetch full knowledge data including content_text
    const response = await SaturnKnowledgeAPI.show(knowledge.id);
    selectedKnowledge.value = response.data;
    nextTick(() => createDialogRef.value?.dialogRef?.open());
  } catch (error) {
    useAlert(t('SATURN.KNOWLEDGE.ERROR_LOAD_SOURCE'));
    console.error(error);
  }
};

const handleDelete = (knowledge) => {
  selectedKnowledge.value = knowledge;
  nextTick(() => deleteDialogRef.value?.dialogRef?.open());
};

const handleKnowledgeCreated = (knowledge) => {
  knowledgeSources.value.push(knowledge);
};

const handleKnowledgeUpdated = (updatedKnowledge) => {
  const index = knowledgeSources.value.findIndex(k => k.id === updatedKnowledge.id);
  if (index !== -1) {
    knowledgeSources.value[index] = updatedKnowledge;
  } else {
    const optimisticIndex = knowledgeSources.value.findIndex(k => k._optimistic);
    if (optimisticIndex !== -1) {
      knowledgeSources.value[optimisticIndex] = updatedKnowledge;
    }
  }
};

const handleCreateFailed = (knowledgeTitle) => {
  knowledgeSources.value = knowledgeSources.value.filter(k => !k._optimistic || k.title !== knowledgeTitle);
};

const deletedKnowledge = ref(null);

const handleKnowledgeDeleted = (knowledgeId) => {
  deletedKnowledge.value = knowledgeSources.value.find(k => k.id === knowledgeId);
  knowledgeSources.value = knowledgeSources.value.filter(k => k.id !== knowledgeId);
};

const handleKnowledgeRestore = (knowledge) => {
  if (knowledge) {
    knowledgeSources.value.push(knowledge);
    deletedKnowledge.value = null;
  }
};

const handleDialogClose = () => {
  selectedKnowledge.value = null;
};

const getSourceTypeIcon = (type) => {
  const icons = {
    text: 'i-lucide-file-text',
    url: 'i-lucide-link',
    file: 'i-lucide-file',
    faq: 'i-lucide-help-circle',
  };
  return icons[type] || 'i-lucide-file';
};

const handleWebSocketKnowledgeCreated = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    const exists = knowledgeSources.value.find(k => k.id === data.id);
    if (!exists) {
      knowledgeSources.value.push(data);
    }
  }
};

const handleWebSocketKnowledgeUpdated = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    const index = knowledgeSources.value.findIndex(k => k.id === data.id);
    if (index !== -1) {
      knowledgeSources.value[index] = data;
    }
  }
};

const handleWebSocketKnowledgeDeleted = (data) => {
  if (data.agent_profile_id === parseInt(agentId.value)) {
    knowledgeSources.value = knowledgeSources.value.filter(k => k.id !== data.id);
  }
};

onMounted(async () => {
  await fetchAgent();
  await fetchKnowledgeSources();
  
  emitter.on(BUS_EVENTS.SATURN_KNOWLEDGE_CREATED, handleWebSocketKnowledgeCreated);
  emitter.on(BUS_EVENTS.SATURN_KNOWLEDGE_UPDATED, handleWebSocketKnowledgeUpdated);
  emitter.on(BUS_EVENTS.SATURN_KNOWLEDGE_DELETED, handleWebSocketKnowledgeDeleted);
});

onBeforeUnmount(() => {
  emitter.off(BUS_EVENTS.SATURN_KNOWLEDGE_CREATED, handleWebSocketKnowledgeCreated);
  emitter.off(BUS_EVENTS.SATURN_KNOWLEDGE_UPDATED, handleWebSocketKnowledgeUpdated);
  emitter.off(BUS_EVENTS.SATURN_KNOWLEDGE_DELETED, handleWebSocketKnowledgeDeleted);
});
</script>

<template>
  <SaturnPageLayout
    :header-title="`${agent?.name || $t('SATURN.AGENTS.TITLE')} - ${$t('SATURN.KNOWLEDGE.TITLE')}`"
    :back-url="{ name: 'saturn_agents_index' }"
    :button-label="$t('SATURN.KNOWLEDGE.CREATE_BUTTON')"
    :is-fetching="loading"
    :is-empty="!knowledgeSources.length"
    :show-pagination-footer="false"
    @click="handleCreate"
  >
    <template #emptyState>
      <div class="flex flex-col items-center justify-center h-full py-16">
        <div class="max-w-md text-center">
          <div class="mb-6 flex justify-center">
            <div class="i-lucide-book-open text-6xl text-slate-300" />
          </div>
          
          <h2 class="text-2xl font-semibold mb-3">{{ $t('SATURN.KNOWLEDGE.EMPTY_TITLE') }}</h2>
          
          <p class="text-slate-300 mb-8">
            {{ $t('SATURN.KNOWLEDGE.EMPTY_STATE') }}
          </p>
          
          <Button
            color="blue"
            size="lg"
            @click="handleCreate"
          >
            <span class="i-lucide-plus mr-2"></span>
            {{ $t('SATURN.KNOWLEDGE.CREATE_BUTTON') }}
          </Button>
        </div>
      </div>
    </template>

    <template #body>
      <div class="flex flex-col gap-4">
        <CardLayout
          v-for="knowledge in knowledgeSources"
          :key="knowledge.id"
        >
          <div class="flex justify-between w-full">
            <div class="flex items-start gap-3 flex-1">
              <i :class="getSourceTypeIcon(knowledge.source_type)" class="text-xl text-slate-300 mt-0.5" />
              <div class="flex-1 min-w-0">
                <h3 class="font-medium text-slate-900 truncate">
                  {{ knowledge.title || 'Untitled' }}
                </h3>
                <p class="text-sm text-slate-900 line-clamp-2 mt-1">
                  {{ knowledge.content_preview || knowledge.content_text || '' }}
                </p>
                <div class="flex items-center gap-2 mt-2">
                  <span class="text-xs px-2 py-0.5 rounded-full bg-slate-900/10 text-slate-900">
                    {{ knowledge.source_type }}
                  </span>
                  <span v-if="knowledge.source_url" class="text-xs text-slate-900 truncate">
                    {{ knowledge.source_url }}
                  </span>
                </div>
              </div>
            </div>
            
            <div class="flex gap-2">
              <Button
                icon="i-lucide-pencil"
                color="slate"
                size="xs"
                class="rounded-md hover:bg-slate-900/10"
                @click="handleEdit(knowledge)"
              />
              <Button
                icon="i-lucide-trash"
                color="slate"
                size="xs"
                class="rounded-md hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-900/20"
                @click="handleDelete(knowledge)"
              />
            </div>
          </div>
        </CardLayout>
      </div>
    </template>
  </SaturnPageLayout>

  <CreateKnowledgeDialog
    ref="createDialogRef"
    :agent-id="agentId"
    :selected-knowledge="selectedKnowledge"
    @created="handleKnowledgeCreated"
    @updated="handleKnowledgeUpdated"
    @createFailed="handleCreateFailed"
    @close="handleDialogClose"
  />

  <DeleteKnowledgeDialog
    ref="deleteDialogRef"
    :agent-id="agentId"
    :knowledge="selectedKnowledge"
    @deleted="handleKnowledgeDeleted"
    @restore="handleKnowledgeRestore"
    @close="handleDialogClose"
  />
</template>
