import React, { createContext, useState, useEffect, ReactNode } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { router } from "expo-router";

// Define types
type User = {
  id: string;
  phone: string;
  name?: string;
  email?: string;
};

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  authToken: string | null;
  sendOTP: (phoneNumber: string) => Promise<boolean>;
  verifyOTP: (phoneNumber: string, otp: string) => Promise<boolean>;
  signOut: () => void;
}

// Create the auth context with default values
export const AuthContext = createContext<AuthContextType>({
  user: null,
  isLoading: true,
  authToken: null,
  sendOTP: async () => false,
  verifyOTP: async () => false,
  signOut: () => {},
});

// Create the auth provider component
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [authToken, setAuthToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load user data on app start
  useEffect(() => {
    const loadUser = async () => {
      try {
        const storedToken = await AsyncStorage.getItem("authToken");
        if (storedToken) {
          setAuthToken(storedToken);
          // Fetch user profile using the token
          const userData = await AsyncStorage.getItem("userData");
          if (userData) {
            setUser(JSON.parse(userData));
          }
        }
      } catch (error) {
        console.error("Failed to load user data", error);
      } finally {
        setIsLoading(false);
      }
    };

    loadUser();
  }, []);

  // Function to initiate the OTP sending process
  const sendOTP = async (phoneNumber: string): Promise<boolean> => {
    // In a real app, we would call the backend API here
    console.log(`Sending OTP to ${phoneNumber}`);

    // For demo purposes, we'll simulate a successful OTP send
    await new Promise((resolve) => setTimeout(resolve, 1000));
    return true;
  };

  // Function to verify the OTP
  const verifyOTP = async (
    phoneNumber: string,
    otp: string
  ): Promise<boolean> => {
    // In a real app, we would call the backend API here
    console.log(`Verifying OTP ${otp} for ${phoneNumber}`);

    try {
      // For demo purposes, we'll simulate a successful verification for any 6-digit OTP
      if (otp.length === 6) {
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Generate a fake authentication token
        const token = `token-${Date.now()}`;
        await AsyncStorage.setItem("authToken", token);
        setAuthToken(token);

        // Create a fake user
        const userData: User = {
          id: `user-${Date.now()}`,
          phone: phoneNumber,
          name: `User ${phoneNumber.substring(phoneNumber.length - 4)}`,
        };

        await AsyncStorage.setItem("userData", JSON.stringify(userData));
        setUser(userData);

        return true;
      }
      return false;
    } catch (error) {
      console.error("OTP verification failed", error);
      return false;
    }
  };

  // Function to sign out
  const signOut = async () => {
    try {
      await AsyncStorage.removeItem("authToken");
      await AsyncStorage.removeItem("userData");
      setAuthToken(null);
      setUser(null);
      router.replace("/");
    } catch (error) {
      console.error("Sign out failed", error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        authToken,
        sendOTP,
        verifyOTP,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook to use the auth context
export function useAuth() {
  const context = React.useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
