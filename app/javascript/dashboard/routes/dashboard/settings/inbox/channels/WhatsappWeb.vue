<script setup>
import { ref, computed, onUnmounted } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useVuelidate } from '@vuelidate/core';
import { required, helpers } from '@vuelidate/validators';
import { isPhoneE164OrEmpty } from 'shared/helpers/Validators';
import NextButton from 'dashboard/components-next/button/Button.vue';
import ChannelsAPI from 'dashboard/api/channels';

const store = useStore();
const router = useRouter();
const { t } = useI18n();

const inboxName = ref('');
const phoneNumber = ref('');
const qrCode = ref('');
const connectionStatus = ref('idle');
const channelId = ref(null);
const isConnecting = ref(false);
const pollingInterval = ref(null);

const rules = {
  inboxName: { required: helpers.withMessage(t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.ERROR'), required) },
  phoneNumber: { 
    required: helpers.withMessage(t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.ERROR'), required),
    isPhoneE164OrEmpty 
  },
};

const v$ = useVuelidate(rules, { inboxName, phoneNumber });

const uiFlags = computed(() => store.getters['inboxes/getUIFlags']);
const accountId = computed(() => store.getters.getCurrentAccountId);

const showQRCode = computed(() => qrCode.value && connectionStatus.value === 'connecting');
const isConnected = computed(() => connectionStatus.value === 'connected');

const createChannelAndConnect = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;

  try {
    isConnecting.value = true;
    
    const whatsappChannel = await store.dispatch('inboxes/createChannel', {
      name: inboxName.value,
      channel: {
        type: 'whatsapp',
        phone_number: phoneNumber.value,
        provider: 'whatsapp_web',
        provider_config: {},
      },
    });

    channelId.value = whatsappChannel.id;
    
    await connectToWhatsApp(whatsappChannel.id);
    
    startQRPolling(whatsappChannel.id);
  } catch (error) {
    useAlert(error.message || t('INBOX_MGMT.ADD.WHATSAPP.API.ERROR_MESSAGE'));
    isConnecting.value = false;
  }
};

const connectToWhatsApp = async (channelId) => {
  try {
    const { data } = await ChannelsAPI.whatsappWebConnect(accountId.value, channelId);
    connectionStatus.value = data.status || 'connecting';
    if (data.qr_code) {
      qrCode.value = data.qr_code;
    }
  } catch (error) {
    useAlert(t('INBOX_MGMT.ADD.WHATSAPP_WEB.CONNECTION_ERROR'));
    throw error;
  }
};

const startQRPolling = (channelId) => {
  pollingInterval.value = setInterval(async () => {
    try {
      const { data: qrData } = await ChannelsAPI.whatsappWebQRCode(accountId.value, channelId);
      
      if (qrData.qr_code && qrData.qr_code !== qrCode.value) {
        qrCode.value = qrData.qr_code;
      }
      
      const { data: statusData } = await ChannelsAPI.whatsappWebStatus(accountId.value, channelId);
      
      if (statusData.connected && statusData.authenticated) {
        connectionStatus.value = 'connected';
        stopPolling();
        
        router.replace({
          name: 'settings_inboxes_add_agents',
          params: {
            page: 'new',
            inbox_id: channelId,
          },
        });
      }
    } catch (error) {
      console.error('QR polling error:', error);
    }
  }, 3000);
};

const stopPolling = () => {
  if (pollingInterval.value) {
    clearInterval(pollingInterval.value);
    pollingInterval.value = null;
  }
};

onUnmounted(() => {
  stopPolling();
});
</script>

<template>
  <form class="flex flex-wrap flex-col mx-0" @submit.prevent="createChannelAndConnect()">
    <div class="mb-4">
      <p class="text-sm text-slate-11 mb-4">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.DESCRIPTION') }}
      </p>
    </div>

    <div class="flex-shrink-0 flex-grow-0">
      <label :class="{ error: v$.inboxName.$error }">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.LABEL') }}
        <input
          v-model="inboxName"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.PLACEHOLDER')"
          :disabled="isConnecting || isConnected"
          @blur="v$.inboxName.$touch"
        />
        <span v-if="v$.inboxName.$error" class="message">
          {{ v$.inboxName.$errors[0].$message }}
        </span>
      </label>
    </div>

    <div class="flex-shrink-0 flex-grow-0">
      <label :class="{ error: v$.phoneNumber.$error }">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.LABEL') }}
        <input
          v-model="phoneNumber"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.PLACEHOLDER')"
          :disabled="isConnecting || isConnected"
          @blur="v$.phoneNumber.$touch"
        />
        <span v-if="v$.phoneNumber.$error" class="message">
          {{ v$.phoneNumber.$errors[0].$message }}
        </span>
      </label>
    </div>

    <div v-if="showQRCode" class="mt-6 p-4 border border-n-weak rounded-lg bg-n-1">
      <p class="text-sm text-slate-11 mb-3">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.QR_INSTRUCTIONS') }}
      </p>
      <div class="flex justify-center">
        <img :src="qrCode" alt="WhatsApp QR Code" class="w-64 h-64" />
      </div>
    </div>

    <div v-if="isConnected" class="mt-4 p-3 bg-green-50 border border-green-200 rounded-lg">
      <p class="text-sm text-green-800">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.CONNECTED') }}
      </p>
    </div>

    <div class="flex gap-2 items-center py-2 mt-4">
      <NextButton
        :disabled="uiFlags.isCreating || isConnected"
        :loading="uiFlags.isCreating || isConnecting"
        type="submit"
      >
        {{ isConnecting ? $t('INBOX_MGMT.ADD.WHATSAPP_WEB.CONNECTING') : $t('INBOX_MGMT.ADD.WHATSAPP_WEB.SUBMIT') }}
      </NextButton>
    </div>
  </form>
</template>
