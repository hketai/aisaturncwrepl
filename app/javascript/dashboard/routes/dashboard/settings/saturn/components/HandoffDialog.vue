<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import SaturnAPI from 'dashboard/api/saturn';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const { t } = useI18n();

const props = defineProps({
  selectedAgent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'updated']);

const dialogRef = ref(null);
const teams = useMapGetter('teams/getTeams');

const form = ref({
  handoff_enabled: false,
  handoff_team_id: null,
  intent_routing_enabled: false,
  intent_team_mappings: [],
});

const newIntent = ref('');
const newTeamId = ref(null);

watch(() => props.selectedAgent, (agent) => {
  if (agent) {
    form.value = {
      handoff_enabled: agent.handoff_enabled || false,
      handoff_team_id: agent.handoff_team_id || null,
      intent_routing_enabled: agent.intent_routing_enabled || false,
      intent_team_mappings: [...(agent.intent_team_mappings || [])],
    };
  } else {
    form.value = {
      handoff_enabled: false,
      handoff_team_id: null,
      intent_routing_enabled: false,
      intent_team_mappings: [],
    };
  }
}, { immediate: true });

const addIntentMapping = () => {
  if (newIntent.value.trim() && newTeamId.value) {
    const teamName = teams.value.find(t => t.id === newTeamId.value)?.name;
    form.value.intent_team_mappings.push({
      intent: newIntent.value.trim(),
      team_id: newTeamId.value,
      team_name: teamName,
    });
    newIntent.value = '';
    newTeamId.value = null;
  }
};

const removeIntentMapping = (index) => {
  form.value.intent_team_mappings.splice(index, 1);
};

const handleSubmit = async () => {
  try {
    const response = await SaturnAPI.update(props.selectedAgent.id, { agent: form.value });
    useAlert(t('SATURN.AGENTS.HANDOFF_SUCCESS'));
    emit('updated', response.data);
    dialogRef.value.close();
  } catch (error) {
    const errorMsg = error.response?.data?.error || t('SATURN.AGENTS.ERROR_OPERATION');
    useAlert(errorMsg);
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
    type="edit"
    :title="$t('SATURN.AGENTS.HANDOFF_SETTINGS')"
    :description="$t('SATURN.AGENTS.HANDOFF_DESCRIPTION')"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <!-- Basic Handoff Settings -->
      <div class="space-y-3">
        <div class="flex items-center gap-2">
          <input
            v-model="form.handoff_enabled"
            type="checkbox"
            id="handoff-enabled"
            class="rounded"
          />
          <label for="handoff-enabled" class="text-sm font-medium">{{ $t('SATURN.AGENTS.ENABLE_HANDOFF') }}</label>
        </div>

        <div v-if="form.handoff_enabled" class="space-y-2 pl-6">
          <label class="block text-sm font-medium text-n-slate-12">
            {{ $t('SATURN.AGENTS.DEFAULT_HANDOFF_TEAM_LABEL') }}
          </label>
          <select
            v-model="form.handoff_team_id"
            class="w-full px-3 py-2 border border-n-weak rounded-lg focus:outline-none focus:ring-2 focus:ring-woot-500"
          >
            <option :value="null">{{ $t('SATURN.AGENTS.SELECT_TEAM') }}</option>
            <option
              v-for="team in teams"
              :key="team.id"
              :value="team.id"
            >
              {{ team.name }}
            </option>
          </select>
          <p class="text-xs text-n-slate-11">{{ $t('SATURN.AGENTS.DEFAULT_HANDOFF_HINT') }}</p>
        </div>
      </div>

      <!-- Intent-Based Routing -->
      <div v-if="form.handoff_enabled" class="border-t border-n-weak pt-4 space-y-3">
        <div class="flex items-center gap-2">
          <input
            v-model="form.intent_routing_enabled"
            type="checkbox"
            id="intent-routing-enabled"
            class="rounded"
          />
          <label for="intent-routing-enabled" class="text-sm font-medium">{{ $t('SATURN.AGENTS.ENABLE_INTENT_ROUTING') }}</label>
        </div>

        <div v-if="form.intent_routing_enabled" class="space-y-3 pl-6">
          <p class="text-xs text-n-slate-11">{{ $t('SATURN.AGENTS.INTENT_ROUTING_DESCRIPTION') }}</p>
          
          <!-- Intent Mappings List -->
          <div v-if="form.intent_team_mappings.length > 0" class="space-y-2">
            <div
              v-for="(mapping, index) in form.intent_team_mappings"
              :key="index"
              class="flex items-center gap-2 p-2 bg-n-solid-1 rounded-lg"
            >
              <div class="flex-1">
                <div class="text-sm font-medium text-n-slate-12">{{ mapping.intent }}</div>
                <div class="text-xs text-n-slate-11">→ {{ mapping.team_name }}</div>
              </div>
              <button
                type="button"
                @click="removeIntentMapping(index)"
                class="p-1 text-red-600 hover:bg-red-50 rounded"
              >
                <i class="i-lucide-trash text-base"></i>
              </button>
            </div>
          </div>

          <!-- Add New Intent Mapping -->
          <div class="space-y-2 p-3 bg-n-solid-1 rounded-lg">
            <label class="block text-xs font-medium text-n-slate-12">
              {{ $t('SATURN.AGENTS.ADD_INTENT_MAPPING') }}
            </label>
            <input
              v-model="newIntent"
              type="text"
              :placeholder="$t('SATURN.AGENTS.INTENT_PLACEHOLDER')"
              class="w-full px-3 py-2 border border-n-weak rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-woot-500"
            />
            <select
              v-model="newTeamId"
              class="w-full px-3 py-2 border border-n-weak rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-woot-500"
            >
              <option :value="null">{{ $t('SATURN.AGENTS.SELECT_TEAM') }}</option>
              <option
                v-for="team in teams"
                :key="team.id"
                :value="team.id"
              >
                {{ team.name }}
              </option>
            </select>
            <button
              type="button"
              @click="addIntentMapping"
              :disabled="!newIntent.trim() || !newTeamId"
              class="w-full px-3 py-2 bg-woot-500 text-white rounded-lg text-sm font-medium hover:bg-woot-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ $t('SATURN.AGENTS.ADD_MAPPING_BUTTON') }}
            </button>
          </div>
        </div>
      </div>

      <div class="flex gap-3 pt-4">
        <button
          type="button"
          @click="dialogRef.close()"
          class="flex-1 px-4 py-2 border border-n-weak rounded-lg hover:bg-n-solid-2"
        >
          {{ $t('SATURN.AGENTS.CANCEL_BUTTON') }}
        </button>
        <button
          type="submit"
          class="flex-1 px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium"
        >
          {{ $t('SATURN.AGENTS.SAVE_BUTTON') }}
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
