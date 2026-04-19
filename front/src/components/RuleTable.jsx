export default function RuleTable({ rules, onEdit, onDelete }) {
  if (!rules.length) {
    return (
      <div className="empty-state">
        <p>No transformation rules yet. Create your first rule above.</p>
      </div>
    );
  }

  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Type</th>
            <th>Source field</th>
            <th>Target / Value</th>
            <th>Description</th>
            <th>Version</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {rules.map((rule) => (
            <tr key={rule.ruleId}>
              <td>
                <span className={`badge ${rule.ruleType === 'rename' ? 'badge-info' : 'badge-warning'}`}>
                  {rule.ruleType}
                </span>
              </td>
              <td><code>{rule.sourceField}</code></td>
              <td><code>{rule.ruleType === 'rename' ? rule.targetField : rule.staticValue}</code></td>
              <td className="text-muted">{rule.description || '—'}</td>
              <td className="text-muted">v{rule.version ?? 1}</td>
              <td>
                <div className="gap-2">
                  <button className="btn btn-ghost btn-sm" onClick={() => onEdit(rule)}>Edit</button>
                  <button className="btn btn-danger btn-sm" onClick={() => onDelete(rule.ruleId)}>Delete</button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
