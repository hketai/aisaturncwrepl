<script setup>
import { useRouter, useRoute } from 'vue-router';

import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const router = useRouter();
const route = useRoute();

const navigateToMfa = () => {
  router.push({
    name: 'profile_settings_mfa',
    params: {
      accountId: route.params.accountId,
    },
  });
};
</script>

<template>
  <div class="bg-white rounded-xl p-4 border border-slate-300">
    <div class="flex flex-col xs:flex-row items-center justify-between gap-4">
      <div class="flex flex-col items-start gap-1.5">
        <div class="flex items-center gap-2">
          <Icon
            icon="i-lucide-lock-keyhole"
            class="size-4 text-slate-900 flex-shrink-0"
          />
          <h5 class="text-sm font-semibold text-slate-900">
            {{ $t('MFA_SETTINGS.TITLE') }}
          </h5>
        </div>
        <p class="text-sm text-slate-900">
          {{ $t('MFA_SETTINGS.DESCRIPTION') }}
        </p>
      </div>
      <Button
        type="button"
        faded
        :label="$t('PROFILE_SETTINGS.FORM.SECURITY_SECTION.MFA_BUTTON')"
        icon="i-lucide-settings"
        class="flex-shrink-0"
        @click="navigateToMfa"
      />
    </div>
  </div>
</template>
