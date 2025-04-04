import { Text, type TextProps, StyleSheet } from "react-native";

import { useThemeColor } from "@/hooks/useThemeColor";

export type ThemedTextProps = TextProps & {
  lightColor?: string;
  darkColor?: string;
  type?: "default" | "title" | "defaultSemiBold" | "subtitle" | "link";
};

export function ThemedText({
  style,
  lightColor,
  darkColor,
  type = "default",
  ...rest
}: ThemedTextProps) {
  const color = useThemeColor({ light: lightColor, dark: darkColor }, "text");
  const colorScheme =
    useThemeColor({}, "background") === "#fff" ? "light" : "dark";

  // Process specific style to ensure readability in dark mode
  const processedStyle = style
    ? [...(Array.isArray(style) ? style : [style])].map((s) => {
        if (s && typeof s === "object" && "color" in s) {
          const newStyle = { ...s };
          // If it's dark mode and the text color is a grayish tone, make it lighter
          if (colorScheme === "dark" && newStyle.color) {
            if (
              newStyle.color === "#666" ||
              newStyle.color === "#687076" ||
              newStyle.color === "#9ca3af"
            ) {
              newStyle.color = "#b0b0b0";
            }
          }
          return newStyle;
        }
        return s;
      })
    : style;

  return (
    <Text
      style={[
        { color },
        type === "default" ? styles.default : undefined,
        type === "title" ? styles.title : undefined,
        type === "defaultSemiBold" ? styles.defaultSemiBold : undefined,
        type === "subtitle" ? styles.subtitle : undefined,
        type === "link" ? styles.link : undefined,
        processedStyle,
      ]}
      {...rest}
    />
  );
}

const styles = StyleSheet.create({
  default: {
    fontSize: 16,
    lineHeight: 24,
  },
  defaultSemiBold: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: "600",
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    lineHeight: 32,
  },
  subtitle: {
    fontSize: 20,
    fontWeight: "bold",
  },
  link: {
    lineHeight: 30,
    fontSize: 16,
    color: "#0a7ea4",
  },
});
