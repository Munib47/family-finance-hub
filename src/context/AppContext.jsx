import { createContext, useContext, useState } from "react";

const AppContext = createContext(null);

export function AppProvider({ children }) {
  // Set default initial state to the mock wireframe month "June 2026"
  const [selectedMonth, setSelectedMonth] = useState({
    month: "June",
    year: 2026,
    label: "June 2026",
  });

  return (
    <AppContext.Provider value={{ selectedMonth, setSelectedMonth }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error("useApp must be used within an AppProvider");
  }
  return context;
}