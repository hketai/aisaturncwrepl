<script>
import { mapGetters } from 'vuex';
import { useAdmin } from 'dashboard/composables/useAdmin';
import { useAccount } from 'dashboard/composables/useAccount';
import Banner from 'dashboard/components/ui/Banner.vue';

export default {
  components: { Banner },
  setup() {
    const { isAdmin } = useAdmin();
    const { accountId } = useAccount();

    return {
      accountId,
      isAdmin,
    };
  },
  computed: {
    ...mapGetters({
      getAccount: 'accounts/getAccount',
    }),
    currentAccount() {
      return this.getAccount(this.accountId);
    },
    aiConversationLimit() {
      return this.currentAccount?.ai_conversation_limit;
    },
    aiConversationCount() {
      return this.currentAccount?.ai_conversation_count || 0;
    },
    percentageUsed() {
      if (!this.aiConversationLimit) return 0;
      return Math.round((this.aiConversationCount / this.aiConversationLimit) * 100);
    },
    bannerMessage() {
      if (this.isLimitReached) {
        return this.$t('AI_LIMIT.REACHED', {
          limit: this.aiConversationLimit,
        });
      }
      return this.$t('AI_LIMIT.WARNING', {
        count: this.aiConversationCount,
        limit: this.aiConversationLimit,
        percentage: this.percentageUsed,
      });
    },
    isLimitReached() {
      return this.aiConversationLimit && this.aiConversationCount >= this.aiConversationLimit;
    },
    shouldShowWarning() {
      // Show warning when 80% or more of limit is used
      return this.aiConversationLimit && this.percentageUsed >= 80 && !this.isLimitReached;
    },
    shouldShowBanner() {
      if (!this.isAdmin) return false;
      return this.isLimitReached || this.shouldShowWarning;
    },
    colorScheme() {
      return this.isLimitReached ? 'alert' : 'warning';
    },
  },
};
</script>

<template>
  <Banner
    v-if="shouldShowBanner"
    :color-scheme="colorScheme"
    :banner-message="bannerMessage"
  />
</template>
