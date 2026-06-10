import { Link } from "react-router-dom";

export default function DashboardLayout({ children, currentStep, onBack, isOwner }) {
  return (
    <main className="min-h-screen bg-white text-gray-900 antialiased font-sans flex justify-center">
      <div className="w-full max-w-md min-h-screen px-6 py-5 flex flex-col justify-between border-x border-gray-100">
        
        <div>
          {/* TOP HEADER NAVIGATION BAR */}
          <div className="flex items-center justify-between mb-8">
            <button 
              onClick={onBack}
              className={`p-1 -ml-1 text-gray-800 transition-opacity ${
                currentStep === "choose_option" ? "opacity-0 pointer-events-none" : "opacity-100"
              }`}
              aria-label="Go back"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
            </button>
            
            {isOwner && currentStep === "choose_option" && (
              <Link to="/settings" className="p-1 text-gray-800" aria-label="Owner Settings">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </Link>
            )}
          </div>

          {/* DYNAMIC SCREEN CONTENT STEP */}
          {children}
        </div>

        {/* BOTTOM ACCENT FOOTER LINES */}
        <div className="w-full flex flex-col items-center gap-0.5 pt-6 pb-2">
          <div className="w-12 h-0.5 bg-gray-200 rounded-full"></div>
          <div className="w-12 h-0.5 bg-gray-200 rounded-full"></div>
        </div>

      </div>
    </main>
  );
}