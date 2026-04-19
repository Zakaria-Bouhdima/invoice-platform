import { useState, useEffect } from 'react';

const EMPTY = { ruleType: 'rename', sourceField: '', targetField: '', staticValue: '', description: '' };

export default function RuleForm({ initial = null, onSubmit, onCancel, loading }) {
  const [form, setForm] = useState(initial ?? EMPTY);
  const [error, setError] = useState('');

  useEffect(() => { setForm(initial ?? EMPTY); setError(''); }, [initial]);

  function set(field, value) { setForm((f) => ({ ...f, [field]: value })); }

  function handleSubmit(e) {
    e.preventDefault();
    setError('');
    if (!form.sourceField.trim()) { setError('Source field is required.'); return; }
    if (form.ruleType === 'rename' && !form.targetField.trim()) { setError('Target field is required for rename rules.'); return; }
    if (form.ruleType === 'static' && !form.staticValue.trim()) { setError('Static value is required for static rules.'); return; }
    onSubmit(form);
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && <div className="alert alert-error">{error}</div>}

      <div className="form-group">
        <label>Rule type</label>
        <select className="form-control" value={form.ruleType} onChange={(e) => set('ruleType', e.target.value)}>
          <option value="rename">Rename — map source field to a new name</option>
          <option value="static">Static — inject a fixed value</option>
        </select>
      </div>

      <div className="form-group">
        <label>Source field</label>
        <input className="form-control" placeholder="e.g. invoice_number" value={form.sourceField} onChange={(e) => set('sourceField', e.target.value)} />
      </div>

      {form.ruleType === 'rename' && (
        <div className="form-group">
          <label>Target field</label>
          <input className="form-control" placeholder="e.g. invoiceId" value={form.targetField} onChange={(e) => set('targetField', e.target.value)} />
        </div>
      )}

      {form.ruleType === 'static' && (
        <div className="form-group">
          <label>Static value</label>
          <input className="form-control" placeholder="e.g. EUR" value={form.staticValue} onChange={(e) => set('staticValue', e.target.value)} />
        </div>
      )}

      <div className="form-group">
        <label>Description <span className="text-muted">(optional)</span></label>
        <input className="form-control" placeholder="Why this rule exists" value={form.description} onChange={(e) => set('description', e.target.value)} />
      </div>

      <div className="gap-2" style={{ marginTop: '1.25rem' }}>
        <button type="submit" className="btn btn-primary" disabled={loading}>
          {loading ? <span className="spinner" /> : null}
          {initial ? 'Update rule' : 'Create rule'}
        </button>
        <button type="button" className="btn btn-ghost" onClick={onCancel} disabled={loading}>Cancel</button>
      </div>
    </form>
  );
}
