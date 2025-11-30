import AsyncStorage from '@react-native-async-storage/async-storage';
import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';

const STORAGE_KEY = '@azeoo_user_id';

type UserIdContextValue = {
  userId: number | null;
  loading: boolean;
  saveUserId: (value: number) => Promise<void>;
};

const UserIdContext = createContext<UserIdContextValue | undefined>(undefined);

export const UserIdProvider = ({ children }: { children: React.ReactNode }) => {
  const [userId, setUserId] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((value) => {
        if (value) {
          setUserId(intOrNull(value));
        }
      })
      .finally(() => setLoading(false));
  }, []);

  const saveUserId = useCallback(async (value: number) => {
    setUserId(value);
    await AsyncStorage.setItem(STORAGE_KEY, String(value));
  }, []);

  const value = useMemo<UserIdContextValue>(
    () => ({
      userId,
      loading,
      saveUserId,
    }),
    [loading, saveUserId, userId],
  );

  return <UserIdContext.Provider value={value}>{children}</UserIdContext.Provider>;
};

export const useUserId = () => {
  const ctx = useContext(UserIdContext);
  if (!ctx) {
    throw new Error('useUserId doit être utilisé à l’intérieur de UserIdProvider');
  }
  return ctx;
};

const intOrNull = (value: string) => {
  const parsed = parseInt(value, 10);
  return Number.isNaN(parsed) ? null : parsed;
};
