<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const { t } = useI18n();

const props = defineProps({
  agent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'deleted', 'restore']);

const dialogRef = ref(null);
const agentToDelete = ref(null);

watch(() => props.agent, (newAgent) => {
  if (newAgent) {
    agentToDelete.value = { id: newAgent.id, name: newAgent.name };
  }
}, { immediate: true });

const handleConfirm = async () => {
  if (!agentToDelete.value) return;
  
  const agentId = agentToDelete.value.id;
  
  emit('deleted', agentId);
  emit('close');
  agentToDelete.value = null;
  
  try {
    await SaturnAPI.delete(agentId);
    useAlert(t('SATURN.AGENTS.SUCCESS_DELETE'));
  } catch (error) {
    useAlert(t('SATURN.AGENTS.ERROR_DELETE'));
    emit('restore', agentId);
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
        {{ $t('SATURN.AGENTS.DELETE_CONFIRM') }}
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
