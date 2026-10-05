import 'package:flutter/material.dart';
import '../../data/mock_store.dart';
import '../../models/promotion.dart';
import '../../models/venue.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';

/// Màn hình đặt sân (BookingScreen) - phong cách ALOBO.
/// Thiết kế hiện đại, bố cục rõ ràng với các thẻ thông tin bo tròn và thanh CTA cố định.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _date = DateTime.now();
  String? _time;
  final Set<String> _selectedServices = {};
  final _promoController = TextEditingController();
  String? _promoMessage;
  double _discount = 0;

  final _times = const [
    '08:00',
    '09:00',
    '10:00',
    '14:00',
    '15:00',
    '16:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _discount = 0;
        _promoMessage = 'Vui lòng nhập mã khuyến mãi.';
      });
      return;
    }

    Promotion? promo;
    for (final item in MockStore.promotions) {
      if (item.code == code &&
          item.isActive &&
          item.expiryDate.isAfter(DateTime.now())) {
        promo = item;
        break;
      }
    }
    setState(() {
      if (promo == null) {
        _discount = 0;
        _promoMessage = 'Mã không hợp lệ hoặc đã hết hạn.';
      } else {
        _discount = promo.discountPercent;
        _promoMessage =
            'Đã áp dụng giảm ${promo.discountPercent.toStringAsFixed(0)}%.';
      }
    });
  }

  String _formatDateDisplay(DateTime d) {
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    final weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final dayLabel = isToday ? 'Hôm nay' : weekdays[d.weekday - 1];
    return '$dayLabel, ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'bóng đá':
        return Icons.sports_soccer_rounded;
      case 'cầu lông':
        return Icons.sports_tennis_rounded;
      case 'tennis':
        return Icons.sports_tennis_outlined;
      case 'bóng rổ':
        return Icons.sports_basketball_rounded;
      case 'bóng chuyền':
        return Icons.sports_volleyball_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Venue venue = args is Venue
        ? args
        : (MockStore.venues.isNotEmpty
            ? MockStore.venues.first
            : Venue.mockList().first);

    final services = MockStore.servicesFor(venue.id);
    final serviceTotal = services
        .where((s) => _selectedServices.contains(s.id))
        .fold<double>(0, (sum, s) => sum + s.price);
    final subtotal = venue.pricePerHour + serviceTotal;
    final total = subtotal * (1 - _discount / 100);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Đặt sân'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // ─── 1. Thông tin sân ──────────────────────────────────
          _buildVenueInfoCard(venue),
          const SizedBox(height: 16),

          // ─── 2. Chọn ngày đặt sân ──────────────────────────────
          _buildSectionHeader(Icons.calendar_today_rounded, 'Ngày đặt sân'),
          const SizedBox(height: 8),
          _buildDateSelectionCard(context),
          const SizedBox(height: 16),

          // ─── 3. Chọn khung giờ ─────────────────────────────────
          _buildSectionHeader(Icons.access_time_rounded, 'Khung giờ đặt'),
          const SizedBox(height: 8),
          _buildTimeSlotsCard(),
          const SizedBox(height: 16),

          // ─── 4. Dịch vụ kèm theo ───────────────────────────────
          _buildSectionHeader(
              Icons.room_service_outlined, 'Dịch vụ kèm theo (tùy chọn)'),
          const SizedBox(height: 8),
          _buildServicesCard(services),
          const SizedBox(height: 16),

          // ─── 5. Mã khuyến mãi ──────────────────────────────────
          _buildSectionHeader(
              Icons.local_offer_outlined, 'Mã khuyến mãi'),
          const SizedBox(height: 8),
          _buildPromoCodeCard(),
          const SizedBox(height: 16),

          // ─── 6. Bảng chi tiết thanh toán ───────────────────────
          _buildPriceSummaryCard(venue, serviceTotal, subtotal, total),
          const SizedBox(height: 20),
        ],
      ),

      // ─── 7. Nút Tiếp tục (Sticky CTA) ───────────────────────────
      bottomNavigationBar:
          _buildStickyBottomCTA(context, venue, serviceTotal, subtotal, total),
    );
  }

  // 1. Thẻ thông tin sân
  Widget _buildVenueInfoCard(Venue venue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSportIcon(venue.sportType),
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppTheme.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    venue.sportType,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${venue.pricePerHour.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text: ' / giờ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Thẻ chọn ngày
  Widget _buildDateSelectionCard(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            initialDate: _date,
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateDisplay(_date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Nhấn để chọn ngày khác',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Thẻ chọn khung giờ
  Widget _buildTimeSlotsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _times.map((time) {
                final isSelected = _time == time;
                return InkWell(
                  onTap: () => setState(() => _time = time),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.access_time_rounded,
                          size: 14,
                          color:
                              isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_time == null) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppTheme.warning),
                  SizedBox(width: 4),
                  Text(
                    'Vui lòng chọn 1 khung giờ phù hợp để tiếp tục',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 4. Thẻ dịch vụ kèm theo
  Widget _buildServicesCard(List services) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: services.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Sân hiện chưa cung cấp dịch vụ phụ trợ.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              )
            : Column(
                children: services.map((service) {
                  final isChecked = _selectedServices.contains(service.id);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppTheme.primaryLight.withValues(alpha: 0.35)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isChecked ? AppTheme.primary : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      activeColor: AppTheme.primary,
                      title: Text(
                        service.name,
                        style: TextStyle(
                          fontWeight:
                              isChecked ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${service.price.toStringAsFixed(0)} đ / ${service.unit}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: isChecked,
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _selectedServices.add(service.id);
                        } else {
                          _selectedServices.remove(service.id);
                        }
                      }),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  // 5. Thẻ mã khuyến mãi
  Widget _buildPromoCodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: SAN10',
                      prefixIcon: Icon(
                        Icons.discount_outlined,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(90, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: _applyPromo,
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
            if (_promoMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(
                      _discount > 0
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 16,
                      color: _discount > 0 ? AppTheme.primary : AppTheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _promoMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _discount > 0
                              ? AppTheme.primary
                              : AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 6. Thẻ chi tiết thanh toán
  Widget _buildPriceSummaryCard(
    Venue venue,
    double serviceTotal,
    double subtotal,
    double total,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết thanh toán',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            const Divider(height: 20, color: AppTheme.border),
            _summaryRow('Tiền thuê sân', venue.pricePerHour),
            if (serviceTotal > 0) ...[
              const SizedBox(height: 8),
              _summaryRow('Dịch vụ phụ trợ', serviceTotal),
            ],
            if (_discount > 0) ...[
              const SizedBox(height: 8),
              _summaryRow(
                'Giảm giá (${_discount.toStringAsFixed(0)}%)',
                -subtotal * _discount / 100,
                valueColor: AppTheme.primary,
              ),
            ],
            const Divider(height: 22, color: AppTheme.border),
            _summaryRow(
              'Tổng cộng',
              total,
              bold: true,
              valueColor: AppTheme.primary,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 7. Thanh CTA Tiếp tục cố định ở đáy
  Widget _buildStickyBottomCTA(
    BuildContext context,
    Venue venue,
    double serviceTotal,
    double subtotal,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${total.toStringAsFixed(0)} đ',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: ElevatedButton(
                onPressed: _time == null
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookingConfirmation,
                          arguments: {
                            'venue': venue,
                            'date': _date,
                            'time': _time,
                            'serviceIds': _selectedServices.toList(),
                            'courtPrice': venue.pricePerHour,
                            'serviceTotal': serviceTotal,
                            'discount': _discount,
                            'discountAmount': subtotal * _discount / 100,
                            'subtotal': subtotal,
                            'total': total,
                            'promoCode': _promoController.text
                                    .trim()
                                    .toUpperCase()
                                    .isEmpty
                                ? null
                                : _promoController.text.trim().toUpperCase(),
                          },
                        ),
                child: Text(
                  _time == null ? 'Chọn giờ để tiếp tục' : 'Tiếp tục',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool bold = false,
    Color? valueColor,
    double fontSize = 14,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: fontSize,
      color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
    );
    final valStyle = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
      fontSize: fontSize,
      color: valueColor ?? AppTheme.textPrimary,
    );

    final formattedAmount = amount < 0
        ? '-${(-amount).toStringAsFixed(0)} đ'
        : '${amount.toStringAsFixed(0)} đ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(formattedAmount, style: valStyle),
      ],
    );
  }
}
