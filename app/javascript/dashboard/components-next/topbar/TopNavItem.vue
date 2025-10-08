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
  <div class="relative" v-on-click-outside="closeDropdown">
    <component
      :is="to && !children.length ? 'router-link' : 'button'"
      :to="to && !children.length ? to : undefined"
      :class="[
        'flex items-center gap-2 px-3 h-10 rounded-md text-sm font-medium transition-colors duration-150',
        isActive
          ? 'bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400'
          : 'text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800',
      ]"
      @click="toggleDropdown"
    >
      <span v-if="icon" :class="[icon, 'text-lg']" />
      <span>{{ label }}</span>
      <span
        v-if="count > 0"
        class="ml-1 px-1.5 py-0.5 text-xs font-semibold rounded-full bg-indigo-600 text-white"
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

    <div
      v-if="children && children.length > 0 && showDropdown"
      class="absolute top-full left-0 mt-1 min-w-[200px] bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-lg z-50 py-1 max-h-96 overflow-y-auto"
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
  </div>
</template>
