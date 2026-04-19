import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { fetchClients } from '../services/api';

export default function AdminPage() {
  const { idToken } = useAuth();
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchClients(idToken)
      .then((data) => setClients(Array.isArray(data) ? data : []))
      .catch(() => setError('Failed to load clients. The /admin/clients endpoint may not be configured yet.'))
      .finally(() => setLoading(false));
  }, [idToken]);

  return (
    <div className="page">
      <div className="page-header">
        <h1>Admin — Client overview</h1>
        <p>All registered clients and their rule versions.</p>
      </div>

      <div className="card">
        {error && <div className="alert alert-error">{error}</div>}

        {loading ? (
          <div className="empty-state"><p>Loading…</p></div>
        ) : clients.length === 0 && !error ? (
          <div className="empty-state"><p>No clients found.</p></div>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Client ID</th>
                  <th>Name</th>
                  <th>Rules</th>
                  <th>Latest version</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {clients.map((client) => (
                  <tr key={client.clientId}>
                    <td><code>{client.clientId}</code></td>
                    <td>{client.name || '—'}</td>
                    <td>{client.ruleCount ?? '—'}</td>
                    <td>{client.latestVersion != null ? `v${client.latestVersion}` : '—'}</td>
                    <td>
                      <span className={`badge ${client.active ? 'badge-success' : 'badge-warning'}`}>
                        {client.active ? 'active' : 'inactive'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
