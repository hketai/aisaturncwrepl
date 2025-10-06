<script setup>
import { computed, onMounted, ref, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';
import SaturnAPI from 'dashboard/api/saturn';

import PageLayout from 'dashboard/components-next/captain/PageLayout.vue';
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
    useAlert('Failed to load agent');
  }
};

const fetchKnowledgeSources = async () => {
  try {
    loading.value = true;
    const response = await SaturnKnowledgeAPI.getForAgent(agentId.value);
    knowledgeSources.value = response.data.payload || [];
  } catch (error) {
    useAlert('Failed to load knowledge sources');
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleCreate = () => {
  selectedKnowledge.value = null;
  nextTick(() => createDialogRef.value?.dialogRef?.open());
};

const handleEdit = (knowledge) => {
  selectedKnowledge.value = knowledge;
  nextTick(() => createDialogRef.value?.dialogRef?.open());
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
  }
};

const handleKnowledgeDeleted = (knowledgeId) => {
  knowledgeSources.value = knowledgeSources.value.filter(k => k.id !== knowledgeId);
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

onMounted(async () => {
  await fetchAgent();
  await fetchKnowledgeSources();
});
</script>

<template>
  <PageLayout
    :header-title="`${agent?.name || 'Agent'} - Knowledge Sources`"
    :back-url="{ name: 'saturn_agents_index' }"
    button-label="Add Knowledge Source"
    :is-fetching="loading"
    :is-empty="!knowledgeSources.length"
    :show-pagination-footer="false"
    @click="handleCreate"
  >
    <template #emptyState>
      <div class="flex flex-col items-center justify-center h-full py-16">
        <div class="max-w-md text-center">
          <div class="mb-6 flex justify-center">
            <div class="i-lucide-book-open text-6xl text-n-weak" />
          </div>
          
          <h2 class="text-2xl font-semibold mb-3">No Knowledge Sources Yet</h2>
          
          <p class="text-n-weak mb-8">
            Add documents, FAQs, or URLs to build your agent's knowledge base. 
            The agent will use this information to answer customer questions.
          </p>
          
          <Button
            color="primary"
            size="large"
            @click="handleCreate"
          >
            <span class="i-lucide-plus mr-2"></span>
            Add Knowledge Source
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
              <i :class="getSourceTypeIcon(knowledge.source_type)" class="text-xl text-n-weak mt-0.5" />
              <div class="flex-1 min-w-0">
                <h3 class="font-medium text-n-slate-12 truncate">
                  {{ knowledge.title || 'Untitled' }}
                </h3>
                <p class="text-sm text-n-slate-11 line-clamp-2 mt-1">
                  {{ knowledge.content_text?.substring(0, 150) }}{{ knowledge.content_text?.length > 150 ? '...' : '' }}
                </p>
                <div class="flex items-center gap-2 mt-2">
                  <span class="text-xs px-2 py-0.5 rounded-full bg-n-alpha-2 text-n-slate-11">
                    {{ knowledge.source_type }}
                  </span>
                  <span v-if="knowledge.source_url" class="text-xs text-n-slate-11 truncate">
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
                class="rounded-md hover:bg-n-alpha-2"
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
  </PageLayout>

  <CreateKnowledgeDialog
    ref="createDialogRef"
    :agent-id="agentId"
    :selected-knowledge="selectedKnowledge"
    @created="handleKnowledgeCreated"
    @updated="handleKnowledgeUpdated"
    @close="handleDialogClose"
  />

  <DeleteKnowledgeDialog
    v-if="selectedKnowledge"
    ref="deleteDialogRef"
    :agent-id="agentId"
    :knowledge="selectedKnowledge"
    @deleted="handleKnowledgeDeleted"
    @close="handleDialogClose"
  />
</template>
