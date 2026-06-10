export default function ChooseOptionStep({ onSelectModule }) {
  return (
    <div className="space-y-8">
      <div className="text-center space-y-1.5">
        <h1 className="text-2xl font-bold tracking-tight">Choose an option</h1>
        <p className="text-sm text-gray-500">Select what you want to do</p>
      </div>

      <div className="space-y-4 pt-4">
        {/* Expense Management Option Box */}
        <button
          onClick={() => onSelectModule("expenses")}
          className="w-full text-left p-5 rounded-2xl border border-gray-200 bg-white hover:border-gray-400 active:bg-gray-50 transition-all flex items-center gap-4 group"
        >
          <div className="h-12 w-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center border border-emerald-100">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
            </svg>
          </div>
          <div>
            <span className="block font-bold text-base text-gray-900">Expense Management</span>
          </div>
        </button>

        {/* Want To Buy Option Box */}
        <button
          onClick={() => onSelectModule("want-to-buy")}
          className="w-full text-left p-5 rounded-2xl border border-gray-200 bg-white hover:border-gray-400 active:bg-gray-50 transition-all flex items-center gap-4 group"
        >
          <div className="h-12 w-12 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center border border-indigo-100">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
          </div>
          <div>
            <span className="block font-bold text-base text-gray-900">Want to Buy</span>
          </div>
        </button>
      </div>
    </div>
  );
}