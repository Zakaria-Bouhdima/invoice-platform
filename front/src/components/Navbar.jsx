import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Navbar() {
  const { user, signOut, isAdmin } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    signOut();
    navigate('/login');
  }

  if (!user) return null;

  return (
    <nav className="navbar">
      <span className="navbar-brand">Invoice Platform</span>
      <div className="navbar-links">
        <NavLink to="/dashboard">Dashboard</NavLink>
        {isAdmin && <NavLink to="/admin">Admin</NavLink>}
        <span className="navbar-user">{user.email}</span>
        <button
          className="btn btn-ghost btn-sm"
          style={{ color: 'white', borderColor: 'rgba(255,255,255,0.3)' }}
          onClick={handleLogout}
        >
          Logout
        </button>
      </div>
    </nav>
  );
}
