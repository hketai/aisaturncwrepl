<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useAlert } from 'dashboard/composables';
import PageLayout from 'dashboard/components-next/PageLayout.vue';
import CardLayout from 'dashboard/components-next/CardLayout.vue';
import Button from 'dashboard/components-next/Button.vue';
import Dialog from 'dashboard/components-next/Dialog.vue';
import Input from 'dashboard/components-next/Input.vue';
import Textarea from 'dashboard/components-next/Textarea.vue';
import SaturnAutoRepliesAPI from 'dashboard/api/saturnAutoReplies';

const route = useRoute();
const agentId = computed(() => route.params.agentId);
const accountId = computed(() => route.params.accountId);

const loading = ref(false);
const autoReplies = ref([]);
const showCreateDialog = ref(false);
const showDeleteDialog = ref(false);
const selectedReply = ref(null);

const newReply = ref({
  user_query: '',
  agent_response: '',
});

const fetchAutoReplies = async () => {
  loading.value = true;
  try {
    const response = await SaturnAutoRepliesAPI.getForAgent(agentId.value);
    autoReplies.value = response.data.payload || [];
  } catch (error) {
    useAlert('Failed to load auto replies');
  } finally {
    loading.value = false;
  }
};

const handleCreate = async () => {
  if (!newReply.value.user_query || !newReply.value.agent_response) {
    useAlert('Please fill in all fields');
    return;
  }

  const optimisticReply = {
    id: `temp-${Date.now()}`,
    user_query: newReply.value.user_query,
    agent_response: newReply.value.agent_response,
    created_at: new Date().toISOString(),
    _optimistic: true,
  };

  autoReplies.value.unshift(optimisticReply);
  const tempReply = { ...newReply.value };
  newReply.value = { user_query: '', agent_response: '' };
  showCreateDialog.value = false;

  try {
    const response = await SaturnAutoRepliesAPI.create(agentId.value, tempReply);
    const index = autoReplies.value.findIndex(r => r._optimistic);
    if (index !== -1) {
      autoReplies.value[index] = response.data;
    }
    useAlert('Auto reply created successfully');
  } catch (error) {
    autoReplies.value = autoReplies.value.filter(r => !r._optimistic);
    useAlert('Failed to create auto reply');
    newReply.value = tempReply;
  }
};

const handleDelete = async () => {
  if (!selectedReply.value) return;

  const replyToDelete = selectedReply.value;
  const index = autoReplies.value.findIndex(r => r.id === replyToDelete.id);
  if (index !== -1) {
    autoReplies.value.splice(index, 1);
  }

  showDeleteDialog.value = false;
  selectedReply.value = null;

  try {
    await SaturnAutoRepliesAPI.delete(replyToDelete.id);
    useAlert('Auto reply deleted successfully');
  } catch (error) {
    if (index !== -1) {
      autoReplies.value.splice(index, 0, replyToDelete);
    }
    useAlert('Failed to delete auto reply');
  }
};

const openDeleteDialog = (reply) => {
  selectedReply.value = reply;
  showDeleteDialog.value = true;
};

onMounted(() => {
  fetchAutoReplies();
});
</script>

<template>
  <PageLayout
    :header-title="`Auto Replies`"
    :back-url="`/accounts/${accountId}/settings/saturn-agents`"
    :is-fetching="loading"
  >
    <template #header-actions>
      <Button
        icon="i-lucide-plus"
        @click="showCreateDialog = true"
      >
        Add Auto Reply
      </Button>
    </template>

    <div v-if="autoReplies.length === 0 && !loading" class="flex flex-col items-center justify-center py-16">
      <div class="w-16 h-16 mb-4 rounded-full bg-n-slate-3 flex items-center justify-center">
        <i class="i-lucide-message-square text-3xl text-n-slate-9"></i>
      </div>
      <h3 class="text-lg font-semibold text-n-slate-12 mb-2">No Auto Replies</h3>
      <p class="text-sm text-n-slate-11 mb-4">Create pattern-based automatic responses</p>
      <Button
        icon="i-lucide-plus"
        @click="showCreateDialog = true"
      >
        Add First Auto Reply
      </Button>
    </div>

    <div v-else class="grid grid-cols-1 gap-4">
      <CardLayout
        v-for="reply in autoReplies"
        :key="reply.id"
        :class="{ 'opacity-60': reply._optimistic }"
        class="overflow-visible"
      >
        <div class="space-y-3">
          <div>
            <div class="flex items-start justify-between mb-2">
              <span class="text-xs font-medium text-n-slate-11 uppercase">User Query</span>
              <Button
                v-if="!reply._optimistic"
                icon="i-lucide-trash"
                color="ruby"
                size="xs"
                @click="openDeleteDialog(reply)"
              />
            </div>
            <p class="text-sm text-n-slate-12 font-medium">{{ reply.user_query }}</p>
          </div>
          
          <div class="pt-3 border-t border-n-weak">
            <span class="text-xs font-medium text-n-slate-11 uppercase block mb-2">Agent Response</span>
            <p class="text-sm text-n-slate-12">{{ reply.agent_response }}</p>
          </div>

          <div v-if="reply._optimistic" class="pt-2 border-t border-n-weak">
            <span class="text-xs text-blue-600 dark:text-blue-400 font-medium">
              Creating...
            </span>
          </div>
        </div>
      </CardLayout>
    </div>

    <Dialog
      v-model="showCreateDialog"
      title="Create Auto Reply"
      size="md"
    >
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            User Query / Pattern
          </label>
          <Input
            v-model="newReply.user_query"
            placeholder="e.g., What are your business hours?"
          />
          <p class="text-xs text-n-slate-11 mt-1">
            The question or phrase that triggers this response
          </p>
        </div>

        <div>
          <label class="block text-sm font-medium text-n-slate-12 mb-2">
            Agent Response
          </label>
          <Textarea
            v-model="newReply.agent_response"
            placeholder="e.g., We're open Monday-Friday, 9am-5pm EST"
            :rows="4"
          />
          <p class="text-xs text-n-slate-11 mt-1">
            The automatic response that will be sent
          </p>
        </div>
      </div>

      <template #footer>
        <div class="flex justify-end gap-2">
          <Button
            color="slate"
            @click="showCreateDialog = false"
          >
            Cancel
          </Button>
          <Button
            @click="handleCreate"
          >
            Create
          </Button>
        </div>
      </template>
    </Dialog>

    <Dialog
      v-model="showDeleteDialog"
      title="Delete Auto Reply"
      size="sm"
    >
      <p class="text-sm text-n-slate-11">
        Are you sure you want to delete this auto reply? This action cannot be undone.
      </p>

      <template #footer>
        <div class="flex justify-end gap-2">
          <Button
            color="slate"
            @click="showDeleteDialog = false"
          >
            Cancel
          </Button>
          <Button
            color="ruby"
            @click="handleDelete"
          >
            Delete
          </Button>
        </div>
      </template>
    </Dialog>
  </PageLayout>
</template>
