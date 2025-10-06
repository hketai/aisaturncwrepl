<script setup>
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['create']);

const handleCreate = () => {
  emit('create');
};
</script>

<template>
  <div class="flex flex-col items-center justify-center h-full py-16">
    <div class="max-w-md text-center">
      <div class="mb-6 flex justify-center">
        <div class="i-lucide-sparkles text-6xl text-n-weak" />
      </div>
      
      <h2 class="text-2xl font-semibold mb-3">Create Your First AI Agent</h2>
      
      <p class="text-n-weak mb-8">
        AI agents automatically respond to customer inquiries using your knowledge base. 
        Start by creating your first agent and adding knowledge sources.
      </p>
      
      <Button
        color="primary"
        size="large"
        @click="handleCreate"
      >
        <span class="i-lucide-plus mr-2"></span>
        Create Agent
      </Button>
    </div>
  </div>
</template>
