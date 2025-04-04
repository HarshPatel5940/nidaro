import React, { useState } from "react";
import {
  StyleSheet,
  View,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Switch,
  Alert,
} from "react-native";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { useAuth } from "@/contexts/AuthContext";

export default function ProfileScreen() {
  const { user, signOut } = useAuth();

  // State for editable profile fields
  const [name, setName] = useState(user?.name || "");
  const [email, setEmail] = useState(user?.email || "");
  const [isEditing, setIsEditing] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  // Mock data for user's reports and submissions
  const myReports: any[] = [];
  const mySubmissions = [
    {
      id: "1",
      businessName: "ABC Industries",
      date: "2023-09-15",
      status: "verified",
    },
    {
      id: "2",
      businessName: "XYZ Corp",
      date: "2023-10-22",
      status: "pending",
    },
  ];

  const handleSaveProfile = () => {
    // In a real app, we would call the API to update user profile here
    Alert.alert("Success", "Profile updated successfully");
    setIsEditing(false);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "verified":
        return "#4ade80";
      case "pending":
        return "#facc15";
      case "rejected":
        return "#f87171";
      default:
        return "#9ca3af";
    }
  };

  return (
    <ThemedView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.profileHeader}>
          <View style={styles.profileAvatar}>
            <ThemedText style={styles.avatarText}>
              {name ? name[0].toUpperCase() : user?.phone[0] || "U"}
            </ThemedText>
          </View>
          <ThemedText type="title">{name || "User"}</ThemedText>
          <ThemedText>{user?.phone}</ThemedText>
        </View>

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <ThemedText type="subtitle">Profile Information</ThemedText>
            <TouchableOpacity onPress={() => setIsEditing(!isEditing)}>
              <ThemedText style={styles.editButton}>
                {isEditing ? "Cancel" : "Edit"}
              </ThemedText>
            </TouchableOpacity>
          </View>

          {isEditing ? (
            <View style={styles.editForm}>
              <View style={styles.inputGroup}>
                <ThemedText style={styles.label}>Name</ThemedText>
                <TextInput
                  style={styles.input}
                  value={name}
                  onChangeText={setName}
                  placeholder="Enter your name"
                />
              </View>

              <View style={styles.inputGroup}>
                <ThemedText style={styles.label}>Email</ThemedText>
                <TextInput
                  style={styles.input}
                  value={email}
                  onChangeText={setEmail}
                  placeholder="Enter your email"
                  keyboardType="email-address"
                />
              </View>

              <TouchableOpacity
                style={styles.saveButton}
                onPress={handleSaveProfile}
              >
                <ThemedText style={styles.saveButtonText}>
                  Save Changes
                </ThemedText>
              </TouchableOpacity>
            </View>
          ) : (
            <View style={styles.profileInfo}>
              <View style={styles.infoRow}>
                <ThemedText style={styles.infoLabel}>Name:</ThemedText>
                <ThemedText>{name || "Not set"}</ThemedText>
              </View>
              <View style={styles.infoRow}>
                <ThemedText style={styles.infoLabel}>Email:</ThemedText>
                <ThemedText>{email || "Not set"}</ThemedText>
              </View>
              <View style={styles.infoRow}>
                <ThemedText style={styles.infoLabel}>Phone:</ThemedText>
                <ThemedText>{user?.phone}</ThemedText>
              </View>
            </View>
          )}
        </View>

        <View style={styles.section}>
          <ThemedText type="subtitle">App Settings</ThemedText>
          <View style={styles.settingRow}>
            <ThemedText>Push Notifications</ThemedText>
            <Switch
              value={notificationsEnabled}
              onValueChange={setNotificationsEnabled}
              trackColor={{ false: "#767577", true: "#0a7ea4" }}
              thumbColor="#f4f3f4"
            />
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText type="subtitle">My Submissions</ThemedText>
          {mySubmissions.length > 0 ? (
            mySubmissions.map((submission) => (
              <View key={submission.id} style={styles.reportCard}>
                <View style={styles.reportHeader}>
                  <ThemedText style={styles.reportBusinessName}>
                    {submission.businessName}
                  </ThemedText>
                  <View
                    style={[
                      styles.statusBadge,
                      { backgroundColor: getStatusColor(submission.status) },
                    ]}
                  >
                    <ThemedText style={styles.statusText}>
                      {submission.status}
                    </ThemedText>
                  </View>
                </View>
                <ThemedText style={styles.reportDate}>
                  Reported on: {submission.date}
                </ThemedText>
              </View>
            ))
          ) : (
            <ThemedText style={styles.emptyStateText}>
              You haven't submitted any reports yet.
            </ThemedText>
          )}
        </View>

        <View style={styles.section}>
          <ThemedText type="subtitle">Reports Against Me</ThemedText>
          {myReports.length > 0 ? (
            myReports.map((report) => (
              <View key={report.id} style={styles.reportCard}>
                {/* Report details */}
              </View>
            ))
          ) : (
            <ThemedText style={styles.emptyStateText}>
              No reports found against your business.
            </ThemedText>
          )}
        </View>

        <TouchableOpacity style={styles.logoutButton} onPress={signOut}>
          <ThemedText style={styles.logoutButtonText}>Sign Out</ThemedText>
        </TouchableOpacity>
      </ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  profileHeader: {
    alignItems: "center",
    marginBottom: 24,
  },
  profileAvatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: "#0a7ea4",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 12,
  },
  avatarText: {
    color: "#fff",
    fontSize: 32,
    fontWeight: "bold",
  },
  section: {
    marginBottom: 24,
    padding: 16,
    backgroundColor: "#f5f5f5",
    borderRadius: 8,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  editButton: {
    color: "#0a7ea4",
    fontWeight: "bold",
  },
  profileInfo: {
    gap: 8,
  },
  infoRow: {
    flexDirection: "row",
    marginBottom: 4,
  },
  infoLabel: {
    fontWeight: "bold",
    width: 60,
  },
  editForm: {
    gap: 12,
  },
  inputGroup: {
    marginBottom: 12,
  },
  label: {
    marginBottom: 4,
  },
  input: {
    height: 50,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 8,
    paddingHorizontal: 15,
    fontSize: 16,
  },
  saveButton: {
    height: 50,
    backgroundColor: "#0a7ea4",
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
    marginTop: 8,
  },
  saveButtonText: {
    color: "#fff",
    fontWeight: "bold",
  },
  settingRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: 12,
  },
  reportCard: {
    marginBottom: 12,
    padding: 12,
    backgroundColor: "#fff",
    borderRadius: 8,
    borderWidth: 1,
    borderColor: "#e5e5e5",
  },
  reportHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  reportBusinessName: {
    fontWeight: "bold",
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  statusText: {
    color: "#fff",
    fontSize: 12,
    fontWeight: "bold",
    textTransform: "capitalize",
  },
  reportDate: {
    fontSize: 12,
    color: "#666",
  },
  emptyStateText: {
    textAlign: "center",
    paddingVertical: 16,
    color: "#666",
  },
  logoutButton: {
    height: 50,
    backgroundColor: "#f87171",
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
  },
  logoutButtonText: {
    color: "#fff",
    fontWeight: "bold",
  },
});
