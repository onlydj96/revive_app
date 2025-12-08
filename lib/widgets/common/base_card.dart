import 'package:flutter/material.dart';

/// 앱 전체에서 일관된 카드 스타일을 제공하는 기본 카드 위젯
///
/// 모든 카드 위젯은 이 BaseCard를 사용하여 일관성을 유지합니다.
class BaseCard extends StatelessWidget {
  /// 카드 내부 콘텐츠
  final Widget child;

  /// 카드 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 카드의 elevation (그림자 높이)
  /// 기본값: 2.0
  final double elevation;

  /// 카드의 모서리 둥글기 반지름
  /// 기본값: 12.0
  final double borderRadius;

  /// 카드의 패딩
  /// 기본값: EdgeInsets.zero (패딩 없음)
  final EdgeInsets padding;

  /// 카드의 마진
  /// 기본값: EdgeInsets.zero (마진 없음)
  final EdgeInsets margin;

  /// 카드의 배경색 (null이면 테마 기본값 사용)
  final Color? backgroundColor;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        shadowColor: Colors.grey.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              )
            : Padding(
                padding: padding,
                child: child,
              ),
      ),
    );
  }
}

/// 이미지 헤더가 있는 카드를 위한 BaseCard 변형
class ImageHeaderCard extends StatelessWidget {
  /// 카드 헤더 이미지 위젯
  final Widget headerImage;

  /// 카드 바디 콘텐츠
  final Widget body;

  /// 카드 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 카드의 elevation
  final double elevation;

  /// 카드의 모서리 둥글기 반지름
  final double borderRadius;

  /// 헤더 이미지의 높이
  final double headerHeight;

  /// 바디의 패딩
  final EdgeInsets bodyPadding;

  const ImageHeaderCard({
    super.key,
    required this.headerImage,
    required this.body,
    this.onTap,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.headerHeight = 140.0,
    this.bodyPadding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            child: SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: headerImage,
            ),
          ),
          Padding(
            padding: bodyPadding,
            child: body,
          ),
        ],
      ),
    );
  }
}
