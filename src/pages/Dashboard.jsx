import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../features/auth";
import { useApp } from "../context/AppContext";

// Modular Feature Component Imports
import DashboardLayout from "../features/dashboard/components/DashboardLayout";
import ChooseOptionStep from "../features/dashboard/components/ChooseOptionStep";
import SelectMonthStep from "../features/dashboard/components/SelectMonthStep";

export default function Dashboard() {
  const { isOwner } = useAuth();
  const { setSelectedMonth } = useApp();
  const navigate = useNavigate();

  const [currentStep, setCurrentStep] = useState("choose_option");
  const [selectedModule, setSelectedModule] = useState(null);

  const handleModuleSelect = (moduleType) => {
    setSelectedModule(moduleType);
    setCurrentStep("select_month");
  };

  const handleMonthSelect = (monthConfig) => {
    setSelectedMonth(monthConfig);
    if (selectedModule === "expenses") {
      navigate("/expenses");
    } else {
      navigate("/want-to-buy");
    }
  };

  const handleBack = () => {
    if (currentStep === "select_month") {
      setCurrentStep("choose_option");
      setSelectedModule(null);
    }
  };

  return (
    <DashboardLayout currentStep={currentStep} onBack={handleBack} isOwner={isOwner}>
      {currentStep === "choose_option" ? (
        <ChooseOptionStep onSelectModule={handleModuleSelect} />
      ) : (
        <SelectMonthStep onSelectMonth={handleMonthSelect} />
      )}
    </DashboardLayout>
  );
}