import React, { useState, useEffect } from "react";
import {
  StyleSheet,
  View,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from "react-native";
import { Stack, useLocalSearchParams, router } from "expo-router";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { useAuth } from "@/contexts/AuthContext";

export default function OTPVerificationScreen() {
  const { phoneNumber } = useLocalSearchParams<{ phoneNumber: string }>();
  const [otp, setOtp] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [countdown, setCountdown] = useState(30);
  const { verifyOTP, sendOTP } = useAuth();

  useEffect(() => {
    // Countdown timer for resend OTP
    if (countdown <= 0) return;

    const timer = setTimeout(() => {
      setCountdown(countdown - 1);
    }, 1000);

    return () => clearTimeout(timer);
  }, [countdown]);

  const handleVerifyOTP = async () => {
    if (!otp || otp.length !== 6) {
      setError("Please enter a valid 6-digit OTP");
      return;
    }

    setError("");
    setIsLoading(true);

    try {
      const success = await verifyOTP(phoneNumber || "", otp);
      if (success) {
        // Fix the navigation path to the tabs
        router.replace("/(tabs)");
      } else {
        setError("Invalid OTP. Please try again.");
      }
    } catch (error) {
      setError("An error occurred. Please try again.");
      console.error("Verify OTP error:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendOTP = async () => {
    setError("");
    try {
      await sendOTP(phoneNumber || "");
      setCountdown(30);
    } catch (error) {
      setError("Failed to resend OTP. Please try again.");
      console.error("Resend OTP error:", error);
    }
  };

  return (
    <ThemedView style={styles.container}>
      <Stack.Screen options={{ title: "Verify OTP" }} />

      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={styles.keyboardAvoidingView}
      >
        <View style={styles.contentContainer}>
          <ThemedText type="title" style={styles.title}>
            Verify Your Number
          </ThemedText>
          <ThemedText style={styles.subtitle}>
            We've sent a 6-digit verification code to {phoneNumber}
          </ThemedText>

          <View style={styles.formContainer}>
            <ThemedText style={styles.label}>Enter OTP</ThemedText>
            <TextInput
              style={styles.input}
              placeholder="6-digit code"
              value={otp}
              onChangeText={setOtp}
              keyboardType="number-pad"
              maxLength={6}
              autoFocus
            />

            {error ? (
              <ThemedText style={styles.errorText}>{error}</ThemedText>
            ) : null}

            <TouchableOpacity
              style={styles.button}
              onPress={handleVerifyOTP}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <ThemedText style={styles.buttonText}>
                  Verify & Continue
                </ThemedText>
              )}
            </TouchableOpacity>

            <View style={styles.resendContainer}>
              {countdown > 0 ? (
                <ThemedText style={styles.countdownText}>
                  Resend code in {countdown}s
                </ThemedText>
              ) : (
                <TouchableOpacity onPress={handleResendOTP}>
                  <ThemedText style={styles.resendText}>Resend OTP</ThemedText>
                </TouchableOpacity>
              )}
            </View>
          </View>
        </View>
      </KeyboardAvoidingView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  contentContainer: {
    flex: 1,
    padding: 20,
    justifyContent: "center",
  },
  title: {
    marginBottom: 10,
    textAlign: "center",
  },
  subtitle: {
    fontSize: 16,
    textAlign: "center",
    marginBottom: 50,
  },
  formContainer: {
    width: "100%",
  },
  label: {
    marginBottom: 8,
  },
  input: {
    height: 50,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 8,
    paddingHorizontal: 15,
    fontSize: 18,
    marginBottom: 20,
    textAlign: "center",
    letterSpacing: 8,
  },
  button: {
    height: 50,
    backgroundColor: "#0a7ea4",
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  errorText: {
    color: "red",
    marginBottom: 15,
  },
  resendContainer: {
    marginTop: 20,
    alignItems: "center",
  },
  countdownText: {
    color: "#666",
  },
  resendText: {
    color: "#0a7ea4",
    fontWeight: "bold",
  },
});
