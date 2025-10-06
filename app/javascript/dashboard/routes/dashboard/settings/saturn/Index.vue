<template>
  <div class="flex flex-col h-full">
    <div class="p-6 border-b border-n-weak">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-semibold mb-2 flex items-center gap-2">
            <span class="i-lucide-sparkles text-2xl"></span>
            Saturn AI Agents
          </h1>
          <p class="text-n-weak">
            Create and manage AI agents that automatically respond to customer inquiries.
          </p>
        </div>
        <button
          @click="showCreateModal = true"
          class="px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium flex items-center gap-2"
        >
          <span class="i-lucide-plus"></span>
          Create Agent
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex-1 flex items-center justify-center">
      <div class="text-center">
        <div class="i-lucide-loader-2 text-4xl text-n-weak animate-spin mb-2"></div>
        <p class="text-n-weak">Loading agents...</p>
      </div>
    </div>

    <div v-else-if="agents.length === 0" class="flex-1 flex items-center justify-center p-6">
      <div class="text-center max-w-md">
        <div class="mb-4 flex justify-center">
          <div class="i-lucide-sparkles text-6xl text-n-weak" />
        </div>
        <h2 class="text-xl font-semibold mb-2">No AI Agents Yet</h2>
        <p class="text-n-weak mb-6">
          Create your first AI agent to start automating customer support responses.
        </p>
        <button
          @click="showCreateModal = true"
          class="px-6 py-3 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium inline-flex items-center gap-2"
        >
          <span class="i-lucide-plus"></span>
          Create Your First Agent
        </button>
      </div>
    </div>

    <div v-else class="flex-1 overflow-auto p-6">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="agent in agents"
          :key="agent.id"
          class="bg-n-solid-1 border border-n-weak rounded-lg p-6 hover:shadow-lg transition-shadow"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-full bg-gradient-to-br from-purple-400 to-pink-500 flex items-center justify-center text-white font-bold text-lg">
                {{ agent.name.charAt(0).toUpperCase() }}
              </div>
              <div>
                <h3 class="font-semibold text-lg">{{ agent.name }}</h3>
                <span
                  :class="[
                    'inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium',
                    agent.active
                      ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                      : 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400'
                  ]"
                >
                  <span :class="agent.active ? 'i-lucide-check-circle' : 'i-lucide-circle'"></span>
                  {{ agent.active ? 'Active' : 'Inactive' }}
                </span>
              </div>
            </div>
          </div>

          <p class="text-n-weak text-sm mb-4 line-clamp-2">
            {{ agent.description || 'No description provided' }}
          </p>

          <div class="flex items-center justify-between pt-4 border-t border-n-weak">
            <span class="text-xs text-n-weak">
              Created {{ formatDate(agent.created_at) }}
            </span>
            <div class="flex gap-2">
              <button
                @click="editAgent(agent)"
                class="p-2 hover:bg-n-solid-2 rounded transition-colors"
                title="Edit"
              >
                <span class="i-lucide-pencil text-n-weak"></span>
              </button>
              <button
                @click="deleteAgent(agent)"
                class="p-2 hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition-colors"
                title="Delete"
              >
                <span class="i-lucide-trash-2 text-red-600"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal (simplified for now) -->
    <div
      v-if="showCreateModal"
      class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
      @click.self="showCreateModal = false"
    >
      <div class="bg-white dark:bg-n-solid-1 rounded-lg max-w-2xl w-full p-6">
        <h2 class="text-xl font-semibold mb-4">Create New AI Agent</h2>
        <form @submit.prevent="createAgent">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium mb-1">Agent Name</label>
              <input
                v-model="newAgent.name"
                type="text"
                required
                class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500"
                placeholder="e.g., Customer Support Agent"
              />
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Description</label>
              <textarea
                v-model="newAgent.description"
                rows="3"
                class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500"
                placeholder="Describe what this agent does..."
              ></textarea>
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Product Context</label>
              <input
                v-model="newAgent.product_context"
                type="text"
                class="w-full px-3 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-woot-500"
                placeholder="e.g., SaaS product support, E-commerce store"
              />
            </div>
            <div>
              <label class="flex items-center gap-2">
                <input
                  v-model="newAgent.active"
                  type="checkbox"
                  class="rounded"
                />
                <span class="text-sm">Activate agent immediately</span>
              </label>
            </div>
          </div>
          <div class="flex gap-3 mt-6">
            <button
              type="button"
              @click="showCreateModal = false"
              class="flex-1 px-4 py-2 border border-n-weak rounded-lg hover:bg-n-solid-2"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="flex-1 px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium"
            >
              Create Agent
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';

const agents = ref([]);
const loading = ref(true);
const showCreateModal = ref(false);
const newAgent = ref({
  name: '',
  description: '',
  product_context: '',
  active: true,
});

const fetchAgents = async () => {
  try {
    loading.value = true;
    const response = await SaturnAPI.get();
    agents.value = response.data.payload || [];
  } catch (error) {
    useAlert('Failed to load agents');
    console.error('Error fetching agents:', error);
  } finally {
    loading.value = false;
  }
};

const createAgent = async () => {
  try {
    await SaturnAPI.create({ agent: newAgent.value });
    useAlert('Agent created successfully');
    showCreateModal.value = false;
    newAgent.value = { name: '', description: '', product_context: '', active: true };
    await fetchAgents();
  } catch (error) {
    const errorMsg = error.response?.data?.error || 'Failed to create agent';
    useAlert(errorMsg);
    console.error('Error creating agent:', error.response?.data || error);
  }
};

const editAgent = (agent) => {
  useAlert('Edit functionality coming soon!');
};

const deleteAgent = async (agent) => {
  if (!confirm(`Are you sure you want to delete "${agent.name}"?`)) return;
  
  try {
    await SaturnAPI.delete(agent.id);
    useAlert('Agent deleted successfully');
    await fetchAgents();
  } catch (error) {
    useAlert('Failed to delete agent');
    console.error('Error deleting agent:', error);
  }
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

onMounted(() => {
  fetchAgents();
});
</script>
