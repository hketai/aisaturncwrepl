<script setup>
import { ref, watch } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Textarea from 'dashboard/components-next/textarea/TextArea.vue';

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

const sourceTypes = [
  { value: 'text', label: 'Text/Document' },
  { value: 'url', label: 'URL/Website' },
  { value: 'faq', label: 'FAQ' },
];

const isEdit = ref(false);

watch(() => props.selectedKnowledge, (knowledge) => {
  if (knowledge) {
    isEdit.value = true;
    form.value = {
      title: knowledge.title,
      content_text: knowledge.content_text || '',
      source_type: knowledge.source_type,
      source_url: knowledge.source_url || '',
    };
  } else {
    isEdit.value = false;
    form.value = {
      title: '',
      content_text: '',
      source_type: 'text',
      source_url: '',
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      const response = await SaturnKnowledgeAPI.updateForAgent(props.agentId, props.selectedKnowledge.id, {
        knowledge_source: form.value,
      });
      useAlert('Knowledge source updated successfully');
      emit('updated', response.data);
      handleClose();
      dialogRef.value?.close();
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
      useAlert('Knowledge source added successfully');
      emit('updated', response.data);
      handleClose();
      dialogRef.value?.close();
    }
  } catch (error) {
    const errorMsg = error.response?.data?.error || 'Operation failed';
    useAlert(errorMsg);
    if (!isEdit.value) {
      emit('createFailed', form.value.title);
    }
  }
};

const handleClose = () => {
  emit('close');
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="isEdit ? 'Edit Knowledge Source' : 'Add Knowledge Source'"
    description="Add information that your AI agent can use to answer customer questions"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label class="block text-sm font-medium mb-1">Source Type</label>
        <select
          v-model="form.source_type"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500"
        >
          <option v-for="type in sourceTypes" :key="type.value" :value="type.value">
            {{ type.label }}
          </option>
        </select>
      </div>

      <Input
        v-model="form.title"
        label="Title"
        placeholder="e.g., Product Return Policy"
        required
      />
      
      <Textarea
        v-model="form.content_text"
        label="Content"
        placeholder="Enter the knowledge content here..."
        rows="6"
        required
      />
      
      <Input
        v-if="form.source_type === 'url'"
        v-model="form.source_url"
        label="Source URL"
        type="url"
        placeholder="https://example.com/docs"
      />

      <div class="flex gap-3 pt-4">
        <button
          type="button"
          @click="dialogRef.close()"
          class="flex-1 px-4 py-2 border border-n-weak rounded-lg hover:bg-n-solid-2"
        >
          Cancel
        </button>
        <button
          type="submit"
          class="flex-1 px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium"
        >
          {{ isEdit ? 'Update' : 'Add' }} Knowledge Source
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
