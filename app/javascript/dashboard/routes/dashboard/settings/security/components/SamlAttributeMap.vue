<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Icon from 'next/icon/Icon.vue';

const { t } = useI18n();
const isExpanded = ref(false);

const toggleExpanded = () => {
  isExpanded.value = !isExpanded.value;
};
</script>

<template>
  <section
    class="rounded-xl border border-slate-300 bg-slate-100 w-full text-sm text-slate-900 mb-5 overflow-hidden"
  >
    <button
      type="button"
      class="w-full px-4 py-3 flex items-center justify-between text-left hover:bg-slate-200 transition-colors"
      @click="toggleExpanded"
    >
      <h4 class="font-medium text-slate-900">
        {{ t('SECURITY_SETTINGS.SAML.ATTRIBUTE_MAPPING.TITLE') }}
      </h4>
      <Icon
        icon="i-lucide-chevron-down"
        class="transition-transform duration-200"
        :class="{ 'rotate-180': isExpanded }"
      />
    </button>

    <div
      class="transition-[height] duration-200 ease-in-out overflow-hidden"
      :class="isExpanded ? 'h-auto' : 'h-0'"
    >
      <div class="px-4 pb-3">
        <p class="text-slate-900 mb-2">
          {{ t('SECURITY_SETTINGS.SAML.ATTRIBUTE_MAPPING.DESCRIPTION') }}
        </p>
        <!-- eslint-disable vue/no-bare-strings-in-template -->
        <ul class="list-none text-slate-900 space-y-1">
          <li><code class="px-1 rounded bg-slate-200">email</code></li>
          <li><code class="px-1 rounded bg-slate-200">first_name</code></li>
          <li><code class="px-1 rounded bg-slate-200">last_name</code></li>
        </ul>
      </div>
    </div>
  </section>
</template>
