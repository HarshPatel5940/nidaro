import { View, type ViewProps } from "react-native";
import { useThemeColor } from "@/hooks/useThemeColor";

export type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
};

export function ThemedView({
  style,
  lightColor,
  darkColor,
  ...otherProps
}: ThemedViewProps) {
  const backgroundColor = useThemeColor(
    { light: lightColor, dark: darkColor },
    "background"
  );
  const colorScheme =
    useThemeColor({}, "background") === "#fff" ? "light" : "dark";

  // Ensure sections and cards have proper contrast in dark mode
  const processedStyle =
    colorScheme === "dark" && style
      ? [...(Array.isArray(style) ? style : [style])].map((s) => {
          if (s && typeof s === "object" && "backgroundColor" in s) {
            // Create a new object to avoid modifying the original style
            const newStyle = { ...s };
            // If it has backgroundColor and it's light gray, adjust for dark mode
            if (
              newStyle.backgroundColor &&
              (newStyle.backgroundColor === "#f5f5f5" ||
                newStyle.backgroundColor === "#f0f9ff")
            ) {
              newStyle.backgroundColor = "#2a2a2a";
            }
            return newStyle;
          }
          return s;
        })
      : style;

  return <View style={[{ backgroundColor }, processedStyle]} {...otherProps} />;
}
