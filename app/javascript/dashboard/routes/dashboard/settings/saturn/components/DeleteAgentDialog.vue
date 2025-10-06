<script setup>
import { ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const props = defineProps({
  agent: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['close', 'deleted']);

const dialogRef = ref(null);

const handleConfirm = async () => {
  try {
    await SaturnAPI.delete(props.agent.id);
    useAlert('Agent deleted successfully');
    emit('deleted', props.agent.id);
    dialogRef.value.close();
  } catch (error) {
    useAlert('Failed to delete agent');
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
    type="delete"
    :title="`Delete ${agent.name}?`"
    description="This action cannot be undone. All associated knowledge sources and configurations will be permanently deleted."
    confirm-button-label="Delete Agent"
    @close="handleClose"
    @confirm="handleConfirm"
  />
</template>
