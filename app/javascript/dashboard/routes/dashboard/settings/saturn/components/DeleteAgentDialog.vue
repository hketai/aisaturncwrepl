<script setup>
import { ref, watch } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  agent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'deleted']);

const dialogRef = ref(null);
const agentToDelete = ref(null);

watch(() => props.agent, (newAgent) => {
  if (newAgent) {
    agentToDelete.value = { id: newAgent.id, name: newAgent.name };
  }
}, { immediate: true });

const handleConfirm = async () => {
  if (!agentToDelete.value) {
    console.error('❌ No agent to delete');
    return;
  }
  
  try {
    console.log('🗑️ Starting delete for agent:', agentToDelete.value.id);
    await SaturnAPI.delete(agentToDelete.value.id);
    console.log('✅ Delete API success, emitting deleted event');
    useAlert('Agent deleted successfully');
    emit('deleted', agentToDelete.value.id);
    console.log('📤 Deleted event emitted');
    emit('close');
    console.log('🚪 Close event emitted');
    agentToDelete.value = null;
  } catch (error) {
    console.error('❌ Delete error:', error);
    useAlert('Failed to delete agent');
  }
};

const handleClose = () => {
  agentToDelete.value = null;
  emit('close');
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    v-if="agentToDelete"
    ref="dialogRef"
    type="alert"
    :title="`Delete ${agentToDelete.name}?`"
    :show-cancel-button="true"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <template #description>
      <p class="mb-0 text-sm text-n-slate-11">
        This action cannot be undone. All associated knowledge sources and configurations will be permanently deleted.
      </p>
    </template>
    
    <template #footer>
      <div class="flex items-center justify-between w-full gap-3">
        <Button
          variant="faded"
          color="slate"
          label="Cancel"
          class="w-full"
          @click="handleClose"
        />
        <Button
          color="ruby"
          label="Delete Agent"
          class="w-full"
          @click="handleConfirm"
        />
      </div>
    </template>
  </Dialog>
</template>
