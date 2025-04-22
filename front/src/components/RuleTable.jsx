import React from 'react';

const RuleTable = ({ rules }) => {
  return (
    <table>
      <thead>
        <tr>
          <th>Rule ID</th>
          <th>Version</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {rules.map((rule) => (
          <tr key={rule.ruleId}>
            <td>{rule.ruleId}</td>
            <td>{rule.version}</td>
            <td>
              <button>Edit</button>
              <button>Delete</button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default RuleTable;