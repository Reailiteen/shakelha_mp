import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  static const routeName = '/shop';
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _category(
            context,
            icon: Icons.auto_fix_high,
            title: 'متجر القدرات',
            description: 'اشترِ قدرات خاصة لتعزيز أسلوب لعبك',
            color: const Color(0xFF26A69A),
            items: [
              _item(context, 'قوة الكلمات', 'مضاعف نقاط +50%', '100', Icons.monetization_on),
              _item(context, 'رؤية المساعد', 'اكتشف أفضل كلمة ممكنة', '150', Icons.monetization_on),
              _item(context, 'تبديل الأحرف', 'استبدال حرفين مجاناً', '75', Icons.monetization_on),
              _item(context, 'وقت إضافي', '+30 ثانية لكل جولة', '50', Icons.monetization_on),
            ],
          ),
          const SizedBox(height: 18),
          _category(
            context,
            icon: Icons.pets,
            title: 'معرض التمائم',
            description: 'اجمع تمائم جميلة تمثل ثقافة الخليج',
            color: const Color(0xFFFFD54F),
            items: [
              _item(context, 'صقر الصحراء', 'تميمة نادرة من التراث العربي', '25', Icons.diamond),
              _item(context, 'جمل البدو', 'رفيق الرحلات الصحراوية', '30', Icons.diamond),
              _item(context, 'لؤلؤة الخليج', 'كنز من أعماق البحار', '40', Icons.diamond),
              _item(context, 'نخلة الواحة', 'رمز الحياة في الصحراء', '20', Icons.diamond),
            ],
          ),
          const SizedBox(height: 18),
          _category(
            context,
            icon: Icons.palette,
            title: 'الديكورات والثيمات',
            description: 'خصص مظهر اللعبة بألوان وديكورات خليجية',
            color: const Color(0xFF8D6E63),
            items: [
              _item(context, 'ثيم القصر الذهبي', 'لوحة ألوان فاخرة ذهبية', '200', Icons.monetization_on),
              _item(context, 'ثيم البحر الفيروزي', 'ألوان البحر الخليجي', '150', Icons.monetization_on),
              _item(context, 'ثيم الصحراء', 'ألوان الغروب الصحراوي', '175', Icons.monetization_on),
              _item(context, 'إطار اللؤلؤ', 'إطار لوحة مرصع باللؤلؤ', '100', Icons.monetization_on),
            ],
          ),
          const SizedBox(height: 18),
          _category(
            context,
            icon: Icons.account_balance_wallet,
            title: 'حزم العملات',
            description: 'احصل على المزيد من الذهب والجواهر',
            color: const Color(0xFF19B6A6),
            items: [
              _item(context, 'حزمة المبتدئ', '1,000 ذهب + 10 جواهر', '0.99', Icons.attach_money),
              _item(context, 'حزمة المتقدم', '5,000 ذهب + 50 جواهر', '4.99', Icons.attach_money),
              _item(context, 'حزمة الخبير', '15,000 ذهب + 150 جواهر', '12.99', Icons.attach_money),
              _item(context, 'حزمة الأسطورة', '50,000 ذهب + 500 جواهر', '29.99', Icons.attach_money),
            ],
          ),
        ],
      ),
    );
  }

  Widget _category(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<Widget> items,
  }) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
    final descStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    const SizedBox(height: 2),
                    Text(description, style: descStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, String description, String price, IconData currencyIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19B6A6).withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showPurchaseDialog(title, price),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF19B6A6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF19B6A6).withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(currencyIcon, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    price,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(String item, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF2B4E6E),
        title: Text('تأكيد الشراء', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        content: Text('هل تريد شراء "$item" مقابل $price؟', 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19B6A6).withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPurchaseSuccessDialog(item);
              },
              child: const Text('شراء', style: TextStyle(color: Color(0xFF19B6A6))),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessDialog(String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF2B4E6E),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 8),
            const Text('تم الشراء!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text('تم شراء "$item" بنجاح! يمكنك الآن استخدامه في اللعبة.', 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19B6A6).withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('رائع!', style: TextStyle(color: Color(0xFF19B6A6))),
            ),
          ),
        ],
      ),
    );
  }
}
