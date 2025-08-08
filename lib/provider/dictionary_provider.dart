import 'package:flutter/material.dart';

class DictionaryProvider extends ChangeNotifier {
  // Basic Arabic words dictionary for validation
  static final Set<String> _arabicWords = {
    ...<String>[
    // Common Arabic words
    'كتاب', 'بيت', 'مدرسة', 'طالب', 'معلم', 'درس', 'قلم', 'ورقة', 'باب', 'نافذة',
    'طاولة', 'كرسي', 'سيارة', 'طريق', 'شارع', 'مدينة', 'قرية', 'بلد', 'عالم', 'سماء',
    'أرض', 'بحر', 'نهر', 'جبل', 'شجرة', 'زهرة', 'حديقة', 'حيوان', 'طائر', 'سمك',
    'إنسان', 'رجل', 'امرأة', 'طفل', 'أب', 'أم', 'أخ', 'أخت', 'عائلة', 'صديق',
    'طعام', 'ماء', 'خبز', 'لحم', 'فاكهة', 'خضار', 'حليب', 'شاي', 'قهوة', 'عصير',
    'يوم', 'ليلة', 'صباح', 'مساء', 'ساعة', 'دقيقة', 'ثانية', 'أسبوع', 'شهر', 'سنة',
    'لون', 'أحمر', 'أزرق', 'أخضر', 'أصفر', 'أبيض', 'أسود', 'بني', 'رمادي', 'وردي',
    'كبير', 'صغير', 'طويل', 'قصير', 'عريض', 'ضيق', 'سميك', 'رفيع', 'ثقيل', 'خفيف',
    'جميل', 'قبيح', 'جديد', 'قديم', 'نظيف', 'وسخ', 'ساخن', 'بارد', 'حار', 'دافئ',
    'سعيد', 'حزين', 'غاضب', 'خائف', 'متعب', 'نشيط', 'مريض', 'صحي', 'قوي', 'ضعيف',
    // Two letter words
    'في', 'من', 'إلى', 'على', 'عن', 'مع', 'بل', 'لا', 'نعم', 'هو', 'هي', 'أن',
    'ما', 'لم', 'لن', 'قد', 'كل', 'بعض', 'غير', 'سوى', 'حتى', 'لكن', 'أو', 'أم',
    // Three letter words
    'كان', 'صار', 'بات', 'ظل', 'مازال', 'ليس', 'عسى', 'كاد', 'أوشك', 'طفق', 'جعل',
    'ترك', 'وضع', 'أخذ', 'أعطى', 'قال', 'سمع', 'رأى', 'علم', 'فهم', 'حفظ', 'نسي',
    'ذهب', 'جاء', 'وصل', 'خرج', 'دخل', 'نزل', 'صعد', 'جلس', 'وقف', 'نام', 'استيقظ',
    'أكل', 'شرب', 'طبخ', 'غسل', 'لبس', 'خلع', 'فتح', 'أغلق', 'كتب', 'قرأ', 'رسم',
    'لعب', 'ركض', 'مشى', 'قفز', 'سبح', 'طار', 'غنى', 'رقص', 'ضحك', 'بكى', 'صرخ',
    // Four letter words and more
    'مرحبا', 'شكرا', 'عفوا', 'آسف', 'وداعا', 'صباح', 'مساء', 'نهار', 'فجر',
    'ظهر', 'عصر', 'مغرب', 'عشاء', 'فطار', 'غداء', 'وجبة', 'طبق', 'كوب',
    'ملعقة', 'شوكة', 'سكين', 'صحن', 'إناء', 'قدر', 'مقلاة', 'فرن', 'ثلاجة', 'موقد',
    ]
  };  
  /// Validates if a word exists in the Arabic dictionary
  bool isValidWord(String word) {
    if (word.length < 2) return false;
    
    // Remove diacritics and normalize the word
    final normalizedWord = _normalizeArabicWord(word);
    
    return _arabicWords.contains(normalizedWord);
  }
  
  /// Validates multiple words
  List<String> getInvalidWords(List<String> words) {
    return words.where((word) => !isValidWord(word)).toList();
  }
  
  /// Normalizes Arabic word by removing diacritics and extra characters
  String _normalizeArabicWord(String word) {
    // Remove common diacritics
    String normalized = word
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '') // Remove diacritics
        .replaceAll('أ', 'ا') // Normalize alif
        .replaceAll('إ', 'ا') // Normalize alif
        .replaceAll('آ', 'ا') // Normalize alif
        .replaceAll('ة', 'ه') // Normalize taa marbouta
        .trim();
    
    return normalized;
  }
  
  /// Gets word suggestions based on partial input
  List<String> getSuggestions(String partial) {
    if (partial.length < 2) return [];
    
    final normalizedPartial = _normalizeArabicWord(partial);
    
    return _arabicWords
        .where((word) => word.startsWith(normalizedPartial))
        .take(10)
        .toList();
  }
  
  /// Gets the total number of words in the dictionary
  int get wordCount => _arabicWords.length;
  
  /// Checks if the dictionary contains a specific word
  bool containsWord(String word) {
    return _arabicWords.contains(_normalizeArabicWord(word));
  }
}
