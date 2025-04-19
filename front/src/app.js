import React from "react";
import RuleEditor from "./components/RuleEditor";
import Dashboard from "./components/Dashboard";

function App() {
  return (
    <div>
      <h1>Invoice Transformation Platform</h1>
      <Dashboard />
      <RuleEditor />
    </div>
  );
}

export default App;