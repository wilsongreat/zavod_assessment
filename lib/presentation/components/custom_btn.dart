import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zavod_assessment_app/utils/app_colors.dart';
import 'package:zavod_assessment_app/utils/screen_utils.dart';



class CustomAppButton extends StatelessWidget {
  final String? title;
  final Color? color;
  final Color? innActiveColor;
  final VoidCallback? voidCallback;
  final bool? isActive;
  final bool? withEmoji;
  final double? radius;
  final double? width;
  final double? height;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? borderColor;

  const CustomAppButton({
    super.key,
    this.title,
    this.color,
    this.innActiveColor,
    this.isActive,
    this.withEmoji,
    this.voidCallback,
    this.radius,
    this.textColor,
    this.width,
    this.fontWeight,
    this.height,
    this.fontSize, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap:  voidCallback ,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        height: height ?? fullHeight(context) * .048,
        width: width ?? double.maxFinite,
        decoration: BoxDecoration(
          color: color ?? AppColors.kbg,

          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
          border: Border.all(color: borderColor ?? AppColors.kTransparent )
        ),
        child: Center(
            child: Text(
              title?? '  ',
              style: GoogleFonts.lato(
                  color: textColor ?? Colors.white,
                  fontWeight: fontWeight ?? FontWeight.w500,
                  fontSize: fontSize ?? 14),
            )),
      ),
    );
  }
}