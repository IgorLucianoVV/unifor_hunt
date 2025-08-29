import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onTap;

  const MissionCardWidget({
    Key? key,
    required this.mission,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = (mission['status'] as String?) ?? 'locked';
    final bool isLocked = status == 'locked';
    final bool isActive = status == 'active';
    final bool isCompleted = status == 'completed';
    final int completedClues = (mission['completedClues'] as int?) ?? 0;
    final int totalClues = (mission['totalClues'] as int?) ?? 1;
    final double progress = totalClues > 0 ? completedClues / totalClues : 0.0;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [
                    AppTheme.primaryDark.withValues(alpha: 0.2),
                    AppTheme.primaryVariantDark.withValues(alpha: 0.1),
                  ]
                : isCompleted
                    ? [
                        AppTheme.secondaryDark.withValues(alpha: 0.2),
                        AppTheme.secondaryDark.withValues(alpha: 0.1),
                      ]
                    : [
                        AppTheme.surfaceDark.withValues(alpha: 0.8),
                        AppTheme.surfaceDark.withValues(alpha: 0.6),
                      ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryDark
                : isCompleted
                    ? AppTheme.secondaryDark
                    : AppTheme.dividerDark.withValues(alpha: 0.3),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                blurRadius: 12.0,
                spreadRadius: 2.0,
                offset: Offset.zero,
              ),
            BoxShadow(
              color: AppTheme.shadowDark,
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (mission['title'] as String?) ?? 'Missão Sem Nome',
                          style:
                              AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color: isLocked
                                ? AppTheme.textMediumEmphasis
                                : AppTheme.textHighEmphasis,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          (mission['description'] as String?) ??
                              'Descrição não disponível',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: isLocked
                                ? AppTheme.textDisabled
                                : AppTheme.textMediumEmphasis,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  _buildStatusBadge(status),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.secondaryVariantDark,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Dificuldade: ${_getDifficultyText((mission['difficulty'] as String?) ?? 'medium')}',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasis,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'monetization_on',
                    color: AppTheme.secondaryVariantDark,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${(mission['points'] as int?) ?? 0} pts',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryVariantDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isCompleted) ...[
                SizedBox(height: 2.h),
                _buildProgressBar(progress, completedClues, totalClues),
              ],
              if (isActive) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryDark,
                        AppTheme.primaryVariantDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'play_arrow',
                        color: AppTheme.onPrimaryDark,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Continuar Missão',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.onPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isLocked) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: AppTheme.dividerDark.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'lock',
                        color: AppTheme.textDisabled,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        (mission['unlockRequirement'] as String?) ??
                            'Complete missões anteriores',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDisabled,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (status) {
      case 'active':
        badgeColor = AppTheme.primaryDark;
        badgeText = 'ATIVA';
        badgeIcon = Icons.play_circle_filled;
        break;
      case 'completed':
        badgeColor = AppTheme.secondaryDark;
        badgeText = 'CONCLUÍDA';
        badgeIcon = Icons.check_circle;
        break;
      case 'locked':
      default:
        badgeColor = AppTheme.textMediumEmphasis;
        badgeText = 'BLOQUEADA';
        badgeIcon = Icons.lock;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: badgeColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            color: badgeColor,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            badgeText,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, int completed, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso das Pistas',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
            Text(
              '$completed/$total',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 0.8.h,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryDark),
            ),
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Médio';
      case 'hard':
        return 'Difícil';
      default:
        return 'Médio';
    }
  }
}
