import React, { useState } from "react";
import {
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  View,
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from "react-native";
import * as ImagePicker from "expo-image-picker";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { useAuth } from "@/contexts/AuthContext";
import { IconSymbol } from "@/components/ui/IconSymbol";

export default function ReportScreen() {
  const {} = useAuth();
  const [businessName, setBusinessName] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [panNumber, setPanNumber] = useState("");
  const [scamAmount, setScamAmount] = useState("");
  const [reportDetails, setReportDetails] = useState("");
  const [proofImages, setProofImages] = useState<string[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const pickImage = async () => {
    // Request permissions
    const permissionResult =
      await ImagePicker.requestMediaLibraryPermissionsAsync();

    if (permissionResult.granted === false) {
      Alert.alert(
        "Permission Required",
        "You need to grant permission to access your photos"
      );
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: "images",
      allowsEditing: true,
      quality: 0.8,
    });

    if (!result.canceled && result.assets.length > 0) {
      setProofImages([...proofImages, result.assets[0].uri]);
    }
  };

  const handleSubmit = async () => {
    // Validate input
    if (!businessName.trim()) {
      Alert.alert("Error", "Please enter the business name");
      return;
    }

    if (!phoneNumber.trim()) {
      Alert.alert("Error", "Please provide the phone number");
      return;
    }

    if (!scamAmount.trim()) {
      Alert.alert("Error", "Please enter the scam amount");
      return;
    }

    if (!reportDetails.trim()) {
      Alert.alert("Error", "Please provide details about the fraud");
      return;
    }

    setIsSubmitting(true);

    // Simulate API call
    setTimeout(() => {
      setIsSubmitting(false);

      // Reset form
      setBusinessName("");
      setPhoneNumber("");
      setPanNumber("");
      setScamAmount("");
      setReportDetails("");
      setProofImages([]);

      // Show success message
      Alert.alert(
        "Report Submitted",
        "Your report has been submitted successfully. It will be reviewed by our team.",
        [{ text: "OK" }]
      );
    }, 2000);
  };

  return (
    <ThemedView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={{ flex: 1 }}
      >
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <ThemedText type="title" style={styles.title}>
            Report a Business
          </ThemedText>
          <ThemedText style={styles.subtitle}>
            Help the community by reporting fraudulent businesses
          </ThemedText>

          <View style={styles.form}>
            <View style={styles.inputGroup}>
              <ThemedText style={styles.label}>Business Name *</ThemedText>
              <TextInput
                style={styles.input}
                placeholder="Enter business name"
                value={businessName}
                onChangeText={setBusinessName}
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={styles.label}>Phone Number *</ThemedText>
              <TextInput
                style={styles.input}
                placeholder="Enter phone number"
                value={phoneNumber}
                onChangeText={setPhoneNumber}
                keyboardType="phone-pad"
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={styles.label}>PAN Number</ThemedText>
              <TextInput
                style={styles.input}
                placeholder="Enter PAN number"
                value={panNumber}
                onChangeText={setPanNumber}
                autoCapitalize="characters"
                maxLength={10}
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={styles.label}>Scam Amount (INR) *</ThemedText>
              <TextInput
                style={styles.input}
                placeholder="Enter amount in INR"
                value={scamAmount}
                onChangeText={setScamAmount}
                keyboardType="numeric"
              />
            </View>

            <View style={styles.inputGroup}>
              <ThemedText style={styles.label}>Report Details *</ThemedText>
              <TextInput
                style={[styles.input, styles.textArea]}
                placeholder="Describe the fraudulent activity in detail"
                value={reportDetails}
                onChangeText={setReportDetails}
                multiline
                numberOfLines={5}
                textAlignVertical="top"
              />
            </View>

            <View style={styles.proofSection}>
              <ThemedText style={styles.label}>
                Attach Proof (Optional)
              </ThemedText>
              <TouchableOpacity
                style={styles.addProofButton}
                onPress={pickImage}
              >
                <IconSymbol name="paperplane.fill" size={20} color="#0a7ea4" />
                <ThemedText style={styles.addProofText}>Add Photo</ThemedText>
              </TouchableOpacity>

              {proofImages.length > 0 && (
                <View style={styles.imagePreviewContainer}>
                  <ThemedText style={styles.proofCountText}>
                    {proofImages.length}{" "}
                    {proofImages.length === 1 ? "image" : "images"} attached
                  </ThemedText>
                </View>
              )}
            </View>

            <TouchableOpacity
              style={styles.submitButton}
              onPress={handleSubmit}
              disabled={isSubmitting}
            >
              {isSubmitting ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <ThemedText style={styles.submitButtonText}>
                  Submit Report
                </ThemedText>
              )}
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 50,
  },
  title: {
    marginBottom: 8,
    textAlign: "center",
  },
  subtitle: {
    textAlign: "center",
    marginBottom: 24,
  },
  form: {
    width: "100%",
  },
  inputGroup: {
    marginBottom: 16,
  },
  label: {
    marginBottom: 8,
    fontWeight: "500",
  },
  input: {
    height: 50,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 8,
    paddingHorizontal: 15,
    fontSize: 16,
  },
  textArea: {
    height: 120,
    paddingTop: 12,
  },
  proofSection: {
    marginBottom: 24,
  },
  addProofButton: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: "#0a7ea4",
    borderRadius: 8,
    borderStyle: "dashed",
  },
  addProofText: {
    color: "#0a7ea4",
    marginLeft: 8,
  },
  imagePreviewContainer: {
    marginTop: 12,
    padding: 12,
    backgroundColor: "#f0f9ff",
    borderRadius: 8,
  },
  proofCountText: {
    color: "#0a7ea4",
  },
  submitButton: {
    height: 50,
    backgroundColor: "#0a7ea4",
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
  },
  submitButtonText: {
    color: "#fff",
    fontWeight: "bold",
    fontSize: 16,
  },
});
