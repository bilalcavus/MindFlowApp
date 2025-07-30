# Google Play Billing Kurulum Rehberi

## 1. Google Play Console'da Ürün Tanımlama

### Abonelik Ürünleri
Google Play Console > Uygulamanız > Monetizasyon > Ürünler > Abonelikler

Aşağıdaki ürünleri oluşturun:

#### Premium Abonelik
- **Ürün ID**: `mind_flow_premium`
- **Ad**: `Mind Flow Premium`
- **Açıklama**: `Aylık premium abonelik - sınırsız analiz ve öncelikli destek`
- **Fiyat**: $19.99/ay
- **Abonelik Süresi**: 1 ay
- **Ücretsiz Deneme**: 7 gün (opsiyonel)

### Tek Seferlik Satın Alma Ürünleri
Google Play Console > Uygulamanız > Monetizasyon > Ürünler > Tek Seferlik Satın Alma

#### Kredi Paketleri
- **Ürün ID**: `mind_flow_credits_5`
- **Ad**: `5 Kredi`
- **Açıklama**: `5 analiz kredisi`
- **Fiyat**: $0.99

- **Ürün ID**: `mind_flow_credits_10`
- **Ad**: `10 Kredi`
- **Açıklama**: `10 analiz kredisi`
- **Fiyat**: $1.99

- **Ürün ID**: `mind_flow_credits_20`
- **Ad**: `20 Kredi`
- **Açıklama**: `20 analiz kredisi`
- **Fiyat**: $3.99

## 2. Test Kullanıcıları Ekleme

Google Play Console > Ayarlar > Lisans Testi

Test kullanıcılarınızın Gmail adreslerini ekleyin. Bu kullanıcılar gerçek ödeme yapmadan test edebilir.

## 3. Uygulama İmzalama

Uygulamanızı Google Play Store'a yüklemeden önce:

1. **Release APK/AAB oluşturun**:
   ```bash
   flutter build appbundle --release
   ```

2. **Google Play Console'a yükleyin**:
   - Google Play Console > Uygulamanız > Sürümler
   - Yeni sürüm oluşturun
   - AAB dosyasını yükleyin

## 4. Güvenlik

### Sunucu Tarafı Doğrulama
Gerçek uygulamada, satın alma işlemlerini sunucu tarafında doğrulamanız gerekir:

```dart
// TODO: Implement server-side verification
Future<bool> _verifyPurchaseWithServer(PurchaseDetails purchase) async {
  // Google Play Developer API ile doğrulama
  // https://developer.android.com/google/play/billing/security
  return true;
}
```

### Önerilen Güvenlik Önlemleri:
1. **Purchase Token Doğrulama**: Her satın alma için Google Play'den token doğrulayın
2. **Order ID Kontrolü**: Aynı siparişin tekrar kullanılmasını önleyin
3. **Sunucu Tarafı Kayıt**: Tüm satın almaları sunucunuzda kaydedin

## 5. Test Etme

### Test Ortamında:
1. Test kullanıcısı ile giriş yapın
2. Abonelik satın almayı deneyin
3. Kredi satın almayı deneyin
4. Aboneliği iptal etmeyi deneyin

### Test Senaryoları:
- ✅ Başarılı satın alma
- ✅ Satın alma iptali
- ✅ Ağ hatası durumu
- ✅ Yetersiz bakiye
- ✅ Abonelik yenileme

## 6. Hata Ayıklama

### Yaygın Hatalar:
1. **"Product not found"**: Ürün ID'lerini kontrol edin
2. **"Billing not available"**: Test kullanıcısı olduğunuzdan emin olun
3. **"Purchase failed"**: Google Play hesabınızı kontrol edin

### Debug Logları:
```dart
// Debug modunda detaylı loglar
if (kDebugMode) {
  print('Purchase status: ${purchaseDetails.status}');
  print('Product ID: ${purchaseDetails.productID}');
  print('Purchase ID: ${purchaseDetails.purchaseID}');
}
```

## 7. Canlıya Alma

1. **Test kullanıcılarından çıkarın**
2. **Ürünleri aktif hale getirin**
3. **Uygulamayı production'a yükleyin**
4. **İlk gerçek satın almaları izleyin**

## 8. İzleme ve Analitik

### Firebase Analytics ile:
- Satın alma olaylarını izleyin
- Dönüşüm oranlarını takip edin
- Kullanıcı davranışlarını analiz edin

### Google Play Console ile:
- Gelir raporlarını inceleyin
- Abonelik metriklerini takip edin
- İptal oranlarını izleyin

## 9. Destek

Sorun yaşarsanız:
1. Google Play Console dokümantasyonu
2. Flutter in_app_purchase paketi dokümantasyonu
3. Google Play Developer API dokümantasyonu

## 10. Yasal Uyarılar

- Google Play politikalarına uyun
- Kullanıcı verilerini koruyun
- Abonelik iptal süreçlerini netleştirin
- Fiyatlandırma şeffaflığını sağlayın 