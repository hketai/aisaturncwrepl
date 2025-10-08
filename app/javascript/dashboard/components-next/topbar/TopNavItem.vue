<script setup>
import { computed, ref } from 'vue';
import { useRoute } from 'vue-router';
import { useMapGetter } from 'dashboard/composables/store';
import { vOnClickOutside } from '@vueuse/components';

const props = defineProps({
  name: {
    type: String,
    required: true,
  },
  label: {
    type: String,
    required: true,
  },
  icon: {
    type: String,
    default: '',
  },
  to: {
    type: [String, Object],
    default: null,
  },
  activeOn: {
    type: Array,
    default: () => [],
  },
  children: {
    type: Array,
    default: () => [],
  },
  getterKeys: {
    type: Object,
    default: () => ({}),
  },
});

const route = useRoute();
const showDropdown = ref(false);
const buttonRef = ref(null);

const count = computed(() => {
  if (props.getterKeys?.count) {
    const getter = useMapGetter(props.getterKeys.count);
    return getter.value || 0;
  }
  return 0;
});

const isActive = computed(() => {
  if (props.activeOn && props.activeOn.length > 0) {
    return props.activeOn.includes(route.name);
  }
  if (props.to) {
    const toPath = typeof props.to === 'string' ? props.to : props.to.path;
    return route.path === toPath;
  }
  return false;
});

const dropdownPosition = computed(() => {
  if (!buttonRef.value) return { top: 0, left: 0 };
  const rect = buttonRef.value.getBoundingClientRect();
  return {
    top: rect.bottom + 4,
    left: rect.left,
  };
});

const emit = defineEmits(['itemClick']);

const toggleDropdown = () => {
  if (props.children && props.children.length > 0) {
    showDropdown.value = !showDropdown.value;
  } else {
    emit('itemClick');
  }
};

const closeDropdown = () => {
  showDropdown.value = false;
  emit('itemClick');
};
</script>

<template>
  <div class="relative" v-on-click-outside="closeDropdown" ref="buttonRef">
    <component
      :is="to && !children.length ? 'router-link' : 'button'"
      :to="to && !children.length ? to : undefined"
      :class="[
        'flex items-center gap-2 px-3 h-10 rounded-md text-sm font-medium transition-colors duration-150',
        isActive
          ? 'bg-brand-50 dark:bg-brand-900/20 text-brand-600 dark:text-brand-400'
          : 'text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800',
      ]"
      @click.stop="toggleDropdown"
    >
      <span v-if="icon" :class="[icon, 'text-lg']" />
      <span>{{ label }}</span>
      <span
        v-if="count > 0"
        class="ml-1 px-1.5 py-0.5 text-xs font-semibold rounded-full bg-brand-600 text-white"
      >
        {{ count }}
      </span>
      <span
        v-if="children && children.length > 0"
        :class="[
          'i-ph-caret-down text-sm transition-transform duration-200',
          showDropdown ? 'rotate-180' : ''
        ]"
      />
    </component>

    <Teleport to="body">
      <div
        v-if="children && children.length > 0 && showDropdown"
        :style="{
          position: 'fixed',
          top: dropdownPosition.top + 'px',
          left: dropdownPosition.left + 'px',
        }"
        class="min-w-[200px] bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-xl z-[9999] py-1 max-h-96 overflow-y-auto"
      >
        <router-link
          v-for="child in children"
          :key="child.name"
          :to="child.to"
          class="flex items-center gap-2 px-3 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
          @click="closeDropdown"
        >
          <span v-if="child.icon" :class="child.icon" />
          <span>{{ child.label }}</span>
        </router-link>
      </div>
    </Teleport>
  </div>
</template>
