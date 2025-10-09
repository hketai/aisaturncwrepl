<script setup>
import { computed } from 'vue';
import { useStoreGetters } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import { frontendURL } from 'dashboard/helper/URLHelper';
import { useBranding } from 'shared/composables/useBranding';

import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  id: {
    type: [String, Number],
    required: true,
  },
  name: {
    type: String,
    default: '',
  },
  description: {
    type: String,
    default: '',
  },
  enabled: {
    type: Boolean,
    default: false,
  },
});

const getters = useStoreGetters();
const accountId = getters.getCurrentAccountId;

const { t } = useI18n();
const { replaceInstallationName } = useBranding();

const integrationStatus = computed(() =>
  props.enabled
    ? t('INTEGRATION_APPS.STATUS.ENABLED')
    : t('INTEGRATION_APPS.STATUS.DISABLED')
);

const integrationStatusColor = computed(() =>
  props.enabled ? 'bg-teal-800' : 'bg-slate-700'
);

const actionURL = computed(() =>
  frontendURL(`accounts/${accountId.value}/settings/integrations/${props.id}`)
);
</script>

<template>
  <div
    class="flex flex-col flex-1 p-6 m-[1px] outline outline-slate-300 outline-1 bg-slate-900/15 rounded-md shadow"
  >
    <div class="flex items-start justify-between">
      <div class="flex h-12 w-12 mb-4">
        <img
          :src="`/dashboard/images/integrations/${id}.png`"
          class="max-w-full rounded-md border border-slate-300 shadow-sm block dark:hidden bg-slate-900/15 dark:bg-slate-900/10"
        />
        <img
          :src="`/dashboard/images/integrations/${id}-dark.png`"
          class="max-w-full rounded-md border border-slate-300 shadow-sm hidden dark:block bg-slate-900/15 dark:bg-slate-900/10"
        />
      </div>
      <span
        v-tooltip="integrationStatus"
        class="text-white p-0.5 rounded-full w-5 h-5 flex items-center justify-center"
        :class="integrationStatusColor"
      >
        <i class="i-ph-check-bold text-sm" />
      </span>
    </div>
    <div class="flex flex-col m-0 flex-1">
      <div
        class="font-medium mb-2 text-slate-900 flex justify-between items-center"
      >
        <span class="text-base font-semibold">{{ name }}</span>
        <router-link :to="actionURL">
          <Button :label="$t('INTEGRATION_APPS.CONFIGURE')" link />
        </router-link>
      </div>
      <p class="text-slate-900">
        {{ replaceInstallationName(description) }}
      </p>
    </div>
  </div>
</template>
