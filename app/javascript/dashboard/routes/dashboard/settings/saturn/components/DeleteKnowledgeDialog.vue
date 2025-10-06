<script setup>
import { ref, watch } from 'vue';
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
    default: null,
  },
});

const emit = defineEmits(['close', 'deleted', 'restore']);

const dialogRef = ref(null);
const knowledgeToDelete = ref(null);

watch(() => props.knowledge, (newKnowledge) => {
  if (newKnowledge) {
    knowledgeToDelete.value = { 
      id: newKnowledge.id, 
      title: newKnowledge.title,
      ...newKnowledge 
    };
  }
}, { immediate: true });

const handleConfirm = async () => {
  if (!knowledgeToDelete.value) {
    console.log('[DELETE] No knowledge to delete');
    return;
  }
  
  const knowledgeId = knowledgeToDelete.value.id;
  const knowledgeData = { ...knowledgeToDelete.value };
  
  console.log('[DELETE] Emitting deleted event for ID:', knowledgeId);
  emit('deleted', knowledgeId);
  emit('close');
  knowledgeToDelete.value = null;
  
  try {
    console.log('[DELETE] Calling API to delete knowledge ID:', knowledgeId);
    await SaturnKnowledgeAPI.deleteForAgent(props.agentId, knowledgeId);
    console.log('[DELETE] API call successful');
    useAlert('Knowledge source deleted successfully');
  } catch (error) {
    console.log('[DELETE] API call failed, restoring:', error);
    useAlert('Failed to delete knowledge source');
    emit('restore', knowledgeData);
  }
};

const handleClose = () => {
  knowledgeToDelete.value = null;
  emit('close');
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    v-if="knowledgeToDelete"
    ref="dialogRef"
    type="alert"
    :title="`Delete ${knowledgeToDelete.title}?`"
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
