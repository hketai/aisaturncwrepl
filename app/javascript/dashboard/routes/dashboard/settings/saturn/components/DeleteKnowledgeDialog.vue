<script setup>
import { ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const props = defineProps({
  agentId: {
    type: [String, Number],
    required: true,
  },
  knowledge: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['close', 'deleted']);

const dialogRef = ref(null);

const handleConfirm = async () => {
  try {
    await SaturnKnowledgeAPI.deleteForAgent(props.agentId, props.knowledge.id);
    useAlert('Knowledge source deleted successfully');
    emit('deleted', props.knowledge.id);
    dialogRef.value.close();
  } catch (error) {
    useAlert('Failed to delete knowledge source');
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
    type="alert"
    :title="`Delete ${knowledge.title}?`"
    description="This knowledge source will be permanently removed from the agent's knowledge base."
    confirm-button-label="Delete Knowledge Source"
    @close="handleClose"
    @confirm="handleConfirm"
  />
</template>
