import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const { signIn } = useAuth();
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await signIn(username.trim(), password);
      navigate('/dashboard');
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-wrap">
      <div className="login-card">
        <h1>Invoice Platform</h1>
        <p className="subtitle">Sign in with your Cognito account</p>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Username or email</label>
            <input
              className="form-control"
              type="text"
              autoComplete="username"
              placeholder="you@example.com"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input
              className="form-control"
              type="password"
              autoComplete="current-password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', marginTop: '0.5rem', justifyContent: 'center' }}
            disabled={loading}
          >
            {loading ? <span className="spinner" /> : 'Sign in'}
          </button>
        </form>
      </div>
    </div>
  );
}

function friendlyError(err) {
  const msg = err.message || '';
  if (msg === 'NEW_PASSWORD_REQUIRED') return 'Your account requires a password reset. Contact your administrator.';
  if (msg.includes('NotAuthorizedException')) return 'Incorrect username or password.';
  if (msg.includes('UserNotFoundException')) return 'Account not found.';
  if (msg.includes('UserNotConfirmedException')) return 'Account not confirmed. Check your email.';
  return msg || 'Sign-in failed. Please try again.';
}
