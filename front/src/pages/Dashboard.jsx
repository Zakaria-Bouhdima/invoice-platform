import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import { fetchRules, createRule, updateRule, deleteRule, submitInvoice } from '../services/api';
import RuleTable from '../components/RuleTable';
import RuleForm from '../components/RuleForm';

export default function Dashboard() {
  const { user, idToken } = useAuth();
  const clientId = user?.username;

  const [rules, setRules] = useState([]);
  const [rulesLoading, setRulesLoading] = useState(true);
  const [rulesError, setRulesError] = useState('');

  const [showForm, setShowForm] = useState(false);
  const [editTarget, setEditTarget] = useState(null);
  const [formLoading, setFormLoading] = useState(false);

  const [invoiceJson, setInvoiceJson] = useState('{\n  "invoiceNumber": "INV-001",\n  "amount": 1500,\n  "currency": "EUR"\n}');
  const [submitState, setSubmitState] = useState({ loading: false, result: null, error: '' });

  const loadRules = useCallback(async () => {
    setRulesLoading(true);
    setRulesError('');
    try {
      const data = await fetchRules(clientId, idToken);
      setRules(Array.isArray(data) ? data : []);
    } catch {
      setRulesError('Failed to load rules. The /rules endpoint may not be configured yet.');
    } finally {
      setRulesLoading(false);
    }
  }, [clientId, idToken]);

  useEffect(() => { loadRules(); }, [loadRules]);

  async function handleFormSubmit(form) {
    setFormLoading(true);
    try {
      if (editTarget) {
        const updated = await updateRule(editTarget.ruleId, { ...form, clientId }, idToken);
        setRules((prev) => prev.map((r) => (r.ruleId === updated.ruleId ? updated : r)));
      } else {
        const created = await createRule({ ...form, clientId }, idToken);
        setRules((prev) => [...prev, created]);
      }
      setShowForm(false);
      setEditTarget(null);
    } catch {
      alert('Failed to save rule. Please try again.');
    } finally {
      setFormLoading(false);
    }
  }

  async function handleDelete(ruleId) {
    if (!window.confirm('Delete this rule?')) return;
    try {
      await deleteRule(ruleId, idToken);
      setRules((prev) => prev.filter((r) => r.ruleId !== ruleId));
    } catch {
      alert('Failed to delete rule.');
    }
  }

  function openEdit(rule) {
    setEditTarget(rule);
    setShowForm(true);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function handleSubmitInvoice(e) {
    e.preventDefault();
    setSubmitState({ loading: true, result: null, error: '' });
    try {
      const payload = JSON.parse(invoiceJson);
      const result = await submitInvoice({ clientId, ...payload }, idToken);
      setSubmitState({ loading: false, result, error: '' });
    } catch (err) {
      const msg = err instanceof SyntaxError ? 'Invalid JSON.' : (err.response?.data?.error || err.message);
      setSubmitState({ loading: false, result: null, error: msg });
    }
  }

  return (
    <div className="page">
      <div className="page-header">
        <h1>Dashboard</h1>
        <p>Client: <strong>{clientId}</strong></p>
      </div>

      {showForm && (
        <div className="card" style={{ marginBottom: '1.5rem' }}>
          <div className="card-title">{editTarget ? 'Edit rule' : 'New transformation rule'}</div>
          <RuleForm
            initial={editTarget}
            onSubmit={handleFormSubmit}
            onCancel={() => { setShowForm(false); setEditTarget(null); }}
            loading={formLoading}
          />
        </div>
      )}

      <div className="card">
        <div className="flex-between" style={{ marginBottom: '1.25rem' }}>
          <span className="card-title" style={{ margin: 0 }}>Transformation rules</span>
          {!showForm && (
            <button className="btn btn-primary btn-sm" onClick={() => { setEditTarget(null); setShowForm(true); }}>
              + New rule
            </button>
          )}
        </div>

        {rulesError && <div className="alert alert-error">{rulesError}</div>}

        {rulesLoading ? (
          <div className="empty-state"><p>Loading…</p></div>
        ) : (
          <RuleTable rules={rules} onEdit={openEdit} onDelete={handleDelete} />
        )}
      </div>

      <div className="card">
        <div className="card-title">Submit invoice</div>
        <p className="text-muted" style={{ marginBottom: '1rem' }}>
          POST to <code>/invoices</code> → Lambda ingestion → SQS → transformation → distribution.
        </p>
        <form onSubmit={handleSubmitInvoice}>
          <div className="form-group">
            <label>Invoice payload (JSON)</label>
            <textarea
              className="form-control"
              rows={6}
              value={invoiceJson}
              onChange={(e) => setInvoiceJson(e.target.value)}
            />
          </div>
          {submitState.error && <div className="alert alert-error">{submitState.error}</div>}
          {submitState.result && (
            <div className="alert alert-success">
              Accepted — invoice ID: <strong>{submitState.result.invoiceId}</strong>
            </div>
          )}
          <button type="submit" className="btn btn-primary" disabled={submitState.loading}>
            {submitState.loading ? <span className="spinner" /> : null}
            Submit invoice
          </button>
        </form>
      </div>
    </div>
  );
}
