<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import SaturnAPI from 'dashboard/api/saturn';

const { t } = useI18n();

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
});

const isEdit = ref(false);

const industryTypes = [
  { value: 'ecommerce', label: 'E-Ticaret', description: 'Online mağazalar ve e-ticaret platformları' },
  { value: 'hotel', label: 'Otel & Konaklama', description: 'Oteller ve konaklama hizmetleri' },
  { value: 'restaurant', label: 'Restoran & Yemek Servisi', description: 'Restoranlar ve yemek teslimatı' },
  { value: 'healthcare', label: 'Sağlık & Tıp', description: 'Sağlık tesisleri ve tıbbi hizmetler' },
  { value: 'education', label: 'Eğitim & Öğretim', description: 'Eğitim kurumları ve online öğrenme' },
  { value: 'finance', label: 'Finans & Bankacılık', description: 'Finansal hizmetler ve bankacılık' },
  { value: 'real_estate', label: 'Gayrimenkul', description: 'Emlak satış ve kiralamalar' },
  { value: 'retail', label: 'Perakende & Alışveriş', description: 'Perakende mağazalar ve alışveriş merkezleri' },
  { value: 'saas', label: 'SaaS & Teknoloji', description: 'Yazılım ve teknoloji şirketleri' },
  { value: 'automotive', label: 'Otomotiv & Araç Servisi', description: 'Araba bayileri ve otomotiv hizmetleri' },
  { value: 'general', label: 'Genel Müşteri Desteği', description: 'Genel amaçlı müşteri desteği' },
];

const industryTemplates = {
  ecommerce: {
    description: 'Online mağazalar ve e-ticaret platformları için AI asistan',
    product_context: 'E-ticaret müşteri desteği',
    behavior_rules: [
      'Her zaman yardımcı ve ürün odaklı ol',
      'Ürünler, kargo ve iadeler hakkında net bilgi ver',
      'Müşterilere satın alma sürecinde rehberlik et',
      'Sipariş durumu sorgularını profesyonelce ele al',
      'Uygun olduğunda ek satış ve çapraz satış yap',
      'Şikayetleri empati ve çözümlerle karşıla',
    ],
    safety_guidelines: [
      'Asla müşteri ödeme bilgilerini paylaşma',
      'İadeleri doğrudan işleme koyma - insan temsilciye aktar',
      'Hassas hesap değişiklikleri için müşteri kimliğini doğrula',
      'Şirket iade ve geri ödeme politikalarını kesinlikle takip et',
      'Dolandırıcılık veya şüpheli aktiviteyi hemen bildir',
    ],
  },
  hotel: {
    description: 'Oteller ve konaklama hizmetleri için AI konsiyerj',
    product_context: 'Otel misafir hizmetleri',
    behavior_rules: [
      'Misafirleri sıcak ve profesyonel bir şekilde karşıla',
      'Odalar, olanaklar ve hizmetler hakkında bilgi ver',
      'Rezervasyon, check-in ve check-out süreçlerinde yardımcı ol',
      'Yerel cazibe merkezleri ve restoranlar öner',
      'Özel istekleri ve oda servisi siparişlerini ele al',
      'Şikayetlere anında çözümlerle yaklaş',
    ],
    safety_guidelines: [
      'Misafir gizliliğini ve kişisel bilgilerini koru',
      'Oda numaralarını veya misafir detaylarını paylaşma',
      'Acil durumları otel personeliyle hemen paylaş',
      'Oda erişimi veya fatura değişiklikleri için misafir kimliğini doğrula',
      'Otel güvenlik protokollerini takip et',
    ],
  },
  restaurant: {
    description: 'Restoranlar ve yemek teslimatı için AI asistan',
    product_context: 'Restoran müşteri hizmetleri',
    behavior_rules: [
      'Açıklamalarda arkadaş canlısı ve iştah açıcı ol',
      'Menü seçimleri ve önerilerde yardımcı ol',
      'Rezervasyonları ve siparişleri doğru şekilde al',
      'Diyet seçenekleri (vegan, glutensiz vb.) hakkında bilgi ver',
      'Bekleme süreleri ve teslimat tahminlerini sun',
      'Gıda alerjilerini son derece dikkatli ele al',
    ],
    safety_guidelines: [
      'Mutlaka gıda alerjileri ve diyet kısıtlamaları hakkında sor',
      'Emin değilsen asla alerjen içermediğini garanti etme',
      'Gıda güvenliği endişelerini hemen bildir',
      'Teslimat adreslerini ve ödeme yöntemlerini doğrula',
      'Gıda işleme ve hijyen kurallarını takip et',
    ],
  },
  healthcare: {
    description: 'Sağlık tesisleri ve tıbbi hizmetler için AI asistan',
    product_context: 'Sağlık hasta desteği',
    behavior_rules: [
      'Her zaman empatik ve profesyonel ol',
      'Randevu planlaması ve hatırlatmalarda yardımcı ol',
      'Genel sağlık bilgisi ver (teşhis koyma yok)',
      'Hastalara tesis süreçlerinde rehberlik et',
      'Fatura ve sigorta sorgularını ele al',
      'Hasta gizliliğine ve mahremiyetine saygı göster',
    ],
    safety_guidelines: [
      'ASLA tıbbi teşhis veya tedavi önerisi verme',
      'Her zaman sağlık profesyonellerine danışmayı öner',
      'Hasta sağlık bilgilerini koru (KVKK uyumluluğu)',
      'Tıbbi acil durumları hemen bildir',
      'Tıbbi kayıtlara erişme veya paylaşma',
      'Klinik soruları nitelikli personele yönlendir',
    ],
  },
  education: {
    description: 'Eğitim kurumları ve online öğrenme için AI asistan',
    product_context: 'Eğitim destek hizmetleri',
    behavior_rules: [
      'Öğrenmeyi teşvik edici ve destekleyici ol',
      'Kurs kayıt ve kayıt işlemlerinde yardımcı ol',
      'Programlar ve müfredat hakkında bilgi ver',
      'Takvim ve son tarihler hakkındaki soruları yanıtla',
      'Öğrencilere öğrenme kaynaklarında rehberlik et',
      'Hem öğrencileri hem de veli/velileri destekle',
    ],
    safety_guidelines: [
      'Öğrenci gizliliğini ve akademik kayıtları koru',
      'Notları veya performans verilerini paylaşma',
      'Akademik dürüstlük sorunlarını personele aktar',
      'Çocuk koruma ve güvenlik politikalarını takip et',
      'Hassas bilgi erişimi için kimliği doğrula',
    ],
  },
  finance: {
    description: 'Finansal hizmetler ve bankacılık için AI asistan',
    product_context: 'Finansal müşteri desteği',
    behavior_rules: [
      'Profesyonel ve güvenlik odaklı ol',
      'Hesap sorguları ve işlemlerde yardımcı ol',
      'Finansal ürün ve hizmetleri açıkça anlat',
      'Bankacılık süreçleri ve başvurularda rehberlik et',
      'Genel finansal bilgi ver',
      'Şikayetleri öncelik ve özenle ele al',
    ],
    safety_guidelines: [
      'ASLA şifre, PIN veya tam kart numarası isteme',
      'Hesap erişimi için mutlaka müşteri kimliğini doğrula',
      'Dolandırıcılık veya şüpheli aktiviteyi hemen bildir',
      'Yatırım tavsiyesi verme',
      'Finansal düzenlemelere ve uyumluluğa kesinlikle uy',
      'Müşteri finansal verilerini her ne pahasına olursa olsun koru',
    ],
  },
  real_estate: {
    description: 'Emlak satış ve kiralamalar için AI asistan',
    product_context: 'Emlak hizmetleri',
    behavior_rules: [
      'Mülkler ve konumlar hakkında bilgili ol',
      'Mülk aramalarında ve görüntülemelerinde yardımcı ol',
      'Piyasa bilgisi ve fiyatlandırma ver',
      'Alım/kiralama süreçlerinde rehberlik et',
      'Mülk turları ve randevuları planla',
      'Mahalle ve olanaklar hakkındaki soruları yanıtla',
    ],
    safety_guidelines: [
      'Mülk detayları paylaşmadan önce müşteri kimliğini doğrula',
      'Satıcı/ev sahiplerinin kişisel bilgilerini paylaşma',
      'Hukuki soruları nitelikli profesyonellere aktar',
      'Adil konut yasalarına ve düzenlemelerine uy',
      'Hassas finansal ve sözleşme bilgilerini koru',
    ],
  },
  retail: {
    description: 'Perakende mağazalar ve alışveriş merkezleri için AI asistan',
    product_context: 'Perakende müşteri hizmetleri',
    behavior_rules: [
      'Yardımcı ve ürün bilgili ol',
      'Ürün aramalarında ve karşılaştırmalarda yardımcı ol',
      'Mağaza saatleri, konumları ve stoğu sun',
      'İadeler, değişimler ve garantilerde yardımcı ol',
      'Stil tavsiyeleri ve ürün önerileri sun',
      'Sadakat programları ve promosyonları yönet',
    ],
    safety_guidelines: [
      'Müşteri satın alma geçmişini ve tercihlerini koru',
      'Finansal işlemleri doğrudan işleme koyma',
      'Hesap değişiklikleri için kimliği doğrula',
      'Güvenlik veya hırsızlık endişelerini mağaza personeliyle paylaş',
      'İade ve değişim politikalarını kesinlikle takip et',
    ],
  },
  saas: {
    description: 'Yazılım ve teknoloji şirketleri için AI asistan',
    product_context: 'SaaS müşteri desteği',
    behavior_rules: [
      'Açıklamalarda teknik ama ulaşılabilir ol',
      'Kullanıcı katılımı ve özellik benimsenmesinde yardımcı ol',
      'Yaygın teknik sorunları çöz',
      'Entegrasyonlar ve iş akışlarında rehberlik et',
      'Fiyatlandırma ve abonelik seçeneklerini açıkla',
      'Geri bildirim ve özellik isteklerini topla',
    ],
    safety_guidelines: [
      'Asla API anahtarlarını veya kimlik doğrulama tokenlarını paylaşma',
      'Kullanıcı verilerini ve hesap bilgilerini koru',
      'Güvenlik açıklarını hemen bildir',
      'İzin olmadan kullanıcı hesaplarına erişme',
      'Veri gizliliği düzenlemelerini takip et (KVKK, GDPR)',
      'Hassas hesap işlemleri için kimliği doğrula',
    ],
  },
  automotive: {
    description: 'Araba bayileri ve otomotiv hizmetleri için AI asistan',
    product_context: 'Otomotiv müşteri hizmetleri',
    behavior_rules: [
      'Araçlar ve hizmetler hakkında bilgili ol',
      'Araç seçimi ve karşılaştırmalarda yardımcı ol',
      'Test sürüşleri ve servis randevuları planla',
      'Fiyatlandırma ve finansman bilgisi ver',
      'Garantiler ve bakım hakkındaki soruları yanıtla',
      'Satın alma veya kiralama süreçlerinde rehberlik et',
    ],
    safety_guidelines: [
      'Servis kayıtları için müşteri kimliğini doğrula',
      'Önceki sahiplerin bilgilerini paylaşma',
      'Güvenlik geri çağırmalarını hemen bildir',
      'Finansal ve kredi bilgilerini koru',
      'Otomotiv düzenlemelerine ve uyumluluğa uy',
    ],
  },
  general: {
    description: 'Çeşitli sektörler için genel amaçlı AI asistan',
    product_context: 'Genel müşteri desteği',
    behavior_rules: [
      'Yardımsever, profesyonel ve nazik ol',
      'Müşteri ihtiyaçlarını dikkatlice dinle',
      'Net ve doğru bilgi ver',
      'Müşterileri uygun kaynaklara yönlendir',
      'Şikayetleri empati ve çözümlerle ele al',
      'Karmaşık sorunları gerektiğinde aktar',
    ],
    safety_guidelines: [
      'Müşteri gizliliğini ve kişisel verilerini koru',
      'Asla hassas bilgi paylaşma',
      'Hesap erişimi için kimliği doğrula',
      'Güvenlik endişelerini hemen bildir',
      'Şirket politikalarını ve prosedürlerini takip et',
      'AI sınırlamalar hakkında şeffaf ol',
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
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      const response = await SaturnAPI.update(props.selectedAgent.id, { agent: form.value });
      useAlert(t('SATURN.AGENTS.SUCCESS_UPDATE'));
      emit('updated', response.data);
      dialogRef.value.close();
    } else {
      const optimisticAgent = {
        id: `temp-${Date.now()}`,
        name: form.value.name,
        description: form.value.description,
        product_context: form.value.product_context,
        enabled: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        _optimistic: true,
      };
      
      emit('created', optimisticAgent);
      dialogRef.value.close();
      
      const response = await SaturnAPI.create({ agent: form.value });
      useAlert(t('SATURN.AGENTS.SUCCESS_CREATE'));
      emit('updated', response.data);
    }
  } catch (error) {
    const errorMsg = error.response?.data?.error || t('SATURN.AGENTS.ERROR_OPERATION');
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
    :title="isEdit ? $t('SATURN.AGENTS.EDIT_AGENT') : $t('SATURN.AGENTS.CREATE_AGENT')"
    :description="$t('SATURN.AGENTS.CREATE_DESCRIPTION')"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <Input
        v-model="form.name"
        :label="$t('SATURN.AGENTS.AGENT_NAME_LABEL')"
        placeholder="e.g., Customer Support Agent"
        required
      />
      
      <div class="space-y-2">
        <label class="block text-sm font-medium text-n-slate-12">
          {{ $t('SATURN.AGENTS.INDUSTRY_TYPE_LABEL') }}
        </label>
        <select
          v-model="form.industry_type"
          @change="handleIndustryChange"
          class="w-full px-3 py-2 border border-n-weak rounded-lg focus:outline-none focus:ring-2 focus:ring-woot-500"
          :disabled="isEdit"
        >
          <option value="">{{ $t('SATURN.AGENTS.SELECT_INDUSTRY') }}</option>
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
        :label="$t('SATURN.AGENTS.DESCRIPTION_LABEL')"
        :placeholder="$t('SATURN.AGENTS.DESCRIPTION_PLACEHOLDER')"
        rows="3"
      />
      
      <Input
        v-model="form.product_context"
        :label="$t('SATURN.AGENTS.PRODUCT_CONTEXT_LABEL')"
        placeholder="e.g., SaaS product support, E-commerce store"
      />

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
          {{ isEdit ? $t('SATURN.AGENTS.UPDATE_BUTTON') : $t('SATURN.AGENTS.CREATE_BUTTON') }}
        </button>
      </div>
    </form>

    <template #footer />
  </Dialog>
</template>
