<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import SaturnAPI from 'dashboard/api/saturn';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const { t } = useI18n();
const router = useRouter();

const props = defineProps({
  selectedAgent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'updated']);

const dialogRef = ref(null);
const teams = useMapGetter('teams/getTeams');
const allAgents = ref([]);

const handoffType = ref('human');

const form = ref({
  handoff_enabled: false,
  handoff_team_id: null,
  intent_routing_enabled: false,
  intent_team_mappings: [],
  transfer_enabled: false,
  transfer_agent_id: null,
  intent_agent_mappings: [],
});

const newIntent = ref('');
const newTeamId = ref(null);
const newAgentIntent = ref('');
const newAgentId = ref(null);

const hasNoTeams = computed(() => !teams.value || teams.value.length === 0);

const availableAgents = computed(() => {
  return allAgents.value.filter(agent => agent.id !== props.selectedAgent?.id);
});

const fetchAgents = async () => {
  try {
    const response = await SaturnAPI.get();
    allAgents.value = response.data.payload || [];
  } catch (error) {
    console.error('Error fetching agents:', error);
  }
};

const navigateToTeams = () => {
  dialogRef.value.close();
  router.push({ name: 'settings_teams_list', params: { accountId: 1 } });
};

onMounted(() => {
  fetchAgents();
});

watch(() => props.selectedAgent, (agent) => {
  if (agent) {
    form.value = {
      handoff_enabled: agent.handoff_enabled || false,
      handoff_team_id: agent.handoff_team_id || null,
      intent_routing_enabled: agent.intent_routing_enabled || false,
      intent_team_mappings: [...(agent.intent_team_mappings || [])],
      transfer_enabled: agent.transfer_enabled || false,
      transfer_agent_id: agent.transfer_agent_id || null,
      intent_agent_mappings: [...(agent.intent_agent_mappings || [])],
    };
    
    if (agent.transfer_enabled) {
      handoffType.value = 'agent';
    } else if (agent.handoff_enabled) {
      handoffType.value = 'human';
    }
  } else {
    form.value = {
      handoff_enabled: false,
      handoff_team_id: null,
      intent_routing_enabled: false,
      intent_team_mappings: [],
      transfer_enabled: false,
      transfer_agent_id: null,
      intent_agent_mappings: [],
    };
    handoffType.value = 'human';
  }
}, { immediate: true });

watch(handoffType, (type) => {
  if (type === 'human') {
    form.value.transfer_enabled = false;
    form.value.transfer_agent_id = null;
    form.value.intent_agent_mappings = [];
  } else if (type === 'agent') {
    form.value.handoff_enabled = false;
    form.value.handoff_team_id = null;
    form.value.intent_routing_enabled = false;
    form.value.intent_team_mappings = [];
  }
});

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

const addAgentIntentMapping = () => {
  if (newAgentIntent.value.trim() && newAgentId.value) {
    const agentName = allAgents.value.find(a => a.id === newAgentId.value)?.name;
    form.value.intent_agent_mappings.push({
      intent: newAgentIntent.value.trim(),
      agent_id: newAgentId.value,
      agent_name: agentName,
    });
    newAgentIntent.value = '';
    newAgentId.value = null;
  }
};

const removeAgentIntentMapping = (index) => {
  form.value.intent_agent_mappings.splice(index, 1);
};

const handleSubmit = async () => {
  try {
    const payload = { ...form.value };
    
    if (handoffType.value === 'human') {
      payload.handoff_enabled = true;
      payload.transfer_enabled = false;
      payload.transfer_agent_id = null;
    } else if (handoffType.value === 'agent') {
      payload.transfer_enabled = true;
      payload.handoff_enabled = false;
      payload.handoff_team_id = null;
      payload.intent_routing_enabled = false;
      payload.intent_team_mappings = [];
    }
    
    const response = await SaturnAPI.update(props.selectedAgent.id, { agent: payload });
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
      <!-- Handoff Type Selection -->
      <div class="space-y-3">
        <h4 class="text-sm font-semibold text-n-slate-12">{{ $t('SATURN.AGENTS.HANDOFF_TYPE_LABEL') }}</h4>
        
        <div class="flex gap-3">
          <label 
            :class="[
              'flex-1 p-4 border-2 rounded-lg cursor-pointer transition-all',
              handoffType === 'human' 
                ? 'border-woot-500 bg-woot-50 dark:bg-woot-900/20' 
                : 'border-n-slate-7 dark:border-n-slate-6 bg-n-slate-2 dark:bg-n-slate-3 hover:border-n-slate-8 dark:hover:border-n-slate-5'
            ]"
          >
            <input
              v-model="handoffType"
              type="radio"
              value="human"
              class="sr-only"
            />
            <div class="flex items-center gap-3">
              <i class="i-lucide-user-round-search text-2xl" :class="handoffType === 'human' ? 'text-woot-500' : 'text-n-slate-11 dark:text-n-slate-5'"></i>
              <div>
                <div class="text-sm font-medium text-n-slate-12 dark:text-n-slate-1">{{ $t('SATURN.AGENTS.HANDOFF_TO_HUMAN') }}</div>
                <div class="text-xs text-n-slate-11 dark:text-n-slate-4">{{ $t('SATURN.AGENTS.HANDOFF_TO_HUMAN_DESC') }}</div>
              </div>
            </div>
          </label>

          <label 
            :class="[
              'flex-1 p-4 border-2 rounded-lg cursor-pointer transition-all',
              handoffType === 'agent' 
                ? 'border-woot-500 bg-woot-50 dark:bg-woot-900/20' 
                : 'border-n-slate-7 dark:border-n-slate-6 bg-n-slate-2 dark:bg-n-slate-3 hover:border-n-slate-8 dark:hover:border-n-slate-5'
            ]"
          >
            <input
              v-model="handoffType"
              type="radio"
              value="agent"
              class="sr-only"
            />
            <div class="flex items-center gap-3">
              <i class="i-lucide-bot text-2xl" :class="handoffType === 'agent' ? 'text-woot-500' : 'text-n-slate-11 dark:text-n-slate-5'"></i>
              <div>
                <div class="text-sm font-medium text-n-slate-12 dark:text-n-slate-1">{{ $t('SATURN.AGENTS.HANDOFF_TO_AGENT') }}</div>
                <div class="text-xs text-n-slate-11 dark:text-n-slate-4">{{ $t('SATURN.AGENTS.HANDOFF_TO_AGENT_DESC') }}</div>
              </div>
            </div>
          </label>
        </div>
      </div>

      <!-- Human Handoff Settings -->
      <div v-if="handoffType === 'human'" class="space-y-4 border-t border-n-weak pt-4">
        <!-- No Teams Warning -->
        <div v-if="hasNoTeams" class="p-4 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg">
          <div class="flex items-start gap-3">
            <i class="i-lucide-alert-triangle text-amber-600 dark:text-amber-400 text-xl mt-0.5"></i>
            <div class="flex-1">
              <h4 class="text-sm font-semibold text-amber-900 dark:text-amber-100 mb-1">{{ $t('SATURN.AGENTS.NO_TEAMS_WARNING') }}</h4>
              <p class="text-xs text-amber-800 dark:text-amber-200">{{ $t('SATURN.AGENTS.NO_TEAMS_MESSAGE') }}</p>
              <button
                type="button"
                @click="navigateToTeams"
                class="inline-flex items-center gap-1 mt-2 px-4 py-2 text-xs font-semibold bg-amber-600 text-white hover:bg-amber-700 dark:bg-amber-500 dark:text-white dark:hover:bg-amber-600 rounded-md shadow-sm transition-colors"
              >
                {{ $t('SATURN.AGENTS.CREATE_TEAM_LINK') }} →
              </button>
            </div>
          </div>
        </div>

        <div class="space-y-2">
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
      <div v-if="handoffType === 'human'" class="border-t border-n-weak pt-4 space-y-3">
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

      <!-- Agent Transfer Settings -->
      <div v-if="handoffType === 'agent'" class="border-t border-n-weak pt-4 space-y-3">
        <p class="text-sm text-n-slate-11">{{ $t('SATURN.AGENTS.AGENT_INTENT_ROUTING_DESCRIPTION') }}</p>
        
        <!-- Intent Mappings List -->
        <div v-if="form.intent_agent_mappings.length > 0" class="space-y-2">
          <div
            v-for="(mapping, index) in form.intent_agent_mappings"
            :key="index"
            class="flex items-center gap-2 p-2 bg-n-solid-1 rounded-lg"
          >
            <div class="flex-1">
              <div class="text-sm font-medium text-n-slate-12">{{ mapping.intent }}</div>
              <div class="text-xs text-n-slate-11">→ {{ mapping.agent_name }}</div>
            </div>
            <button
              type="button"
              @click="removeAgentIntentMapping(index)"
              class="p-1 text-red-600 hover:bg-red-50 rounded"
            >
              <i class="i-lucide-trash text-base"></i>
            </button>
          </div>
        </div>

        <!-- Add New Intent Mapping -->
        <div class="space-y-2 p-3 bg-n-solid-1 rounded-lg">
          <label class="block text-xs font-medium text-n-slate-12">
            {{ $t('SATURN.AGENTS.ADD_AGENT_INTENT_MAPPING') }}
          </label>
          <input
            v-model="newAgentIntent"
            type="text"
            :placeholder="$t('SATURN.AGENTS.AGENT_INTENT_PLACEHOLDER')"
            class="w-full px-3 py-2 border border-n-weak rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-woot-500"
          />
          <select
            v-model="newAgentId"
            class="w-full px-3 py-2 border border-n-weak rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-woot-500"
          >
            <option :value="null">{{ $t('SATURN.AGENTS.SELECT_AGENT') }}</option>
            <option
              v-for="agent in availableAgents"
              :key="agent.id"
              :value="agent.id"
            >
              {{ agent.name }}
            </option>
          </select>
          <button
            type="button"
            @click="addAgentIntentMapping"
            :disabled="!newAgentIntent.trim() || !newAgentId"
            class="w-full px-3 py-2 bg-woot-500 text-white rounded-lg text-sm font-medium hover:bg-woot-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ $t('SATURN.AGENTS.ADD_MAPPING_BUTTON') }}
          </button>
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
