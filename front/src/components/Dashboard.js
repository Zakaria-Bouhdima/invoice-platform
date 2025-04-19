import React, { useEffect, useState } from "react";

function Dashboard() {
  const [rules, setRules] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch rules from the backend API
    fetch("/api/rules")
      .then((response) => response.json())
      .then((data) => {
        setRules(data);
        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching rules:", error);
        setLoading(false);
      });
  }, []);

  const handleDelete = async (ruleId) => {
    if (window.confirm("Are you sure you want to delete this rule?")) {
      try {
        await fetch(`/api/rules/${ruleId}`, { method: "DELETE" });
        setRules(rules.filter((rule) => rule.ruleId !== ruleId));
      } catch (error) {
        console.error("Error deleting rule:", error);
      }
    }
  };

  return (
    <div>
      <h2>Transformation Rules Dashboard</h2>
      {loading ? (
        <p>Loading rules...</p>
      ) : (
        <table border="1">
          <thead>
            <tr>
              <th>Rule ID</th>
              <th>Client ID</th>
              <th>Version</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {rules.map((rule) => (
              <tr key={rule.ruleId}>
                <td>{rule.ruleId}</td>
                <td>{rule.clientId}</td>
                <td>{rule.version}</td>
                <td>
                  <button onClick={() => handleDelete(rule.ruleId)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default Dashboard;