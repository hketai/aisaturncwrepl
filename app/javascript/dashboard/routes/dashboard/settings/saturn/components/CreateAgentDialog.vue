<script setup>
import { ref, watch } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Textarea from 'dashboard/components-next/textarea/TextArea.vue';

const props = defineProps({
  selectedAgent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'created', 'updated']);

const dialogRef = ref(null);
const form = ref({
  name: '',
  description: '',
  product_context: '',
  active: true,
});

const isEdit = ref(false);

watch(() => props.selectedAgent, (agent) => {
  if (agent) {
    isEdit.value = true;
    form.value = {
      name: agent.name,
      description: agent.description || '',
      product_context: agent.product_context || '',
      active: agent.active,
    };
  } else {
    isEdit.value = false;
    form.value = {
      name: '',
      description: '',
      product_context: '',
      active: true,
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      const response = await SaturnAPI.update(props.selectedAgent.id, { agent: form.value });
      console.log('✅ Update response:', response);
      useAlert('Agent updated successfully');
      emit('updated', response.data);
    } else {
      const response = await SaturnAPI.create({ agent: form.value });
      console.log('✅ Create response:', response);
      console.log('✅ Response data:', response.data);
      useAlert('Agent created successfully');
      emit('created', response.data);
    }
    dialogRef.value.close();
  } catch (error) {
    console.error('❌ Error:', error);
    const errorMsg = error.response?.data?.error || 'Operation failed';
    useAlert(errorMsg);
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
    :title="isEdit ? 'Edit Agent' : 'Create New Agent'"
    description="Configure your AI agent to automatically respond to customer inquiries"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <Input
        v-model="form.name"
        label="Agent Name"
        placeholder="e.g., Customer Support Agent"
        required
      />
      
      <Textarea
        v-model="form.description"
        label="Description"
        placeholder="Describe what this agent does..."
        rows="3"
      />
      
      <Input
        v-model="form.product_context"
        label="Product Context"
        placeholder="e.g., SaaS product support, E-commerce store"
      />
      
      <div class="flex items-center gap-2">
        <input
          v-model="form.active"
          type="checkbox"
          id="agent-active"
          class="rounded"
        />
        <label for="agent-active" class="text-sm">Activate agent immediately</label>
      </div>

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
          {{ isEdit ? 'Update' : 'Create' }} Agent
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
