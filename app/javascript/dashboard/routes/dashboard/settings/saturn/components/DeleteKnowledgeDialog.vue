<script setup>
import { ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnKnowledgeAPI from 'dashboard/api/saturnKnowledge';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

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
const knowledgeToDelete = ref(null);

const handleConfirm = async () => {
  knowledgeToDelete.value = { ...props.knowledge };
  
  emit('deleted', props.knowledge.id);
  emit('close');
  
  try {
    await SaturnKnowledgeAPI.deleteForAgent(props.agentId, props.knowledge.id);
    useAlert('Knowledge source deleted successfully');
  } catch (error) {
    useAlert('Failed to delete knowledge source');
    emit('restore', knowledgeToDelete.value);
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
    :show-cancel-button="true"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <template #description>
      <p class="mb-0 text-sm text-n-slate-11">
        This knowledge source will be permanently removed from the agent's knowledge base.
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
          label="Delete Knowledge Source"
          class="w-full"
          @click="handleConfirm"
        />
      </div>
    </template>
  </Dialog>
</template>
