<script setup>
import { ref, watch, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const { t } = useI18n();

const props = defineProps({
  agentId: {
    type: [String, Number],
    required: true,
  },
  selectedKnowledge: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'created', 'updated', 'createFailed']);

const dialogRef = ref(null);
const form = ref({
  title: '',
  content_text: '',
  source_type: 'text',
  source_url: '',
});

const sourceTypes = computed(() => [
  { value: 'text', label: t('SATURN.KNOWLEDGE.SOURCE_TYPE_TEXT'), icon: 'i-lucide-file-text' },
  { value: 'url', label: t('SATURN.KNOWLEDGE.SOURCE_TYPE_URL'), icon: 'i-lucide-link' },
  { value: 'faq', label: t('SATURN.KNOWLEDGE.SOURCE_TYPE_FAQ'), icon: 'i-lucide-message-circle-question' },
]);

const isEdit = ref(false);

const resetForm = () => {
  form.value = {
    title: '',
    content_text: '',
    source_type: 'text',
    source_url: '',
  };
};

const populateForm = () => {
  if (props.selectedKnowledge) {
    isEdit.value = true;
    const knowledge = props.selectedKnowledge;
    form.value.title = knowledge.title || '';
    form.value.content_text = knowledge.content_text || knowledge.contentText || '';
    form.value.source_type = knowledge.source_type || knowledge.sourceType || 'text';
    form.value.source_url = knowledge.source_url || knowledge.sourceUrl || '';
  } else {
    isEdit.value = false;
    resetForm();
  }
};

// Watch only ID changes, not the whole object to avoid re-triggering on every input
watch(() => props.selectedKnowledge?.id, (newId, oldId) => {
  if (newId !== oldId) {
    populateForm();
  }
});

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      const response = await SaturnKnowledgeAPI.updateForAgent(props.agentId, props.selectedKnowledge.id, {
        knowledge_source: form.value,
      });
      useAlert(t('SATURN.KNOWLEDGE.SUCCESS_UPDATE'));
      emit('updated', response.data);
      handleClose();
    } else {
      const optimisticKnowledge = {
        id: `temp-${Date.now()}`,
        title: form.value.title,
        content_text: form.value.content_text,
        source_type: form.value.source_type,
        source_url: form.value.source_url,
        agent_profile_id: props.agentId,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        _optimistic: true,
      };
      
      emit('created', optimisticKnowledge);
      
      const response = await SaturnKnowledgeAPI.createForAgent(props.agentId, {
        knowledge_source: form.value,
      });
      useAlert(t('SATURN.KNOWLEDGE.SUCCESS_CREATE'));
      emit('updated', response.data);
      handleClose();
    }
  } catch (error) {
    const errorMsg = error.response?.data?.error || t('SATURN.AGENTS.ERROR_OPERATION');
    useAlert(errorMsg);
    if (!isEdit.value) {
      emit('createFailed', form.value.title);
    }
  }
};

const handleClose = () => {
  resetForm();
  dialogRef.value?.close();
};

const handleDialogClose = () => {
  resetForm();
  emit('close');
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="isEdit ? $t('SATURN.KNOWLEDGE.EDIT') : $t('SATURN.KNOWLEDGE.ADD')"
    :description="$t('SATURN.KNOWLEDGE.CREATE_DESCRIPTION')"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleDialogClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label class="block text-sm font-medium mb-2">{{ $t('SATURN.KNOWLEDGE.SOURCE_TYPE_LABEL') }}</label>
        <div class="grid grid-cols-3 gap-2">
          <button
            v-for="type in sourceTypes.value"
            :key="type.value"
            type="button"
            @click="form.source_type = type.value"
            :class="[
              'flex flex-col items-center gap-2 p-3 border-2 rounded-lg transition-all',
              form.source_type === type.value
                ? 'border-woot-500 bg-woot-50 dark:bg-woot-900/20'
                : 'border-n-weak hover:border-n-strong hover:bg-n-solid-2'
            ]"
          >
            <i :class="type.icon" class="text-2xl"></i>
            <span class="text-xs font-medium text-center">{{ type.label }}</span>
          </button>
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ $t('SATURN.KNOWLEDGE.TITLE_LABEL') }}</label>
        <input
          v-model="form.title"
          type="text"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500 focus:border-woot-500"
          :placeholder="$t('SATURN.KNOWLEDGE.TITLE_PLACEHOLDER')"
          required
        />
      </div>
      
      <div>
        <label class="block text-sm font-medium mb-1">{{ $t('SATURN.KNOWLEDGE.CONTENT_LABEL') }}</label>
        <textarea
          v-model="form.content_text"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500 focus:border-woot-500"
          :placeholder="$t('SATURN.KNOWLEDGE.CONTENT_PLACEHOLDER')"
          rows="6"
          required
        />
      </div>
      
      <div v-if="form.source_type === 'url'">
        <label class="block text-sm font-medium mb-1">Source URL</label>
        <input
          v-model="form.source_url"
          type="url"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500 focus:border-woot-500"
          placeholder="https://example.com/docs"
        />
      </div>

      <div class="flex gap-3 pt-4">
        <button
          type="button"
          @click="handleClose"
          class="flex-1 px-4 py-2 border border-n-weak rounded-lg hover:bg-n-solid-2"
        >
          {{ $t('SATURN.KNOWLEDGE.CANCEL_BUTTON') }}
        </button>
        <button
          type="submit"
          class="flex-1 px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium"
        >
          {{ isEdit ? $t('SATURN.KNOWLEDGE.UPDATE_BUTTON') : $t('SATURN.KNOWLEDGE.ADD_BUTTON') }}
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
