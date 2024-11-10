import 'package:cashguard/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialButtonIcon extends StatelessWidget {
  const MaterialButtonIcon({
    super.key,
    this.height,
    this.width,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.buttonColor,
    this.highlightColor,
    this.splashColor,
    this.borderRadius,
    required this.onTap,
    this.iconPadding,
    this.withIcon = true,
    this.withText = false,
    this.text,
    this.fontSize,
    this.fontColor,
    this.fontWeight,
    this.buttonPadding,
    this.iconTextDistance,
    this.fontFamily,
    this.isHorizontal = true,
    this.iconIsSVG,
    this.svgIcon,
  });

  final double? height;
  final double? width;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? buttonColor;
  final Color? highlightColor;
  final Color? splashColor;
  final BorderRadius? borderRadius;
  final VoidCallback onTap;
  final EdgeInsets? iconPadding;
  final EdgeInsets? buttonPadding;
  final bool? withIcon;
  final bool? withText;
  final String? text;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final double? iconTextDistance;
  final String? fontFamily;
  final bool? isHorizontal;
  final bool? iconIsSVG;
  final String? svgIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      shadowColor: darkGrey.withOpacity(0.25),
      color: buttonColor ?? primaryColor,
      borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
        onTap: onTap,
        splashColor: splashColor ?? primaryColorLight,
        highlightColor: highlightColor ?? primaryColorDark,
        child: Container(
            height: height,
            width: width,
            padding: buttonPadding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(height ?? 30),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: isHorizontal ?? true
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (withIcon ?? true)
                          Padding(
                            padding: iconPadding ?? EdgeInsets.all(0),
                            child: iconIsSVG ?? false
                                ? Container(
                                    height: iconSize,
                                    width: iconSize,
                                    child: SvgPicture.asset(
                                      svgIcon!,
                                      fit: BoxFit.contain,
                                      colorFilter: ColorFilter.mode(
                                          iconColor ?? pureWhite,
                                          BlendMode.srcIn),
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    size: iconSize ?? 25,
                                    color: iconColor ?? pureWhite,
                                  ),
                          ),
                        if (withText ?? false)
                          Container(
                            padding:
                                EdgeInsets.only(left: iconTextDistance ?? 0),
                            child: Text(
                              text ?? "",
                              style: fontFamily == null
                                  ? GoogleFonts.poppins(
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600)
                                  : TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? pureWhite,
                                      fontWeight:
                                          fontWeight ?? FontWeight.w600),
                            ),
                          )
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (withIcon ?? true)
                          Padding(
                            padding: iconPadding ?? EdgeInsets.all(0),
                            child: iconIsSVG ?? false
                                ? Container(
                                    height: iconSize,
                                    width: iconSize,
                                    child: SvgPicture.asset(
                                      svgIcon!,
                                      fit: BoxFit.contain,
                                      colorFilter: ColorFilter.mode(
                                          iconColor ?? pureWhite,
                                          BlendMode.srcIn),
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    size: iconSize ?? 25,
                                    color: iconColor ?? pureWhite,
                                  ),
                          ),
                        if (withText ?? false)
                          Container(
                            padding:
                                EdgeInsets.only(top: iconTextDistance ?? 0),
                            child: Text(
                              text ?? "",
                              style: fontFamily == null
                                  ? GoogleFonts.poppins(
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? pureWhite,
                                      fontWeight: fontWeight ?? FontWeight.w600)
                                  : TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: fontSize ?? 16,
                                      color: fontColor ?? pureWhite,
                                      fontWeight:
                                          fontWeight ?? FontWeight.w600),
                            ),
                          )
                      ],
                    ),
            )),
      ),
    );
  }
}
