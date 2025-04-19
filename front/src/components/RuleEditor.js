import React, { useState } from "react";

function RuleEditor() {
  const [rule, setRule] = useState({});

  const handleSave = async () => {
    const response = await fetch("/api/rules", {
      method: "POST",
      body: JSON.stringify(rule),
    });
    if (response.ok) alert("Rule saved!");
  };

  return (
    <div>
      <h2>Edit Rule</h2>
      <textarea
        value={JSON.stringify(rule, null, 2)}
        onChange={(e) => setRule(JSON.parse(e.target.value))}
      />
      <button onClick={handleSave}>Save Rule</button>
    </div>
  );
}

export default RuleEditor;