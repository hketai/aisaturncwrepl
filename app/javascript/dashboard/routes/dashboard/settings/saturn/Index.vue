<template>
  <div class="flex flex-col h-full p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-semibold mb-2">Saturn AI Agents</h1>
      <p class="text-n-weak">
        Create and manage AI agents that automatically respond to customer inquiries using your knowledge base.
      </p>
    </div>

    <div class="flex-1 bg-n-solid-1 rounded-lg border border-n-weak p-8 flex items-center justify-center">
      <div class="text-center max-w-md">
        <div class="mb-4 flex justify-center">
          <div class="i-lucide-sparkles text-6xl text-n-weak" />
        </div>
        <h2 class="text-xl font-semibold mb-2">Saturn AI - Coming Soon</h2>
        <p class="text-n-weak mb-4">
          The MIT-licensed automatic response system is currently under development. 
          This feature will enable you to create AI agents that can automatically respond to customer messages.
        </p>
        <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 text-left">
          <p class="text-sm text-yellow-800 dark:text-yellow-200">
            <strong>Note:</strong> Saturn AI requires an OpenAI API key. 
            Please add your <code class="px-1 bg-yellow-100 dark:bg-yellow-900/40 rounded">OPENAI_API_KEY</code> 
            to your environment secrets to use this feature.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
</script>
