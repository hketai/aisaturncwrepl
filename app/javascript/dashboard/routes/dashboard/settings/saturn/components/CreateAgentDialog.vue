<script setup>
import { ref, watch, computed } from 'vue';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Textarea from 'dashboard/components-next/textarea/TextArea.vue';

const props = defineProps({
  selectedAgent: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'created', 'updated', 'createFailed']);

const dialogRef = ref(null);
const form = ref({
  name: '',
  description: '',
  product_context: '',
  industry_type: '',
  behavior_rules: [],
  safety_guidelines: [],
  active: true,
});

const isEdit = ref(false);

const industryTypes = [
  { value: 'ecommerce', label: 'E-Commerce', description: 'Online stores and e-commerce platforms' },
  { value: 'hotel', label: 'Hotel & Hospitality', description: 'Hotels and accommodation services' },
  { value: 'restaurant', label: 'Restaurant & Food Service', description: 'Restaurants and food delivery' },
  { value: 'healthcare', label: 'Healthcare & Medical', description: 'Healthcare facilities and medical services' },
  { value: 'education', label: 'Education & Training', description: 'Educational institutions and online learning' },
  { value: 'finance', label: 'Finance & Banking', description: 'Financial services and banking' },
  { value: 'real_estate', label: 'Real Estate', description: 'Property sales and rentals' },
  { value: 'retail', label: 'Retail & Shopping', description: 'Retail stores and shopping centers' },
  { value: 'saas', label: 'SaaS & Technology', description: 'Software and technology companies' },
  { value: 'automotive', label: 'Automotive & Car Services', description: 'Car dealerships and automotive services' },
  { value: 'general', label: 'General Customer Support', description: 'General-purpose customer support' },
];

const industryTemplates = {
  ecommerce: {
    description: 'AI assistant for online stores and e-commerce platforms',
    product_context: 'E-commerce customer support',
    behavior_rules: [
      'Always be helpful and product-focused',
      'Provide clear information about products, shipping, and returns',
      'Guide customers through the purchase process',
      'Handle order status inquiries professionally',
      'Upsell and cross-sell when appropriate',
      'Resolve complaints with empathy and solutions',
    ],
    safety_guidelines: [
      'Never share customer payment information',
      'Do not process refunds directly - escalate to human agent',
      'Verify customer identity for sensitive account changes',
      'Follow company return and refund policies strictly',
      'Escalate fraud or suspicious activity immediately',
    ],
  },
  hotel: {
    description: 'AI concierge for hotels and accommodation services',
    product_context: 'Hotel guest services',
    behavior_rules: [
      'Greet guests warmly and professionally',
      'Provide information about rooms, amenities, and services',
      'Help with booking, check-in, and check-out processes',
      'Recommend local attractions and restaurants',
      'Handle special requests and room service orders',
      'Address complaints with immediate solutions',
    ],
    safety_guidelines: [
      'Protect guest privacy and personal information',
      'Do not share room numbers or guest details',
      'Escalate emergency situations to hotel staff immediately',
      'Verify guest identity for room access or billing changes',
      'Follow hotel safety and security protocols',
    ],
  },
  restaurant: {
    description: 'AI assistant for restaurants and food delivery',
    product_context: 'Restaurant customer service',
    behavior_rules: [
      'Be friendly and appetizing in descriptions',
      'Help with menu selections and recommendations',
      'Take reservations and orders accurately',
      'Inform about dietary options (vegan, gluten-free, etc.)',
      'Provide wait times and delivery estimates',
      'Handle food allergies with utmost care',
    ],
    safety_guidelines: [
      'Always ask about food allergies and dietary restrictions',
      'Never guarantee allergen-free if uncertain',
      'Escalate food safety concerns immediately',
      'Verify delivery addresses and payment methods',
      'Follow food handling and hygiene guidelines',
    ],
  },
  healthcare: {
    description: 'AI assistant for healthcare facilities and medical services',
    product_context: 'Healthcare patient support',
    behavior_rules: [
      'Be empathetic and professional at all times',
      'Help with appointment scheduling and reminders',
      'Provide general health information (non-diagnostic)',
      'Guide patients through facility processes',
      'Handle billing and insurance inquiries',
      'Respect patient privacy and confidentiality',
    ],
    safety_guidelines: [
      'NEVER provide medical diagnosis or treatment advice',
      'Always recommend consulting healthcare professionals',
      'Protect patient health information (HIPAA compliance)',
      'Escalate medical emergencies immediately',
      'Do not access or share medical records',
      'Direct clinical questions to qualified staff',
    ],
  },
  education: {
    description: 'AI assistant for educational institutions and online learning',
    product_context: 'Educational support services',
    behavior_rules: [
      'Be encouraging and supportive of learning',
      'Help with course enrollment and registration',
      'Provide information about programs and curriculum',
      'Answer questions about schedules and deadlines',
      'Guide students through learning resources',
      'Support both students and parents/guardians',
    ],
    safety_guidelines: [
      'Protect student privacy and academic records',
      'Do not share grades or performance data',
      'Escalate academic integrity issues to staff',
      'Follow child protection and safety policies',
      'Verify identity for sensitive information access',
    ],
  },
  finance: {
    description: 'AI assistant for financial services and banking',
    product_context: 'Financial customer support',
    behavior_rules: [
      'Be professional and security-conscious',
      'Help with account inquiries and transactions',
      'Explain financial products and services clearly',
      'Guide through banking processes and applications',
      'Provide general financial information',
      'Handle complaints with priority and care',
    ],
    safety_guidelines: [
      'NEVER ask for passwords, PINs, or full card numbers',
      'Always verify customer identity for account access',
      'Escalate fraud or suspicious activity immediately',
      'Do not provide investment advice',
      'Follow financial regulations and compliance strictly',
      'Protect customer financial data at all costs',
    ],
  },
  real_estate: {
    description: 'AI assistant for property sales and rentals',
    product_context: 'Real estate services',
    behavior_rules: [
      'Be knowledgeable about properties and locations',
      'Help with property searches and viewings',
      'Provide market information and pricing',
      'Guide through buying/renting processes',
      'Schedule property tours and appointments',
      'Answer questions about neighborhoods and amenities',
    ],
    safety_guidelines: [
      'Verify client identity before sharing property details',
      'Do not share personal information of sellers/landlords',
      'Escalate legal questions to qualified professionals',
      'Follow fair housing laws and regulations',
      'Protect sensitive financial and contract information',
    ],
  },
  retail: {
    description: 'AI assistant for retail stores and shopping centers',
    product_context: 'Retail customer service',
    behavior_rules: [
      'Be helpful and product-knowledgeable',
      'Assist with product searches and comparisons',
      'Provide store hours, locations, and inventory',
      'Help with returns, exchanges, and warranties',
      'Offer style advice and product recommendations',
      'Handle loyalty programs and promotions',
    ],
    safety_guidelines: [
      'Protect customer purchase history and preferences',
      'Do not process financial transactions directly',
      'Verify identity for account changes',
      'Escalate security or theft concerns to store staff',
      'Follow return and exchange policies strictly',
    ],
  },
  saas: {
    description: 'AI assistant for software and technology companies',
    product_context: 'SaaS customer support',
    behavior_rules: [
      'Be technical yet accessible in explanations',
      'Help with onboarding and feature adoption',
      'Troubleshoot common technical issues',
      'Guide through integrations and workflows',
      'Explain pricing and subscription options',
      'Collect feedback and feature requests',
    ],
    safety_guidelines: [
      'Never share API keys or authentication tokens',
      'Protect user data and account information',
      'Escalate security vulnerabilities immediately',
      'Do not access user accounts without permission',
      'Follow data privacy regulations (GDPR, CCPA)',
      'Verify identity for sensitive account operations',
    ],
  },
  automotive: {
    description: 'AI assistant for car dealerships and automotive services',
    product_context: 'Automotive customer service',
    behavior_rules: [
      'Be knowledgeable about vehicles and services',
      'Help with vehicle selection and comparisons',
      'Schedule test drives and service appointments',
      'Provide pricing and financing information',
      'Answer questions about warranties and maintenance',
      'Guide through buying or leasing processes',
    ],
    safety_guidelines: [
      'Verify customer identity for service records',
      'Do not share previous owners information',
      'Escalate safety recalls immediately',
      'Protect financial and credit information',
      'Follow automotive regulations and compliance',
    ],
  },
  general: {
    description: 'General-purpose AI assistant for various industries',
    product_context: 'General customer support',
    behavior_rules: [
      'Be helpful, professional, and courteous',
      'Listen carefully to customer needs',
      'Provide clear and accurate information',
      'Guide customers to appropriate resources',
      'Handle complaints with empathy and solutions',
      'Escalate complex issues when needed',
    ],
    safety_guidelines: [
      'Protect customer privacy and personal data',
      'Never share sensitive information',
      'Verify identity for account access',
      'Escalate security concerns immediately',
      'Follow company policies and procedures',
      'Be transparent about AI limitations',
    ],
  },
};

const handleIndustryChange = () => {
  const template = industryTemplates[form.value.industry_type];
  if (template && !isEdit.value) {
    form.value.description = template.description;
    form.value.product_context = template.product_context;
    form.value.behavior_rules = [...template.behavior_rules];
    form.value.safety_guidelines = [...template.safety_guidelines];
  }
};

watch(() => props.selectedAgent, (agent) => {
  if (agent) {
    isEdit.value = true;
    form.value = {
      name: agent.name,
      description: agent.description || '',
      product_context: agent.product_context || '',
      industry_type: agent.industry_type || '',
      behavior_rules: agent.behavior_rules || [],
      safety_guidelines: agent.safety_guidelines || [],
      active: agent.active,
    };
  } else {
    isEdit.value = false;
    form.value = {
      name: '',
      description: '',
      product_context: '',
      industry_type: '',
      behavior_rules: [],
      safety_guidelines: [],
      active: true,
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      const response = await SaturnAPI.update(props.selectedAgent.id, { agent: form.value });
      useAlert('Agent updated successfully');
      emit('updated', response.data);
      dialogRef.value.close();
    } else {
      const optimisticAgent = {
        id: `temp-${Date.now()}`,
        name: form.value.name,
        description: form.value.description,
        product_context: form.value.product_context,
        active: form.value.active,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        _optimistic: true,
      };
      
      emit('created', optimisticAgent);
      dialogRef.value.close();
      
      const response = await SaturnAPI.create({ agent: form.value });
      useAlert('Agent created successfully');
      emit('updated', response.data);
    }
  } catch (error) {
    const errorMsg = error.response?.data?.error || 'Operation failed';
    useAlert(errorMsg);
    if (!isEdit.value) {
      emit('createFailed', form.value.name);
    }
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
    :title="isEdit ? 'Edit Agent' : 'Create New Agent'"
    description="Configure your AI agent to automatically respond to customer inquiries"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <Input
        v-model="form.name"
        label="Agent Name"
        placeholder="e.g., Customer Support Agent"
        required
      />
      
      <div class="space-y-2">
        <label class="block text-sm font-medium text-n-slate-12">
          Industry Type
        </label>
        <select
          v-model="form.industry_type"
          @change="handleIndustryChange"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:outline-none focus:ring-2 focus:ring-woot-500"
          :disabled="isEdit"
        >
          <option value="">Select an industry...</option>
          <option
            v-for="industry in industryTypes"
            :key="industry.value"
            :value="industry.value"
          >
            {{ industry.label }}
          </option>
        </select>
        <p v-if="form.industry_type" class="text-xs text-n-slate-11">
          {{ industryTypes.find(i => i.value === form.industry_type)?.description }}
        </p>
      </div>
      
      <Textarea
        v-model="form.description"
        label="Description"
        placeholder="Describe what this agent does..."
        rows="3"
      />
      
      <Input
        v-model="form.product_context"
        label="Product Context"
        placeholder="e.g., SaaS product support, E-commerce store"
      />
      
      <div class="flex items-center gap-2">
        <input
          v-model="form.active"
          type="checkbox"
          id="agent-active"
          class="rounded"
        />
        <label for="agent-active" class="text-sm">Activate agent immediately</label>
      </div>

      <div class="flex gap-3 pt-4">
        <button
          type="button"
          @click="dialogRef.close()"
          class="flex-1 px-4 py-2 border border-n-weak rounded-lg hover:bg-n-solid-2"
        >
          Cancel
        </button>
        <button
          type="submit"
          class="flex-1 px-4 py-2 bg-woot-500 hover:bg-woot-600 text-white rounded-lg font-medium"
        >
          {{ isEdit ? 'Update' : 'Create' }} Agent
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
