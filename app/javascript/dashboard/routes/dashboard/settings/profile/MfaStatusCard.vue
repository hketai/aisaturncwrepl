<script setup>
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

defineProps({
  mfaEnabled: {
    type: Boolean,
    required: true,
  },
  showSetup: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['enableMfa']);

const startSetup = () => {
  emit('enableMfa');
};
</script>

<template>
  <div v-if="!mfaEnabled && !showSetup" class="space-y-6">
    <div
      class="bg-slate-100 rounded-lg p-6 outline outline-slate-300 outline-1 text-center"
    >
      <Icon
        icon="i-lucide-lock-keyhole"
        class="size-8 text-slate-900 mx-auto mb-4 block"
      />
      <h3 class="text-lg font-medium text-slate-900 mb-2">
        {{ $t('MFA_SETTINGS.ENHANCE_SECURITY') }}
      </h3>
      <p class="text-sm text-slate-900 mb-6 max-w-md mx-auto">
        {{ $t('MFA_SETTINGS.ENHANCE_SECURITY_DESC') }}
      </p>
      <Button
        icon="i-lucide-settings"
        :label="$t('MFA_SETTINGS.ENABLE_BUTTON')"
        @click="startSetup"
      />
    </div>
  </div>
  <div v-else-if="mfaEnabled && !showSetup">
    <div
      class="bg-slate-100 rounded-xl outline-1 outline-slate-300 outline p-4 flex-1 flex flex-col gap-2"
    >
      <div class="flex items-center gap-2">
        <Icon
          icon="i-lucide-lock-keyhole"
          class="size-4 flex-shrink-0 text-slate-900"
        />
        <h4 class="text-sm font-medium text-slate-900">
          {{ $t('MFA_SETTINGS.STATUS_ENABLED') }}
        </h4>
      </div>
      <p class="text-sm text-slate-900">
        {{ $t('MFA_SETTINGS.STATUS_ENABLED_DESC') }}
      </p>
    </div>
  </div>
</template>
