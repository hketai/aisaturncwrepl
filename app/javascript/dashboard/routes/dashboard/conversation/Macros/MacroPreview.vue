<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store.js';
import {
  resolveActionName,
  resolveTeamIds,
  resolveLabels,
  resolveAgents,
} from 'dashboard/routes/dashboard/settings/macros/macroHelper';

const props = defineProps({
  macro: {
    type: Object,
    required: true,
  },
});

const labels = useMapGetter('labels/getLabels');
const teams = useMapGetter('teams/getTeams');
const agents = useMapGetter('agents/getAgents');

const getActionValue = (key, params) => {
  const actionsMap = {
    assign_team: resolveTeamIds(teams.value, params),
    add_label: resolveLabels(labels.value, params),
    remove_label: resolveLabels(labels.value, params),
    assign_agent: resolveAgents(agents.value, params),
    mute_conversation: null,
    snooze_conversation: null,
    resolve_conversation: null,
    remove_assigned_team: null,
    send_webhook_event: params[0],
    send_message: params[0],
    send_email_transcript: params[0],
    add_private_note: params[0],
  };
  return actionsMap[key] || '';
};

const resolvedMacro = computed(() => {
  return props.macro.actions.map(action => ({
    actionName: resolveActionName(action.action_name),
    actionValue: getActionValue(action.action_name, action.action_params),
  }));
});
</script>

<template>
  <div
    class="macro-preview absolute border border-slate-300 max-h-[22.5rem] z-50 w-64 rounded-md bg-slate-900/15 backdrop-blur-[100px] shadow-lg bottom-8 right-8 overflow-y-auto p-4 text-left rtl:text-right"
  >
    <h6 class="mb-4 text-sm text-slate-900">
      {{ macro.name }}
    </h6>
    <div
      v-for="(action, i) in resolvedMacro"
      :key="i"
      class="relative pl-4 macro-block"
    >
      <div
        v-if="i !== macro.actions.length - 1"
        class="top-[0.390625rem] absolute -bottom-1 left-0 w-px bg-slate-500"
      />
      <div
        class="absolute -left-[0.21875rem] top-[0.2734375rem] w-2 h-2 rounded-full bg-slate-100 border-2 border-solid border-slate-300 dark:border-slate-500"
      />
      <p class="mb-1 text-xs text-slate-900">
        {{ $t(`MACROS.ACTIONS.${action.actionName}`) }}
      </p>
      <p class="text-slate-900 text-sm">{{ action.actionValue }}</p>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.macro-preview {
  .macro-block {
    &:not(:last-child) {
      @apply pb-2;
    }
  }
}
</style>
