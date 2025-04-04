import {
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  FlatList,
  View,
} from "react-native";
import { useState } from "react";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { IconSymbol } from "@/components/ui/IconSymbol";

// Define business type for search results
type Business = {
  id: string;
  name: string;
  panNumber?: string;
  phone?: string;
  verifiedReports: number;
  authenticity: number;
};

// Mock data for demonstration
const mockBusinesses: Business[] = [
  {
    id: "1",
    name: "ABC Industries",
    panNumber: "ABCDE1234F",
    phone: "9876543210",
    verifiedReports: 5,
    authenticity: 85,
  },
  {
    id: "2",
    name: "XYZ Enterprises",
    panNumber: "XYZAB5678G",
    phone: "8765432109",
    verifiedReports: 2,
    authenticity: 65,
  },
  {
    id: "3",
    name: "Sunrise Solutions",
    panNumber: "SRJPK8765H",
    phone: "7654321098",
    verifiedReports: 0,
    authenticity: 50,
  },
];

export default function SearchScreen() {
  const [searchQuery, setSearchQuery] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [searchResults, setSearchResults] = useState<Business[]>([]);
  const [hasSearched, setHasSearched] = useState(false);

  const handleSearch = () => {
    if (!searchQuery.trim()) return;

    setIsLoading(true);

    // Simulate API call with mock data
    setTimeout(() => {
      const results = mockBusinesses.filter(
        (business) =>
          business.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          (business.panNumber &&
            business.panNumber
              .toLowerCase()
              .includes(searchQuery.toLowerCase())) ||
          (business.phone && business.phone.includes(searchQuery))
      );

      setSearchResults(results);
      setIsLoading(false);
      setHasSearched(true);
    }, 1000);
  };

  const renderBusinessItem = ({ item }: { item: Business }) => (
    <TouchableOpacity style={styles.businessCard}>
      <View style={styles.businessHeader}>
        <ThemedText type="subtitle">{item.name}</ThemedText>
        <View
          style={[
            styles.authenticityBadge,
            { backgroundColor: getAuthenticityColor(item.authenticity) },
          ]}
        >
          <ThemedText style={styles.authenticityText}>
            {item.authenticity}
          </ThemedText>
        </View>
      </View>

      {item.panNumber && (
        <View style={styles.infoRow}>
          <ThemedText style={styles.infoLabel}>PAN:</ThemedText>
          <ThemedText>{item.panNumber}</ThemedText>
        </View>
      )}

      {item.phone && (
        <View style={styles.infoRow}>
          <ThemedText style={styles.infoLabel}>Phone:</ThemedText>
          <ThemedText>{item.phone}</ThemedText>
        </View>
      )}

      <View style={styles.reportInfo}>
        <ThemedText>
          {item.verifiedReports} verified{" "}
          {item.verifiedReports === 1 ? "report" : "reports"}
        </ThemedText>
      </View>
    </TouchableOpacity>
  );

  // Helper to get color based on authenticity score
  const getAuthenticityColor = (score: number): string => {
    if (score >= 80) return "#4ade80"; // Green for high authenticity
    if (score >= 60) return "#facc15"; // Yellow for medium
    return "#f87171"; // Red for low
  };

  return (
    <ThemedView style={styles.container}>
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search by name, PAN, or phone number"
          value={searchQuery}
          onChangeText={setSearchQuery}
          onSubmitEditing={handleSearch}
        />
        <TouchableOpacity
          style={styles.searchButton}
          onPress={handleSearch}
          disabled={isLoading || !searchQuery.trim()}
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" size="small" />
          ) : (
            <IconSymbol name="chevron.right" size={20} color="#fff" />
          )}
        </TouchableOpacity>
      </View>

      {!hasSearched ? (
        <View style={styles.emptyStateContainer}>
          <ThemedText style={styles.emptyStateText}>
            Search for businesses by name, PAN number, or phone number
          </ThemedText>
        </View>
      ) : searchResults.length === 0 ? (
        <View style={styles.emptyStateContainer}>
          <ThemedText style={styles.emptyStateText}>
            No businesses found matching "{searchQuery}"
          </ThemedText>
        </View>
      ) : (
        <FlatList
          data={searchResults}
          renderItem={renderBusinessItem}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.resultsList}
        />
      )}
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  searchContainer: {
    flexDirection: "row",
    marginBottom: 16,
  },
  searchInput: {
    flex: 1,
    height: 50,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 8,
    paddingHorizontal: 16,
    fontSize: 16,
  },
  searchButton: {
    width: 50,
    height: 50,
    backgroundColor: "#0a7ea4",
    borderRadius: 8,
    marginLeft: 8,
    justifyContent: "center",
    alignItems: "center",
  },
  resultsList: {
    paddingBottom: 20,
  },
  businessCard: {
    padding: 16,
    backgroundColor: "#f5f5f5",
    borderRadius: 8,
    marginBottom: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 2,
    elevation: 2,
  },
  businessHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  authenticityBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  authenticityText: {
    color: "#fff",
    fontWeight: "bold",
  },
  infoRow: {
    flexDirection: "row",
    marginBottom: 4,
  },
  infoLabel: {
    fontWeight: "bold",
    marginRight: 8,
  },
  reportInfo: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: "#e0e0e0",
  },
  emptyStateContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  emptyStateText: {
    textAlign: "center",
    color: "#666",
  },
});
